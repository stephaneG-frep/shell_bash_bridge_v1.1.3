class Comparison {
  final String id;
  final String task;
  final String category;
  final String bashCommand;
  final String bashExplanation;
  final String psCommand;
  final String psExplanation;
  final String differences;

  const Comparison({
    required this.id,
    required this.task,
    required this.category,
    required this.bashCommand,
    required this.bashExplanation,
    required this.psCommand,
    required this.psExplanation,
    required this.differences,
  });
}
