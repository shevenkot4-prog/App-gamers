import '../../character/data/character_repository.dart';
import '../../character/domain/character_model.dart';

class BonfireService {
  BonfireService(this._characterRepository);

  final CharacterRepository _characterRepository;

  Future<void> rest(CharacterModel character) async {
    await _characterRepository.restAtBonfire(character);
  }
}
