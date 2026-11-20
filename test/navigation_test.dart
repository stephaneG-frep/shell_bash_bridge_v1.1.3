import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shell_bash_bridge/data/bash_courses.dart';
import 'package:shell_bash_bridge/features/courses/course_detail_screen.dart';
import 'package:shell_bash_bridge/services/progress_service.dart';
import 'package:shell_bash_bridge/services/storage_service.dart';

void main() {
  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    await StorageService.init();
    ProgressService.load();
  });

  testWidgets('toutes les leçons d\'un cours sont accessibles et enchaînables', (tester) async {
    final course = BashCourseData.allCourses.first;
    await tester.pumpWidget(MaterialApp(home: CourseDetailScreen(course: course)));

    // La 3e leçon s'ouvre depuis la liste (avant : seule la 1re était accessible).
    await tester.tap(find.text(course.lessons[2].title));
    await tester.pumpAndSettle();
    expect(find.text('Leçon 3/${course.lessons.length} · ${course.title}'), findsOneWidget);

    // « Suivante » mène à la 4e leçon.
    await tester.scrollUntilVisible(find.text('Suivante'), 300, scrollable: find.byType(Scrollable).last);
    await tester.tap(find.text('Suivante'));
    await tester.pumpAndSettle();
    expect(find.text('Leçon 4/${course.lessons.length} · ${course.title}'), findsOneWidget);

    // « Terminer et continuer » valide la leçon et passe à la 5e.
    await tester.scrollUntilVisible(find.text('Terminer et continuer'), 300, scrollable: find.byType(Scrollable).last);
    await tester.tap(find.text('Terminer et continuer'));
    await tester.pumpAndSettle();
    expect(ProgressService.isLessonComplete(course.lessons[3].id), isTrue);
    expect(find.text('Leçon 5/${course.lessons.length} · ${course.title}'), findsOneWidget);
  });

  testWidgets('le cours propose de reprendre à la première leçon non terminée', (tester) async {
    final course = BashCourseData.allCourses.first;
    await ProgressService.completeLesson(course.lessons[0].id);
    await tester.pumpWidget(MaterialApp(home: CourseDetailScreen(course: course)));
    expect(find.text('Reprendre : ${course.lessons[1].title}'), findsOneWidget);
    expect(find.text('1/${course.lessons.length}'), findsOneWidget);
  });
}
