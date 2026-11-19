import '../../core/app_fonts.dart';
import 'package:flutter/material.dart';

import '../../core/theme.dart';
import '../../data/comparisons.dart';
import '../../models/comparison.dart';
import '../../services/progress_service.dart';

class ComparisonScreen extends StatefulWidget {
  const ComparisonScreen({super.key});

  @override
  State<ComparisonScreen> createState() => _ComparisonScreenState();
}

class _ComparisonScreenState extends State<ComparisonScreen> {
  final _searchController = TextEditingController();
  String _selectedCategory = 'Tous';
  String _searchQuery = '';
  final Set<String> _expandedCards = {};

  static const _categories = [
    'Tous',
    'Fichiers',
    'Dossiers',
    'Texte',
    'Recherche',
    'Processus',
    'Services',
    'Réseau',
    'Archives',
    'HTTP',
    'JSON',
    'Scripts',
  ];

  static const _categoryFilterMap = {
    'Fichiers': 'fichiers',
    'Dossiers': 'dossiers',
    'Texte': 'texte',
    'Recherche': 'recherche',
    'Processus': 'processus',
    'Services': 'services',
    'Réseau': 'réseau',
    'Archives': 'archives',
    'HTTP': 'réseau',
    'JSON': 'scripts',
    'Scripts': 'scripts',
  };

