import 'package:flutter_test/flutter_test.dart';
import 'package:shell_bash_bridge/core/constants.dart';
import 'package:shell_bash_bridge/data/bash_courses.dart';
import 'package:shell_bash_bridge/data/cheat_sheets.dart';
import 'package:shell_bash_bridge/data/exercises.dart';
import 'package:shell_bash_bridge/data/powershell_courses.dart';
import 'package:shell_bash_bridge/features/cheatsheets/cheatsheet_screen.dart';
import 'package:shell_bash_bridge/models/course.dart';
import 'package:shell_bash_bridge/models/lesson.dart';

/// Vérifie l'intégrité du contenu pédagogique (utile à chaque ajout de leçon).
void main() {
  final courses = <Course>[...BashCourseData.allCourses, ...PowerShellCourseData.allCourses];
  final lessons = <Lesson>[for (final c in courses) ...c.lessons];

  test('identifiants uniques (cours, leçons, exercices, fiches)', () {
    void unique(Iterable<String> ids, String what) {
      final seen = <String>{};
      final dup = ids.where((id) => !seen.add(id)).toList();
      expect(dup, isEmpty, reason: '$what en double : $dup');
    }

    unique(courses.map((c) => c.id), 'cours');
    unique(lessons.map((l) => l.id), 'leçons');
    unique(ExerciseData.allExercises.map((e) => e.id), 'exercices');
    unique(CheatSheetData.allSheets.map((s) => s.id), 'fiches');
  });

  test('chaque leçon est complète et cohérente avec son cours', () {
    for (final c in courses) {
      expect(c.lessons, isNotEmpty, reason: c.id);
      expect(c.level, inInclusiveRange(0, AppConstants.levels.length - 1), reason: c.id);
      for (final l in c.lessons) {
        final champs = {
          'title': l.title, 'objective': l.objective, 'explanation': l.explanation,
          'syntax': l.syntax, 'example': l.example, 'lineByLine': l.lineByLine,
          'practicalCase': l.practicalCase, 'commonError': l.commonError,
          'bestPractice': l.bestPractice, 'exercise': l.exercise, 'hint': l.hint,
          'correction': l.correction,
        };
        champs.forEach((k, v) => expect(v.trim(), isNotEmpty, reason: '${l.id}.$k vide'));
        expect(l.shell, c.shell, reason: '${l.id} : shell différent de son cours');
        expect(l.id.startsWith(c.shell == 'bash' ? 'bash_' : 'ps_'), isTrue, reason: l.id);
      }
    }
  });

  test('chaque niveau du parcours a au moins un cours dans chaque shell', () {
    for (final shell in ['bash', 'powershell']) {
      final niveaux = courses.where((c) => c.shell == shell).map((c) => c.level).toSet();
      for (var n = 0; n < AppConstants.levels.length; n++) {
        expect(niveaux, contains(n), reason: '$shell : aucun cours de niveau ${AppConstants.levels[n]}');
      }
    }
  });

  test('les caractères spéciaux du code sont restitués à l\'identique', () {
    Lesson byId(String id) => lessons.firstWhere((l) => l.id == id);
    expect(byId('bash_312').example, contains(r'echo "${fichier%.*}"'));
    expect(byId('bash_501').example, contains(r'\?) echo "Option inconnue : -$OPTARG"'));
    expect(byId('bash_502').example, contains(r"jq --arg n " '"bob"'));
    expect(byId('ps_109').example, contains(r"'$3/$2/$1'"));
    expect(byId('ps_905').example, contains(r'robocopy C:\Source D:\Copie /MIR'));
  });

  test('fiches mémo : catégorie et niveau de danger reconnus par l\'écran', () {
    for (final s in CheatSheetData.allSheets) {
      expect(CheatSheetScreen.categories, contains(s.category), reason: '${s.id} (${s.command})');
      expect(CheatSheetScreen.dangerLevels, contains(s.danger), reason: '${s.id} (${s.command})');
    }
  });

  test('exercices : la bonne réponse figure parmi les options', () {
    for (final e in ExerciseData.allExercises) {
      if (e.options != null) {
        expect(e.options, contains(e.correctAnswer), reason: e.id);
      }
    }
  });
}
