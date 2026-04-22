class NpcEntry {
  const NpcEntry({
    required this.id,
    required this.name,
    this.title,
    required this.introText,
  });

  final String id;
  final String name;
  final String? title;
  final String introText;

  factory NpcEntry.fromMap(Map<String, dynamic> row) {
    return NpcEntry(
      id: row['id'] as String,
      name: row['name'] as String? ?? 'NPC desconocido',
      title: row['title'] as String?,
      introText: row['intro_text'] as String? ?? 'Permanece en silencio entre cenizas.',
    );
  }
}
