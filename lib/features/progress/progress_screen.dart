import '../../core/app_fonts.dart';

import 'package:flutter/material.dart';

import '../../services/progress_service.dart';
import '../../core/theme.dart';
import '../../core/constants.dart';

class ProgressScreen extends StatefulWidget {
  const ProgressScreen({super.key});

  @override
  State<ProgressScreen> createState() => _ProgressScreenState();
}

class _ProgressScreenState extends State<ProgressScreen> {
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
    final totalProjects = progress.completedProjects.length;
    final totalScore = progress.scores.values.fold(0, (a, b) => a + b);

    final bashPct = (progress.bashProgress * 100).toStringAsFixed(0);
    final psPct = (progress.psProgress * 100).toStringAsFixed(0);
    final overallPct =
        ((progress.bashProgress + progress.psProgress) / 2 * 100)
            .toStringAsFixed(0);

    final earnedBadges = progress.badges;
    final allBadges = AppConstants.badges;

    return Scaffold(
      backgroundColor: AppTheme.cardBg(context),
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildOverallRing(overallPct),
                    const SizedBox(height: 20),
                    _buildShellProgress(
                      bashPct,
                      progress.bashProgress,
                      AppTheme.bashGreen,
                      'Bash',
                    ),
                    const SizedBox(height: 12),
                    _buildShellProgress(
                      psPct,
                      progress.psProgress,
                      AppTheme.psBlue,
                      'PowerShell',
                    ),
                    const SizedBox(height: 24),
                    Text(
                      'Statistiques',
                      style: AppFonts.firaCode(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: AppTheme.textColor(context),
                      ),
                    ),
                    const SizedBox(height: 12),
                    _buildStatsGrid(
                      totalLessons,
                      totalExercises,
                      totalChallenges,
                      totalProjects,
                      totalScore,
                    ),
                    const SizedBox(height: 24),
                    _buildCategoryBreakdown(progress.completedLessons),
                    const SizedBox(height: 24),
                    Text(
                      'Badges',
                      style: AppFonts.firaCode(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: AppTheme.textColor(context),
                      ),
                    ),
                    const SizedBox(height: 12),
                    _buildBadgesSection(allBadges, earnedBadges),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back_rounded, size: 22),
            color: AppTheme.textSecColor(context).withValues(alpha: 0.7),
            onPressed: () => Navigator.of(context).pop(),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'Ma Progression',
              style: AppFonts.firaCode(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: AppTheme.textColor(context),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOverallRing(String overallPct) {
    return Center(
      child: SizedBox(
        width: 140,
        height: 140,
        child: Stack(
          alignment: Alignment.center,
          children: [
            SizedBox(
              width: 140,
              height: 140,
              child: CircularProgressIndicator(
                value: ProgressService.progress.bashProgress +
                        ProgressService.progress.psProgress >
                    0
                    ? (ProgressService.progress.bashProgress +
                            ProgressService.progress.psProgress) /
                        2
                    : 0,
                strokeWidth: 10,
                backgroundColor: AppTheme.textSecColor(context).withValues(alpha: 0.08),
                valueColor: AlwaysStoppedAnimation<Color>(
                  AppTheme.accent,
                ),
                strokeCap: StrokeCap.round,
              ),
            ),
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  '$overallPct%',
                  style: AppFonts.firaCode(
                    fontSize: 28,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.textColor(context),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'global',
                  style: AppFonts.firaCode(
                    fontSize: 10,
                    color: AppTheme.textSecColor(context).withValues(alpha: 0.4),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildShellProgress(
    String pct,
    double value,
    Color color,
    String label,
  ) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppTheme.chipBg(context).withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: color.withValues(alpha: 0.15),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                label,
                style: AppFonts.firaCode(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.textColor(context),
                ),
              ),
              Text(
                '$pct%',
                style: AppFonts.firaCode(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: color,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(5),
            child: LinearProgressIndicator(
              value: value,
              minHeight: 8,
              backgroundColor: color.withValues(alpha: 0.12),
              valueColor: AlwaysStoppedAnimation<Color>(color),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsGrid(
    int lessons,
    int exercises,
    int challenges,
    int projects,
    int score,
  ) {
    final items = [
      (Icons.menu_book_rounded, '$lessons', 'Cours terminés', AppTheme.bashGreen),
      (Icons.check_circle_rounded, '$exercises', 'Exercices réussis', AppTheme.psBlue),
      (Icons.emoji_events_rounded, '$challenges', 'Défis relevés', AppTheme.warning),
      (Icons.folder_rounded, '$projects', 'Projets terminés', AppTheme.accent),
      (Icons.star_rounded, '$score', 'Score total', AppTheme.safe),
    ];

    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: items.map((item) {
        final (icon, value, label, color) = item;
        return SizedBox(
          width: (MediaQuery.of(context).size.width - 50) / 2,
          child: Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppTheme.chipBg(context).withValues(alpha: 0.06),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: AppTheme.textSecColor(context).withValues(alpha: 0.08),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(icon, color: color, size: 20),
                const SizedBox(height: 8),
                Text(
                  value,
                  style: AppFonts.firaCode(
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                    color: color,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  label,
                  style: AppFonts.firaCode(
                    fontSize: 10,
                    color: AppTheme.textSecColor(context).withValues(alpha: 0.45),
                  ),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildCategoryBreakdown(Map<String, bool> completedLessons) {
    final categories = <String, int>{};
    for (final entry in completedLessons.entries) {
      if (entry.value) {
        final prefix = entry.key.startsWith('bash_') ? 'Bash' : 'PowerShell';
        categories[prefix] = (categories[prefix] ?? 0) + 1;
      }
    }

    if (categories.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Répartition par shell',
          style: AppFonts.firaCode(
            fontSize: 15,
            fontWeight: FontWeight.w700,
            color: AppTheme.textColor(context),
          ),
        ),
        const SizedBox(height: 12),
        ...categories.entries.map((entry) {
          final color =
              entry.key == 'Bash' ? AppTheme.bashGreen : AppTheme.psBlue;
          return Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppTheme.chipBg(context).withValues(alpha: 0.06),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Container(
                    width: 4,
                    height: 28,
                    decoration: BoxDecoration(
                      color: color,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      entry.key,
                      style: AppFonts.firaCode(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.textColor(context),
                      ),
                    ),
                  ),
                  Text(
                    '${entry.value} leçons',
                    style: AppFonts.firaCode(
                      fontSize: 12,
                      color: color,
                    ),
                  ),
                ],
              ),
            ),
          );
        }),
      ],
    );
  }

  Widget _buildBadgesSection(List<String> allBadges, List<String> earned) {
    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: allBadges.map((badge) {
        final isEarned = earned.contains(badge);
        return Tooltip(
          message: ProgressService.badgeDescription(badge),
          triggerMode: TooltipTriggerMode.tap,
          child: _buildBadgeChip(badge, isEarned),
        );
      }).toList(),
    );
  }

  Widget _buildBadgeChip(String label, bool earned) {
    final color = earned ? AppTheme.warning : AppTheme.terminalText;
    final bgColor =
        earned ? AppTheme.warning.withValues(alpha: 0.12) : AppTheme.chipBg(context).withValues(alpha: 0.04);
    final borderColor = earned
        ? AppTheme.warning.withValues(alpha: 0.25)
        : AppTheme.textSecColor(context).withValues(alpha: 0.06);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: borderColor),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            earned
                ? Icons.military_tech_rounded
                : Icons.military_tech_outlined,
            size: 16,
            color: color,
          ),
          const SizedBox(width: 6),
          Text(
            label,
            style: AppFonts.firaCode(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: earned
                  ? Colors.white
                  : AppTheme.textSecColor(context).withValues(alpha: 0.35),
            ),
          ),
        ],
      ),
    );
  }
}
