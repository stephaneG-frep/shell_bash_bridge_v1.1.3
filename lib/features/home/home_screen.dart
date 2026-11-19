import '../../core/app_fonts.dart';
import 'package:flutter/material.dart';
import '../../core/theme.dart';
import '../../services/progress_service.dart';
import '../../data/bash_courses.dart';
import '../../data/powershell_courses.dart';
import '../courses/courses_screen.dart';
import '../comparison/comparison_screen.dart';
import '../cheatsheets/cheatsheet_screen.dart';
import '../search/search_screen.dart';
import '../guide/guide_screen.dart';
import '../exercises/exercises_screen.dart';
import '../projects/projects_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
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


  @override
  Widget build(BuildContext context) {
    final progress = ProgressService.progress;
    final totalLessons = progress.completedLessons.length;
    final totalExercises = progress.completedExercises.length;
    final totalChallenges = progress.completedChallenges.length;
    final totalBadges = progress.badges.length;
    final bashLessons = BashCourseData.allCourses.fold<int>(0, (sum, c) => sum + c.lessons.length);
    final psLessons = PowerShellCourseData.allCourses.fold<int>(0, (sum, c) => sum + c.lessons.length);
    final bashPct = bashLessons > 0 ? (progress.bashProgress * 100).toInt() : 0;
    final psPct = psLessons > 0 ? (progress.psProgress * 100).toInt() : 0;

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(),
              const SizedBox(height: 20),
              _buildOverallProgress(bashPct, psPct),
              const SizedBox(height: 20),
              _buildShellCards(context),
              const SizedBox(height: 20),
              _buildStats(totalLessons, totalExercises, totalChallenges, totalBadges),
              const SizedBox(height: 20),
              _buildQuickActions(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppTheme.accentGreen.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(r'$', style: AppFonts.firaCode(fontSize: 24, color: AppTheme.accentGreen, fontWeight: FontWeight.bold)),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Shell-Bash-Bridge', style: AppFonts.firaCode(fontSize: 20, fontWeight: FontWeight.bold, color: AppTheme.textColor(context))),
              Text('Apprenez Bash et PowerShell', style: TextStyle(color: AppTheme.textSecColor(context), fontSize: 13)),
            ],
          ),
        ),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppTheme.accentBlue.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text('PS>', style: AppFonts.firaCode(fontSize: 18, color: AppTheme.accentBlue, fontWeight: FontWeight.bold)),
        ),
      ],
    );
  }

  Widget _buildOverallProgress(int bashPct, int psPct) {
    final overall = ((bashPct + psPct) / 2).toInt();
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Progression générale', style: TextStyle(color: AppTheme.textColor(context), fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            Row(
              children: [
                SizedBox(
                  width: 60, height: 60,
                  child: CircularProgressIndicator(value: overall / 100, strokeWidth: 6, backgroundColor: AppTheme.chipBg(context), color: AppTheme.accent),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _progressBar('Bash', bashPct.toDouble(), AppTheme.accentGreen),
                      const SizedBox(height: 8),
                      _progressBar('PowerShell', psPct.toDouble(), AppTheme.accentBlue),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _progressBar(String label, double value, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label, style: TextStyle(color: AppTheme.textSecColor(context), fontSize: 12)),
            Text('${value.toInt()}%', style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.bold)),
          ],
        ),
        const SizedBox(height: 4),
        LinearProgressIndicator(value: value / 100, backgroundColor: AppTheme.chipBg(context), color: color, minHeight: 6),
      ],
    );
  }

  Widget _buildShellCards(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Parcours', style: TextStyle(color: AppTheme.textColor(context), fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 12),
        _shellCard(context, r'$', 'Bash', 'Apprenez le shell Linux', AppTheme.accentGreen, () => Navigator.push(context, MaterialPageRoute(builder: (_) => const CoursesScreen()))),
        const SizedBox(height: 8),
        _shellCard(context, 'PS>', 'PowerShell', 'Maîtrisez PowerShell Windows', AppTheme.accentBlue, () => Navigator.push(context, MaterialPageRoute(builder: (_) => const CoursesScreen(initialTab: 1)))),
        const SizedBox(height: 8),
        _shellCard(context, r'$ ↔ PS>', 'Comparateur', 'Comparez Bash et PowerShell', AppTheme.accentPurple, () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ComparisonScreen()))),
      ],
    );
  }

  Widget _shellCard(BuildContext context, String icon, String title, String subtitle, Color color, VoidCallback onTap) {
    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 48, height: 48,
                decoration: BoxDecoration(color: color.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(12)),
                child: Center(child: Text(icon, style: AppFonts.firaCode(color: color, fontSize: 14, fontWeight: FontWeight.bold))),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: TextStyle(color: AppTheme.textColor(context), fontSize: 16, fontWeight: FontWeight.bold)),
                    Text(subtitle, style: TextStyle(color: AppTheme.textSecColor(context), fontSize: 12)),
                  ],
                ),
              ),
              Icon(Icons.chevron_right, color: AppTheme.textSecColor(context)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStats(int lessons, int exercises, int challenges, int badges) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Statistiques', style: TextStyle(color: AppTheme.textColor(context), fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            Row(
              children: [
                _statItem('Cours', '$lessons', AppTheme.accentGreen),
                _statItem('Exercices', '$exercises', AppTheme.accentBlue),
                _statItem('Défis', '$challenges', AppTheme.accentOrange),
                _statItem('Badges', '$badges', AppTheme.accentPurple),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _statItem(String label, String value, Color color) {
    return Expanded(
      child: Column(
        children: [
          Text(value, style: TextStyle(color: color, fontSize: 22, fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          Text(label, style: TextStyle(color: AppTheme.textSecColor(context), fontSize: 11)),
        ],
      ),
    );
  }

  Widget _buildQuickActions(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Accès rapide', style: TextStyle(color: AppTheme.textColor(context), fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            _actionChip('Cheat Sheets', Icons.description, () => Navigator.push(context, MaterialPageRoute(builder: (_) => const CheatSheetScreen()))),
            _actionChip('Recherche', Icons.search, () => Navigator.push(context, MaterialPageRoute(builder: (_) => const SearchScreen()))),
            _actionChip('Exercices', Icons.quiz, () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ExercisesScreen()))),
            _actionChip('Projets', Icons.build_circle_outlined, () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ProjectsScreen()))),
            _actionChip('Guide', Icons.help_outline, () => Navigator.push(context, MaterialPageRoute(builder: (_) => const GuideScreen()))),
          ],
        ),
      ],
    );
  }

  Widget _actionChip(String label, IconData icon, VoidCallback onTap) {
    return ActionChip(
      avatar: Icon(icon, size: 18, color: AppTheme.accent),
      label: Text(label, style: TextStyle(color: AppTheme.textColor(context), fontSize: 13)),
      onPressed: onTap,
      backgroundColor: AppTheme.chipBg(context),
      side: BorderSide(color: AppTheme.accent.withValues(alpha: 0.3)),
    );
  }
}
