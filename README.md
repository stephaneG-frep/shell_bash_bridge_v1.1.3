# Shell-Bash-Bridge

Application Flutter (Android) éducative pour apprendre **Bash** et **PowerShell**, du niveau débutant à expert, et passer de l'un à l'autre. Elle fonctionne entièrement hors ligne et propose cours, exercices, défis, projets, fiches mémo et un terminal simulé.

Version : **1.1.3**

---

## Fonctionnalités

- **Cours** Bash (8 cours, 71 leçons) et PowerShell (9 cours, 64 leçons), répartis sur 8 niveaux, de Découverte à Expert, dont un niveau Automatisation (JSON, CSV, sauvegardes, jobs, Git…). Chaque leçon comprend une explication, des exemples commentés, un cas pratique, l'erreur fréquente, la bonne pratique et un exercice corrigé.
- **Navigation par cours** : liste des leçons avec progression, reprise à la première leçon non terminée, boutons Précédente / Suivante
- **Comparateur** Bash ↔ PowerShell pour les tâches courantes
- **48 exercices** (QCM, compléter, corriger, prédire, écrire une commande, script) avec validation immédiate
- **Défis** et **projets** classés par difficulté, avec indices et solutions
- **62 fiches mémo** (cheat sheets) et **recherche** globale
- **Lab** : terminal Bash et PowerShell simulé, avec missions guidées ; fichiers, dossier courant et missions sont conservés d'une session à l'autre
- **Progression**, badges, favoris et notes personnelles, sauvegardés sur l'appareil
- **Thème clair / sombre / système**, taille du texte et taille du code réglables
- **Accessibilité** : boutons et filtres annoncés par les lecteurs d'écran (TalkBack)
- **Guide** affiché automatiquement au premier lancement

---

## Architecture

```
shell_bash_bridge/
├── android/                    # Projet Android (Gradle)
├── lib/
│   ├── main.dart               # Point d'entrée
│   ├── app/                    # MaterialApp, navigation principale
│   ├── core/                   # Thème, constantes, polices
│   ├── data/                   # Contenu pédagogique embarqué
│   ├── models/                 # Modèles (cours, leçon, progression, note…)
│   ├── services/               # Stockage, progression, recherche
│   ├── shared/widgets/         # Widgets réutilisables
│   └── features/               # Écrans (home, courses, lab, challenges…)
├── test/                       # Tests unitaires
├── pubspec.yaml
└── README.md
```

---

## Prérequis et installation

- Flutter **3.35 ou supérieur** (Dart 3)
- Android SDK

```bash
flutter pub get
```

`android/local.properties` est propre à chaque machine : Flutter le régénère automatiquement (chemin du SDK) au premier `flutter run` ou `flutter build`.

## Exécution

```bash
flutter run
```

## Tests

```bash
flutter test
```

Les tests couvrent le stockage (données corrompues), la progression et les badges, le simulateur du Lab, les notes, la navigation entre leçons et l'intégrité du contenu pédagogique (identifiants uniques, champs remplis, catégories reconnues).

## Ajouter une leçon

Ajoutez une entrée `Lesson(...)` dans `lib/data/bash_courses.dart` ou `lib/data/powershell_courses.dart`, avec un identifiant unique commençant par `bash_` ou `ps_` et tous les champs remplis. La progression, la recherche, les badges et la navigation se mettent à jour automatiquement. Lancez `flutter test` : `test/content_test.dart` signale tout oubli.

---

## Construction de l'APK release

La signature release se configure dans `android/key.properties` (fichier ignoré par git) :

```properties
storePassword=<mot de passe du keystore>
keyPassword=<mot de passe de la clé>
keyAlias=upload
storeFile=/chemin/vers/upload-keystore.jks
```

Création d'une clé :

```bash
keytool -genkey -v -keystore ~/upload-keystore.jks -keyalg RSA -keysize 2048 -validity 10000 -alias upload
```

Puis :

```bash
flutter build apk --release
```

L'APK se trouve dans `build/app/outputs/flutter-apk/app-release.apk`.
Sans `key.properties`, le build utilise la clé **debug** (un avertissement s'affiche) : cet APK convient pour des tests, mais **pas pour le Play Store**.

---

## Hors ligne et confidentialité

Tout le contenu est embarqué dans l'application. La version release ne demande pas la permission Internet. Elle n'est déclarée que pour les builds debug et profile, pour les outils de développement Flutter.

La progression, les notes et les préférences sont stockées localement via `shared_preferences`. Aucune donnée n'est envoyée à un serveur. Si des données stockées sont corrompues, elles sont ignorées (et conservées sous une clé `*_corrupt`) au lieu de bloquer le démarrage.

---

## Le Lab (terminal simulé)

Le Lab simule un système de fichiers en mémoire. **Aucune commande n'est réellement exécutée sur l'appareil.**

- **Bash** : `pwd`, `ls [-l] [-a]`, `cd` (`..`, `~`, `-`, chemins relatifs ou absolus), `mkdir [-p]`, `rmdir`, `touch`, `cp [-r]`, `mv`, `rm [-r] [-f]`, `cat`, `echo`, `clear`, `help`. Les options combinées (`-rf`, `-la`), les guillemets et les redirections `>` / `>>` sont gérés. Comme le vrai Bash, le simulateur distingue les majuscules des minuscules.
- **PowerShell** : `Get-Location`, `Get-ChildItem`, `Set-Location`, `New-Item`, `mkdir`, `Copy-Item [-Recurse]`, `Move-Item`, `Remove-Item [-Recurse]`, `Get-Content`, `Write-Output`, `Clear-Host`, `Get-Help`, ainsi que leurs alias courants (`ls`, `cd`, `cp`, `rm`, `cat`…). Les noms de paramètres abrégés sont acceptés. Comme le vrai PowerShell, le simulateur ne distingue pas les majuscules des minuscules.

Les missions sont validées d'après le résultat obtenu, c'est-à-dire l'état du système de fichiers, et non d'après le texte exact tapé. L'état du Lab est sauvegardé après chaque commande et restauré au lancement suivant ; « Réinitialiser le Lab » (onglet Missions ou Profil) repart de zéro.

---

## Badges

| Badge | Condition |
|-------|-----------|
| Premier terminal | Terminer une leçon |
| Première commande | Réussir un exercice |
| Bash Beginner | Terminer 5 leçons Bash |
| PowerShell Beginner | Terminer 5 leçons PowerShell |
| Pipeline Master | Réussir 10 exercices |
| Regex Wizard | Réussir 25 exercices |
| Scripteur | Relever 5 défis |
| Automatisation | Relever 10 défis |
| Administration | Terminer 3 projets |
| Shell Master | Débloquer tous les autres badges |

---

## Limitations connues

- Pas d'exécution réelle de commandes : le Lab est une simulation (pas de pipes, de variables ni de scripts)
- Pas de synchronisation cloud de la progression
- Interface en français uniquement

---

## Licence

Ce projet est distribué sous licence MIT. Voir le fichier [LICENSE](LICENSE).
