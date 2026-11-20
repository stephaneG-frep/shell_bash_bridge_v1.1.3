import '../../core/app_fonts.dart';
import 'package:flutter/material.dart';
import '../../shared/widgets/tappable.dart';

import '../../data/cheat_sheets.dart';
import '../../core/theme.dart';
import '../../models/cheat_sheet.dart';
import '../../services/progress_service.dart';

class CheatSheetScreen extends StatefulWidget {
  /// Catégories proposées en filtre (toute fiche doit en utiliser une).
  static const categories = [
    'Tous',
    'Navigation',
    'Fichiers',
    'Dossiers',
    'Texte',
    'Recherche',
    'Permissions',
    'Utilisateurs',
    'Processus',
    'Services',
    'Réseau',
    'SSH',
    'Archives',
    'HTTP',
    'Variables',
    'Conditions',
    'Boucles',
    'Fonctions',
    'JSON',
    'CSV',
    'Administration',
  ];

  /// Niveaux de danger reconnus (couleur et filtre).
  static const dangerLevels = ['SAFE', 'WARNING', 'SENSITIVE', 'DESTRUCTIVE'];

  const CheatSheetScreen({super.key});

  @override
  State<CheatSheetScreen> createState() => _CheatSheetScreenState();
}

class _CheatSheetScreenState extends State<CheatSheetScreen> {
  final _searchController = TextEditingController();
  String _searchQuery = '';
  String _selectedCategory = 'Tous';
  String _selectedShell = 'Tous';
  String _selectedDanger = 'Tous';

  static const _categories = CheatSheetScreen.categories;

  static const _shellFilters = ['Tous', 'Bash', 'PowerShell'];
  static const _dangerFilters = ['Tous', ...CheatSheetScreen.dangerLevels];

