import 'package:flutter/material.dart';
import '../../core/app_fonts.dart';
import '../../core/theme.dart';
import '../../models/course.dart';
import '../../models/lesson.dart';
import '../../services/progress_service.dart';
import '../lessons/lesson_detail_screen.dart';

/// Liste des leçons d'un cours, avec leur état d'avancement.
class CourseDetailScreen extends StatefulWidget {
  final Course course;
  const CourseDetailScreen({super.key, required this.course});

  @override
  State<CourseDetailScreen> createState() => _CourseDetailScreenState();
}

class _CourseDetailScreenState extends State<CourseDetailScreen> {
  @override
  void initState() {
    super.initState();
    ProgressService.notifier.addListener(_onProgressChanged);
  }

  @override
  void dispose() {
    ProgressService.notifier.removeListener(_onProgressChanged);
    super.dispose();
  }

  void _onProgressChanged() {
    if (mounted) setState(() {});
  }

  void _open(Lesson lesson) {
    Navigator.of(context).push(MaterialPageRoute(
      builder: (_) => LessonDetailScreen(lesson: lesson, course: widget.course),
    ));
  }

  @override
  Widget build(BuildContext context) {
    final course = widget.course;
    final isBash = course.shell == 'bash';
    final color = isBash ? AppTheme.accentGreen : AppTheme.accentBlue;
    final done = course.lessons.where((l) => ProgressService.isLessonComplete(l.id)).length;
    final total = course.lessons.length;
    // Première leçon non terminée : point de reprise proposé.
    final next = course.lessons.where((l) => !ProgressService.isLessonComplete(l.id)).firstOrNull;

    return Scaffold(
      backgroundColor: AppTheme.scaffoldBg(context),
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          tooltip: 'Retour',
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(course.title, maxLines: 1, overflow: TextOverflow.ellipsis),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(course.description, style: TextStyle(color: AppTheme.textSecColor(context), fontSize: 13, height: 1.4)),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: total == 0 ? 0 : done / total,
                    minHeight: 8,
                    color: color,
                    backgroundColor: color.withValues(alpha: 0.15),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Text('$done/$total', style: AppFonts.firaCode(color: color, fontWeight: FontWeight.w700, fontSize: 13)),
            ],
          ),
          if (next != null) ...[
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                style: FilledButton.styleFrom(backgroundColor: color, foregroundColor: Colors.white),
                onPressed: () => _open(next),
                icon: const Icon(Icons.play_arrow_rounded),
                label: Text(done == 0 ? 'Commencer le cours' : 'Reprendre : ${next.title}',
                    maxLines: 1, overflow: TextOverflow.ellipsis),
              ),
            ),
          ],
          const SizedBox(height: 16),
          for (var i = 0; i < total; i++) _lessonTile(i, course.lessons[i], color),
        ],
      ),
    );
  }

  Widget _lessonTile(int index, Lesson lesson, Color color) {
    final complete = ProgressService.isLessonComplete(lesson.id);
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        onTap: () => _open(lesson),
        leading: CircleAvatar(
          radius: 16,
          backgroundColor: complete ? color : color.withValues(alpha: 0.12),
          child: complete
              ? const Icon(Icons.check_rounded, size: 18, color: Colors.white)
              : Text('${index + 1}', style: AppFonts.firaCode(color: color, fontSize: 12, fontWeight: FontWeight.w700)),
        ),
        title: Text(lesson.title,
            style: TextStyle(color: AppTheme.textColor(context), fontSize: 14, fontWeight: FontWeight.w500)),
        subtitle: Text(lesson.category, style: TextStyle(color: AppTheme.textSecColor(context), fontSize: 11)),
        trailing: Icon(Icons.chevron_right, color: AppTheme.textSecColor(context)),
      ),
    );
  }
}
