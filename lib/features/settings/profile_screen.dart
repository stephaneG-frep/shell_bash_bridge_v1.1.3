import '../../core/app_fonts.dart';
import 'package:flutter/material.dart';
import '../../shared/widgets/tappable.dart';

import '../../app/app.dart';
import '../../core/app_settings.dart';
import '../../core/constants.dart';
import '../../core/theme.dart';
import '../../services/storage_service.dart';
import '../../services/progress_service.dart';
import '../guide/guide_screen.dart';
import '../lab/lab_screen.dart';
import '../progress/progress_screen.dart';
import '../favorites/favorites_screen.dart';
import '../notes/notes_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  String _themeMode = 'system';
  double _textSize = 14.0;
  double _codeSize = 13.0;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  void _loadSettings() {
    setState(() {
      _themeMode = StorageService.getThemeMode();
      _textSize = StorageService.getTextSize();
      _codeSize = StorageService.getCodeSize();
    });
  }

  Future<void> _setThemeMode(String mode) async {
    await StorageService.setThemeMode(mode);
    themeNotifier.value = mode == 'light'
        ? ThemeMode.light
        : mode == 'dark'
            ? ThemeMode.dark
            : ThemeMode.system;
    setState(() => _themeMode = mode);
  }

  Future<void> _setTextSize(double size) async {
    await StorageService.setTextSize(size);
    textSizeNotifier.value = size / 14.0;
    setState(() => _textSize = size);
  }

  Future<void> _setCodeSize(double size) async {
    await StorageService.setCodeSize(size);
    codeSizeNotifier.value = size;
    setState(() => _codeSize = size);
  }

  Future<bool?> _showResetDialog({
    required String title,
    required String message,
    required Color color,
  }) {
    return showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
        backgroundColor: AppTheme.cardBg(context),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        titlePadding: const EdgeInsets.fromLTRB(24, 24, 24, 8),
        contentPadding: const EdgeInsets.fromLTRB(24, 8, 24, 8),
        actionsPadding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.warning_rounded, color: color, size: 22),
            const SizedBox(width: 10),
            Flexible(
              child: Text(
                title,
                style: AppFonts.firaCode(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.textColor(context),
                ),
              ),
            ),
          ],
        ),
        content: SingleChildScrollView(
          child: Text(
            message,
            style: AppFonts.firaCode(
              fontSize: 12,
              color: AppTheme.textSecColor(context).withValues(alpha: 0.8),
              height: 1.5,
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: Text(
              'Annuler',
              style: AppFonts.firaCode(
                fontSize: 12,
                color: AppTheme.textSecColor(context),
              ),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: Text(
              'Réinitialiser',
              style: AppFonts.firaCode(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: color,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _resetProgress() async {
    final confirmed = await _showResetDialog(
      title: 'Réinitialiser la progression',
      message: 'Toute votre progression (cours, exercices, défis, projets, badges et scores) sera définitivement supprimée.\n\nCette action est irréversible.',
      color: AppTheme.danger,
    );

    if (confirmed == true) {
      await ProgressService.resetProgress();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Progression réinitialisée',
              style: AppFonts.firaCode(fontSize: 12),
            ),
            backgroundColor: AppTheme.danger,
          ),
        );
      }
    }
  }

  Future<void> _resetLab() async {
    final confirmed = await _showResetDialog(
      title: 'Réinitialiser le Lab',
      message: 'L\'état du laboratoire simulé (missions, historique de commandes) sera réinitialisé.\n\nCette action est irréversible.',
      color: AppTheme.warning,
    );

    if (confirmed == true) {
      // Ne réinitialise QUE le Lab (avant : clearAll() effaçait toutes les données).
      await StorageService.clearLabState();
      labResetNotifier.value++;
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Lab réinitialisé',
              style: AppFonts.firaCode(fontSize: 12),
            ),
            backgroundColor: AppTheme.warning,
          ),
        );
      }
    }
  }

  void _navigateTo(Widget screen) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => screen),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.cardBg(context),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildProfileHeader(),
              const SizedBox(height: 24),
              _buildLinksSection(),
              const SizedBox(height: 24),
              _buildThemeSection(),
              const SizedBox(height: 16),
              _buildTextSizeSection(),
              const SizedBox(height: 16),
              _buildCodeSizeSection(),
              const SizedBox(height: 24),
              _buildAboutSection(),
              const SizedBox(height: 24),
              _buildDangerZone(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProfileHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppTheme.accent.withValues(alpha: 0.12),
            AppTheme.bashGreen.withValues(alpha: 0.08),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppTheme.accent.withValues(alpha: 0.2),
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppTheme.accent.withValues(alpha: 0.18),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Text(
              r'$',
              style: AppFonts.firaCode(
                fontSize: 26,
                fontWeight: FontWeight.w700,
                color: AppTheme.accent,
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Shell-Bash-Bridge',
                  style: AppFonts.firaCode(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.textColor(context),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Maîtrisez les deux shells',
                  style: AppFonts.firaCode(
                    fontSize: 12,
                    color: AppTheme.textSecColor(context).withValues(alpha: 0.5),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLinksSection() {
    final links = [
      _NavLink(
        title: 'Ma Progression',
        subtitle: 'Cours, exercices et badges',
        icon: Icons.trending_up_rounded,
        color: AppTheme.bashGreen,
        destination: const ProgressScreen(),
      ),
      _NavLink(
        title: 'Mes Favoris',
        subtitle: 'Leçons et commandes sauvegardées',
        icon: Icons.favorite_rounded,
        color: AppTheme.danger,
        destination: const FavoritesScreen(),
      ),
      _NavLink(
        title: 'Mes Notes',
        subtitle: 'Notes personnelles',
        icon: Icons.note_alt_rounded,
        color: AppTheme.accent,
        destination: const NotesScreen(),
      ),
      _NavLink(
        title: 'Guide',
        subtitle: 'Mode d\'emploi et tutoriel',
        icon: Icons.menu_book_rounded,
        color: AppTheme.psBlue,
        destination: const GuideScreen(),
      ),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Accès rapide',
          style: AppFonts.firaCode(
            fontSize: 15,
            fontWeight: FontWeight.w700,
            color: AppTheme.textColor(context),
          ),
        ),
        const SizedBox(height: 12),
        ...links.map((link) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: _buildLinkCard(link),
            )),
      ],
    );
  }

  Widget _buildLinkCard(_NavLink link) {
    return Tappable(
      onTap: () => _navigateTo(link.destination),
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
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: link.color.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(link.icon, color: link.color, size: 18),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    link.title,
                    style: AppFonts.firaCode(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.textColor(context),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    link.subtitle,
                    style: AppFonts.firaCode(
                      fontSize: 10,
                      color: AppTheme.textSecColor(context).withValues(alpha: 0.4),
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios_rounded,
              size: 16,
              color: AppTheme.textSecColor(context).withValues(alpha: 0.3),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildThemeSection() {
    final options = [
      ('system', 'Système', Icons.brightness_auto_rounded),
      ('light', 'Clair', Icons.light_mode_rounded),
      ('dark', 'Sombre', Icons.dark_mode_rounded),
    ];

    return _buildSectionCard(
      title: 'Thème',
      icon: Icons.palette_rounded,
      child: Row(
        children: options.map((opt) {
          final (value, label, icon) = opt;
          final isSelected = _themeMode == value;
          final color = isSelected ? AppTheme.accent : AppTheme.textColor(context);

          return Expanded(
            child: Tappable(
              selected: isSelected,
              onTap: () => _setThemeMode(value),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(vertical: 10),
                margin: const EdgeInsets.symmetric(horizontal: 4),
                decoration: BoxDecoration(
                  color: isSelected
                      ? AppTheme.accent.withValues(alpha: 0.15)
                      : AppTheme.chipBg(context).withValues(alpha: 0.04),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: isSelected
                        ? AppTheme.accent.withValues(alpha: 0.3)
                        : AppTheme.textSecColor(context).withValues(alpha: 0.2),
                  ),
                ),
                child: Column(
                  children: [
                    Icon(
                      icon,
                      size: 18,
                      color: color.withValues(alpha: isSelected ? 1.0 : 0.5),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      label,
                      style: AppFonts.firaCode(
                        fontSize: 10,
                        fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                        color: color.withValues(alpha: isSelected ? 1.0 : 0.5),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildTextSizeSection() {
    return _buildSectionCard(
      title: 'Taille du texte',
      icon: Icons.text_fields_rounded,
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'A',
                style: AppFonts.firaCode(
                  fontSize: 10,
                  color: AppTheme.textSecColor(context).withValues(alpha: 0.4),
                ),
              ),
              Text(
                '${_textSize.toStringAsFixed(0)} pt',
                style: AppFonts.firaCode(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.accent,
                ),
              ),
              Text(
                'A',
                style: AppFonts.firaCode(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.textSecColor(context).withValues(alpha: 0.4),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          SliderTheme(
            data: SliderThemeData(
              activeTrackColor: AppTheme.accent,
              inactiveTrackColor: AppTheme.accent.withValues(alpha: 0.12),
              thumbColor: AppTheme.accent,
              thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 6),
              trackHeight: 4,
              overlayShape: const RoundSliderOverlayShape(overlayRadius: 14),
            ),
            child: Slider(
              value: _textSize,
              min: 10,
              max: 22,
              divisions: 12,
              onChanged: _setTextSize,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCodeSizeSection() {
    return _buildSectionCard(
      title: 'Taille du code',
      icon: Icons.code_rounded,
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'code',
                style: AppFonts.firaCode(
                  fontSize: 9,
                  color: AppTheme.textSecColor(context).withValues(alpha: 0.4),
                ),
              ),
              Text(
                '${_codeSize.toStringAsFixed(0)} pt',
                style: AppFonts.firaCode(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.psBlue,
                ),
              ),
              Text(
                'code',
                style: AppFonts.firaCode(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.textSecColor(context).withValues(alpha: 0.4),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          SliderTheme(
            data: SliderThemeData(
              activeTrackColor: AppTheme.psBlue,
              inactiveTrackColor: AppTheme.psBlue.withValues(alpha: 0.12),
              thumbColor: AppTheme.psBlue,
              thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 6),
              trackHeight: 4,
              overlayShape: const RoundSliderOverlayShape(overlayRadius: 14),
            ),
            child: Slider(
              value: _codeSize,
              min: 9,
              max: 20,
              divisions: 11,
              onChanged: _setCodeSize,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAboutSection() {
    return _buildSectionCard(
      title: 'À propos',
      icon: Icons.info_outline_rounded,
      child: Column(
        children: [
          _buildAboutRow('Application', 'Shell-Bash-Bridge'),
          const SizedBox(height: 8),
          _buildAboutRow('Version', AppConstants.version),
          const SizedBox(height: 8),
          _buildAboutRow('Package', 'com.shellbashbridge.app'),
        ],
      ),
    );
  }

  Widget _buildAboutRow(String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppFonts.firaCode(
            fontSize: 12,
            color: AppTheme.textSecColor(context).withValues(alpha: 0.45),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            value,
            textAlign: TextAlign.right,
            style: AppFonts.firaCode(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: AppTheme.textSecColor(context).withValues(alpha: 0.75),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDangerZone() {
    return _buildSectionCard(
      title: 'Zone de danger',
      icon: Icons.warning_amber_rounded,
      titleColor: AppTheme.danger,
      child: Column(
        children: [
          _buildDangerButton(
            label: 'Réinitialiser la progression',
            subtitle: 'Cours, exercices, défis, badges',
            color: AppTheme.danger,
            onPressed: _resetProgress,
          ),
          const SizedBox(height: 10),
          _buildDangerButton(
            label: 'Réinitialiser le Lab',
            subtitle: 'Missions et historique',
            color: AppTheme.warning,
            onPressed: _resetLab,
          ),
        ],
      ),
    );
  }

  Widget _buildDangerButton({
    required String label,
    required String subtitle,
    required Color color,
    required VoidCallback onPressed,
  }) {
    return Tappable(
      onTap: onPressed,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: color.withValues(alpha: 0.2),
          ),
        ),
        child: Row(
          children: [
            Icon(Icons.restore_rounded, color: color, size: 20),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: AppFonts.firaCode(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: color,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: AppFonts.firaCode(
                      fontSize: 10,
                      color: color.withValues(alpha: 0.6),
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios_rounded,
              size: 14,
              color: color.withValues(alpha: 0.4),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionCard({
    required String title,
    required IconData icon,
    required Widget child,
    Color? titleColor,
  }) {
    final color = titleColor ?? AppTheme.textColor(context);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.cardBg(context),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: (titleColor ?? AppTheme.textSecColor(context)).withValues(alpha: 0.15),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 18, color: color.withValues(alpha: 0.7)),
              const SizedBox(width: 8),
              Text(
                title,
                style: AppFonts.firaCode(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: color,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          child,
        ],
      ),
    );
  }
}

class _NavLink {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
  final Widget destination;

  const _NavLink({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
    required this.destination,
  });
}
