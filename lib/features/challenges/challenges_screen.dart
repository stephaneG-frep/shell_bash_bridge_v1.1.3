import '../../core/app_fonts.dart';
import 'package:flutter/material.dart';

import '../../core/theme.dart';
import '../../services/progress_service.dart';
import '../projects/projects_screen.dart';
import '../../data/challenges.dart';
import '../../models/challenge.dart';

class ChallengesScreen extends StatefulWidget {
  const ChallengesScreen({super.key});

  @override
  State<ChallengesScreen> createState() => _ChallengesScreenState();
}

class _ChallengesScreenState extends State<ChallengesScreen> {
  String _selectedShell = 'Tous';
  String _selectedDifficulty = 'Tous';
  final Set<String> _expandedCards = {};
  final Set<String> _showSolution = {};
  final Set<String> _showHints = {};
  // Initialisé depuis la progression sauvegardée pour survivre aux changements d'écran.
  late final Set<String> _completedChallenges = ProgressService.progress.completedChallenges.entries
      .where((e) => e.value)
      .map((e) => e.key)
      .toSet();

  static const _shellFilters = ['Tous', 'Bash', 'PowerShell', 'Les deux'];
  static const _difficultyFilters = [
    'Tous',
    'Facile',
    'Moyen',
    'Difficile',
    'Expert',
  ];

  static const _shellFilterMap = {
    'Bash': 'bash',
    'PowerShell': 'powershell',
    'Les deux': 'both',
  };

