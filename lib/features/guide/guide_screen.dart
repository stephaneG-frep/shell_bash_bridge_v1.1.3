import '../../core/app_fonts.dart';
import 'package:flutter/material.dart';
import '../../shared/widgets/tappable.dart';

import '../../core/theme.dart';

class GuideScreen extends StatefulWidget {
  const GuideScreen({super.key});

  @override
  State<GuideScreen> createState() => _GuideScreenState();
}

class _GuideScreenState extends State<GuideScreen> {
  final Set<int> _expandedSections = {};

  static const _sections = [
    _GuideSection(
      title: 'Bienvenue',
      icon: Icons.waving_hand_rounded,
      content:
          'Shell-Bash-Bridge est une application éducative conçue pour vous aider à '
          'maîtriser les deux shells principaux : Bash (Linux/macOS) et PowerShell (Windows). '
          'Que vous soyez débutant ou avancé, cette app vous offre 135 leçons réparties en cours '
          'sur 8 niveaux, un laboratoire simulé, des comparaisons côte à côte, des cheat sheets, '
          'des exercices, des défis, des projets et un suivi de progression détaillé.\n\n'
          'Tout fonctionne hors ligne et vos données restent sur votre appareil.\n\n'
          'Objectif : devenir à l\'aise avec les deux shells et savoir naviguer '
          'efficacement entre les deux environnements.',
    ),
    _GuideSection(
      title: 'Accueil',
      icon: Icons.home_rounded,
      content:
          'L\'écran d\'accueil est votre tableau de bord principal. Il affiche :\n\n'
          '• Votre progression globale (Bash et PowerShell)\n'
          '• Les parcours Bash et PowerShell, qui ouvrent directement le bon onglet des cours\n'
          '• Le comparateur Bash ↔ PowerShell\n'
          '• Vos statistiques : leçons terminées, exercices réussis, défis relevés, badges obtenus\n'
          '• Les actions rapides vers Cheat Sheets, Recherche, Exercices, Projets et Guide\n\n'
          'Les statistiques se mettent à jour automatiquement dès que vous progressez.',
    ),
    _GuideSection(
      title: 'Cours',
      icon: Icons.menu_book_rounded,
      content:
          'Les cours sont organisés par shell (onglets Bash et PowerShell) et par niveau :\n\n'
          '• Découverte : premiers pas dans le terminal\n'
          '• Fondamentaux : commandes du quotidien, pipeline\n'
          '• Intermédiaire : pipes, redirections, recherche, formats de données\n'
          '• Scripting : variables, conditions, boucles, fonctions\n'
          '• Administration : utilisateurs, processus, services, réseau, archives\n'
          '• Automatisation : JSON, CSV, sauvegardes planifiées, jobs, Git\n'
          '• Avancé : débogage, parallélisme, fonctions avancées\n'
          '• Expert : performance, tests, sécurité, DevOps\n\n'
          'Touchez un cours pour voir la liste de ses leçons, avec une coche sur celles '
          'que vous avez terminées. Le bouton « Reprendre » vous mène directement à la '
          'première leçon non terminée.\n\n'
          'Chaque leçon contient l\'objectif, l\'explication, la syntaxe, un exemple commenté '
          'ligne par ligne, un cas pratique, l\'erreur fréquente, la bonne pratique et un '
          'exercice avec indice et correction. En bas de la leçon :\n'
          '• « Terminer et continuer » valide la leçon et ouvre la suivante\n'
          '• « Précédente » et « Suivante » permettent de naviguer dans le cours\n'
          '• L\'icône note, en haut, ouvre vos notes sur cette leçon',
    ),
    _GuideSection(
      title: 'Navigation',
      icon: Icons.navigation,
      content:
          'La barre de navigation en bas de l\'écran permet d\'accéder aux 5 sections principales :\n\n'
          '• Accueil : tableau de bord et statistiques\n'
          '• Cours : bibliothèque de cours Bash et PowerShell\n'
          '• Lab : terminal simulé pour pratiquer les commandes\n'
          '• Défis : défis techniques à résoudre\n'
          '• Profil : paramètres, progression, favoris et notes\n\n'
          'Chaque onglet garde son état quand vous en changez : vous retrouvez le Lab, '
          'vos filtres et votre position là où vous les aviez laissés.',
    ),
    _GuideSection(
      title: 'Exercices',
      icon: Icons.fitness_center_rounded,
      content:
          'Deux types d\'exercices vous attendent.\n\n'
          'Dans chaque leçon : un exercice pratique, avec un indice et une correction à déplier.\n\n'
          'Dans l\'écran Exercices (action rapide de l\'accueil, ou icône en haut de l\'onglet Cours) :\n'
          '• QCM et choix de la bonne commande\n'
          '• Compléter une commande\n'
          '• Corriger une commande erronée\n'
          '• Prédire le résultat d\'une commande\n'
          '• Écrire une commande ou un petit script\n\n'
          'Filtrez par shell et par type, puis touchez « Vérifier ». En cas d\'erreur, la bonne '
          'réponse et une explication s\'affichent. Les exercices réussis comptent pour vos badges.',
    ),
    _GuideSection(
      title: 'Laboratoire',
      icon: Icons.science_rounded,
      content:
          'Le Laboratoire (Lab) est un terminal simulé où vous pouvez pratiquer '
          'les commandes Bash et PowerShell en toute sécurité.\n\n'
          'Fonctionnalités :\n'
          '• Un terminal Bash (prompt student@bash-lab:~\$) et un terminal PowerShell (prompt PS C:\\home\\student>)\n'
          '• Le prompt affiche le dossier courant, comme dans un vrai terminal\n'
          '• Un système de fichiers virtuel partagé par les deux terminaux\n'
          '• 8 missions guidées, avec des exemples de commandes et des indices\n'
          '• Chemins composés (cd ../docs), options combinées (rm -rf), guillemets et redirections (echo texte > fichier)\n\n'
          'Les missions sont validées d\'après le résultat obtenu, pas d\'après le texte exact tapé. '
          'Votre session (fichiers, dossier courant, missions) est sauvegardée et restaurée '
          'au prochain lancement. Pour repartir de zéro, utilisez « Réinitialiser le lab » dans '
          'l\'onglet Missions ou dans le Profil.\n\n'
          'Tapez "help" dans un terminal pour voir les commandes disponibles. '
          'Comme dans la réalité, Bash distingue les majuscules des minuscules, PowerShell non.',
    ),
    _GuideSection(
      title: 'Comparateur',
      icon: Icons.compare_arrows_rounded,
      content:
          'Le Comparateur Bash ↔ PowerShell est un outil de référence qui vous permet '
          'de comparer les commandes entre les deux shells côte à côte.\n\n'
          'Fonctionnalités :\n'
          '• Plus de comparaisons organisées par catégorie\n'
          '• Filtres par catégorie (Fichiers, Dossiers, Texte, etc.)\n'
          '• Barre de recherche pour trouver rapidement une commande\n'
          '• Affichage terminal avec syntaxe colorée pour chaque shell\n'
          '• Section "Différences" dépliable pour comprendre les nuances\n\n'
          'C\'est l\'outil idéal pour traduire vos scripts d\'un shell à l\'autre.',
    ),
    _GuideSection(
      title: 'Cheat Sheets',
      icon: Icons.description_rounded,
      content:
          'Les Cheat Sheets sont des fiches de référence rapide pour toutes les commandes.\n\n'
          'Chaque fiche affiche :\n'
          '• Le nom de la commande en monospace\n'
          '• Le shell (Bash ou PowerShell)\n'
          '• La syntaxe dans un conteneur terminal\n'
          '• Une description de la commande\n'
          '• Un exemple d\'utilisation\n'
          '• Le niveau de compétence requis\n'
          '• Le niveau de danger (SAFE, WARNING, SENSITIVE, DESTRUCTIVE)\n'
          '• L\'équivalent dans l\'autre shell\n'
          '• Un bouton favori pour sauvegarder\n\n'
          'Filtrez par catégorie, shell ou niveau de danger pour trouver exactement ce dont vous avez besoin.',
    ),
    _GuideSection(
      title: 'Défis',
      icon: Icons.emoji_events_rounded,
      content:
          'Les Défis sont des exercices techniques qui testent vos connaissances.\n\n'
          'Fonctionnalités :\n'
          '• Difficulté croissante : Facile, Moyen, Difficile, Expert\n'
          '• Filtres par shell et par difficulté\n'
          '• Points attribués pour chaque défi relevé\n'
          '• Indices disponibles avant de consulter la solution\n'
          '• Explication détaillée après chaque défi\n'
          '• Marquage "Relevé" pour suivre votre progression\n\n'
          'Relevez autant de défis que possible pour débloquer des badges !',
    ),
    _GuideSection(
      title: 'Projets',
      icon: Icons.folder_rounded,
      content:
          'Les Projets sont des guides pas à pas pour réaliser des tâches complètes. '
          'Vous les trouvez avec le bouton « Projets » en haut de l\'onglet Défis, ou dans les actions rapides de l\'accueil.\n\n'
          'Chaque projet contient :\n'
          '• Une description de l\'objectif\n'
          '• Les étapes détaillées à suivre\n'
          '• La solution complète avec le code\n'
          '• Une explication de chaque étape\n'
          '• La difficulté et le shell utilisé\n\n'
          'Marquez un projet comme terminé pour faire avancer votre progression : '
          '3 projets terminés débloquent le badge « Administration ».',
    ),
    _GuideSection(
      title: 'Favoris',
      icon: Icons.favorite_rounded,
      content:
          'Vous pouvez ajouter des éléments en favoris pour y accéder rapidement.\n\n'
          'Éléments éligibles aux favoris :\n'
          '• Leçons de cours\n'
          '• Cheat Sheets\n'
          '• Comparaisons\n\n'
          'Appuyez sur l\'icône cœur ♡ sur n\'importe quel élément pour l\'ajouter '
          'à vos favoris. Vos favoris sont sauvegardés localement sur votre appareil.',
    ),
    _GuideSection(
      title: 'Notes',
      icon: Icons.note_alt_rounded,
      content:
          'La section Notes vous permet de créer et gérer des notes personnelles.\n\n'
          'Fonctionnalités :\n'
          '• Créer une note avec titre et contenu (Profil > Mes Notes)\n'
          '• Prendre une note depuis une leçon (icône note en haut de la leçon) : '
          'elle est rattachée à la leçon, dont le nom s\'affiche dans la liste\n'
          '• Éditer et supprimer des notes\n'
          '• Les notes sont sauvegardées localement\n\n'
          'Utilisez les notes pour consigner vos découvertes, '
          'vos astuces et tout ce que vous apprenez en cours de route.',
    ),
    _GuideSection(
      title: 'Progression',
      icon: Icons.trending_up_rounded,
      content:
          'Votre progression est automatiquement suivie et sauvegardée.\n\n'
          'Éléments suivis :\n'
          '• Leçons terminées (pourcentage par shell)\n'
          '• Exercices réussis avec scores\n'
          '• Défis relevés\n'
          '• Projets terminés\n'
          '• Badges débloqués\n\n'
          'Badges disponibles :\n'
          '• "Premier terminal" : complétez votre première leçon\n'
          '• "Première commande" : réussissez votre premier exercice\n'
          '• "Bash Beginner" : terminez 5 leçons Bash\n'
          '• "PowerShell Beginner" : terminez 5 leçons PowerShell\n'
          '• "Pipeline Master" : réussissez 10 exercices\n'
          '• "Regex Wizard" : réussissez 25 exercices\n'
          '• "Scripteur" : relevez 5 défis\n'
          '• "Automatisation" : relevez 10 défis\n'
          '• "Administration" : terminez 3 projets\n'
          '• "Shell Master" : débloquez tous les autres badges\n\n'
          'Touchez un badge dans l\'écran Progression pour voir sa condition.\n\n'
          'Toutes les données sont sauvegardées localement sur votre appareil.',
    ),
    _GuideSection(
      title: 'Paramètres',
      icon: Icons.settings_rounded,
      content:
          'Accédez aux paramètres depuis l\'onglet Profil.\n\n'
          'Options disponibles :\n'
          '• Thème : Clair / Système / Sombre\n'
          '• Taille du texte : adapter la taille de police de l\'application\n'
          '• Taille du code : adapter la taille des blocs de code des leçons et du terminal du Lab\n'
          '• Réinitialiser la progression (leçons, exercices, défis, projets et badges)\n'
          '• Réinitialiser le Lab (missions et fichiers du terminal simulé)\n\n'
          'Ce guide s\'ouvre automatiquement au premier lancement. Vous pouvez le revoir à '
          'tout moment depuis le Profil ou les actions rapides de l\'accueil.',
    ),
  ];

