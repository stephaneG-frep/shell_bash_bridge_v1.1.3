class Project {
  final String id;
  final String title;
  final String shell;
  final String difficulty;
  final String description;
  final List<String> steps;
  final String solution;
  final String explanation;

  const Project({
    required this.id,
    required this.title,
    required this.shell,
    required this.difficulty,
    required this.description,
    required this.steps,
    required this.solution,
    required this.explanation,
  });
}
