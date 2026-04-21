import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/auth/presentation/auth_screen.dart';
import '../../features/blacksmith/presentation/blacksmith_screen.dart';
import '../../features/bonfire/presentation/bonfire_screen.dart';
import '../../features/boss/presentation/boss_encounter_placeholder_screen.dart';
import '../../features/character/presentation/character_naming_screen.dart';
import '../../features/character/presentation/class_selection_screen.dart';
import '../../features/combat/presentation/combat_screen.dart';
import '../../features/death/presentation/death_screen.dart';
import '../../features/encounter/presentation/encounter_screen.dart';
import '../../features/equipment/presentation/equipment_screen.dart';
import '../../features/event/presentation/event_screen.dart';
import '../../features/hub/presentation/hub_sanctuary_screen.dart';
import '../../features/inventory/presentation/inventory_screen.dart';
import '../../features/loot/presentation/loot_screen.dart';
import '../../features/level_up/presentation/level_up_screen.dart';
import '../../features/map/presentation/region_map_screen.dart';
import '../../features/menu/presentation/main_menu_screen.dart';
import '../../features/npc/presentation/npc_dialogue_screen.dart';
import '../../features/settings/presentation/settings_screen.dart';
import '../../features/quests/presentation/quest_log_screen.dart';
import '../../features/splash/presentation/splash_screen.dart';

final appRouterProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/',
    routes: [
      GoRoute(path: '/', builder: (context, state) => const SplashScreen()),
      GoRoute(path: '/menu', builder: (context, state) => const MainMenuScreen()),
      GoRoute(path: '/auth', builder: (context, state) => const AuthScreen()),
      GoRoute(path: '/character/class', builder: (context, state) => const ClassSelectionScreen()),
      GoRoute(
        path: '/character/name',
        builder: (context, state) => CharacterNamingScreen(
          selectedClass: state.uri.queryParameters['class'] ?? 'Caballero',
        ),
      ),
      GoRoute(path: '/hub', builder: (context, state) => const HubSanctuaryScreen()),
      GoRoute(path: '/inventory', builder: (context, state) => const InventoryScreen()),
      GoRoute(path: '/equipment', builder: (context, state) => const EquipmentScreen()),
      GoRoute(path: '/bonfire', builder: (context, state) => const BonfireScreen()),
      GoRoute(path: '/blacksmith', builder: (context, state) => const BlacksmithScreen()),
      GoRoute(path: '/level-up', builder: (context, state) => const LevelUpScreen()),
      GoRoute(path: '/quests', builder: (context, state) => const QuestLogScreen()),
      GoRoute(path: '/map', builder: (context, state) => const RegionMapScreen()),
      GoRoute(
        path: '/encounter',
        builder: (context, state) => EncounterScreen(nodeCode: state.uri.queryParameters['node'] ?? ''),
      ),
      GoRoute(
        path: '/combat',
        builder: (context, state) => CombatScreen(nodeCode: state.uri.queryParameters['node'] ?? ''),
      ),
      GoRoute(path: '/death', builder: (context, state) => const DeathScreen()),
      GoRoute(
        path: '/npc/:id',
        builder: (context, state) => NpcDialogueScreen(npcId: state.pathParameters['id'] ?? ''),
      ),
      GoRoute(
        path: '/event',
        builder: (context, state) => EventScreen(nodeCode: state.uri.queryParameters['node'] ?? 'unknown_event_node'),
      ),
      GoRoute(
        path: '/loot',
        builder: (context, state) => LootScreen(nodeCode: state.uri.queryParameters['node'] ?? 'unknown_loot_node'),
      ),
      GoRoute(
        path: '/boss-placeholder',
        builder: (context, state) => BossEncounterPlaceholderScreen(
          nodeCode: state.uri.queryParameters['node'] ?? 'unknown_boss_node',
        ),
      ),
      GoRoute(path: '/settings', builder: (context, state) => const SettingsScreen()),
    ],
  );
});
