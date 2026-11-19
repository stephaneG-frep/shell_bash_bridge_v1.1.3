import '../models/comparison.dart';

class ComparisonData {
  static final List<Comparison> allComparisons = [
    // ── Fichiers ──────────────────────────────────────────────
    Comparison(
      id: 'comp_001',
      task: 'Lister les fichiers',
      category: 'fichiers',
      bashCommand: 'ls -la /chemin',
      bashExplanation:
          'Liste tous les fichiers (yacachés) avec détails '
          '(droits, propriétaire, taille, date).',
      psCommand: 'Get-ChildItem -Force /chemin',
      psExplanation:
          'Get-ChildItem (alias ls) liste le contenu ; '
          '-Force inclut les fichiers cachés.',
      differences:
          'ls affiche une sortie formatée en colonnes compactes ; '
          'Get-ChildItem retourne des objets .NET exploitables en pipeline. '
          'Le format de sortie est radicalement différent.',
    ),
    Comparison(
      id: 'comp_002',
      task: 'Lister les fichiers cachés',
      category: 'fichiers',
      bashCommand: 'ls -a /chemin',
      bashExplanation:
          '-a inclut les entrées commençant par un point ( fichiers cachés '
          'sous Unix).',
      psCommand: 'Get-ChildItem -Force -Hidden /chemin',
      psExplanation:
          'Le paramètre -Hidden filtre spécifiquement les fichiers '
          'marqués cachés par le système de fichiers.',
      differences:
          'Sous Unix, "caché" signifie simplement que le nom commence par un '
          'point ; sous Windows le flag caché est un attribut NTFS distinct. '
          '-Force et -Hidden ont des comportements différents.',
    ),
    Comparison(
      id: 'comp_003',
      task: 'Créer un dossier',
      category: 'fichiers',
      bashCommand: 'mkdir nom_dossier',
      bashExplanation: 'Crée un répertoire nommé.',
      psCommand: 'New-Item -ItemType Directory -Name nom_dossier',
      psExplanation:
          'New-Item crée un objet filesystem de type Directory.',
      differences:
          'mkdir crée directement le dossier ; New-Item est une cmdlet '
          'générique qui peut créer différents types d\'éléments. '
          'PowerShell nécessite le paramètre -ItemType pour préciser '
          'qu\'il s\'agit d\'un dossier.',
    ),
    Comparison(
      id: 'comp_004',
      task: 'Supprimer un fichier',
      category: 'fichiers',
      bashCommand: 'rm fichier',
      bashExplanation: 'Supprime un fichier définitivement (pas de corbeille).',
      psCommand: 'Remove-Item fichier',
      psExplanation:
          'Supprime un fichier ou dossier. '
          'Sous Windows peut demander confirmation selon la config.',
      differences:
          'rm sous Linux supprime sans confirmation ni corbeille ; '
          'Remove-Item peut être intercepté par un provider et '
          'demander confirmation. Pour un comportement forcé, '
          'il faut ajouter -Force.',
    ),
    Comparison(
      id: 'comp_005',
      task: 'Copier un fichier',
      category: 'fichiers',
      bashCommand: 'cp source destination',
      bashExplanation: 'Copie le fichier source vers la destination.',
      psCommand: 'Copy-Item source destination',
      psExplanation: 'Copie un élément vers un autre emplacement.',
      differences:
          'cp -r est nécessaire pour les dossiers sous Bash ; '
          'Copy-Item copie les dossiers récursivement par défaut. '
          'En cas de collision de nom, cp écrase sans avertir, '
          'tandis que Copy-Item peut demander confirmation.',
    ),
    Comparison(
      id: 'comp_006',
      task: 'Déplacer un fichier',
      category: 'fichiers',
      bashCommand: 'mv source destination',
      bashExplanation: 'Déplace ou renomme un fichier/dossier.',
      psCommand: 'Move-Item source destination',
      psExplanation: 'Déplace un élément vers un autre emplacement.',
      differences:
          'mv et Move-Item ont un comportement similaire, mais '
          'Move-Item peut refuser d\'écraser sans -Force et '
          'peut échouer si le fichier est verrouillé par un processus Windows.',
    ),
    Comparison(
      id: 'comp_007',
      task: 'Renommer un fichier',
      category: 'fichiers',
      bashCommand: 'mv ancien_nom nouveau_nom',
      bashExplanation:
          'Un renommage est un déplacement vers le même répertoire.',
      psCommand: 'Rename-Item ancien_nom nouveau_nom',
      psExplanation:
          'Rename-Item est dédié au renommage sans changer '
          'de répertoire.',
      differences:
          'Bash utilise mv (déplacement) pour renommer, tandis que '
          'PowerShell a une cmdlet dédiée. C\'est purement une '
          'différence de sémantique ; le résultat est identique.',
    ),
    Comparison(
      id: 'comp_008',
      task: 'Afficher le contenu d\'un fichier',
      category: 'fichiers',
      bashCommand: 'cat fichier',
      bashExplanation: 'Affiche l\'intégralité du contenu dans le terminal.',
      psCommand: 'Get-Content fichier',
      psExplanation:
          'Lit le contenu d\'un fichier et le retourne sous forme '
          'de lignes (tableau de strings).',
      differences:
          'cat affiche directement le texte brut ; Get-Content retourne '
          'un tableau de lignes exploitable en pipeline. '
          'L\'encodage peut différer (UTF-8 par défaut en PowerShell Core).',
    ),
    Comparison(
      id: 'comp_009',
      task: 'Afficher les 10 premières lignes',
      category: 'fichiers',
      bashCommand: 'head -n 10 fichier',
      bashExplanation: 'Extrait et affiche les 10 premières lignes.',
      psCommand: 'Get-Content -Head 10 fichier',
      psExplanation:
          'Paramètre -Head de Get-Content qui lit seulement les '
          'N premières lignes.',
      differences:
          'head est une commande externe autonome ; '
          '-Head est un paramètre intégré de Get-Content. '
          'Les performances peuvent différer sur de très gros fichiers.',
    ),
    Comparison(
      id: 'comp_010',
      task: 'Afficher les 10 dernières lignes',
      category: 'fichiers',
      bashCommand: 'tail -n 10 fichier',
      bashExplanation: 'Extrait et affiche les 10 dernières lignes.',
      psCommand: 'Get-Content -Tail 10 fichier',
      psExplanation:
          'Paramètre -Tail de Get-Content qui lit les N dernières lignes.',
      differences:
          'tail -f permet un suivi en temps réel ; '
          'Get-Content -Tail n\'a pas d\'équivalent de suivi en temps réel '
          'intégral. La différence majeure est donc le suivi continu.',
    ),

    // ── Dossiers ──────────────────────────────────────────────
    Comparison(
      id: 'comp_011',
      task: 'Voir le répertoire courant',
      category: 'dossiers',
      bashCommand: 'pwd',
      bashExplanation: 'Affiche le chemin absolu du répertoire en cours.',
      psCommand: 'Get-Location',
      psExplanation:
          'Retourne l\'emplacement actuel du provider (pwd en alias).',
      differences:
          'pwd retourne une simple chaîne ; Get-Location retourne un objet '
          'avec des propriétés Path, Drive, Provider. '
          'Comportement quasi identique en usage courant.',
    ),
    Comparison(
      id: 'comp_012',
      task: 'Changer de répertoire',
      category: 'dossiers',
      bashCommand: 'cd /chemin/vers/dossier',
      bashExplanation: 'Change le répertoire de travail courant.',
      psCommand: 'Set-Location /chemin/vers/dossier',
      psExplanation:
          'Déplace l\'emplacement courant du provider. '
          'Set-Location est l\'alias cd dans PowerShell.',
      differences:
          'cd sous Bash change le shell courant ; '
          'Set-Location change le provider courant (peut être un '
          'rive de registre, un LDAP, etc.). '
          'cd est un alias de Set-Location dans PowerShell.',
    ),

    // ── Texte ─────────────────────────────────────────────────
    Comparison(
      id: 'comp_013',
      task: 'Rechercher du texte dans un fichier',
      category: 'texte',
      bashCommand: 'grep "mot" fichier',
      bashExplanation:
          'Recherche les lignes contenant "mot" et les affiche.',
      psCommand: 'Select-String -Pattern "mot" -Path fichier',
      psExplanation:
          'Select-String est le cmdlet PowerShell pour la recherche '
          'de texte dans des fichiers.',
      differences:
          'grep retourne le texte brut des lignes correspondantes ; '
          'Select-String retourne des objets avec LineNumber, Line, '
          'Filename. Le résultat est structuré et pipeline-friendly.',
    ),
    Comparison(
      id: 'comp_014',
      task: 'Rechercher du texte récursivement',
      category: 'texte',
      bashCommand: 'grep -r "mot" dossier/',
      bashExplanation:
          'Recherche récursivement "mot" dans tous les fichiers du dossier.',
      psCommand:
          'Get-ChildItem -Recurse dossier/ | Select-String "mot"',
      psExplanation:
          'Liste tous les fichiers récursivement puis pipe vers '
          'Select-String pour la recherche.',
      differences:
          'grep -r est une option native intégrée ; '
          'PowerShell combine deux cmdlets via un pipeline. '
          'La performance et le comportement de filtrage '
          '(types de fichiers) peuvent différer.',
    ),
    Comparison(
      id: 'comp_015',
      task: 'Trier les lignes d\'un fichier',
      category: 'texte',
      bashCommand: 'sort fichier',
      bashExplanation: 'Trie les lignes du fichier par ordre alphabétique.',
      psCommand: 'Get-Content fichier | Sort-Object',
      psExplanation:
          'Lit les lignes puis les trie via Sort-Object.',
      differences:
          'sort est une commande externe qui traite du texte brut ; '
          'Sort-Object peut trier des objets par propriétés. '
          'Avec du texte simple le résultat est similaire.',
    ),
    Comparison(
      id: 'comp_016',
      task: 'Compter les lignes d\'un fichier',
      category: 'texte',
      bashCommand: 'wc -l fichier',
      bashExplanation:
          'wc -l compte et affiche le nombre de lignes.',
      psCommand: '(Get-Content fichier).Count',
      psExplanation:
          'Charge toutes les lignes en mémoire puis compte le tableau.',
      differences:
          'wc -l est optimisé pour les gros fichiers et fonctionne en flux ; '
          'Get-Content charge tout en mémoire, ce qui peut être '
          'problématique pour de très grands fichiers.',
    ),
    Comparison(
      id: 'comp_017',
      task: 'Remplacer du texte dans un fichier',
      category: 'texte',
      bashCommand: "sed -i 's/ancien/nouveau/' fichier",
      bashExplanation:
          'sed édite le fichier en place, remplaçant la première occurrence '
          'de "ancien" par "nouveau" sur chaque ligne.',
      psCommand:
          "(Get-Content fichier) -replace 'ancien','nouveau' | "
          "Set-Content fichier",
      psExplanation:
          'Lit le fichier, applique un remplacement regex, '
          'puis réécrit le fichier.',
      differences:
          'sed modifie en place efficacement ; '
          'PowerShell doit tout charger en mémoire puis réécrire. '
          'Le modèle de regex diffère (BRE vs .NET regex). '
          'Les retours à la ligne peuvent être modifiés.',
    ),
    Comparison(
      id: 'comp_018',
      task: 'Écrire dans un fichier (écraser)',
      category: 'texte',
      bashCommand: 'echo "texte" > fichier',
      bashExplanation:
          '> redirige la sortie standard dans le fichier, '
          'écrasant son contenu précédent.',
      psCommand: 'Set-Content fichier "texte"',
      psExplanation: 'Écrit du contenu dans un fichier (écrase le précédent).',
      differences:
          '> sous Bash écrase sans avertir ; Set-Content peut '
          'être redirigé par un provider et comporter des pièges '
          'd\'encodage (BOM sous Windows par défaut en ancien PowerShell).',
    ),
    Comparison(
      id: 'comp_019',
      task: 'Ajouter du texte dans un fichier',
      category: 'texte',
      bashCommand: 'echo "texte" >> fichier',
      bashExplanation:
          '>> ajoute la sortie à la fin du fichier sans écraser.',
      psCommand: 'Add-Content fichier "texte"',
      psExplanation: 'Ajoute du contenu à la fin du fichier existant.',
      differences:
          '>> sous Bash ajoute en texte brut ; '
          'Add-Content peut ajouter avec un BOM selon l\'encodage. '
          'Le comportement est fonctionnellement similaire.',
    ),
    Comparison(
      id: 'comp_020',
      task: 'Concaténer des fichiers',
      category: 'texte',
      bashCommand: 'cat f1.txt f2.txt > combined.txt',
      bashExplanation:
          'Lit les deux fichiers et redirige la sortie dans combined.txt.',
      psCommand:
          'Get-Content f1.txt,f2.txt | Set-Content combined.txt',
      psExplanation:
          'Lit les deux fichiers via Get-Content puis écrit le résultat.',
      differences:
          'cat concatène en flux ; Get-Content charge en mémoire les '
          'deux fichiers. Pour de gros fichiers, la méthode Bash '
          'est plus efficace en termes de mémoire.',
    ),

    // ── Recherche ─────────────────────────────────────────────
    Comparison(
      id: 'comp_021',
      task: 'Trouver un fichier par nom',
      category: 'recherche',
      bashCommand: 'find . -name "*.txt"',
      bashExplanation:
          'Recherche récursivement tous les fichiers .txt dans '
          'le répertoire courant.',
      psCommand:
          'Get-ChildItem -Recurse -Filter "*.txt" .',
      psExplanation:
          'Liste tous les fichiers correspondant au filtre récursivement.',
      differences:
          'find est très puissant avec des critères complexes '
          '(mtime, taille, exécution de commandes) ; '
          'Get-ChildItem -Filter est plus simple mais limité. '
          'Get-ChildItem retourne des objets, find du texte brut.',
    ),

    // ── Processus ─────────────────────────────────────────────
    Comparison(
      id: 'comp_022',
      task: 'Voir les processus en cours',
      category: 'processus',
      bashCommand: 'ps aux',
      bashExplanation:
          'Affiche tous les processus en cours avec détails '
          '(utilisateur, CPU, mémoire).',
      psCommand: 'Get-Process',
      psExplanation:
          'Liste tous les processus en cours sous forme d\'objets.',
      differences:
          'ps aux affiche du texte brut formaté ; '
          'Get-Process retourne des objets Process avec des propriétés '
          'comme Id, ProcessName, CPU, WorkingSet64. '
          'Le format de sortie est complètement différent.',
    ),
    Comparison(
      id: 'comp_023',
      task: 'Tuer un processus',
      category: 'processus',
      bashCommand: 'kill PID',
      bashExplanation:
          'Envoie le signal SIGTERM (15) au processus identifié par PID.',
      psCommand: 'Stop-Process -Id PID',
      psExplanation:
          'Arrête le processus ayant l\'identifiant spécifié.',
      differences:
          'kill envoie un signal ; Stop-Process appelle .NET '
          'Process.Kill(). '
          'kill -9 (SIGKILL) est plus violent ; '
          'Stop-Process -Force est l\'équivalent. '
          'Les signaux Unix n\'existent pas sous Windows.',
    ),

    // ── Services ──────────────────────────────────────────────
    Comparison(
      id: 'comp_024',
      task: 'Voir les services système',
      category: 'services',
      bashCommand: 'systemctl list-units --type=service',
      bashExplanation:
          'Liste toutes les unités de type service gérées par systemd.',
      psCommand: 'Get-Service',
      psExplanation:
          'Liste tous les services enregistrés dans le SCM Windows.',
      differences:
          'systemctl est spécifique aux systèmes Linux avec systemd ; '
          'Get-Service utilise le Service Control Manager de Windows. '
          'Les noms et états des services diffèrent '
          '(running/stopped vs active/inactive).',
    ),
    Comparison(
      id: 'comp_025',
      task: 'Démarrer un service',
      category: 'services',
      bashCommand: 'systemctl start nom_service',
      bashExplanation: 'Démarre le service spécifié.',
      psCommand: 'Start-Service nom_service',
      psExplanation:
          'Démarre le service ayant le nom spécifié.',
      differences:
          'systemctl nécessite des privilèges root (sudo) ; '
          'Start-Service nécessite des droits administrateur. '
          'Le mécanisme sous-jacent (systemd vs SCM) est différent.',
    ),
    Comparison(
      id: 'comp_026',
      task: 'Arrêter un service',
      category: 'services',
      bashCommand: 'systemctl stop nom_service',
      bashExplanation: 'Arrête le service spécifié.',
      psCommand: 'Stop-Service nom_service',
      psExplanation:
          'Arrête le service ayant le nom spécifié.',
      differences:
          'Identique à démarrer mais dans le sens inverse. '
          'systemctl peut envoyer des signaux graduels ; '
          'Stop-Service est plus brutal par défaut.',
    ),

    // ── Réseau ────────────────────────────────────────────────
    Comparison(
      id: 'comp_027',
      task: 'Tester la connectivité réseau',
      category: 'réseau',
      bashCommand: 'ping hote',
      bashExplanation:
          'Envoie des paquets ICMP Echo Request à l\'hôte et '
          'affiche les réponses.',
      psCommand: 'Test-Connection hote',
      psExplanation:
          'Teste la connectivité via des paquets ICMP '
          '(similaire à ping).',
      differences:
          'ping affiche en continu ; Test-Connection envoie par défaut '
          '4 paquets et retourne des objets. '
          'ping est une commande externe, '
          'Test-Connection est un cmdlet PowerShell.',
    ),
    Comparison(
      id: 'comp_028',
      task: 'Télécharger un fichier',
      category: 'réseau',
      bashCommand: 'wget url -O fichier',
      bashExplanation:
          'Télécharge le fichier à l\'URL et le sauvegarde sous '
          'le nom spécifié.',
      psCommand:
          'Invoke-WebRequest url -OutFile fichier',
      psExplanation:
          'Effectue une requête HTTP et sauvegarde la réponse.',
      differences:
          'wget gère la reprise, les redirections, l\'authentification ; '
          'Invoke-WebRequest est plus basique. '
          'curl est souvent préféré sous Bash pour sa polyvalence. '
          'Invoke-WebRequest retourne un objet HTTPWebResponse.',
    ),
    Comparison(
      id: 'comp_029',
      task: 'Requête HTTP GET',
      category: 'réseau',
      bashCommand: 'curl url',
      bashExplanation:
          'Effectue une requête GET et affiche le corps de la réponse.',
      psCommand: 'Invoke-RestMethod url',
      psExplanation:
          'Effectue une requête REST et retourne le contenu décodé.',
      differences:
          'curl affiche le texte brut ; Invoke-RestMethod décode '
          'automatiquement JSON/XML en objets .NET. '
          'curl est plus flexible pour le débogage HTTP.',
    ),
    Comparison(
      id: 'comp_030',
      task: 'Requête HTTP POST',
      category: 'réseau',
      bashCommand: 'curl -X POST -d \'data\' url',
      bashExplanation:
          'Envoie une requête POST avec des données dans le corps.',
      psCommand:
          "Invoke-RestMethod -Uri url -Method Post -Body data",
      psExplanation:
          'Envoie une requête POST avec le corps spécifié.',
      differences:
          'curl nécessite -d ou --data pour les données ; '
          'Invoke-RestMethod utilise -Body. '
          'curl est plus explicite sur les headers, '
          'Invoke-RestMethod détecte le type de contenu automatiquement.',
    ),

    // ── Archives ──────────────────────────────────────────────
    Comparison(
      id: 'comp_031',
      task: 'Créer une archive compressée',
      category: 'archives',
      bashCommand: 'tar -czf archive.tar.gz dossier/',
      bashExplanation:
          'Crée une archive gzip (.tar.gz) du dossier spécifié.',
      psCommand:
          'Compress-Archive -Path dossier/ -DestinationPath archive.zip',
      psExplanation:
          'Crée une archive ZIP compressée du dossier.',
      differences:
          'tar crée des .tar.gz (gzip) ; Compress-Archive crée des .zip. '
          'Les formats de compression sont différents. '
          'tar est plus flexible (bzip2, xz, etc.), '
          'Compress-Archive est limité au ZIP.',
    ),
    Comparison(
      id: 'comp_032',
      task: 'Extraire une archive',
      category: 'archives',
      bashCommand: 'tar -xzf archive.tar.gz',
      bashExplanation:
          'Extrait une archive gzip dans le répertoire courant.',
      psCommand:
          'Expand-Archive -Path archive.zip -DestinationPath ./',
      psExplanation:
          'Extrait une archive ZIP vers la destination spécifiée.',
      differences:
          'tar traite les .tar.gz ; Expand-Archive traite les .zip. '
          'Le format d\'entrée est incompatible entre les deux. '
          'tar préserve les permissions Unix ; '
          'Expand-Archive ne gère pas les permissions NTFS spécifiques.',
    ),

    // ── Scripts ───────────────────────────────────────────────
    Comparison(
      id: 'comp_033',
      task: 'Lire une variable d\'environnement',
      category: 'scripts',
      bashCommand: 'echo \$VAR',
      bashExplanation:
          'Affiche la valeur de la variable d\'environnement VAR.',
      psCommand: 'Write-Output \$env:VAR',
      psExplanation:
          'Accède à la variable d\'environnement via \$env: et '
          'l\'affiche.',
      differences:
          'Bash utilise \$VAR (sans préfixe) ; '
          'PowerShell utilise \$env:VAR (préfixe obligatoire). '
          'La syntaxe d\'accès aux variables d\'environnement est '
          'fondamentalement différente.',
    ),
    Comparison(
      id: 'comp_034',
      task: 'Définir une variable d\'environnement',
      category: 'scripts',
      bashCommand: 'export VAR=value',
      bashExplanation:
          'Définit VAR pour la session courante et les sous-processus.',
      psCommand: '\$env:VAR = "value"',
      psExplanation:
          'Définit la variable d\'environnement pour la session PowerShell.',
      differences:
          'export rend la variable visible des sous-processus ; '
          '\$env:VAR est propre à la session PowerShell courante. '
          'Pour persister, il faut modifier le registre ou le profil.',
    ),
    Comparison(
      id: 'comp_035',
      task: 'Condition if/else',
      category: 'scripts',
      bashCommand: 'if [ condition ]; then\n  ...\nelse\n  ...\nfi',
      bashExplanation:
          'Exécute un bloc si la condition est vraie, sinon l\'alternative.',
      psCommand: 'if (\$condition) {\n  ...\n} else {\n  ...\n}',
      psExplanation:
          'Exécute un bloc si la condition est vraie, sinon l\'alternative.',
      differences:
          'Bash utilise [ ] ou [[ ]] avec des opérateurs spéciaux '
          '(-eq, -ne, etc.) ; PowerShell utilise des parenthèses () '
          'avec des opérateurs classiques (-eq, -ne mais en .NET). '
          'La syntaxe de fermeture diffère (fi vs }).',
    ),
    Comparison(
      id: 'comp_036',
      task: 'Boucle for',
      category: 'scripts',
      bashCommand: 'for i in 1 2 3; do\n  echo \$i\ndone',
      bashExplanation:
          'Itère sur une liste de valeurs et exécute le bloc pour chaque.',
      psCommand: 'foreach (\$i in 1..3) {\n  Write-Output \$i\n}',
      psExplanation:
          'Itère sur une plage de valeurs et exécute le bloc.',
      differences:
          'Bash utilise une syntaxe do/done ; '
          'PowerShell utilise des accolades {}. '
          'La plage 1..3 est une syntaxe PowerShell ; '
          'Bash utilise des séquences ou seq.',
    ),
    Comparison(
      id: 'comp_037',
      task: 'Définir une fonction',
      category: 'scripts',
      bashCommand: 'ma_fonction() {\n  echo "Hello"\n}',
      bashExplanation:
          'Définit une fonction avec une syntaxe POSIX.',
      psCommand: 'function Ma-Fonction {\n  Write-Output "Hello"\n}',
      psExplanation:
          'Définit une fonction avec la syntaxe PowerShell.',
      differences:
          'Bash utilise des parenthèses vides () ; '
          'PowerShell utilise le mot-clé function et des accolades. '
          'La convention de nommage diffère '
          '(snake_case vs PascalCase-PascalCase).',
    ),
    Comparison(
      id: 'comp_038',
      task: 'Convertir du JSON',
      category: 'scripts',
      bashCommand: 'cat fichier.json | jq .',
      bashExplanation:
          'jq formate et affiche le JSON de manière lisible.',
      psCommand:
          'Get-Content fichier.json | ConvertFrom-Json',
      psExplanation:
          'Convertit le JSON en objet PowerShell exploitable.',
      differences:
          'jq est un outil externe spécialisé ; '
          'ConvertFrom-Json est intégré à PowerShell. '
          'jq formate le texte ; ConvertFrom-Json crée des objets .NET. '
          'jq nécessite une installation séparée.',
    ),
    Comparison(
      id: 'comp_039',
      task: 'Exporter des colonnes CSV',
      category: 'scripts',
      bashCommand: "awk -F',' '{print \$1,\$2}' fichier.csv",
      bashExplanation:
          'Extrait les deux premières colonnes d\'un CSV séparé par des virgules.',
      psCommand:
          'Import-Csv fichier.csv | Select-Object Prop1,Prop2',
      psExplanation:
          'Importe le CSV en objets puis sélectionne les propriétés.',
      differences:
          'awk traite du texte brut avec des séparateurs ; '
          'Import-Csv crée des objets avec des noms de colonnes '
          '(première ligne comme en-tête). '
          'awk est plus flexible pour le traitement de texte, '
          'Import-Csv est plus structuré.',
    ),
    Comparison(
      id: 'comp_040',
      task: 'Afficher l\'historique des commandes',
      category: 'scripts',
      bashCommand: 'history',
      bashExplanation:
          'Affiche les commandes précédemment exécutées dans ce terminal.',
      psCommand: 'Get-History',
      psExplanation:
          'Retourne l\'historique des commandes de la session courante.',
      differences:
          'history affiche du texte brut ; '
          'Get-History retourne des objets HistoryInfo '
          'avec Id, CommandLine, ExecutionStatus. '
          'Invoke-History rejoue une commande par son Id.',
    ),
  ];
}
