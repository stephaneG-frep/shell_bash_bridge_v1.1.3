import '../models/challenge.dart';

class ChallengeData {
  static final List<Challenge> allChallenges = [
    const Challenge(
      id: 'ch_001',
      title: 'Créer une arborescence',
      shell: 'bash',
      difficulty: 'Facile',
      objective:
          'Créez une structure de dossiers : projet/src, projet/docs, projet/tests',
      hints: [
        'Utilisez mkdir -p',
        'Un seul mkdir peut créer plusieurs niveaux',
      ],
      solution: 'mkdir -p projet/src projet/docs projet/tests',
      explanation:
          'La commande mkdir avec l\'option -p crée les répertoires parents si nécessaire, '
          'permettant de créer toute l\'arborescence en une seule commande.',
      points: 50,
    ),
    const Challenge(
      id: 'ch_002',
      title: 'Chercher des fichiers',
      shell: 'bash',
      difficulty: 'Facile',
      objective:
          'Trouvez tous les fichiers .log dans /var/log modifiés il y a moins de 7 jours',
      hints: [
        'Utilisez find',
        'L\'option -mtime filtre par date',
      ],
      solution: "find /var/log -name '*.log' -mtime -7",
      explanation:
          'La commande find recherche les fichiers correspondant aux critères. '
          '-name filtre par extension et -mtime -7 sélectionne les fichiers modifiés durant les 7 derniers jours.',
      points: 50,
    ),
    const Challenge(
      id: 'ch_003',
      title: 'Analyser un log',
      shell: 'bash',
      difficulty: 'Moyen',
      objective:
          'Comptez le nombre d\'erreurs (ligne contenant \'ERROR\') dans un fichier log',
      hints: [
        'Utilisez grep avec -c',
        'Ou pipez vers wc -l',
      ],
      solution: "grep -c 'ERROR' logfile.log",
      explanation:
          'grep -c compte le nombre de lignes correspondant au motif. '
          'Il affiche directement le nombre de matches au lieu de lister les lignes.',
      points: 100,
    ),
    const Challenge(
      id: 'ch_004',
      title: 'Trouver les processus lourds',
      shell: 'bash',
      difficulty: 'Moyen',
      objective: 'Affichez les 5 processus utilisant le plus de CPU',
      hints: [
        'Utilisez ps aux',
        'Puis triez avec sort',
      ],
      solution: 'ps aux --sort=-%cpu | head -n 6',
      explanation:
          'ps aux liste tous les processus. --sort=-%cpu trie par CPU décroissant. '
          'head -n 6 affiche les 5 premières lignes (en-tête inclus).',
      points: 100,
    ),
    const Challenge(
      id: 'ch_005',
      title: 'Créer une sauvegarde',
      shell: 'bash',
      difficulty: 'Moyen',
      objective:
          'Créez une archive compressée de /home/user/documents avec date dans le nom',
      hints: [
        'Utilisez tar avec -czf',
        'La commande date génère la date actuelle',
      ],
      solution: 'tar -czf backup_\$(date +%Y%m%d).tar.gz /home/user/documents',
      explanation:
          'tar -czf crée une archive gzip. \$(date +%Y%m%d) insère la date actuelle '
          'au format YYYYMMDD dans le nom du fichier.',
      points: 100,
    ),
    const Challenge(
      id: 'ch_006',
      title: 'Exporter un rapport',
      shell: 'bash',
      difficulty: 'Difficile',
      objective:
          'Créez un rapport système contenant hostname, date, uptime, et taille disque',
      hints: [
        'Utilisez hostname, date, uptime, df -h',
        'Redirigez avec >',
      ],
      solution:
          'echo "=== Rapport ===" > rapport.txt && hostname >> rapport.txt && date >> rapport.txt && uptime >> rapport.txt && df -h >> rapport.txt',
      explanation:
          'La première redirection (> ) crée le fichier, les suivantes (>>) append le contenu. '
          'Chaque commande ajoute ses informations au rapport.',
      points: 150,
    ),
    const Challenge(
      id: 'ch_007',
      title: 'Automatiser un tri de fichiers',
      shell: 'bash',
      difficulty: 'Difficile',
      objective:
          'Créez un script qui déplace tous les .jpg dans un dossier \'images\'',
      hints: [
        'Utilisez une boucle for',
        'Ou find avec -exec',
      ],
      solution:
          '#!/bin/bash\nmkdir -p images\nfor f in *.jpg; do\n  mv "\$f" images/\ndone',
      explanation:
          'Le script crée le dossier images, puis itère sur tous les fichiers .jpg '
          'et les déplace un par un dans le dossier cible.',
      points: 150,
    ),
    const Challenge(
      id: 'ch_008',
      title: 'Rapport système PowerShell',
      shell: 'powershell',
      difficulty: 'Moyen',
      objective:
          'Créez un rapport avec nom de la machine, RAM totale, et top 5 processus',
      hints: [
        'Utilisez \$env:COMPUTERNAME',
        'Get-Process | Sort-Object WorkingSet64 -Descending',
      ],
      solution:
          '"Rapport: \$env:COMPUTERNAME" | Out-File rapport.txt\nGet-Process | Sort-Object WorkingSet64 -Descending -First 5 | Out-File rapport.txt',
      explanation:
          '\$env:COMPUTERNAME récupère le nom de la machine. Get-Process avec Sort-Object '
          'trie les processus par mémoire utilisée, et -First 5 limite aux 5 premiers.',
      points: 100,
    ),
    const Challenge(
      id: 'ch_009',
      title: 'Analyseur de processus',
      shell: 'powershell',
      difficulty: 'Moyen',
      objective:
          'Listez les processus utilisant plus de 200MB de mémoire, triés par consommation',
      hints: [
        'Utilisez Where-Object pour filtrer',
        'WorkingSet64 est la mémoire utilisée',
      ],
      solution:
          'Get-Process | Where-Object {\$_.WorkingSet64 -gt 200MB} | Sort-Object WorkingSet64 -Descending',
      explanation:
          'Where-Object filtre les processus dont la mémoire (WorkingSet64) dépasse 200MB. '
          'Sort-Object les trie par consommation décroissante.',
      points: 100,
    ),
    const Challenge(
      id: 'ch_010',
      title: 'Gestionnaire de services',
      shell: 'powershell',
      difficulty: 'Difficile',
      objective:
          'Listez tous les services en état \'Running\' et exportez-les en CSV',
      hints: [
        'Filtrez avec Where-Object',
        'Exportez avec Export-Csv',
      ],
      solution:
          "Get-Service | Where-Object {\$_.Status -eq 'Running'} | Export-Csv -Path services.csv -NoTypeInformation",
      explanation:
          'Get-Service liste tous les services. Where-Object filtre ceux en état Running. '
          'Export-Csv écrit le résultat dans un fichier CSV sans en-tête de type.',
      points: 150,
    ),
    const Challenge(
      id: 'ch_011',
      title: 'Inventaire système',
      shell: 'powershell',
      difficulty: 'Difficile',
      objective:
          'Créez un inventaire complet : OS, CPU, RAM, disques',
      hints: [
        'Utilisez Get-CimInstance',
        'Win32_OperatingSystem, Win32_Processor, Win32_LogicalDisk',
      ],
      solution:
          'Get-CimInstance Win32_OperatingSystem | Select-Object Caption,Version | Out-File inventor.txt\nGet-CimInstance Win32_Processor | Out-File -Append inventor.txt\nGet-CimInstance Win32_LogicalDisk | Out-File -Append inventor.txt',
      explanation:
          'Get-CimInstance interroge les classes WMI pour obtenir les informations système. '
          'Chaque catégorie est ajoutée au fichier avec -Append.',
      points: 150,
    ),
    const Challenge(
      id: 'ch_012',
      title: 'Projet Double Shell',
      shell: 'both',
      difficulty: 'Expert',
      objective:
          'Créez un script qui liste les fichiers > 10MB, une fois en Bash et une fois en PowerShell',
      hints: [
        'Bash: find + -size',
        'PowerShell: Get-ChildItem + Where-Object',
      ],
      solution:
          'Bash: find . -type f -size +10M\nPS: Get-ChildItem -Recurse | Where-Object {\$_.Length -gt 10MB}',
      explanation:
          'En Bash, find avec -size +10M filtre les fichiers de plus de 10 Mo. '
          'En PowerShell, Get-ChildItem -Recurse liste tous les fichiers et Where-Object filtre par taille.',
      points: 300,
    ),
    const Challenge(
      id: 'ch_013',
      title: 'Nettoyeur de logs',
      shell: 'bash',
      difficulty: 'Expert',
      objective:
          'Supprimez les fichiers .log de plus de 30 jours dans /var/log',
      hints: [
        'Utilisez find avec -mtime +30',
        'Ajoutez -delete ou -exec rm',
      ],
      solution: "find /var/log -name '*.log' -mtime +30 -delete",
      explanation:
          'find avec -mtime +30 sélectionne les fichiers modifiés il y a plus de 30 jours. '
          'L\'option -delete les supprime directement, plus efficace que -exec rm.',
      points: 250,
    ),
    const Challenge(
      id: 'ch_014',
      title: 'Convertisseur CSV',
      shell: 'powershell',
      difficulty: 'Difficile',
      objective:
          'Importez un CSV, filtrez les lignes avec une valeur > 100, exportez le résultat',
      hints: [
        'Import-Csv pour lire',
        'Where-Object pour filtrer',
        'Export-Csv pour écrire',
      ],
      solution:
          'Import-Csv data.csv | Where-Object {[int]\$_.Valeur -gt 100} | Export-Csv filtered.csv -NoTypeInformation',
      explanation:
          'Import-Csv lit le fichier CSV en objets PowerShell. Where-Object filtre les lignes '
          'dont la colonne Valeur dépasse 100. Export-Csv écrit le résultat filtré.',
      points: 150,
    ),
    const Challenge(
      id: 'ch_015',
      title: 'Script complet',
      shell: 'bash',
      difficulty: 'Expert',
      objective:
          'Créez un script de monitoring qui vérifie espace disque, CPU, et envoie une alerte si seuil dépassé',
      hints: [
        'Utilisez df, top ou ps',
        'Les conditions if',
        'Seuil à 80%',
      ],
      solution:
          'Le script doit vérifier df -h | grep \'/dev/\' et comparer le % utilisé, alerter si > 80%',
      explanation:
          'Le script parse la sortie de df -h pour chaque partition, extrait le pourcentage '
          'd\'utilisation et déclenche une alerte via echo ou mail si le seuil de 80% est dépassé.',
      points: 500,
    ),
  ];
}
