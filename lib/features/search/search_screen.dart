import '../../core/app_fonts.dart';
import 'package:flutter/material.dart';

import '../../services/search_service.dart';
import '../../core/theme.dart';
import '../comparison/comparison_screen.dart';
import '../cheatsheets/cheatsheet_screen.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final _searchController = TextEditingController();
  List<SearchResult> _results = [];
  bool _hasSearched = false;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _performSearch(String query) {
    setState(() {
      _results = SearchService.search(query);
      _hasSearched = query.isNotEmpty;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.cardBg(context),
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            _buildSearchField(),
            Expanded(
              child: _hasSearched
                  ? (_results.isEmpty
                      ? _buildEmptyState()
                      : _buildResultsList())
                  : _buildInitialState(),
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
              'Recherche',
              style: AppFonts.firaCode(
                fontSize: 22,
                fontWeight: FontWeight.w700,
                color: AppTheme.textColor(context),
              ),
            ),
          ),
          if (_results.isNotEmpty)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: AppTheme.accent.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                '${_results.length} résultat${_results.length > 1 ? 's' : ''}',
                style: AppFonts.firaCode(
                  fontSize: 10,
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
        onChanged: _performSearch,
        autofocus: true,
        style: AppFonts.firaCode(
          fontSize: 13,
          color: AppTheme.textColor(context),
        ),
        decoration: InputDecoration(
          hintText: 'Rechercher dans les cours, leçons, commandes, comparaisons...',
          hintStyle: AppFonts.firaCode(
            fontSize: 12,
            color: AppTheme.textSecColor(context).withValues(alpha: 0.4),
          ),
          prefixIcon: Icon(
            Icons.search_rounded,
            color: AppTheme.textSecColor(context),
            size: 20,
          ),
          suffixIcon: _searchController.text.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.clear_rounded, size: 18),
                  color: AppTheme.textSecColor(context).withValues(alpha: 0.5),
                  onPressed: () {
                    _searchController.clear();
                    _performSearch('');
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

  Widget _buildInitialState() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.search_rounded,
            size: 64,
            color: AppTheme.textSecColor(context).withValues(alpha: 0.12),
          ),
          const SizedBox(height: 16),
          Text(
            'Rechercher dans les cours,',
            style: AppFonts.firaCode(
              fontSize: 14,
              color: AppTheme.textSecColor(context).withValues(alpha: 0.4),
            ),
          ),
          Text(
            'leçons, commandes, comparaisons...',
            style: AppFonts.firaCode(
              fontSize: 14,
              color: AppTheme.textSecColor(context).withValues(alpha: 0.4),
            ),
          ),
        ],
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
            'Aucun résultat pour "${_searchController.text}"',
            style: AppFonts.firaCode(
              fontSize: 13,
              color: AppTheme.textSecColor(context).withValues(alpha: 0.5),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Essayez avec d\'autres mots-clés',
            style: AppFonts.firaCode(
              fontSize: 11,
              color: AppTheme.textSecColor(context).withValues(alpha: 0.35),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildResultsList() {
    return ListView.builder(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
      itemCount: _results.length,
      itemBuilder: (context, index) {
        final result = _results[index];
        return Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: _buildResultCard(result),
        );
      },
    );
  }

  Widget _buildResultCard(SearchResult result) {
    return GestureDetector(
      onTap: () => _navigateToResult(result),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          color: AppTheme.chipBg(context).withValues(alpha: 0.06),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: AppTheme.textSecColor(context).withValues(alpha: 0.08),
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  _buildTypeBadge(result.type),
                  const SizedBox(width: 6),
                  _buildShellBadge(result.shell),
                  const Spacer(),
                  Icon(
                    Icons.arrow_forward_ios_rounded,
                    size: 14,
                    color: AppTheme.textSecColor(context).withValues(alpha: 0.3),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Text(
                result.title,
                style: AppFonts.firaCode(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.textColor(context),
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 6),
              Text(
                result.snippet,
                style: AppFonts.firaCode(
                  fontSize: 11,
                  height: 1.4,
                  color: AppTheme.textSecColor(context).withValues(alpha: 0.55),
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTypeBadge(String type) {
    final color = _typeColor(type);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        type,
        style: AppFonts.firaCode(
          fontSize: 9,
          fontWeight: FontWeight.w700,
          color: color,
        ),
      ),
    );
  }

  Widget _buildShellBadge(String shell) {
    final color = _shellColor(shell);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        shell,
        style: AppFonts.firaCode(
          fontSize: 9,
          fontWeight: FontWeight.w700,
          color: color,
        ),
      ),
    );
  }

  Color _typeColor(String type) {
    switch (type) {
      case 'Cours':
        return AppTheme.psBlue;
      case 'Leçon':
        return AppTheme.bashGreen;
      case 'Comparaison':
        return AppTheme.accent;
      case 'Cheat Sheet':
        return AppTheme.warning;
      default:
        return AppTheme.terminalText;
    }
  }

  Color _shellColor(String shell) {
    if (shell.toLowerCase() == 'bash') return AppTheme.bashGreen;
    if (shell.toLowerCase() == 'powershell') return AppTheme.psBlue;
    return AppTheme.accent;
  }

  void _navigateToResult(SearchResult result) {
    switch (result.type) {
      case 'Cours':
      case 'Leçon':
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Ouvrez l\'onglet Cours pour consulter "${result.title}"',
              style: AppFonts.firaCode(fontSize: 11),
            ),
            backgroundColor: AppTheme.bashGreen,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        );
        break;
      case 'Comparaison':
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => const ComparisonScreen(),
          ),
        );
        break;
      case 'Cheat Sheet':
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => const CheatSheetScreen(),
          ),
        );
        break;
    }
  }
}