  List<CheatSheet> get _filteredSheets {
    return CheatSheetData.allSheets.where((s) {
      final matchesCategory =
          _selectedCategory == 'Tous' || s.category == _selectedCategory;
      final matchesShell = _selectedShell == 'Tous' ||
          s.shell.toLowerCase() == _selectedShell.toLowerCase();
      final matchesDanger =
          _selectedDanger == 'Tous' || s.danger == _selectedDanger;
      final matchesSearch = _searchQuery.isEmpty ||
          s.command.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          s.description.toLowerCase().contains(_searchQuery.toLowerCase());
      return matchesCategory && matchesShell && matchesDanger && matchesSearch;
    }).toList();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final filtered = _filteredSheets;

    return Scaffold(
      backgroundColor: AppTheme.cardBg(context),
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            _buildSearchField(),
            _buildShellChips(),
            _buildDangerChips(),
            _buildCategoryChips(),
            Expanded(
              child: filtered.isEmpty
                  ? _buildEmptyState()
                  : _buildCheatsheetList(filtered),
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
              'Cheat Sheets',
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
              '${_filteredSheets.length}',
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
              ? IconButton(tooltip: 'Effacer la recherche', 
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

  Widget _buildShellChips() {
    return SizedBox(
      height: 48,
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

  Widget _buildDangerChips() {
    return SizedBox(
      height: 44,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.fromLTRB(20, 6, 20, 0),
        itemCount: _dangerFilters.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final danger = _dangerFilters[index];
          final isSelected = _selectedDanger == danger;
          final color = _dangerChipColor(danger);
          return Tappable(
            selected: isSelected,
            onTap: () => setState(() => _selectedDanger = danger),
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
                danger,
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

  Widget _buildCategoryChips() {
    return SizedBox(
      height: 48,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
        itemCount: _categories.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final cat = _categories[index];
          final isSelected = _selectedCategory == cat;
          return Tappable(
            selected: isSelected,
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
            'Aucune commande trouvée',
            style: AppFonts.firaCode(
              fontSize: 14,
              color: AppTheme.textSecColor(context).withValues(alpha: 0.5),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCheatsheetList(List<CheatSheet> sheets) {
    return ListView.builder(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
      itemCount: sheets.length,
      itemBuilder: (context, index) {
        final sheet = sheets[index];
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: _buildCheatsheetCard(sheet),
        );
      },
    );
  }

  Widget _buildCheatsheetCard(CheatSheet sheet) {
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
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    sheet.command,
                    style: AppFonts.firaCode(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: AppTheme.textColor(context),
                    ),
                  ),
                ),
                _buildShellBadge(sheet.shell),
                const SizedBox(width: 6),
                _buildDangerBadge(sheet.danger),
                const SizedBox(width: 6),
                _buildFavoriteButton(sheet),
              ],
            ),
            const SizedBox(height: 10),
            _buildTerminalBlock(sheet.syntax, prefix: '\$'),
            const SizedBox(height: 10),
            Text(
              sheet.description,
              style: AppFonts.firaCode(
                fontSize: 11,
                height: 1.4,
                color: AppTheme.textSecColor(context).withValues(alpha: 0.7),
              ),
            ),
            const SizedBox(height: 10),
            _buildTerminalBlock(sheet.example, prefix: '→'),
            const SizedBox(height: 10),
            Row(
              children: [
                _buildLevelBadge(sheet.level),
                const Spacer(),
                if (sheet.equivalent.isNotEmpty) _buildEquivalentBadge(sheet),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildShellBadge(String shell) {
    final isBash = shell.toLowerCase() == 'bash';
    final color = isBash ? AppTheme.bashGreen : AppTheme.psBlue;
    final label = isBash ? 'Bash' : 'PowerShell';

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

  Widget _buildDangerBadge(String danger) {
    final color = _dangerColor(danger);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        danger,
        style: AppFonts.firaCode(
          fontSize: 9,
          fontWeight: FontWeight.w600,
          color: color,
        ),
      ),
    );
  }

  Widget _buildLevelBadge(String level) {
    final color = _levelColor(level);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        level,
        style: AppFonts.firaCode(
          fontSize: 9,
          fontWeight: FontWeight.w600,
          color: color,
        ),
      ),
    );
  }

  Widget _buildEquivalentBadge(CheatSheet sheet) {
    final isBash = sheet.shell.toLowerCase() == 'bash';
    final eqColor = isBash ? AppTheme.psBlue : AppTheme.bashGreen;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
      decoration: BoxDecoration(
        color: eqColor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(
          color: eqColor.withValues(alpha: 0.2),
        ),
      ),
      child: Text(
        '${isBash ? "PS" : "Bash"}: ${sheet.equivalent}',
        style: AppFonts.firaCode(
          fontSize: 9,
          fontWeight: FontWeight.w500,
          color: eqColor.withValues(alpha: 0.8),
        ),
      ),
    );
  }

  Widget _buildFavoriteButton(CheatSheet sheet) {
    final isFav = ProgressService.isFavorite(sheet.id);
    return Tappable(
      label: isFav ? 'Retirer des favoris' : 'Ajouter aux favoris',
      onTap: () async {
        await ProgressService.toggleFavorite(sheet.id);
        setState(() {});
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
    );
  }

  Widget _buildTerminalBlock(String text, {required String prefix}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: AppTheme.terminalBg,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: AppTheme.textSecColor(context).withValues(alpha: 0.1),
        ),
      ),
      child: RichText(
        text: TextSpan(
          children: [
            TextSpan(
              text: '$prefix ',
              style: AppFonts.firaCode(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: AppTheme.accent,
              ),
            ),
            TextSpan(
              text: text,
              style: AppFonts.firaCode(
                fontSize: 12,
                color: AppTheme.textSecColor(context),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _shellChipColor(String shell) {
    switch (shell) {
      case 'Bash':
        return AppTheme.bashGreen;
      case 'PowerShell':
        return AppTheme.psBlue;
      default:
        return AppTheme.accent;
    }
  }

  Color _dangerChipColor(String danger) {
    switch (danger) {
      case 'SAFE':
        return AppTheme.safe;
      case 'WARNING':
        return AppTheme.warning;
      case 'SENSITIVE':
        return AppTheme.danger;
      case 'DESTRUCTIVE':
        return const Color(0xFF8B0000);
      default:
        return AppTheme.terminalText;
    }
  }

  Color _dangerColor(String danger) {
    switch (danger) {
      case 'SAFE':
        return AppTheme.safe;
      case 'WARNING':
        return AppTheme.warning;
      case 'SENSITIVE':
        return AppTheme.danger;
      case 'DESTRUCTIVE':
        return const Color(0xFF8B0000);
      default:
        return AppTheme.terminalText;
    }
  }

  Color _levelColor(String level) {
    switch (level.toLowerCase()) {
      case 'débutant':
      case 'beginner':
        return AppTheme.safe;
      case 'intermédiaire':
      case 'intermediate':
        return AppTheme.psBlue;
      case 'avancé':
      case 'advanced':
        return AppTheme.warning;
      case 'expert':
        return AppTheme.accent;
      default:
        return AppTheme.terminalText;
    }
  }
}
