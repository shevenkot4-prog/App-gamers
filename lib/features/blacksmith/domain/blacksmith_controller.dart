import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/utils/error_mapper.dart';
import '../../character/domain/character_controller.dart';
import '../../quests/domain/quest_controller.dart';
import '../data/blacksmith_repository.dart';
import 'blacksmith_models.dart';

class BlacksmithState {
  const BlacksmithState({
    this.loading = false,
    this.error,
    this.message,
    this.weapons = const [],
    this.materials = const {},
    this.emberUnlocked = false,
  });

  final bool loading;
  final String? error;
  final String? message;
  final List<UpgradeableWeaponView> weapons;
  final Map<String, int> materials;
  final bool emberUnlocked;

  BlacksmithState copyWith({
    bool? loading,
    String? error,
    String? message,
    List<UpgradeableWeaponView>? weapons,
    Map<String, int>? materials,
    bool? emberUnlocked,
  }) {
    return BlacksmithState(
      loading: loading ?? this.loading,
      error: error,
      message: message,
      weapons: weapons ?? this.weapons,
      materials: materials ?? this.materials,
      emberUnlocked: emberUnlocked ?? this.emberUnlocked,
    );
  }
}

class BlacksmithController extends StateNotifier<BlacksmithState> {
  BlacksmithController(this._repo, this._characterController, this._questController) : super(const BlacksmithState());

  final BlacksmithRepository _repo;
  final CharacterController _characterController;
  final QuestController _questController;

  Future<void> load() async {
    final character = _characterController.state.character;
    if (character == null) {
      state = state.copyWith(error: 'No hay personaje activo.');
      return;
    }
    state = state.copyWith(loading: true, error: null, message: null);
    try {
      final weapons = await _repo.loadWeapons(character.id);
      final materials = await _repo.loadMaterials(character.id);
      final emberUnlocked = (materials['material_blackened_ember'] ?? 0) > 0 ||
          _questController.state.quests.any((q) => q.questCode == 'quest_blacksmith_ember' && q.stage > 0);
      state = state.copyWith(
        loading: false,
        weapons: weapons,
        materials: materials,
        emberUnlocked: emberUnlocked,
      );
    } catch (e) {
      state = state.copyWith(loading: false, error: humanizeError(e, fallback: 'No se pudo cargar herrero.'));
    }
  }

  Future<void> deliverEmber() async {
    final character = _characterController.state.character;
    if (character == null) return;
    if ((state.materials['material_blackened_ember'] ?? 0) <= 0) {
      state = state.copyWith(error: 'No tienes Ascua Ennegrecida para entregar.', message: null);
      return;
    }

    state = state.copyWith(loading: true, error: null, message: null);
    try {
      await _repo.consumeMaterial(character.id, 'material_blackened_ember', 1);
      await _questController.deliverBlackenedEmber();
      await load();
      state = state.copyWith(message: 'Ascua Ennegrecida entregada. Mejoras +4 habilitadas.');
    } catch (e) {
      state = state.copyWith(loading: false, error: humanizeError(e, fallback: 'No se pudo entregar el ascua.'));
    }
  }

  Future<void> upgrade(UpgradeableWeaponView weapon) async {
    final character = _characterController.state.character;
    if (character == null) return;

    final current = weapon.upgradeLevel;
    final needsLarge = current >= 3;
    final requiredCode = needsLarge ? 'material_large_titanite_shard' : 'material_titanite_shard';
    const requiredQty = 1;

    if (needsLarge && !state.emberUnlocked) {
      state = state.copyWith(error: 'Necesitas entregar Ascua Ennegrecida para +4 o más.', message: null);
      return;
    }

    final have = state.materials[requiredCode] ?? 0;
    if (have < requiredQty) {
      final materialName = needsLarge ? 'Titanita Grande' : 'Titanita Normal';
      state = state.copyWith(error: 'Falta material: $materialName.', message: null);
      return;
    }

    state = state.copyWith(loading: true, error: null, message: null);
    try {
      await _repo.consumeMaterial(character.id, requiredCode, requiredQty);
      await _repo.upgradeWeapon(weapon.inventoryId, current + 1);
      await load();
      state = state.copyWith(message: '${weapon.name} mejorada a +${current + 1}.');
    } catch (e) {
      state = state.copyWith(loading: false, error: humanizeError(e, fallback: 'No se pudo mejorar el arma.'));
    }
  }
}

final blacksmithRepositoryProvider = Provider<BlacksmithRepository>((ref) => BlacksmithRepository());

final blacksmithControllerProvider = StateNotifierProvider<BlacksmithController, BlacksmithState>((ref) {
  return BlacksmithController(
    ref.watch(blacksmithRepositoryProvider),
    ref.read(characterControllerProvider.notifier),
    ref.read(questControllerProvider.notifier),
  );
});
