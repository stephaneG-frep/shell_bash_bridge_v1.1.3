import '../../core/app_fonts.dart';
import 'package:flutter/material.dart';

import '../../services/progress_service.dart';
import '../../data/bash_courses.dart';
import '../../data/powershell_courses.dart';
import '../../data/comparisons.dart';
import '../../data/cheat_sheets.dart';
import '../../core/theme.dart';

enum _FavType { lesson, comparison, cheatSheet }

class _FavoriteItem {
  final String id;
  final String title;
  final String shell;
  final String subtitle;
  final _FavType type;
  final Widget Function() destinationBuilder;

  const _FavoriteItem({
    required this.id,
    required this.title,
    required this.shell,
    required this.subtitle,
    required this.type,
    required this.destinationBuilder,
  });
}

class FavoritesScreen extends StatefulWidget {
  const FavoritesScreen({super.key});

  @override
  State<FavoritesScreen> createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends State<FavoritesScreen> {
  List<_FavoriteItem> _favorites = [];

  @override
  void initState() {
    super.initState();
    _loadFavorites();
  }

  void _loadFavorites() {
    final favIds = ProgressService.progress.favorites;
    final items = <_FavoriteItem>[];

    for (final id in favIds) {
      final item = _resolveFavorite(id);
      if (item != null) {
        items.add(item);
      }
    }

    setState(() => _favorites = items);
  }

  _FavoriteItem? _resolveFavorite(String id) {
    for (final course in BashCourseData.allCourses) {
      for (final lesson in course.lessons) {
        if (lesson.id == id) {
          return _FavoriteItem(
            id: id,
            title: lesson.title,
            shell: 'Bash',
            subtitle: lesson.category,
            type: _FavType.lesson,
            destinationBuilder: () => _buildLessonNotFound(lesson.title),
          );
        }
      }
    }

    for (final course in PowerShellCourseData.allCourses) {
      for (final lesson in course.lessons) {
        if (lesson.id == id) {
          return _FavoriteItem(
            id: id,
            title: lesson.title,
            shell: 'PowerShell',
            subtitle: lesson.category,
            type: _FavType.lesson,
            destinationBuilder: () => _buildLessonNotFound(lesson.title),
          );
        }
      }
    }

    for (final comp in ComparisonData.allComparisons) {
      if (comp.id == id) {
        return _FavoriteItem(
          id: id,
          title: comp.task,
          shell: 'Bash ↔ PowerShell',
          subtitle: comp.category,
          type: _FavType.comparison,
          destinationBuilder: () => _buildLessonNotFound(comp.task),
        );
      }
    }

    for (final sheet in CheatSheetData.allSheets) {
      if (sheet.id == id) {
        return _FavoriteItem(
          id: id,
          title: sheet.command,
          shell: sheet.shell == 'bash' ? 'Bash' : 'PowerShell',
          subtitle: sheet.category,
          type: _FavType.cheatSheet,
          destinationBuilder: () => _buildLessonNotFound(sheet.command),
        );
      }
    }

    return null;
  }

  Widget _buildLessonNotFound(String title) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(title),
      ),
      body: const Center(child: Text('Détails non disponibles')),
    );
  }

  Future<void> _removeFavorite(String id) async {
    await ProgressService.toggleFavorite(id);
    _loadFavorites();
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Retiré des favoris',
            style: AppFonts.firaCode(fontSize: 12),
          ),
          backgroundColor: AppTheme.danger,
          duration: const Duration(seconds: 1),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.cardBg(context),
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            Expanded(
              child: _favorites.isEmpty
                  ? _buildEmptyState()
                  : _buildFavoritesList(),
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
              'Mes Favoris',
              style: AppFonts.firaCode(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: AppTheme.textColor(context),
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: AppTheme.accent.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              '${_favorites.length}',
              style: AppFonts.firaCode(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: AppTheme.accent,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppTheme.accent.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.favorite_border_rounded,
                size: 48,
                color: AppTheme.accent.withValues(alpha: 0.5),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'Aucun favori enregistré.',
              style: AppFonts.firaCode(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AppTheme.textSecColor(context),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'Parcourez les cours et ajoutez des favoris !',
              style: AppFonts.firaCode(
                fontSize: 12,
                color: AppTheme.textSecColor(context).withValues(alpha: 0.5),
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFavoritesList() {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      itemCount: _favorites.length,
      itemBuilder: (context, index) {
        final item = _favorites[index];
        return Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: _buildFavoriteCard(item),
        );
      },
    );
  }

  Widget _buildFavoriteCard(_FavoriteItem item) {
    final (typeLabel, typeColor, typeIcon) = switch (item.type) {
      _FavType.lesson => ('Cours', AppTheme.bashGreen, Icons.menu_book_rounded),
      _FavType.comparison => ('Comparaison', AppTheme.accent, Icons.compare_arrows_rounded),
      _FavType.cheatSheet => ('Cheat Sheet', AppTheme.warning, Icons.description_rounded),
    };

    final shellColor = item.shell == 'Bash'
        ? AppTheme.bashGreen
        : item.shell == 'PowerShell'
            ? AppTheme.psBlue
            : AppTheme.accent;

    return GestureDetector(
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => item.destinationBuilder()),
        );
      },
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppTheme.chipBg(context).withValues(alpha: 0.06),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: AppTheme.textSecColor(context).withValues(alpha: 0.08),
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: typeColor.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(typeIcon, color: typeColor, size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.title,
                    style: AppFonts.firaCode(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.textColor(context),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: shellColor.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          item.shell,
                          style: AppFonts.firaCode(
                            fontSize: 9,
                            fontWeight: FontWeight.w600,
                            color: shellColor,
                          ),
                        ),
                      ),
                      const SizedBox(width: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: typeColor.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          typeLabel,
                          style: AppFonts.firaCode(
                            fontSize: 9,
                            color: typeColor.withValues(alpha: 0.8),
                          ),
                        ),
                      ),
                      if (item.subtitle.isNotEmpty) ...[
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            item.subtitle,
                            style: AppFonts.firaCode(
                              fontSize: 9,
                              color: AppTheme.textSecColor(context).withValues(alpha: 0.4),
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
            IconButton(
              icon: const Icon(Icons.favorite_rounded, size: 20),
              color: AppTheme.danger,
              onPressed: () => _removeFavorite(item.id),
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
            ),
          ],
        ),
      ),
    );
  }
}