  static const _tourSteps = [
    _TourStep(
      number: 1,
      title: 'Explorez l\'accueil',
      description: 'Découvrez le tableau de bord, vos statistiques et les actions rapides.',
      icon: Icons.home_rounded,
    ),
    _TourStep(
      number: 2,
      title: 'Commencez le cours "Découverte de Bash"',
      description: 'Dans l\'onglet Cours, touchez « Découverte de Bash » puis « Commencer le cours ».',
      icon: Icons.menu_book_rounded,
    ),
    _TourStep(
      number: 3,
      title: 'Essayez votre première commande dans le Lab',
      description: 'Ouvrez le Lab, tapez "help", puis suivez la première mission : mkdir projects.',
      icon: Icons.science_rounded,
    ),
    _TourStep(
      number: 4,
      title: 'Consultez une Cheat Sheet',
      description: 'Cherchez "ls" ou "Get-ChildItem" dans les Cheat Sheets pour voir la syntaxe complète.',
      icon: Icons.description_rounded,
    ),
    _TourStep(
      number: 5,
      title: 'Comparez une commande Bash et PowerShell',
      description: 'Ouvrez le Comparateur et voyez comment "cp" se traduit en "Copy-Item".',
      icon: Icons.compare_arrows_rounded,
    ),
    _TourStep(
      number: 6,
      title: 'Tentez un défi facile',
      description: 'Dans l\'onglet Défis, filtrez par "Facile" et choisissez un défi Bash.',
      icon: Icons.emoji_events_rounded,
    ),
    _TourStep(
      number: 7,
      title: 'Enregistrez un favori',
      description: 'Appuyez sur l\'icône cœur sur une leçon ou une Cheat Sheet pour la sauvegarder.',
      icon: Icons.favorite_rounded,
    ),
    _TourStep(
      number: 8,
      title: 'Créez une note',
      description: 'Dans le Profil, créez une note pour consigner ce que vous avez appris.',
      icon: Icons.note_alt_rounded,
    ),
    _TourStep(
      number: 9,
      title: 'Consultez votre progression',
      description: 'Retournez à l\'accueil pour voir vos statistiques mises à jour.',
      icon: Icons.trending_up_rounded,
    ),
    _TourStep(
      number: 10,
      title: 'Explorez les paramètres',
      description: 'Personnalisez le thème, la taille du texte et celle du code depuis l\'onglet Profil.',
      icon: Icons.settings_rounded,
    ),
  ];

