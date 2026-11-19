import '../models/project.dart';

class ProjectData {
  static final List<Project> allProjects = [
    Project(
      id: 'proj_001',
      title: 'Organisateur de fichiers automatique',
      shell: 'bash',
      difficulty: 'Difficile',
      description:
          'Créez un script qui organise automatiquement un dossier Downloads en catégories (images, documents, vidéos, archives)',
      steps: [
        'Analyser les extensions des fichiers',
        'Créer les catégories de dossiers',
        'Déplacer chaque fichier selon son extension',
        'Générer un rapport de déplacement',
      ],
      solution: '''#!/bin/bash
DIR="\$HOME/Downloads"
mkdir -p "\$DIR"/{images,documents,videos,archives,autres}
for f in "\$DIR"/*; do
  ext="\${f##*.}"
  case \$ext in
    jpg|jpeg|png|gif) mv "\$f" "\$DIR/images/" ;;
    pdf|doc|docx|txt) mv "\$f" "\$DIR/documents/" ;;
    mp4|avi|mkv) mv "\$f" "\$DIR/videos/" ;;
    tar|gz|zip|rar) mv "\$f" "\$DIR/archives/" ;;
    *) mv "\$f" "\$DIR/autres/" ;;
  esac
done
echo "Organisation terminée !"''',
      explanation:
          'Ce script utilise un for loop pour itérer sur chaque fichier du dossier Downloads. '
              'L\'extension est extraite avec \${f##*.}. '
              'Un case gère le mapping extension -> dossier. '
              'mkdir -p crée tous les sous-dossiers en une seule commande grâce aux sequences bash.',
    ),
    Project(
      id: 'proj_002',
      title: 'Sauvegarde automatique',
      shell: 'bash',
      difficulty: 'Difficile',
      description:
          'Créez un script de sauvegarde qui compresse et date automatiquement les sauvegardes',
      steps: [
        'Définir les chemins source et destination',
        'Créer l\'archive avec date',
        'Vérifier l\'espace disque',
        'Nettoyer les anciennes sauvegardes',
      ],
      solution: '''#!/bin/bash
SRC="\$HOME/documents"
DEST="\$HOME/backups"
mkdir -p "\$DEST"
DATE=\$(date +%Y%m%d_%H%M)
tar -czf "\$DEST/backup_\$DATE.tar.gz" "\$SRC"
echo "Sauvegarde créée: backup_\$DATE.tar.gz"
# Garder les 7 dernières
ls -t "\$DEST"/backup_*.tar.gz | tail -n +8 | xargs rm -f''',
      explanation:
          'Le script combine tar avec gzip (-czf) pour créer une archive compressée. '
              'La commande date formate la date pour un nom de fichier unique. '
              'La rotation se fait en listant les fichiers par date (-t), prenant tout sauf les 7 premiers (tail -n +8), '
              'et supprimant avec xargs rm -f.',
    ),
    Project(
      id: 'proj_003',
      title: 'Analyseur de logs avancé',
      shell: 'bash',
      difficulty: 'Expert',
      description:
          'Créez un script qui analyse un fichier log et produit un rapport détaillé (erreurs, warnings, stats par heure)',
      steps: [
        'Lire le fichier log',
        'Compter les erreurs et warnings',
        'Analyser la distribution horaire',
        'Générer un rapport formaté',
      ],
      solution: '''#!/bin/bash
LOG="\$1"
echo "=== Rapport d'analyse ==="
echo "Fichier: \$LOG"
echo "Erreurs: \$(grep -c 'ERROR' \$LOG)"
echo "Warnings: \$(grep -c 'WARN' \$LOG)"
echo "Lignes totales: \$(wc -l < \$LOG)"
echo "--- Distribution par heure ---"
grep -oP '\\d{2}:\\d{2}' \$LOG | cut -d: -f1 | sort | uniq -c | sort -rn''',
      explanation:
          'Le script utilise grep -c pour compter les occurrences. '
              'La regex -oP extrait les timestamps avec Perl-compatible regex. '
              'cut sépare l\'heure des minutes, sort et uniq -c comptent par heure, '
              'et sort -rn trie par fréquence décroissante.',
    ),
    Project(
      id: 'proj_004',
      title: 'Monitoring système',
      shell: 'bash',
      difficulty: 'Expert',
      description:
          'Créez un script de monitoring en temps réel qui vérifie CPU, RAM, espace disque',
      steps: [
        'Vérifier l\'utilisation CPU',
        'Vérifier la mémoire',
        'Vérifier l\'espace disque',
        'Afficher un rapport formaté',
        'Alerte si seuils dépassés',
      ],
      solution: '''#!/bin/bash
echo "=== Monitoring ==="
echo "CPU:"; top -bn1 | grep 'Cpu(s)' | awk '{print \$2}'
echo "RAM:"; free -h | grep Mem
echo "Disque:"; df -h / | tail -1
DISK=\$(df / | tail -1 | awk '{print \$5}' | tr -d '%')
if [ \$DISK -gt 80 ]; then echo "ALERTE: Disque à \${DISK}% !"; fi''',
      explanation:
          'top -bn1 exécute une seule itération en mode batch. '
              'awk sélectionne des colonnes spécifiques. '
              'free -h affiche la mémoire en format human-readable. '
              'La condition if teste si l\'espace disque dépasse 80% et déclenche une alerte.',
    ),
    Project(
      id: 'proj_005',
      title: 'Script d\'installation Linux',
      shell: 'bash',
      difficulty: 'Moyen',
      description:
          'Créez un script d\'installation automatisée de development tools',
      steps: [
        'Détecter la distribution',
        'Mettre à jour les paquets',
        'Installer les outils',
        'Configurer l\'environnement',
      ],
      solution: '''#!/bin/bash
if command -v apt &> /dev/null; then
  sudo apt update && sudo apt install -y git curl vim build-essential
elif command -v yum &> /dev/null; then
  sudo yum install -y git curl vim gcc
fi
echo 'export EDITOR=vim' >> ~/.bashrc
echo "Installation terminée !"''',
      explanation:
          'command -v détecte le gestionnaire de paquets disponible (apt pour Debian/Ubuntu, yum pour RHEL/CentOS). '
              '&> /dev/null redirige toute la sortie pour un test silencieux. '
              '&& chaîne les commandes pour n\'installer que si la mise à jour réussit. '
              'L\'éditeur est configuré en ajoutant une variable d\'environnement à bashrc.',
    ),
    Project(
      id: 'proj_006',
      title: 'Rapport système Windows',
      shell: 'powershell',
      difficulty: 'Difficile',
      description:
          'Créez un script qui génère un rapport complet du système Windows',
      steps: [
        'Collecter les informations système',
        'Vérifier les services critiques',
        'Lister les processus gourmands',
        'Exporter en rapport',
      ],
      solution: r'''\$report = @()
\$report += "Rapport Système - \$(Get-Date)"
\$report += "OS: \$((Get-CimInstance Win32_OperatingSystem).Caption)"
\$report += "RAM: \$([math]::Round((Get-CimInstance Win32_OperatingSystem).TotalVisibleMemorySize/1MB, 2)) GB"
\$report += "Processus critiques:"
Get-Service | Where-Object {\$_.Status -eq 'Running' -and \$_.StartType -eq 'Automatic'} | ForEach-Object { \$report += "  - \$(\$_.Name)" }
\$report | Out-File rapport_systeme.txt''',
      explanation:
          'Le tableau @() stocke toutes les lignes du rapport. '
              'Get-CimInstance récupère les informations système via WMI. '
              'Where-Object filtre les services par état et type de démarrage. '
              'Out-File exporte le résultat dans un fichier texte.',
    ),
    Project(
      id: 'proj_007',
      title: 'Analyseur de processus',
      shell: 'powershell',
      difficulty: 'Difficile',
      description:
          'Créez un outil qui identifie les processus les plus gourmands et propose d\'arrêter les inutiles',
      steps: [
        'Lister les processus par mémoire',
        'Identifier les processus système vs utilisateur',
        'Afficher les détails',
        'Proposer l\'arrêt',
      ],
      solution: r'''Get-Process | Sort-Object WorkingSet64 -Descending | Select-Object -First 10 Name,@{N='Memoire_MB';E={[math]::Round(\$_.WorkingSet64/1MB,2)}},Id | Format-Table -AutoSize''',
      explanation:
          'Get-Process récupère tous les processus en cours d\'exécution. '
              'Sort-Object trie par consommation mémoire (WorkingSet64) en ordre décroissant. '
              'Select-Object -First 10 limite aux 10 plus gourmands. '
              'La hashtable @{N=...;E=...} crée une colonne calculée pour la mémoire en MB. '
              'Format-Table -AutoSize ajuste la largeur des colonnes.',
    ),
    Project(
      id: 'proj_008',
      title: 'Gestionnaire de services',
      shell: 'powershell',
      difficulty: 'Moyen',
      description:
          'Créez un script pour gérer les services Windows démarrés automatiquement',
      steps: [
        'Lister les services',
        'Identifier ceux en erreur',
        'Tenter un redémarrage',
        'Logger les résultats',
      ],
      solution: r'''Get-Service | Where-Object {\$_.StartType -eq 'Automatic'} | ForEach-Object {
  if (\$_.Status -ne 'Running') {
    Write-Warning "Service arrêté: \$(\$_.Name)"
    try { Start-Service \$_.Name; Write-Host "Redémarré: \$(\$_.Name)" }
    catch { Write-Error "Échec: \$(\$_.Name)" }
  }
}''',
      explanation:
          'Where-Object filtre les services avec démarrage automatique. '
              'ForEach-Object itère sur chaque service pour vérifier son état. '
              'Le bloc try/catch gère les erreurs lors du redémarrage. '
              'Write-Warning et Write-Host fournissent un feedback visuel adapté à chaque cas.',
    ),
    Project(
      id: 'proj_009',
      title: 'Double Shell - Outil de recherche',
      shell: 'both',
      difficulty: 'Expert',
      description:
          'Créez le même outil de recherche de fichiers par taille en Bash et PowerShell, puis comparez',
      steps: [
        'Identifier les fichiers > 10MB en Bash',
        'Faire de même en PowerShell',
        'Comparer la syntaxe',
        'Analyser les avantages/limites',
      ],
      solution: '''# Bash:
find . -type f -size +10M -exec ls -lh {} \\;

# PowerShell:
Get-ChildItem -Recurse | Where-Object {\$_.Length -gt 10MB} | Select-Object FullName,@{N='Size_MB';E={[math]::Round(\$_.Length/1MB,2)}}''',
      explanation:
          'En Bash, find localise les fichiers et -exec exécute ls sur chacun. '
              '-size +10M filtre par taille supérieure à 10 Mo. '
              'En PowerShell, Get-ChildItem -Recurse parcourt récursivement le dossier. '
              'Where-Object filtre par propriété Length (en octets), et 10MB est un literal PowerShell. '
              'La comparaison montre que PowerShell offre un accès direct aux propriétés objet, '
              'tandis que Bash repose sur des commandes extérieures et des pipes.',
    ),
    Project(
      id: 'proj_010',
      title: 'Projet final expert',
      shell: 'both',
      difficulty: 'Expert',
      description:
          'Créez un outil complet de backup avec rotation, compression, logging, et notification',
      steps: [
        'Définir les chemins sources',
        'Créer l\'archive avec date',
        'Appliquer la rotation (garder N backups)',
        'Logger l\'opération',
        'Comparer les implémentations Bash et PowerShell',
      ],
      solution: '''# Bash:
#!/bin/bash
SRC=\$1; DEST=\$2; KEEP=5
DATE=\$(date +%Y%m%d_%H%M)
tar -czf "\$DEST/backup_\$DATE.tar.gz" "\$SRC"
ls -t "\$DEST"/backup_*.tar.gz | tail -n +\$((KEEP+1)) | xargs rm -f
echo "[\$(date)] Backup \$DATE created" >> "\$DEST/backup.log"''',
      explanation:
          'Ce projet final combine toutes les compétences acquises. '
              'Le Bash utilise tar pour la compression, date pour le nommage unique, '
              'et une pipeline ls/tail/xargs pour la rotation des sauvegardes. '
              'L\'option \$((KEEP+1)) calcule dynamiquement combien supprimer. '
              'Le logging se fait par redirection simple vers un fichier log avec horodatage. '
              'Ce pattern est similaire à ce que font les outils professionnels comme rsync.',
    ),
  ];
}
