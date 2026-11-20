import 'package:flutter_test/flutter_test.dart';
import 'package:shell_bash_bridge/features/lab/lab_missions.dart';

void main() {
  late VirtualFileSystem fs;
  setUp(() => fs = VirtualFileSystem());

  String bash(String c) => fs.executeBashCommand(c);
  String ps(String c) => fs.executePowerShellCommand(c);

  group('Bash', () {
    test('cp -r fait une copie indépendante (copie profonde)', () {
      bash('mkdir -p src/lib');
      bash('cp -r src backup');
      bash('touch backup/lib/nouveau.txt');
      expect(fs.isFile('~/backup/lib/nouveau.txt'), isTrue);
      expect(fs.isFile('~/src/lib/nouveau.txt'), isFalse);
    });

    test('mv dossier dans lui-même est refusé sans perte', () {
      bash('mkdir projects');
      final out = bash('mv projects projects');
      expect(out, contains('subdirectory of itself'));
      expect(fs.isDir('~/projects'), isTrue);
      expect(fs.isDir('~/projects/projects'), isFalse);
    });

    test('cp -r dans un sous-dossier de la source est refusé', () {
      bash('mkdir -p a/b');
      expect(bash('cp -r a a/b'), contains('into itself'));
    });

    test('chemins composés, .. et ~', () {
      bash('mkdir -p a/b/c');
      expect(bash('cd a/b/c'), '');
      expect(bash('pwd'), '/home/student/a/b/c');
      bash('cd ../..');
      expect(bash('pwd'), '/home/student/a');
      bash('touch ../f.txt');
      expect(fs.isFile('~/f.txt'), isTrue);
      bash('cd ~');
      expect(bash('ls a/b'), 'c/');
      expect(bash('cat bienvenue.txt'), contains('Bienvenue'));
      bash('cd -');
      expect(bash('pwd'), '/home/student/a');
    });

    test('options combinées -rf / -la', () {
      bash('mkdir -p d/e');
      bash('touch d/e/x');
      expect(bash('cp -rf d d2'), '');
      expect(fs.isFile('~/d2/e/x'), isTrue);
      expect(bash('rm -rf d'), '');
      expect(fs.isDir('~/d'), isFalse);
      expect(bash('ls -la'), contains('.bashrc'));
      expect(bash('ls'), isNot(contains('.bashrc')));
    });

    test('rm sans -r refuse un dossier, rm -f ignore les absents', () {
      bash('mkdir d');
      expect(bash('rm d'), contains('Is a directory'));
      expect(bash('rm -f inexistant'), '');
      expect(bash('rm inexistant'), contains('No such file'));
      expect(bash('rm -rf .'), contains('refusing'));
    });

    test('touch ignore les options', () {
      bash('touch -a fichier');
      expect(fs.isFile('~/fichier'), isTrue);
      expect(fs.isFile('~/-a'), isFalse);
    });

    test('guillemets et redirections', () {
      bash('mkdir "mon dossier"');
      expect(fs.isDir('~/mon dossier'), isTrue);
      bash('echo "ligne  1" > notes.txt');
      bash('echo ligne 2 >> notes.txt');
      expect(bash('cat notes.txt'), 'ligne  1\nligne 2');
      expect(bash('echo "non fermé'), contains('unexpected EOF'));
    });

    test('Bash est sensible à la casse', () {
      expect(bash('LS'), contains('command not found'));
    });

    test('rm du dossier courant remonte au parent', () {
      bash('mkdir -p x/y');
      bash('cd x/y');
      bash('rm -r ../../x');
      expect(bash('pwd'), '/home/student');
    });
  });

  group('PowerShell', () {
    test('alias, casse et chemins Windows', () {
      ps('mkdir src,docs');
      expect(fs.isDir('~/src') && fs.isDir('~/docs'), isTrue);
      ps('New-Item -ItemType File -Path docs\\a.txt -Value bonjour');
      expect(ps('get-content docs/a.txt'), 'bonjour');
      ps('SET-LOCATION C:\\home\\student\\docs');
      expect(fs.currentPathString, '/home/student/docs');
    });

    test('Copy-Item -Recurse (paramètre abrégé) et Remove-Item', () {
      ps('New-Item -ItemType Directory a/b');
      ps('Copy-Item a z -Rec');
      expect(fs.isDir('~/z/b'), isTrue);
      expect(ps('Remove-Item a'), contains('Recurse'));
      ps('Remove-Item a -Recurse');
      expect(fs.isDir('~/a'), isFalse);
    });

    test('paramètre inconnu', () {
      expect(ps('Get-ChildItem -Banane'), contains('cannot be found'));
    });
  });

  group('Missions', () {
    test('parcours complet validé sur l\'état', () {
      final engine = LabEngine();
      engine.processBashCommand('mkdir projects');
      engine.processBashCommand('cd projects');
      engine.processBashCommand('mkdir  src   docs'); // espaces multiples acceptés
      engine.processBashCommand('touch README.txt');
      engine.processBashCommand('mv README.txt docs/');
      engine.processBashCommand('ls');
      engine.processBashCommand('cp -r src backup');
      engine.processBashCommand('pwd');
      expect(engine.allMissionsCompleted, isTrue);
    });

    test('une commande en échec ne valide pas la mission', () {
      final engine = LabEngine();
      engine.processBashCommand('mkdir projets'); // faute de frappe
      expect(engine.completedMissions, 0);
    });

    test('missions réalisées en avance validées en chaîne', () {
      final engine = LabEngine();
      engine.processBashCommand('mkdir -p projects/src projects/docs');
      engine.processBashCommand('cd projects');
      expect(engine.completedMissions, 3);
    });

    test('mélange Bash / PowerShell', () {
      final engine = LabEngine();
      engine.processPowerShellCommand('New-Item -ItemType Directory projects');
      engine.processPowerShellCommand('cd projects');
      expect(engine.completedMissions, 2);
    });
  });

  group('Sauvegarde du Lab', () {
    test('missions, fichiers et dossier courant survivent à un redémarrage', () {
      final engine = LabEngine();
      engine.processBashCommand('mkdir projects');
      engine.processBashCommand('cd projects');
      engine.processBashCommand('echo "contenu" > note.txt');

      final copie = LabEngine();
      expect(copie.restore(engine.toJson()), isTrue);
      expect(copie.completedMissions, 2);
      expect(copie.currentMission!.id, 3);
      expect(copie.fileSystem.currentPathString, '/home/student/projects');
      expect(copie.processBashCommand('cat note.txt'), 'contenu');
    });

    test('un état corrompu est ignoré sans planter', () {
      final engine = LabEngine();
      expect(engine.restore({'fs': {'root': 'n\'importe quoi'}}), isFalse);
      expect(engine.restore({}), isFalse);
      expect(engine.fileSystem.currentPathString, '/home/student');
      expect(engine.completedMissions, 0);
    });
  });
}
