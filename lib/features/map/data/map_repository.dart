import 'package:supabase_flutter/supabase_flutter.dart';

import '../domain/map_models.dart';

class MapRepository {
  SupabaseClient get _client => Supabase.instance.client;

  Future<RegionModel?> fetchRegion(String regionCode) async {
    final row = await _client
        .from('regions_catalog')
        .select('code,name,description,sort_order')
        .eq('code', regionCode)
        .maybeSingle();
    if (row == null) return null;
    return RegionModel.fromMap(row);
  }

  Future<List<MapNode>> fetchRegionNodes(String regionCode) async {
    final rows = await _client
        .from('nodes_catalog')
        .select('code,region_code,name,node_type,description,sort_order,is_bonfire,is_starting_node,enemy_code,boss_code,loot_table,metadata')
        .eq('region_code', regionCode)
        .order('sort_order', ascending: true);

    return rows.map<MapNode>((e) => MapNode.fromMap(e)).toList();
  }

  Future<List<NodeEdgeModel>> fetchEdgesFromNode(String nodeCode) async {
    final rows = await _client
        .from('node_edges')
        .select('from_node,to_node,is_locked,lock_code,is_shortcut,metadata')
        .eq('from_node', nodeCode);

    return rows.map<NodeEdgeModel>((e) => NodeEdgeModel.fromMap(e)).toList();
  }
}
