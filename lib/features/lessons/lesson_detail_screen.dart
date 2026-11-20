import 'package:flutter/material.dart';
import '../../core/theme.dart';
import '../../data/bash_courses.dart';
import '../../data/powershell_courses.dart';
import '../../models/course.dart';
import '../../models/lesson.dart';
import '../../services/progress_service.dart';
import '../../shared/widgets/terminal_container.dart';
import '../../shared/widgets/shell_badge.dart';
import '../notes/notes_screen.dart';

class LessonDetailScreen extends StatefulWidget {
  final Lesson lesson;

  /// Cours de la leçon (retrouvé automatiquement s'il n'est pas fourni).
  final Course? course;
  const LessonDetailScreen({super.key, required this.lesson, this.course});

  static Course? courseOf(Lesson lesson) {
    for (final c in [...BashCourseData.allCourses, ...PowerShellCourseData.allCourses]) {
      if (c.lessons.any((l) => l.id == lesson.id)) return c;
    }
    return null;
  }

  @override
  State<LessonDetailScreen> createState() => _LessonDetailScreenState();
}

class _LessonDetailScreenState extends State<LessonDetailScreen> {
  bool _isCompleted = false;
  bool _isFavorite = false;
  Course? _course;
  int _index = -1;

  Lesson? get _previous => (_course != null && _index > 0) ? _course!.lessons[_index - 1] : null;
  Lesson? get _next =>
      (_course != null && _index >= 0 && _index < _course!.lessons.length - 1) ? _course!.lessons[_index + 1] : null;

  void _goTo(Lesson lesson) {
    Navigator.of(context).pushReplacement(MaterialPageRoute(
      builder: (_) => LessonDetailScreen(lesson: lesson, course: _course),
    ));
  }

  Future<void> _complete() async {
    await ProgressService.completeLesson(widget.lesson.id);
    if (!mounted) return;
    setState(() => _isCompleted = true);
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Leçon terminée !')));
  }

  @override
  void initState() {
    super.initState();
    _course = widget.course ?? LessonDetailScreen.courseOf(widget.lesson);
    _index = _course?.lessons.indexWhere((l) => l.id == widget.lesson.id) ?? -1;
    _isCompleted = ProgressService.isLessonComplete(widget.lesson.id);
    _isFavorite = ProgressService.isFavorite(widget.lesson.id);
  }

