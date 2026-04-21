class QuestStateModel {
  const QuestStateModel({
    required this.questCode,
    required this.stage,
    required this.status,
    this.notes,
    this.name,
    this.description,
    this.reward,
  });

  final String questCode;
  final int stage;
  final String status;
  final String? notes;
  final String? name;
  final String? description;
  final String? reward;

  bool get isCompleted => status == 'completed';
  bool get isFailed => status == 'failed';
}
