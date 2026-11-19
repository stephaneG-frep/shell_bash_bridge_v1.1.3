import '../../core/app_fonts.dart';
import 'package:flutter/material.dart';
import '../../core/theme.dart';
import '../../data/bash_courses.dart';
import '../../data/powershell_courses.dart';
import '../../models/course.dart';
import '../../services/progress_service.dart';
import '../lessons/lesson_detail_screen.dart';
import '../exercises/exercises_screen.dart';

class CoursesScreen extends StatefulWidget {
  /// 0 = Bash, 1 = PowerShell.
  final int initialTab;
  const CoursesScreen({super.key, this.initialTab = 0});

  @override
  State<CoursesScreen> createState() => _CoursesScreenState();
}

class _CoursesScreenState extends State<CoursesScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this, initialIndex: widget.initialTab.clamp(0, 1));
    ProgressService.notifier.addListener(_onProgressChanged);
  }

  void _onProgressChanged() {
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    ProgressService.notifier.removeListener(_onProgressChanged);
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            _buildTabBar(),
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  _buildCourseList(BashCourseData.allCourses, 'bash'),
                  _buildCourseList(PowerShellCourseData.allCourses, 'powershell'),
                ],
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
          Text(
            'Cours',
            style: AppFonts.firaCode(
              fontSize: 22,
              fontWeight: FontWeight.w700,
              color: AppTheme.textColor(context),
            ),
          ),
          const Spacer(),
          IconButton(
            icon: Icon(Icons.quiz, color: AppTheme.accent),
            onPressed: () {
              Navigator.push(context, MaterialPageRoute(builder: (_) => const ExercisesScreen()));
            },
          ),
        ],
      ),
    );
  }

  Widget _buildTabBar() {
    return Container(
      margin: const EdgeInsets.fromLTRB(20, 12, 20, 0),
      decoration: BoxDecoration(
        color: AppTheme.chipBg(context),
        borderRadius: BorderRadius.circular(12),
      ),
      child: TabBar(
        controller: _tabController,
        indicator: BoxDecoration(
          color: AppTheme.accent.withValues(alpha: 0.2),
          borderRadius: BorderRadius.circular(12),
        ),
        labelColor: AppTheme.accent,
        unselectedLabelColor: AppTheme.textSecColor(context),
        labelStyle: AppFonts.firaCode(fontWeight: FontWeight.w600),
        tabs: const [
          Tab(text: '\$ Bash'),
          Tab(text: 'PS> PowerShell'),
        ],
      ),
    );
  }

  Widget _buildCourseList(List<Course> courses, String shell) {
    final grouped = <int, List<Course>>{};
    for (final c in courses) {
      grouped.putIfAbsent(c.level, () => []).add(c);
    }
    final levels = grouped.keys.toList()..sort();

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: levels.length,
      itemBuilder: (context, index) {
        final level = levels[index];
        final levelCourses = grouped[level]!;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Row(
                children: [
                  Container(
                    width: 4, height: 16,
                    decoration: BoxDecoration(
                      color: _levelColor(level),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    _levelLabel(level),
                    style: AppFonts.firaCode(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: _levelColor(level),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '${levelCourses.length} cours',
                    style: TextStyle(color: AppTheme.textSecColor(context), fontSize: 12),
                  ),
                ],
              ),
            ),
            ...levelCourses.map((course) => _buildCourseCard(course, shell)),
            const SizedBox(height: 8),
          ],
        );
      },
    );
  }

  Widget _buildCourseCard(Course course, String shell) {
    final isBash = shell == 'bash';
    final color = isBash ? AppTheme.accentGreen : AppTheme.accentBlue;
    final icon = isBash ? '\$' : 'PS>';

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () {
          if (course.lessons.isNotEmpty) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => LessonDetailScreen(lesson: course.lessons.first),
              ),
            );
          }
        },
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            children: [
              Container(
                width: 44, height: 44,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Center(
                  child: Text(icon, style: AppFonts.firaCode(color: color, fontWeight: FontWeight.bold)),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      course.title,
                      style: TextStyle(color: AppTheme.textColor(context), fontWeight: FontWeight.w600, fontSize: 14),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      course.description,
                      style: TextStyle(color: AppTheme.textSecColor(context), fontSize: 12),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 6),
                    Text(
                      '${course.lessons.length} leçons',
                      style: TextStyle(color: color, fontSize: 11),
                    ),
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

  String _levelLabel(int level) {
    const labels = ['Découverte', 'Fondamentaux', 'Intermédiaire', 'Scripting', 'Administration', 'Automatisation', 'Avancé', 'Expert'];
    return labels[level < labels.length ? level : 0];
  }

  Color _levelColor(int level) {
    const colors = [AppTheme.accentGreen, AppTheme.accentBlue, AppTheme.accentOrange, AppTheme.accent, AppTheme.danger, AppTheme.accentPurple, AppTheme.warning, AppTheme.danger];
    return colors[level < colors.length ? level : 0];
  }
}
