import 'package:flutter/foundation.dart';
import '../data/bash_courses.dart';
import '../data/challenges.dart';
import '../data/powershell_courses.dart';
import '../models/progress.dart';
import 'storage_service.dart';

/// Règle d'attribution d'un badge (nom identique à [AppConstants.badges]).
class BadgeRule {
  final String name;
  final String description;
  final bool Function(UserProgress p) isEarned;
  const BadgeRule(this.name, this.description, this.isEarned);
}

class ProgressService {
  /// Notifie les écrans à chaque changement de progression.
  static final ValueNotifier<UserProgress> notifier =
      ValueNotifier<UserProgress>(const UserProgress());

  static UserProgress get progress => notifier.value;
  static set _progress(UserProgress value) => notifier.value = value;

  // Identifiants réels des leçons, calculés depuis les données embarquées.
  static final Set<String> bashLessonIds = {
    for (final c in BashCourseData.allCourses)
      for (final l in c.lessons) l.id,
  };
  static final Set<String> psLessonIds = {
    for (final c in PowerShellCourseData.allCourses)
      for (final l in c.lessons) l.id,
  };

  static int _countIn(Map<String, bool> done, Set<String> ids) =>
      done.entries.where((e) => e.value && ids.contains(e.key)).length;

  static const String shellMaster = 'Shell Master';

  static final List<BadgeRule> badgeRules = [
    BadgeRule('Premier terminal', 'Terminer une première leçon',
        (p) => p.completedLessons.values.any((v) => v)),
    BadgeRule('Première commande', 'Réussir un premier exercice',
        (p) => p.completedExercises.values.any((v) => v)),
    BadgeRule('Bash Beginner', 'Terminer 5 leçons Bash',
        (p) => _countIn(p.completedLessons, bashLessonIds) >= 5),
    BadgeRule('PowerShell Beginner', 'Terminer 5 leçons PowerShell',
        (p) => _countIn(p.completedLessons, psLessonIds) >= 5),
    BadgeRule('Pipeline Master', 'Réussir 10 exercices',
        (p) => p.completedExercises.values.where((v) => v).length >= 10),
    BadgeRule('Regex Wizard', 'Réussir 25 exercices',
        (p) => p.completedExercises.values.where((v) => v).length >= 25),
    BadgeRule('Scripteur', 'Relever 5 défis',
        (p) => p.completedChallenges.values.where((v) => v).length >= 5),
    BadgeRule(
        'Automatisation',
        'Relever 10 défis',
        (p) => p.completedChallenges.values.where((v) => v).length >=
            (ChallengeData.allChallenges.length < 10
                ? ChallengeData.allChallenges.length
                : 10)),
    BadgeRule('Administration', 'Terminer 3 projets',
        (p) => p.completedProjects.values.where((v) => v).length >= 3),
  ];

  static String badgeDescription(String name) {
    if (name == shellMaster) return 'Débloquer tous les autres badges';
    for (final r in badgeRules) {
      if (r.name == name) return r.description;
    }
    return '';
  }

  static void load() {
    // Recalcule les pourcentages et badges : corrige d'anciennes valeurs (> 100 %).
    _progress = _withDerived(StorageService.loadProgress());
  }

  static Future<void> _save(UserProgress p) async {
    _progress = _withDerived(p);
    await StorageService.saveProgress(progress);
  }

  static Future<void> completeLesson(String lessonId) async {
    final lessons = Map<String, bool>.from(progress.completedLessons);
    lessons[lessonId] = true;
    await _save(progress.copyWith(completedLessons: lessons));
  }

  static Future<void> completeExercise(String exerciseId, int score) async {
    final exercises = Map<String, bool>.from(progress.completedExercises);
    final scores = Map<String, int>.from(progress.scores);
    exercises[exerciseId] = true;
    scores[exerciseId] = score;
    await _save(progress.copyWith(completedExercises: exercises, scores: scores));
  }

  static Future<void> completeChallenge(String challengeId) async {
    final challenges = Map<String, bool>.from(progress.completedChallenges);
    challenges[challengeId] = true;
    await _save(progress.copyWith(completedChallenges: challenges));
  }

  static Future<void> completeProject(String projectId) async {
    final projects = Map<String, bool>.from(progress.completedProjects);
    projects[projectId] = true;
    await _save(progress.copyWith(completedProjects: projects));
  }

  static Future<void> toggleFavorite(String itemId) async {
    final favs = List<String>.from(progress.favorites);
    if (!favs.remove(itemId)) favs.add(itemId);
    await _save(progress.copyWith(favorites: favs));
  }

  static bool isFavorite(String itemId) => progress.favorites.contains(itemId);

  static bool isLessonComplete(String lessonId) =>
      progress.completedLessons[lessonId] == true;

  static Future<void> resetProgress() async {
    await _save(const UserProgress());
  }

  /// Pourcentages bornés à [0, 1] et badges recalculés (jamais retirés).
  static UserProgress _withDerived(UserProgress p) {
    final bash = bashLessonIds.isEmpty
        ? 0.0
        : _countIn(p.completedLessons, bashLessonIds) / bashLessonIds.length;
    final ps = psLessonIds.isEmpty
        ? 0.0
        : _countIn(p.completedLessons, psLessonIds) / psLessonIds.length;

    final badges = List<String>.from(p.badges);
    for (final rule in badgeRules) {
      if (!badges.contains(rule.name) && rule.isEarned(p)) badges.add(rule.name);
    }
    final allOthers = badgeRules.every((r) => badges.contains(r.name));
    if (allOthers && !badges.contains(shellMaster)) badges.add(shellMaster);

    return p.copyWith(
      bashProgress: bash.clamp(0.0, 1.0),
      psProgress: ps.clamp(0.0, 1.0),
      badges: badges,
    );
  }
}
