import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shell_bash_bridge/core/constants.dart';
import 'package:shell_bash_bridge/data/challenges.dart';
import 'package:shell_bash_bridge/data/exercises.dart';
import 'package:shell_bash_bridge/data/projects.dart';
import 'package:shell_bash_bridge/services/progress_service.dart';
import 'package:shell_bash_bridge/services/storage_service.dart';

Future<void> _fresh([Map<String, Object> values = const {}]) async {
  SharedPreferences.setMockInitialValues(values);
  await StorageService.init();
  ProgressService.load();
}

void main() {
  test('pourcentage borné à 100 % et calculé sur les vraies leçons', () async {
    await _fresh();
    for (final id in ProgressService.bashLessonIds) {
      await ProgressService.completeLesson(id);
    }
    await ProgressService.completeLesson('bash_inexistant');
    expect(ProgressService.progress.bashProgress, 1.0);
    expect(ProgressService.progress.psProgress, 0.0);
  });

  test('ancienne valeur > 100 % corrigée au chargement', () async {
    await _fresh({'user_progress': '{"bashProgress": 1.47}'});
    expect(ProgressService.progress.bashProgress, 0.0);
  });

  test('badges sauvegardés et relus après redémarrage', () async {
    await _fresh();
    await ProgressService.completeExercise('ex', 100);
    expect(ProgressService.progress.badges, contains('Première commande'));
    ProgressService.load(); // simule un redémarrage
    expect(ProgressService.progress.badges, contains('Première commande'));
  });

  test('défis et projets comptent pour les badges', () async {
    await _fresh();
    for (final c in ChallengeData.allChallenges.take(5)) {
      await ProgressService.completeChallenge(c.id);
    }
    for (final p in ProjectData.allProjects.take(3)) {
      await ProgressService.completeProject(p.id);
    }
    expect(ProgressService.progress.badges, containsAll(['Scripteur', 'Administration']));
  });

  test('Shell Master atteignable et tous les badges ont une règle', () async {
    final ruled = {...ProgressService.badgeRules.map((r) => r.name), ProgressService.shellMaster};
    expect(ruled, AppConstants.badges.toSet());

    await _fresh();
    final bash = ProgressService.bashLessonIds.take(5);
    final ps = ProgressService.psLessonIds.take(5);
    for (final id in [...bash, ...ps]) {
      await ProgressService.completeLesson(id);
    }
    for (final e in ExerciseData.allExercises.take(25)) {
      await ProgressService.completeExercise(e.id, 100);
    }
    for (final c in ChallengeData.allChallenges) {
      await ProgressService.completeChallenge(c.id);
    }
    for (final p in ProjectData.allProjects.take(3)) {
      await ProgressService.completeProject(p.id);
    }
    expect(ProgressService.progress.badges, contains('Shell Master'));
  });

  test('les écrans sont notifiés des changements', () async {
    await _fresh();
    var notified = 0;
    void listener() => notified++;
    ProgressService.notifier.addListener(listener);
    await ProgressService.toggleFavorite('x');
    ProgressService.notifier.removeListener(listener);
    expect(notified, greaterThan(0));
    expect(ProgressService.isFavorite('x'), isTrue);
  });
}
