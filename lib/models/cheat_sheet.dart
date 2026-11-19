class CheatSheet {
  final String id;
  final String command;
  final String shell;
  final String syntax;
  final String description;
  final String example;
  final String level;
  final String danger;
  final String equivalent;
  final String category;

  const CheatSheet({
    required this.id,
    required this.command,
    required this.shell,
    required this.syntax,
    required this.description,
    required this.example,
    this.level = 'Beginner',
    this.danger = 'SAFE',
    this.equivalent = '',
    this.category = '',
  });
}