  @override
  Widget build(BuildContext context) {
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
                    _buildTourSection(),
                    const SizedBox(height: 24),
                    Text(
                      'Mode d\'emploi',
                      style: AppFonts.firaCode(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: AppTheme.textColor(context),
                      ),
                    ),
                    const SizedBox(height: 12),
                    ...List.generate(_sections.length, (index) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: _buildSectionCard(_sections[index], index),
                      );
                    }),
                    const SizedBox(height: 16),
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
          IconButton(tooltip: 'Retour', 
            icon: const Icon(Icons.arrow_back_rounded, size: 22),
            color: AppTheme.textSecColor(context).withValues(alpha: 0.7),
            onPressed: () => Navigator.of(context).pop(),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'Guide de Shell-Bash-Bridge',
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

  Widget _buildTourSection() {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppTheme.accent.withValues(alpha: 0.15),
            AppTheme.bashGreen.withValues(alpha: 0.1),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppTheme.accent.withValues(alpha: 0.2),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.play_circle_rounded,
                  color: AppTheme.accent,
                  size: 24,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Mes 10 premières minutes',
                    style: AppFonts.firaCode(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: AppTheme.textColor(context),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              'Un parcours guidé pour bien démarrer',
              style: AppFonts.firaCode(
                fontSize: 11,
                color: AppTheme.textSecColor(context).withValues(alpha: 0.6),
              ),
            ),
            const SizedBox(height: 14),
            ..._tourSteps.map((step) => _buildTourStepCard(step)),
          ],
        ),
      ),
    );
  }

  Widget _buildTourStepCard(_TourStep step) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: AppTheme.accent.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Center(
              child: Text(
                '${step.number}',
                style: AppFonts.firaCode(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.accent,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      step.icon,
                      size: 14,
                      color: AppTheme.accent.withValues(alpha: 0.7),
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        step.title,
                        style: AppFonts.firaCode(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: AppTheme.textColor(context),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  step.description,
                  style: AppFonts.firaCode(
                    fontSize: 10,
                    height: 1.4,
                    color: AppTheme.textSecColor(context).withValues(alpha: 0.55),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionCard(_GuideSection section, int index) {
    final isExpanded = _expandedSections.contains(index);

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      decoration: BoxDecoration(
        color: AppTheme.chipBg(context).withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isExpanded
              ? AppTheme.accent.withValues(alpha: 0.25)
              : AppTheme.textSecColor(context).withValues(alpha: 0.08),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Tappable(
            onTap: () {
              setState(() {
                if (isExpanded) {
                  _expandedSections.remove(index);
                } else {
                  _expandedSections.add(index);
                }
              });
            },
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppTheme.accent.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(
                      section.icon,
                      size: 18,
                      color: AppTheme.accent,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      section.title,
                      style: AppFonts.firaCode(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.textColor(context),
                      ),
                    ),
                  ),
                  Icon(
                    isExpanded
                        ? Icons.keyboard_arrow_up_rounded
                        : Icons.keyboard_arrow_down_rounded,
                    size: 20,
                    color: AppTheme.textSecColor(context).withValues(alpha: 0.4),
                  ),
                ],
              ),
            ),
          ),
          if (isExpanded)
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 0, 14, 14),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppTheme.terminalBg.withValues(alpha: 0.5),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  section.content,
                  style: AppFonts.firaCode(
                    fontSize: 11,
                    height: 1.6,
                    color: AppTheme.textSecColor(context).withValues(alpha: 0.75),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _GuideSection {
  final String title;
  final IconData icon;
  final String content;

  const _GuideSection({
    required this.title,
    required this.icon,
    required this.content,
  });
}

class _TourStep {
  final int number;
  final String title;
  final String description;
  final IconData icon;

  const _TourStep({
    required this.number,
    required this.title,
    required this.description,
    required this.icon,
  });
}
