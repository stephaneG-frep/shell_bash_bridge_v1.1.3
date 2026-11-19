class Challenge {
  final String id;
  final String title;
  final String shell;
  final String difficulty;
  final String objective;
  final List<String> hints;
  final String solution;
  final String explanation;
  final int points;

  const Challenge({
    required this.id,
    required this.title,
    required this.shell,
    required this.difficulty,
    required this.objective,
    required this.hints,
    required this.solution,
    required this.explanation,
    this.points = 100,
  });
}