  List<Comparison> get _filteredComparisons {
    return ComparisonData.allComparisons.where((c) {
      final matchesCategory = _selectedCategory == 'Tous' ||
          c.category == _categoryFilterMap[_selectedCategory];
      final matchesSearch = _searchQuery.isEmpty ||
          c.task.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          c.bashCommand.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          c.psCommand.toLowerCase().contains(_searchQuery.toLowerCase());
      return matchesCategory && matchesSearch;
    }).toList();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final filtered = _filteredComparisons;

    return Scaffold(
      backgroundColor: AppTheme.cardBg(context),
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            _buildSearchField(),
            _buildCategoryChips(),
            Expanded(
              child: filtered.isEmpty
                  ? _buildEmptyState()
                  : _buildComparisonList(filtered),
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
          IconButton(
            icon: const Icon(Icons.arrow_back_rounded),
            onPressed: () => Navigator.of(context).pop(),
          ),
          Expanded(
            child: Text(
              'Comparaisons',
              style: AppFonts.firaCode(
                fontSize: 22,
                fontWeight: FontWeight.w700,
                color: AppTheme.textColor(context),
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppTheme.chipBg(context).withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              '${_filteredComparisons.length}',
              style: AppFonts.firaCode(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: AppTheme.accent,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchField() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
      child: TextField(
        controller: _searchController,
        onChanged: (value) => setState(() => _searchQuery = value),
        style: AppFonts.firaCode(
          fontSize: 13,
          color: AppTheme.textColor(context),
        ),
        decoration: InputDecoration(
          hintText: 'Rechercher une commande...',
          hintStyle: AppFonts.firaCode(
            fontSize: 13,
            color: AppTheme.textSecColor(context).withValues(alpha: 0.4),
          ),
          prefixIcon: Icon(
            Icons.search_rounded,
            color: AppTheme.textSecColor(context),
            size: 20,
          ),
          suffixIcon: _searchQuery.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.clear_rounded, size: 18),
                  color: AppTheme.textSecColor(context).withValues(alpha: 0.5),
                  onPressed: () {
                    _searchController.clear();
                    setState(() => _searchQuery = '');
                  },
                )
              : null,
          filled: true,
          fillColor: AppTheme.terminalBg,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 12,
          ),
        ),
      ),
    );
  }

  Widget _buildCategoryChips() {
    return SizedBox(
      height: 52,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.fromLTRB(20, 10, 20, 0),
        itemCount: _categories.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final cat = _categories[index];
          final isSelected = _selectedCategory == cat;
          return GestureDetector(
            onTap: () => setState(() => _selectedCategory = cat),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
              decoration: BoxDecoration(
                color: isSelected
                    ? AppTheme.accent
                    : AppTheme.terminalBg,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: isSelected
                      ? AppTheme.accent
                      : AppTheme.textSecColor(context).withValues(alpha: 0.15),
                  width: 1,
                ),
              ),
              child: Text(
                cat,
                style: AppFonts.firaCode(
                  fontSize: 11,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                  color: isSelected
                      ? Colors.white
                      : AppTheme.textSecColor(context).withValues(alpha: 0.7),
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
            Icons.search_off_rounded,
            size: 48,
            color: AppTheme.textSecColor(context).withValues(alpha: 0.2),
          ),
          const SizedBox(height: 12),
          Text(
            'Aucune comparaison trouvée',
            style: AppFonts.firaCode(
              fontSize: 14,
              color: AppTheme.textSecColor(context).withValues(alpha: 0.5),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildComparisonList(List<Comparison> comparisons) {
    return ListView.builder(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
      itemCount: comparisons.length,
      itemBuilder: (context, index) {
        final comparison = comparisons[index];
        final isExpanded = _expandedCards.contains(comparison.id);
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: _buildComparisonCard(comparison, isExpanded),
        );
      },
    );
  }

  Widget _buildComparisonCard(Comparison comparison, bool isExpanded) {
    final categoryLabel = _categories.firstWhere(
      (cat) => _categoryFilterMap[cat] == comparison.category,
      orElse: () => comparison.category,
    );

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      decoration: BoxDecoration(
        color: AppTheme.chipBg(context).withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppTheme.textSecColor(context).withValues(alpha: 0.08),
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
                    Expanded(
                      child: Text(
                        comparison.task,
                        style: AppFonts.firaCode(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: AppTheme.textColor(context),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    _buildCategoryBadge(categoryLabel),
                    const SizedBox(width: 8),
                    _buildFavoriteButton(comparison),
                  ],
                ),
                const SizedBox(height: 12),
                _buildCommandComparison(comparison),
                const SizedBox(height: 10),
                _buildDifferencesToggle(comparison, isExpanded),
              ],
            ),
          ),
          if (isExpanded) _buildDifferencesSection(comparison),
        ],
      ),
    );
  }

  Widget _buildFavoriteButton(Comparison comparison) {
    final isFav = ProgressService.isFavorite(comparison.id);
    return Semantics(
      button: true,
      label: isFav ? 'Retirer des favoris' : 'Ajouter aux favoris',
      child: GestureDetector(
        onTap: () async {
          await ProgressService.toggleFavorite(comparison.id);
          if (mounted) setState(() {});
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: isFav
                ? AppTheme.danger.withValues(alpha: 0.15)
                : AppTheme.textSecColor(context).withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            isFav ? Icons.favorite_rounded : Icons.favorite_border_rounded,
            size: 16,
            color: isFav ? AppTheme.danger : AppTheme.textSecColor(context).withValues(alpha: 0.4),
          ),
        ),
      ),
    );
  }

  Widget _buildCategoryBadge(String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: AppTheme.accent.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        label,
        style: AppFonts.firaCode(
          fontSize: 9,
          fontWeight: FontWeight.w600,
          color: AppTheme.accent,
        ),
      ),
    );
  }

  Widget _buildCommandComparison(Comparison comparison) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: _buildTerminalContainer(
            label: 'Bash',
            prefix: '\$',
            command: comparison.bashCommand,
            tint: AppTheme.bashGreen,
          ),
        ),
        const SizedBox(width: 8),
        Icon(
          Icons.swap_horiz_rounded,
          color: AppTheme.textSecColor(context).withValues(alpha: 0.3),
          size: 18,
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _buildTerminalContainer(
            label: 'PowerShell',
            prefix: 'PS>',
            command: comparison.psCommand,
            tint: AppTheme.psBlue,
          ),
        ),
      ],
    );
  }

  Widget _buildTerminalContainer({
    required String label,
    required String prefix,
    required String command,
    required Color tint,
  }) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: tint.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: tint.withValues(alpha: 0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: AppFonts.firaCode(
              fontSize: 9,
              fontWeight: FontWeight.w600,
              color: tint,
            ),
          ),
          const SizedBox(height: 6),
          RichText(
            text: TextSpan(
              children: [
                TextSpan(
                  text: '$prefix ',
                  style: AppFonts.firaCode(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: tint,
                  ),
                ),
                TextSpan(
                  text: command,
                  style: AppFonts.firaCode(
                    fontSize: 11,
                    color: AppTheme.textSecColor(context),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDifferencesToggle(Comparison comparison, bool isExpanded) {
    return GestureDetector(
      onTap: () {
        setState(() {
          if (isExpanded) {
            _expandedCards.remove(comparison.id);
          } else {
            _expandedCards.add(comparison.id);
          }
        });
      },
      child: Row(
        children: [
          Icon(
            isExpanded
                ? Icons.keyboard_arrow_up_rounded
                : Icons.keyboard_arrow_down_rounded,
            size: 18,
            color: AppTheme.accent,
          ),
          const SizedBox(width: 4),
          Text(
            'Différences',
            style: AppFonts.firaCode(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: AppTheme.accent,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDifferencesSection(Comparison comparison) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(14, 0, 14, 14),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppTheme.terminalBg.withValues(alpha: 0.5),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Text(
          comparison.differences,
          style: AppFonts.firaCode(
            fontSize: 11,
            height: 1.5,
            color: AppTheme.textSecColor(context).withValues(alpha: 0.8),
          ),
        ),
      ),
    );
  }
}
