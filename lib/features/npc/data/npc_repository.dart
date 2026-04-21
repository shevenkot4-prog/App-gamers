import 'package:supabase_flutter/supabase_flutter.dart';

import '../domain/npc_model.dart';

class NpcRepository {
  SupabaseClient get _client => Supabase.instance.client;

  static const coreNpcIds = [
    'npc_guardian_veiled',
    'npc_derran_astor',
    'npc_sir_edric',
  ];

  Future<List<NpcEntry>> fetchCoreNpcs() async {
    try {
      final rows = await _client
          .from('npc_catalog')
          .select('id,name,title,intro_text')
          .inFilter('id', coreNpcIds);
      if (rows.isEmpty) return _fallback;
      return rows.map<NpcEntry>((e) => NpcEntry.fromMap(e)).toList();
    } catch (_) {
      return _fallback;
    }
  }

  Future<NpcEntry?> fetchNpcById(String id) async {
    try {
      final row = await _client
          .from('npc_catalog')
          .select('id,name,title,intro_text')
          .eq('id', id)
          .maybeSingle();
      if (row != null) return NpcEntry.fromMap(row);
    } catch (_) {
      // fallback below
    }

    for (final npc in _fallback) {
      if (npc.id == id) return npc;
    }
    return null;
  }
}

const _fallback = [
  NpcEntry(
    id: 'npc_guardian_veiled',
    name: 'Guardiana Velada',
    title: 'Custodia de la Brasa Silente',
    introText: 'La llama no grita. Respira lento y escucha su memoria.',
  ),
  NpcEntry(
    id: 'npc_derran_astor',
    name: 'Derran de Astor',
    title: 'Herrero de los Juramentos Rotos',
    introText: 'Sin filo, no hay destino. Sin brasa, no hay acero.',
  ),
  NpcEntry(
    id: 'npc_sir_edric',
    name: 'Sir Edric',
    title: 'Caballero del Umbral Caído',
    introText: 'Un trono vacío siempre reclama un nuevo nombre.',
  ),
];
