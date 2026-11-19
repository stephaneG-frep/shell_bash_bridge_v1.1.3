class Lesson {
  final String id;
  final String title;
  final String shell;
  final int level;
  final String difficulty;
  final String objective;
  final String explanation;
  final String syntax;
  final String example;
  final String lineByLine;
  final String practicalCase;
  final String commonError;
  final String bestPractice;
  final String exercise;
  final String hint;
  final String correction;
  final String category;

  const Lesson({
    required this.id,
    required this.title,
    required this.shell,
    required this.level,
    required this.difficulty,
    required this.objective,
    required this.explanation,
    required this.syntax,
    required this.example,
    required this.lineByLine,
    required this.practicalCase,
    required this.commonError,
    required this.bestPractice,
    required this.exercise,
    required this.hint,
    required this.correction,
    this.category = '',
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'shell': shell,
    'level': level,
    'difficulty': difficulty,
    'objective': objective,
  };

  factory Lesson.fromJson(Map<String, dynamic> json) => Lesson(
    id: json['id'] ?? '',
    title: json['title'] ?? '',
    shell: json['shell'] ?? '',
    level: json['level'] ?? 0,
    difficulty: json['difficulty'] ?? '',
    objective: json['objective'] ?? '',
    explanation: json['explanation'] ?? '',
    syntax: json['syntax'] ?? '',
    example: json['example'] ?? '',
    lineByLine: json['lineByLine'] ?? '',
    practicalCase: json['practicalCase'] ?? '',
    commonError: json['commonError'] ?? '',
    bestPractice: json['bestPractice'] ?? '',
    exercise: json['exercise'] ?? '',
    hint: json['hint'] ?? '',
    correction: json['correction'] ?? '',
    category: json['category'] ?? '',
  );
}
