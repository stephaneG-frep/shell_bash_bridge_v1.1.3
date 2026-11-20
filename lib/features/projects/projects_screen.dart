import '../../core/app_fonts.dart';
import 'package:flutter/material.dart';
import '../../shared/widgets/tappable.dart';

import '../../core/theme.dart';
import '../../services/progress_service.dart';
import '../../data/projects.dart';
import '../../models/project.dart';

class ProjectsScreen extends StatefulWidget {
  const ProjectsScreen({super.key});

  @override
  State<ProjectsScreen> createState() => _ProjectsScreenState();
}

class _ProjectsScreenState extends State<ProjectsScreen> {
  String _selectedShell = 'Tous';
  final Set<String> _expandedCards = {};
  final Set<String> _showSolution = {};
  // Initialisé depuis la progression sauvegardée pour survivre aux changements d'écran.
  late final Set<String> _completedProjects = ProgressService.progress.completedProjects.entries
      .where((e) => e.value)
      .map((e) => e.key)
      .toSet();

  static const _shellFilters = ['Tous', 'Bash', 'PowerShell', 'Les deux'];

  static const _shellFilterMap = {
    'Bash': 'bash',
    'PowerShell': 'powershell',
    'Les deux': 'both',
  };

  List<Project> get _filteredProjects {
    return ProjectData.allProjects.where((p) {
      return _selectedShell == 'Tous' ||
          p.shell == _shellFilterMap[_selectedShell];
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final filtered = _filteredProjects;

    return Scaffold(
      backgroundColor: AppTheme.cardBg(context),
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            _buildShellChips(),
            Expanded(
              child: filtered.isEmpty
                  ? _buildEmptyState()
                  : _buildProjectList(filtered),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 16, 20, 0),
      child: Row(
        children: [
          IconButton(tooltip: 'Retour', 
            icon: const Icon(Icons.arrow_back_rounded),
            onPressed: () => Navigator.of(context).pop(),
          ),
          Expanded(
            child: Text(
              'Projets',
              style: AppFonts.firaCode(
                fontSize: 22,
                fontWeight: FontWeight.w700,
                color: AppTheme.textColor(context),
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: AppTheme.bashGreen.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.folder_rounded,
                  size: 14,
                  color: AppTheme.bashGreen,
                ),
                const SizedBox(width: 4),
                Text(
                  '${_completedProjects.length}/${ProjectData.allProjects.length}',
                  style: AppFonts.firaCode(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.bashGreen,
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
      height: 52,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.fromLTRB(20, 10, 20, 0),
        itemCount: _shellFilters.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final shell = _shellFilters[index];
          final isSelected = _selectedShell == shell;
          final color = _shellChipColor(shell);
          return Tappable(
            selected: isSelected,
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

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.folder_off_rounded,
            size: 48,
            color: AppTheme.textSecColor(context).withValues(alpha: 0.2),
          ),
          const SizedBox(height: 12),
          Text(
            'Aucun projet trouvé',
            style: AppFonts.firaCode(
              fontSize: 14,
              color: AppTheme.textSecColor(context).withValues(alpha: 0.5),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProjectList(List<Project> projects) {
    return ListView.builder(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
      itemCount: projects.length,
      itemBuilder: (context, index) {
        final project = projects[index];
        final isExpanded = _expandedCards.contains(project.id);
        final isCompleted = _completedProjects.contains(project.id);
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: _buildProjectCard(project, isExpanded, isCompleted),
        );
      },
    );
  }

  Widget _buildProjectCard(Project project, bool isExpanded, bool isCompleted) {
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
          Tappable(
            onTap: () {
              setState(() {
                if (isExpanded) {
                  _expandedCards.remove(project.id);
                } else {
                  _expandedCards.add(project.id);
                }
              });
            },
            child: Padding(
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
                          project.title,
                          style: AppFonts.firaCode(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: AppTheme.textColor(context),
                          ),
                        ),
                      ),
                      Icon(
                        isExpanded
                            ? Icons.keyboard_arrow_up_rounded
                            : Icons.keyboard_arrow_down_rounded,
                        size: 18,
                        color: AppTheme.textSecColor(context).withValues(alpha: 0.4),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      _buildShellBadge(project.shell),
                      const SizedBox(width: 6),
                      _buildDifficultyBadge(project.difficulty),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Text(
                    project.description,
                    style: AppFonts.firaCode(
                      fontSize: 11,
                      height: 1.4,
                      color: AppTheme.textSecColor(context).withValues(alpha: 0.7),
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (isExpanded) _buildExpandedSection(project, isCompleted),
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

  Widget _buildExpandedSection(Project project, bool isCompleted) {
    final solutionVisible = _showSolution.contains(project.id);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(14, 0, 14, 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildStepsSection(project),
          const SizedBox(height: 10),
          _buildSolutionSection(project, solutionVisible),
          const SizedBox(height: 10),
          _buildExplanationSection(project),
          const SizedBox(height: 12),
          _buildCompleteButton(project, isCompleted),
        ],
      ),
    );
  }

  Widget _buildStepsSection(Project project) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppTheme.terminalBg.withValues(alpha: 0.4),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.route_rounded,
                size: 14,
                color: AppTheme.accent,
              ),
              const SizedBox(width: 6),
              Text(
                'Étapes',
                style: AppFonts.firaCode(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.accent,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          for (var i = 0; i < project.steps.length; i++)
            Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 20,
                    height: 20,
                    margin: const EdgeInsets.only(right: 8, top: 1),
                    decoration: BoxDecoration(
                      color: AppTheme.accent.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Center(
                      child: Text(
                        '${i + 1}',
                        style: AppFonts.firaCode(
                          fontSize: 9,
                          fontWeight: FontWeight.w700,
                          color: AppTheme.accent,
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: Text(
                      project.steps[i],
                      style: AppFonts.firaCode(
                        fontSize: 11,
                        height: 1.4,
                        color: AppTheme.textSecColor(context).withValues(alpha: 0.8),
                      ),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildSolutionSection(Project project, bool isVisible) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppTheme.terminalBg.withValues(alpha: 0.4),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Tappable(
            onTap: () {
              setState(() {
                if (isVisible) {
                  _showSolution.remove(project.id);
                } else {
                  _showSolution.add(project.id);
                }
              });
            },
            child: Padding(
              padding: const EdgeInsets.all(10),
              child: Row(
                children: [
                  Icon(
                    Icons.code_rounded,
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
                  project.solution,
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

  Widget _buildExplanationSection(Project project) {
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
            project.explanation,
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

  Widget _buildCompleteButton(Project project, bool isCompleted) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: isCompleted
            ? null
            : () {
                setState(() {
                  _completedProjects.add(project.id);
                });
                ProgressService.completeProject(project.id);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      'Projet "${project.title}" marqué comme terminé !',
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
          isCompleted ? Icons.check_circle_rounded : Icons.task_alt_rounded,
          size: 16,
        ),
        label: Text(
          isCompleted ? 'Terminé' : 'Marquer comme terminé',
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
