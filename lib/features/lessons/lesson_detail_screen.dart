import 'package:flutter/material.dart';
import '../../core/theme.dart';
import '../../models/lesson.dart';
import '../../services/progress_service.dart';
import '../../shared/widgets/terminal_container.dart';
import '../../shared/widgets/shell_badge.dart';

class LessonDetailScreen extends StatefulWidget {
  final Lesson lesson;
  const LessonDetailScreen({super.key, required this.lesson});

  @override
  State<LessonDetailScreen> createState() => _LessonDetailScreenState();
}

class _LessonDetailScreenState extends State<LessonDetailScreen> {
  bool _isCompleted = false;
  bool _isFavorite = false;

  @override
  void initState() {
    super.initState();
    _isCompleted = ProgressService.isLessonComplete(widget.lesson.id);
    _isFavorite = ProgressService.isFavorite(widget.lesson.id);
  }

  @override
  Widget build(BuildContext context) {
    final lesson = widget.lesson;
    final isBash = lesson.shell == 'bash';

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(lesson.title),
        actions: [
          ShellBadge(shell: lesson.shell),
          const SizedBox(width: 8),
          IconButton(
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
              child: ElevatedButton.icon(
                onPressed: _isCompleted ? null : () async {
                  await ProgressService.completeLesson(lesson.id);
                  setState(() => _isCompleted = true);
                  if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Leçon terminée !')));
                },
                icon: Icon(_isCompleted ? Icons.check_circle : Icons.check_circle_outline),
                label: Text(_isCompleted ? 'Terminé' : 'Marquer comme terminé'),
              ),
            ),
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