  List<Challenge> get _filteredChallenges {
    return ChallengeData.allChallenges.where((c) {
      final matchesShell = _selectedShell == 'Tous' ||
          c.shell == _shellFilterMap[_selectedShell];
      final matchesDifficulty =
          _selectedDifficulty == 'Tous' || c.difficulty == _selectedDifficulty;
      return matchesShell && matchesDifficulty;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final filtered = _filteredChallenges;

    return Scaffold(
      backgroundColor: AppTheme.cardBg(context),
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            _buildShellChips(),
            _buildDifficultyChips(),
            Expanded(
              child: filtered.isEmpty
                  ? _buildEmptyState()
                  : _buildChallengeList(filtered),
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
          Expanded(
            child: Text(
              'Défis',
              style: AppFonts.firaCode(
                fontSize: 22,
                fontWeight: FontWeight.w700,
                color: AppTheme.textColor(context),
              ),
            ),
          ),
          TextButton.icon(
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const ProjectsScreen()),
            ),
            icon: const Icon(Icons.build_circle_outlined, size: 16),
            label: Text('Projets', style: AppFonts.firaCode(fontSize: 12, fontWeight: FontWeight.w600)),
            style: TextButton.styleFrom(foregroundColor: AppTheme.accent),
          ),
          const SizedBox(width: 6),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: AppTheme.accent.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.emoji_events_rounded,
                  size: 14,
                  color: AppTheme.warning,
                ),
                const SizedBox(width: 4),
                Text(
                  '${_completedChallenges.length}/${ChallengeData.allChallenges.length}',
                  style: AppFonts.firaCode(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.warning,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildShellChips() {
    return SizedBox(
      height: 48,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
        itemCount: _shellFilters.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final shell = _shellFilters[index];
          final isSelected = _selectedShell == shell;
          final color = _shellChipColor(shell);
          return GestureDetector(
            onTap: () => setState(() => _selectedShell = shell),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
              decoration: BoxDecoration(
                color: isSelected
                    ? color.withValues(alpha: 0.2)
                    : AppTheme.terminalBg,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: isSelected
                      ? color.withValues(alpha: 0.5)
                      : AppTheme.textSecColor(context).withValues(alpha: 0.12),
                ),
              ),
              child: Text(
                shell,
                style: AppFonts.firaCode(
                  fontSize: 11,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                  color: isSelected
                      ? color
                      : AppTheme.textSecColor(context).withValues(alpha: 0.6),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildDifficultyChips() {
    return SizedBox(
      height: 44,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.fromLTRB(20, 6, 20, 0),
        itemCount: _difficultyFilters.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final diff = _difficultyFilters[index];
          final isSelected = _selectedDifficulty == diff;
          final color = _difficultyColor(diff);
          return GestureDetector(
            onTap: () => setState(() => _selectedDifficulty = diff),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
              decoration: BoxDecoration(
                color: isSelected
                    ? color.withValues(alpha: 0.15)
                    : AppTheme.terminalBg,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: isSelected
                      ? color.withValues(alpha: 0.4)
                      : AppTheme.textSecColor(context).withValues(alpha: 0.1),
                ),
              ),
              child: Text(
                diff,
                style: AppFonts.firaCode(
                  fontSize: 10,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                  color: isSelected
                      ? color
                      : AppTheme.textSecColor(context).withValues(alpha: 0.5),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.extension_off_rounded,
            size: 48,
            color: AppTheme.textSecColor(context).withValues(alpha: 0.2),
          ),
          const SizedBox(height: 12),
          Text(
            'Aucun défi trouvé',
            style: AppFonts.firaCode(
              fontSize: 14,
              color: AppTheme.textSecColor(context).withValues(alpha: 0.5),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChallengeList(List<Challenge> challenges) {
    return ListView.builder(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
      itemCount: challenges.length,
      itemBuilder: (context, index) {
        final challenge = challenges[index];
        final isExpanded = _expandedCards.contains(challenge.id);
        final isCompleted = _completedChallenges.contains(challenge.id);
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: _buildChallengeCard(challenge, isExpanded, isCompleted),
        );
      },
    );
  }

  Widget _buildChallengeCard(
      Challenge challenge, bool isExpanded, bool isCompleted) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      decoration: BoxDecoration(
        color: AppTheme.chipBg(context).withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isCompleted
              ? AppTheme.safe.withValues(alpha: 0.4)
              : AppTheme.textSecColor(context).withValues(alpha: 0.08),
          width: isCompleted ? 1.5 : 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    if (isCompleted)
                      const Padding(
                        padding: EdgeInsets.only(right: 6),
                        child: Icon(
                          Icons.check_circle_rounded,
                          size: 16,
                          color: AppTheme.safe,
                        ),
                      ),
                    Expanded(
                      child: Text(
                        challenge.title,
                        style: AppFonts.firaCode(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: AppTheme.textColor(context),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    _buildShellBadge(challenge.shell),
                    const SizedBox(width: 6),
                    _buildDifficultyBadge(challenge.difficulty),
                    const Spacer(),
                    _buildPointsBadge(challenge.points),
                  ],
                ),
                const SizedBox(height: 10),
                Text(
                  challenge.objective,
                  style: AppFonts.firaCode(
                    fontSize: 11,
                    height: 1.4,
                    color: AppTheme.textSecColor(context).withValues(alpha: 0.7),
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: () {
                          setState(() {
                            if (isExpanded) {
                              _expandedCards.remove(challenge.id);
                            } else {
                              _expandedCards.add(challenge.id);
                            }
                          });
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          decoration: BoxDecoration(
                            color: AppTheme.accent.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                isExpanded
                                    ? Icons.keyboard_arrow_up_rounded
                                    : Icons.keyboard_arrow_down_rounded,
                                size: 16,
                                color: AppTheme.accent,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                'Voir le défi',
                                style: AppFonts.firaCode(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                  color: AppTheme.accent,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          if (isExpanded) _buildExpandedSection(challenge, isCompleted),
        ],
      ),
    );
  }

  Widget _buildShellBadge(String shell) {
    final label = shell == 'both' ? 'Les deux' : shell.toUpperCase();
    final color = _shellColor(shell);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        label,
        style: AppFonts.firaCode(
          fontSize: 9,
          fontWeight: FontWeight.w700,
          color: color,
        ),
      ),
    );
  }

  Widget _buildDifficultyBadge(String difficulty) {
    final color = _difficultyColor(difficulty);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        difficulty,
        style: AppFonts.firaCode(
          fontSize: 9,
          fontWeight: FontWeight.w600,
          color: color,
        ),
      ),
    );
  }

  Widget _buildPointsBadge(int points) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
      decoration: BoxDecoration(
        color: AppTheme.warning.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.star_rounded,
            size: 11,
            color: AppTheme.warning,
          ),
          const SizedBox(width: 3),
          Text(
            '$points pts',
            style: AppFonts.firaCode(
              fontSize: 9,
              fontWeight: FontWeight.w600,
              color: AppTheme.warning,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildExpandedSection(Challenge challenge, bool isCompleted) {
    final hintsVisible = _showHints.contains(challenge.id);
    final solutionVisible = _showSolution.contains(challenge.id);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(14, 0, 14, 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHintsSection(challenge, hintsVisible),
          const SizedBox(height: 8),
          _buildSolutionSection(challenge, solutionVisible),
          const SizedBox(height: 8),
          _buildExplanationSection(challenge),
          const SizedBox(height: 12),
          _buildCompleteButton(challenge, isCompleted),
        ],
      ),
    );
  }

  Widget _buildHintsSection(Challenge challenge, bool isVisible) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppTheme.terminalBg.withValues(alpha: 0.4),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          GestureDetector(
            onTap: () {
              setState(() {
                if (isVisible) {
                  _showHints.remove(challenge.id);
                } else {
                  _showHints.add(challenge.id);
                }
              });
            },
            child: Padding(
              padding: const EdgeInsets.all(10),
              child: Row(
                children: [
                  Icon(
                    Icons.lightbulb_outline_rounded,
                    size: 14,
                    color: AppTheme.warning,
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      'Indices (${challenge.hints.length})',
                      style: AppFonts.firaCode(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.warning,
                      ),
                    ),
                  ),
                  Icon(
                    isVisible
                        ? Icons.keyboard_arrow_up_rounded
                        : Icons.keyboard_arrow_down_rounded,
                    size: 16,
                    color: AppTheme.warning.withValues(alpha: 0.7),
                  ),
                ],
              ),
            ),
          ),
          if (isVisible)
            Padding(
              padding: const EdgeInsets.fromLTRB(10, 0, 10, 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  for (var i = 0; i < challenge.hints.length; i++)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 4),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '${i + 1}. ',
                            style: AppFonts.firaCode(
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                              color: AppTheme.warning.withValues(alpha: 0.7),
                            ),
                          ),
                          Expanded(
                            child: Text(
                              challenge.hints[i],
                              style: AppFonts.firaCode(
                                fontSize: 10,
                                color: AppTheme.textSecColor(context)
                                    .withValues(alpha: 0.7),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildSolutionSection(Challenge challenge, bool isVisible) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppTheme.terminalBg.withValues(alpha: 0.4),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          GestureDetector(
            onTap: () {
              if (isVisible) {
                setState(() => _showSolution.remove(challenge.id));
              } else {
                _showSolutionWithConfirmation(challenge);
              }
            },
            child: Padding(
              padding: const EdgeInsets.all(10),
              child: Row(
                children: [
                  Icon(
                    Icons.key_rounded,
                    size: 14,
                    color: AppTheme.bashGreen,
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      'Solution',
                      style: AppFonts.firaCode(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.bashGreen,
                      ),
                    ),
                  ),
                  Icon(
                    isVisible
                        ? Icons.keyboard_arrow_up_rounded
                        : Icons.keyboard_arrow_down_rounded,
                    size: 16,
                    color: AppTheme.bashGreen.withValues(alpha: 0.7),
                  ),
                ],
              ),
            ),
          ),
          if (isVisible)
            Padding(
              padding: const EdgeInsets.fromLTRB(10, 0, 10, 10),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppTheme.bashGreen.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: AppTheme.bashGreen.withValues(alpha: 0.2),
                  ),
                ),
                child: Text(
                  challenge.solution,
                  style: AppFonts.firaCode(
                    fontSize: 11,
                    height: 1.5,
                    color: AppTheme.textSecColor(context),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  void _showSolutionWithConfirmation(Challenge challenge) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppTheme.cardBg(context),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: Text(
          'Afficher la solution ?',
          style: AppFonts.firaCode(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: AppTheme.textColor(context),
          ),
        ),
        content: Text(
          'Essayez de résoudre le défi avant de consulter la solution !',
          style: AppFonts.firaCode(
            fontSize: 12,
            color: AppTheme.textSecColor(context).withValues(alpha: 0.7),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(
              'Annuler',
              style: AppFonts.firaCode(
                fontSize: 12,
                color: AppTheme.textSecColor(context).withValues(alpha: 0.5),
              ),
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              setState(() => _showSolution.add(challenge.id));
            },
            child: Text(
              'Voir la solution',
              style: AppFonts.firaCode(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: AppTheme.bashGreen,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildExplanationSection(Challenge challenge) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: AppTheme.psBlue.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.info_outline_rounded,
                size: 14,
                color: AppTheme.psBlue,
              ),
              const SizedBox(width: 6),
              Text(
                'Explication',
                style: AppFonts.firaCode(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.psBlue,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            challenge.explanation,
            style: AppFonts.firaCode(
              fontSize: 10,
              height: 1.5,
              color: AppTheme.textSecColor(context).withValues(alpha: 0.75),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCompleteButton(Challenge challenge, bool isCompleted) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: isCompleted
            ? null
            : () {
                setState(() {
                  _completedChallenges.add(challenge.id);
                });
                ProgressService.completeChallenge(challenge.id);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      'Défi "${challenge.title}" marqué comme relevé !',
                      style: AppFonts.firaCode(fontSize: 11),
                    ),
                    backgroundColor: AppTheme.safe,
                    behavior: SnackBarBehavior.floating,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                );
              },
        icon: Icon(
          isCompleted ? Icons.check_circle_rounded : Icons.flag_rounded,
          size: 16,
        ),
        label: Text(
          isCompleted ? 'Relevé' : 'Marquer comme relevé',
          style: AppFonts.firaCode(
            fontSize: 11,
            fontWeight: FontWeight.w600,
          ),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor:
              isCompleted ? AppTheme.safe.withValues(alpha: 0.2) : AppTheme.accent,
          disabledBackgroundColor: AppTheme.safe.withValues(alpha: 0.2),
          disabledForegroundColor: AppTheme.safe,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 10),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      ),
    );
  }

  Color _shellColor(String shell) {
    switch (shell) {
      case 'bash':
        return AppTheme.bashGreen;
      case 'powershell':
        return AppTheme.psBlue;
      case 'both':
        return AppTheme.accent;
      default:
        return AppTheme.terminalText;
    }
  }

  Color _shellChipColor(String shell) {
    switch (shell) {
      case 'Bash':
        return AppTheme.bashGreen;
      case 'PowerShell':
        return AppTheme.psBlue;
      case 'Les deux':
        return AppTheme.accent;
      default:
        return AppTheme.terminalText;
    }
  }

  Color _difficultyColor(String difficulty) {
    switch (difficulty) {
      case 'Facile':
        return AppTheme.safe;
      case 'Moyen':
        return AppTheme.warning;
      case 'Difficile':
        return AppTheme.danger;
      case 'Expert':
        return AppTheme.accent;
      default:
        return AppTheme.terminalText;
    }
  }
}
