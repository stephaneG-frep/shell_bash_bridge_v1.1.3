import '../data/bash_courses.dart';
import '../data/powershell_courses.dart';
import '../data/comparisons.dart';
import '../data/cheat_sheets.dart';

class SearchResult {
  final String id;
  final String title;
  final String type;
  final String shell;
  final String snippet;

  const SearchResult({
    required this.id,
    required this.title,
    required this.type,
    required this.shell,
    required this.snippet,
  });
}

class SearchService {
  static List<SearchResult> search(String query) {
    if (query.isEmpty) return [];
    final q = query.toLowerCase();
    final results = <SearchResult>[];

    for (final course in BashCourseData.allCourses) {
      if (course.title.toLowerCase().contains(q) || course.description.toLowerCase().contains(q)) {
        results.add(SearchResult(
          id: course.id,
          title: course.title,
          type: 'Cours',
          shell: 'Bash',
          snippet: course.description,
        ));
      }
      for (final lesson in course.lessons) {
        if (lesson.title.toLowerCase().contains(q) || lesson.explanation.toLowerCase().contains(q)) {
          results.add(SearchResult(
            id: lesson.id,
            title: lesson.title,
            type: 'Leçon',
            shell: 'Bash',
            snippet: lesson.explanation.substring(0, (lesson.explanation.length > 100 ? 100 : lesson.explanation.length)),
          ));
        }
      }
    }

    for (final course in PowerShellCourseData.allCourses) {
      if (course.title.toLowerCase().contains(q) || course.description.toLowerCase().contains(q)) {
        results.add(SearchResult(
          id: course.id,
          title: course.title,
          type: 'Cours',
          shell: 'PowerShell',
          snippet: course.description,
        ));
      }
      for (final lesson in course.lessons) {
        if (lesson.title.toLowerCase().contains(q) || lesson.explanation.toLowerCase().contains(q)) {
          results.add(SearchResult(
            id: lesson.id,
            title: lesson.title,
            type: 'Leçon',
            shell: 'PowerShell',
            snippet: lesson.explanation.substring(0, (lesson.explanation.length > 100 ? 100 : lesson.explanation.length)),
          ));
        }
      }
    }

    for (final comp in ComparisonData.allComparisons) {
      if (comp.task.toLowerCase().contains(q) || comp.bashCommand.toLowerCase().contains(q) || comp.psCommand.toLowerCase().contains(q)) {
        results.add(SearchResult(
          id: comp.id,
          title: comp.task,
          type: 'Comparaison',
          shell: 'Bash ↔ PowerShell',
          snippet: '${comp.bashCommand} → ${comp.psCommand}',
        ));
      }
    }

    for (final sheet in CheatSheetData.allSheets) {
      if (sheet.command.toLowerCase().contains(q) || sheet.description.toLowerCase().contains(q)) {
        results.add(SearchResult(
          id: sheet.id,
          title: sheet.command,
          type: 'Cheat Sheet',
          shell: sheet.shell,
          snippet: sheet.description,
        ));
      }
    }

    return results;
  }
}
