import 'package:flutter/material.dart';
import '../core/app_settings.dart';
import '../core/theme.dart';
import '../services/storage_service.dart';
import '../features/home/home_screen.dart';
import '../features/courses/courses_screen.dart';
import '../features/lab/lab_screen.dart';
import '../features/challenges/challenges_screen.dart';
import '../features/settings/profile_screen.dart';
import '../features/guide/guide_screen.dart';

final ValueNotifier<ThemeMode> themeNotifier = ValueNotifier(ThemeMode.system);
final ValueNotifier<double> textSizeNotifier = ValueNotifier(1.0);

ThemeMode _parseThemeMode(String mode) {
  switch (mode) {
    case 'light':
      return ThemeMode.light;
    case 'dark':
      return ThemeMode.dark;
    default:
      return ThemeMode.system;
  }
}

void initApp() {
  themeNotifier.value = _parseThemeMode(StorageService.getThemeMode());
  // text_size slider: 10..24, default 14 → scale factor = value / 14
  final stored = StorageService.getTextSize();
  textSizeNotifier.value = stored / 14.0;
  codeSizeNotifier.value = StorageService.getCodeSize();
}

class ShellBashBridgeApp extends StatelessWidget {
  const ShellBashBridgeApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<double>(
      valueListenable: textSizeNotifier,
      builder: (context, scale, _) {
        return ValueListenableBuilder<ThemeMode>(
          valueListenable: themeNotifier,
          builder: (context, mode, _) {
            return MaterialApp(
              title: 'Shell-Bash-Bridge',
              debugShowCheckedModeBanner: false,
              theme: AppTheme.lightTheme,
              darkTheme: AppTheme.darkTheme,
              themeMode: mode,
              builder: (context, child) {
                return MediaQuery(
                  data: MediaQuery.of(context).copyWith(
                    textScaler: TextScaler.linear(scale),
                  ),
                  child: child!,
                );
              },
              home: const MainNavigation(),
            );
          },
        );
      },
    );
  }
}

class MainNavigation extends StatefulWidget {
  const MainNavigation({super.key});

  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    // Premier lancement : ouvrir le guide une fois.
    if (!StorageService.isGuideSeen()) {
      WidgetsBinding.instance.addPostFrameCallback((_) async {
        await StorageService.setGuideSeen(true);
        if (!mounted) return;
        Navigator.of(context).push(MaterialPageRoute(builder: (_) => const GuideScreen()));
      });
    }
  }

  final List<Widget> _screens = const [
    HomeScreen(),
    CoursesScreen(),
    LabScreen(),
    ChallengesScreen(),
    ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // IndexedStack conserve l'état de chaque onglet (terminal du Lab, filtres…).
      body: IndexedStack(index: _currentIndex, children: _screens),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (index) {
          setState(() => _currentIndex = index);
        },
        animationDuration: const Duration(milliseconds: 500),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home),
            label: 'Accueil',
          ),
          NavigationDestination(
            icon: Icon(Icons.menu_book_outlined),
            selectedIcon: Icon(Icons.menu_book),
            label: 'Cours',
          ),
          NavigationDestination(
            icon: Icon(Icons.terminal_outlined),
            selectedIcon: Icon(Icons.terminal),
            label: 'Lab',
          ),
          NavigationDestination(
            icon: Icon(Icons.emoji_events_outlined),
            selectedIcon: Icon(Icons.emoji_events),
            label: 'Défis',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline),
            selectedIcon: Icon(Icons.person),
            label: 'Profil',
          ),
        ],
      ),
    );
  }
}
