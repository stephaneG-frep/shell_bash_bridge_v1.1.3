import 'lesson.dart';

class Course {
  final String id;
  final String title;
  final String shell;
  final int level;
  final String description;
  final String icon;
  final List<Lesson> lessons;

  const Course({
    required this.id,
    required this.title,
    required this.shell,
    required this.level,
    required this.description,
    this.icon = '📚',
    this.lessons = const [],
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'shell': shell,
    'level': level,
    'description': description,
    'lessonCount': lessons.length,
  };

  factory Course.fromJson(Map<String, dynamic> json) => Course(
    id: json['id'] ?? '',
    title: json['title'] ?? '',
    shell: json['shell'] ?? '',
    level: json['level'] ?? 0,
    description: json['description'] ?? '',
    icon: json['icon'] ?? '📚',
  );
}
