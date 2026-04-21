import 'package:supabase_flutter/supabase_flutter.dart';

import '../domain/map_models.dart';

class WorldProgressRepository {
  SupabaseClient get _client => Supabase.instance.client;

  Future<WorldProgressModel> fetchProgress(String characterId) async {
    final row = await _client
        .from('world_progress')
        .select('discovered_nodes,opened_shortcuts,bloodstain_region,bloodstain_node,bloodstain_souls')
        .eq('character_id', characterId)
        .maybeSingle();

    if (row == null) {
      return const WorldProgressModel(discoveredNodes: [], openedShortcuts: [], bloodstainSouls: 0);
    }
    return WorldProgressModel.fromMap(row);
  }

  Future<void> upsertDiscoveredNode({required String characterId, required String nodeCode}) async {
    final current = await fetchProgress(characterId);
    final discovered = {...current.discoveredNodes, nodeCode}.toList();

    await _client.from('world_progress').upsert({
      'character_id': characterId,
      'discovered_nodes': discovered,
      'opened_shortcuts': current.openedShortcuts,
      'bloodstain_region': current.bloodstainRegion,
      'bloodstain_node': current.bloodstainNode,
      'bloodstain_souls': current.bloodstainSouls,
    });
  }
}