  @override
  Widget build(BuildContext context) {
    final lesson = widget.lesson;
    final isBash = lesson.shell == 'bash';

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(tooltip: 'Retour', 
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(lesson.title, maxLines: 1, overflow: TextOverflow.ellipsis),
            if (_course != null && _index >= 0)
              Text('Leçon ${_index + 1}/${_course!.lessons.length} · ${_course!.title}',
                  style: TextStyle(fontSize: 11, color: AppTheme.textSecColor(context)),
                  maxLines: 1, overflow: TextOverflow.ellipsis),
          ],
        ),
        actions: [
          ShellBadge(shell: lesson.shell),
          const SizedBox(width: 8),
          IconButton(
            icon: const Icon(Icons.note_add_outlined),
            tooltip: 'Mes notes sur cette leçon',
            onPressed: () => Navigator.of(context).push(MaterialPageRoute(
              builder: (_) => NotesScreen(lessonId: lesson.id, lessonTitle: lesson.title),
            )),
          ),
          IconButton(tooltip: _isFavorite ? 'Retirer des favoris' : 'Ajouter aux favoris', 
            icon: Icon(_isFavorite ? Icons.favorite : Icons.favorite_border, color: _isFavorite ? Colors.red : null),
            onPressed: () {
              setState(() => _isFavorite = !_isFavorite);
              ProgressService.toggleFavorite(lesson.id);
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _difficultyBadge(lesson.difficulty),
            const SizedBox(height: 16),
            _section('Objectif', lesson.objective, Icons.flag, AppTheme.accent),
            const SizedBox(height: 12),
            _section('Explication', lesson.explanation, Icons.info_outline, AppTheme.textColor(context)),
            const SizedBox(height: 12),
            _terminalSection('Syntaxe', lesson.syntax, isBash),
            const SizedBox(height: 12),
            _terminalSection('Exemple', lesson.example, isBash),
            const SizedBox(height: 12),
            if (lesson.lineByLine.isNotEmpty) ...[
              _section('Explication ligne par ligne', lesson.lineByLine, Icons.format_list_numbered, AppTheme.textColor(context)),
              const SizedBox(height: 12),
            ],
            if (lesson.practicalCase.isNotEmpty) ...[
              _section('Cas pratique', lesson.practicalCase, Icons.build, AppTheme.accentGreen),
              const SizedBox(height: 12),
            ],
            if (lesson.commonError.isNotEmpty) ...[
              _warningSection('Erreur fréquente', lesson.commonError),
              const SizedBox(height: 12),
            ],
            if (lesson.bestPractice.isNotEmpty) ...[
              _successSection('Bonne pratique', lesson.bestPractice),
              const SizedBox(height: 12),
            ],
            if (lesson.exercise.isNotEmpty) ...[
              _exerciseSection(lesson.exercise),
              const SizedBox(height: 12),
            ],
            if (lesson.hint.isNotEmpty) ...[
              ExpansionTile(
                title: Text('Indice', style: TextStyle(color: AppTheme.warning, fontWeight: FontWeight.bold)),
                children: [Padding(padding: const EdgeInsets.all(12), child: Text(lesson.hint, style: TextStyle(color: AppTheme.textSecColor(context))))],
              ),
            ],
            if (lesson.correction.isNotEmpty) ...[
              ExpansionTile(
                title: Text('Correction', style: TextStyle(color: AppTheme.accentGreen, fontWeight: FontWeight.bold)),
                children: [TerminalContainer(text: lesson.correction, isBash: isBash)],
              ),
            ],
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: _isCompleted || _next == null
                  ? ElevatedButton.icon(
                      onPressed: _isCompleted ? null : _complete,
                      icon: Icon(_isCompleted ? Icons.check_circle : Icons.check_circle_outline),
                      label: Text(_isCompleted ? 'Terminé' : 'Marquer comme terminé'),
                    )
                  : FilledButton.icon(
                      // Termine la leçon et enchaîne directement sur la suivante.
                      onPressed: () async {
                        await _complete();
                        if (mounted) _goTo(_next!);
                      },
                      icon: const Icon(Icons.check_circle_outline),
                      label: const Text('Terminer et continuer'),
                    ),
            ),
            if (_previous != null || _next != null) ...[
              const SizedBox(height: 12),
              Row(
                children: [
                  if (_previous != null)
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () => _goTo(_previous!),
                        icon: const Icon(Icons.chevron_left_rounded),
                        label: const Text('Précédente'),
                      ),
                    ),
                  if (_previous != null && _next != null) const SizedBox(width: 12),
                  if (_next != null)
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () => _goTo(_next!),
                        icon: const Icon(Icons.chevron_right_rounded),
                        label: const Text('Suivante'),
                        iconAlignment: IconAlignment.end,
                      ),
                    ),
                ],
              ),
            ],
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _difficultyBadge(String difficulty) {
    Color color;
    switch (difficulty) {
      case 'Débutant': color = AppTheme.accentGreen; break;
      case 'Intermédiaire': color = AppTheme.accentBlue; break;
      case 'Avancé': color = AppTheme.accentOrange; break;
      case 'Expert': color = AppTheme.danger; break;
      default: color = AppTheme.textSecondary;
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(color: color.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(8)),
      child: Text(difficulty, style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 12)),
    );
  }

  Widget _section(String title, String content, IconData icon, Color color) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(children: [Icon(icon, size: 18, color: color), const SizedBox(width: 8), Text(title, style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 14))]),
            const SizedBox(height: 8),
            Text(content, style: TextStyle(color: AppTheme.textSecColor(context), height: 1.5)),
          ],
        ),
      ),
    );
  }

  Widget _terminalSection(String title, String content, bool isBash) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: TextStyle(color: AppTheme.accent, fontWeight: FontWeight.bold, fontSize: 14)),
            const SizedBox(height: 8),
            TerminalContainer(text: content, isBash: isBash),
          ],
        ),
      ),
    );
  }

  Widget _warningSection(String title, String content) {
    return Card(
      color: AppTheme.warning.withValues(alpha: 0.1),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(children: [const Icon(Icons.warning_amber, size: 18, color: AppTheme.warning), const SizedBox(width: 8), Text(title, style: const TextStyle(color: AppTheme.warning, fontWeight: FontWeight.bold))]),
            const SizedBox(height: 8),
            Text(content, style: TextStyle(color: AppTheme.textSecColor(context))),
          ],
        ),
      ),
    );
  }

  Widget _successSection(String title, String content) {
    return Card(
      color: AppTheme.accentGreen.withValues(alpha: 0.1),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(children: [const Icon(Icons.check_circle, size: 18, color: AppTheme.accentGreen), const SizedBox(width: 8), Text(title, style: const TextStyle(color: AppTheme.accentGreen, fontWeight: FontWeight.bold))]),
            const SizedBox(height: 8),
            Text(content, style: TextStyle(color: AppTheme.textSecColor(context))),
          ],
        ),
      ),
    );
  }

  Widget _exerciseSection(String exercise) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(children: [const Icon(Icons.quiz, size: 18, color: AppTheme.accent), const SizedBox(width: 8), const Text('Exercice', style: TextStyle(color: AppTheme.accent, fontWeight: FontWeight.bold))]),
            const SizedBox(height: 8),
            TerminalContainer(text: exercise),
          ],
        ),
      ),
    );
  }
}
