import 'dart:collection';

/// Séquence renvoyée par `clear` / `Clear-Host` : l'écran Lab vide alors le terminal.
const String kClearSequence = '\x1B[2J\x1B[0;0H';

// ---------------------------------------------------------------------------
// Système de fichiers virtuel
// ---------------------------------------------------------------------------

abstract class VNode {}

class VFile extends VNode {
  String content;
  VFile([this.content = '']);
}

class VDir extends VNode {
  final SplayTreeMap<String, VNode> children = SplayTreeMap<String, VNode>();
}

VNode _deepCopy(VNode node) {
  if (node is VFile) return VFile(node.content);
  final copy = VDir();
  (node as VDir).children.forEach((k, v) => copy.children[k] = _deepCopy(v));
  return copy;
}

void _merge(VDir into, VDir from) {
  from.children.forEach((name, node) {
    final existing = into.children[name];
    if (existing is VDir && node is VDir) {
      _merge(existing, node);
    } else {
      into.children[name] = _deepCopy(node);
    }
  });
}

bool _startsWith(List<String> path, List<String> prefix) {
  if (prefix.length > path.length) return false;
  for (var i = 0; i < prefix.length; i++) {
    if (path[i] != prefix[i]) return false;
  }
  return true;
}

class _Result {
  final String out;
  final bool ok;
  const _Result(this.out, [this.ok = true]);
  const _Result.err(this.out) : ok = false;
}

class _Parsed {
  final List<String> words;
  final String? redirect;
  final bool append;
  final String? error;
  const _Parsed(this.words, {this.redirect, this.append = false, this.error});
}

/// Découpe une ligne en mots (guillemets simples/doubles) et repère `>` / `>>`.
_Parsed _parseLine(String line) {
  final words = <String>[];
  final buf = StringBuffer();
  var inWord = false;
  String? quote;
  String? redirect;
  var append = false;
  var expectTarget = false;

  void flush() {
    if (!inWord) return;
    final w = buf.toString();
    buf.clear();
    inWord = false;
    if (expectTarget) {
      redirect = w;
      expectTarget = false;
    } else {
      words.add(w);
    }
  }

  for (var i = 0; i < line.length; i++) {
    final ch = line[i];
    if (quote != null) {
      if (ch == quote) {
        quote = null;
      } else {
        buf.write(ch);
      }
      continue;
    }
    if (ch == '"' || ch == "'") {
      quote = ch;
      inWord = true;
    } else if (ch == ' ' || ch == '\t') {
      flush();
    } else if (ch == '>') {
      flush();
      append = i + 1 < line.length && line[i + 1] == '>';
      if (append) i++;
      expectTarget = true;
    } else {
      buf.write(ch);
      inWord = true;
    }
  }
  if (quote != null) {
    return _Parsed(const [], error: "unexpected EOF while looking for matching `$quote'");
  }
  flush();
  if (expectTarget) {
    return const _Parsed([], error: "syntax error near unexpected token `newline'");
  }
  return _Parsed(words, redirect: redirect, append: append);
}

enum _TErr { srcMissing, needRecursive, intoItself, dstParentMissing, overwriteDir, overwriteFile, same, dirNotEmpty }

class VirtualFileSystem {
  static const List<String> home = ['home', 'student'];

  late VDir root;
  List<String> currentPath = [...home];
  List<String> _previousPath = [...home];

  /// Nom (canonique) de la dernière commande et succès, utilisés par les missions.
  String lastCommand = '';
  bool lastSucceeded = false;

  VirtualFileSystem() {
    reset();
  }

  void reset() {
    root = VDir();
    final student = VDir();
    student.children['.bashrc'] = VFile('# Fichier caché : visible avec ls -a');
    student.children['bienvenue.txt'] =
        VFile('Bienvenue dans le Lab !\nTapez help pour la liste des commandes.');
    final homeDir = VDir()..children['student'] = student;
    root.children['home'] = homeDir;
    currentPath = [...home];
    _previousPath = [...home];
    lastCommand = '';
    lastSucceeded = false;
  }

  // ----- Chemins ---------------------------------------------------------

  String get currentPathString => bashDisplay(currentPath);

  String bashDisplay(List<String> p) => '/${p.join('/')}';

  String psDisplay(List<String> p) => 'C:\\${p.join('\\')}';

  /// Chemin du prompt Bash, avec `~` pour le dossier personnel.
  String get bashPromptPath {
    if (_startsWith(currentPath, home)) {
      final rest = currentPath.sublist(home.length);
      return rest.isEmpty ? '~' : '~/${rest.join('/')}';
    }
    return currentPathString;
  }

  List<String> resolve(String path, {bool ps = false}) {
    var p = path;
    if (ps) {
      p = p.replaceAll('\\', '/');
      if (RegExp(r'^[a-zA-Z]:').hasMatch(p)) {
        p = p.substring(2);
        if (!p.startsWith('/')) p = '/$p';
      }
    }
    List<String> base;
    if (p.startsWith('/')) {
      base = [];
    } else if (p == '~' || p.startsWith('~/')) {
      base = [...home];
      p = p.substring(1);
    } else {
      base = [...currentPath];
    }
    for (final seg in p.split('/')) {
      if (seg.isEmpty || seg == '.') continue;
      if (seg == '..') {
        if (base.isNotEmpty) base.removeLast();
      } else {
        base.add(seg);
      }
    }
    return base;
  }

  VNode? nodeAt(List<String> path) {
    VNode node = root;
    for (final seg in path) {
      if (node is! VDir) return null;
      final child = node.children[seg];
      if (child == null) return null;
      node = child;
    }
    return node;
  }

  bool isDir(String absPath) => nodeAt(resolve(absPath)) is VDir;
  bool isFile(String absPath) => nodeAt(resolve(absPath)) is VFile;

  VDir? _parentOf(List<String> path) {
    if (path.isEmpty) return null;
    final parent = nodeAt(path.sublist(0, path.length - 1));
    return parent is VDir ? parent : null;
  }

  void _afterRemoval(List<String> removed) {
    if (_startsWith(currentPath, removed)) {
      currentPath = removed.sublist(0, removed.length - 1);
    }
  }

  // ----- Copie / déplacement communs -------------------------------------

  _TErr? _transfer(List<String> src, List<String> dst,
      {required bool move, required bool recursive, bool emptyDirIfNotRecursive = false}) {
    final srcNode = nodeAt(src);
    if (srcNode == null) return _TErr.srcMissing;
    if (src.isEmpty) return _TErr.intoItself;

    var node = srcNode;
    if (!move && srcNode is VDir && !recursive) {
      if (!emptyDirIfNotRecursive) return _TErr.needRecursive;
      node = VDir();
    }

    final dstNode = nodeAt(dst);
    final finalPath = dstNode is VDir ? [...dst, src.last] : dst;
    if (finalPath.isEmpty) return _TErr.same;

    if (finalPath.length == src.length && _startsWith(finalPath, src)) return _TErr.same;
    if (srcNode is VDir && _startsWith(finalPath, src)) return _TErr.intoItself;

    final parent = _parentOf(finalPath);
    if (parent == null) return _TErr.dstParentMissing;

    final existing = parent.children[finalPath.last];
    if (existing is VDir && node is VFile) return _TErr.overwriteDir;
    if (existing is VFile && node is VDir) return _TErr.overwriteFile;

    if (move) {
      if (existing is VDir && existing.children.isNotEmpty) return _TErr.dirNotEmpty;
      _parentOf(src)!.children.remove(src.last);
      parent.children[finalPath.last] = srcNode;
      if (_startsWith(currentPath, src)) {
        currentPath = [...finalPath, ...currentPath.sublist(src.length)];
      }
    } else if (existing is VDir && node is VDir) {
      _merge(existing, node);
    } else {
      parent.children[finalPath.last] = _deepCopy(node);
    }
    return null;
  }

  // ----- Redirection ------------------------------------------------------

  String? _writeRedirect(String target, String text, bool append, {required bool ps}) {
    final path = resolve(target, ps: ps);
    final node = nodeAt(path);
    if (node is VDir || path.isEmpty) {
      return ps ? "Out-File : Access to the path '${psDisplay(path)}' is denied." : 'bash: $target: Is a directory';
    }
    final parent = _parentOf(path);
    if (parent == null) {
      return ps
          ? "Out-File : Could not find a part of the path '${psDisplay(path)}'."
          : 'bash: $target: No such file or directory';
    }
    if (node is VFile && append) {
      node.content = node.content.isEmpty ? text : '${node.content}\n$text';
    } else {
      parent.children[path.last] = VFile(text);
    }
    return null;
  }

  String _finish(_Result r, _Parsed parsed, {required bool ps}) {
    lastSucceeded = r.ok;
    if (parsed.redirect != null && r.ok && r.out != kClearSequence) {
      final err = _writeRedirect(parsed.redirect!, r.out, parsed.append, ps: ps);
      if (err != null) {
        lastSucceeded = false;
        return err;
      }
      return '';
    }
    return r.out;
  }

  // =======================================================================
  // Bash
  // =======================================================================

  static const Map<String, String> _longFlags = {
    'recursive': 'r',
    'force': 'f',
    'all': 'a',
    'parents': 'p',
  };

  (Set<String>, List<String>) _bashFlags(List<String> args) {
    final flags = <String>{};
    final operands = <String>[];
    var endOfOptions = false;
    for (final a in args) {
      if (!endOfOptions && a == '--') {
        endOfOptions = true;
      } else if (!endOfOptions && a.startsWith('--') && a.length > 2) {
        final name = a.substring(2);
        flags.add(_longFlags[name] ?? name);
      } else if (!endOfOptions && a.startsWith('-') && a.length > 1) {
        flags.addAll(a.substring(1).split('')); // -rf => {r, f}
      } else {
        operands.add(a);
      }
    }
    return (flags, operands);
  }

  String executeBashCommand(String line) {
    lastCommand = '';
    lastSucceeded = false;
    final parsed = _parseLine(line.trim());
    if (parsed.error != null) return 'bash: ${parsed.error}';
    if (parsed.words.isEmpty) return '';

    // Bash est sensible à la casse : « LS » n'est pas « ls ».
    final cmd = parsed.words.first;
    final args = parsed.words.sublist(1);
    lastCommand = cmd;

    final _Result r;
    switch (cmd) {
      case 'pwd':
        r = _Result(currentPathString);
      case 'ls':
        r = _ls(args);
      case 'cd':
        r = _cd(args);
      case 'mkdir':
        r = _mkdir(args);
      case 'rmdir':
        r = _rmdir(args);
      case 'touch':
        r = _touch(args);
      case 'cp':
        r = _cpMv(args, move: false);
      case 'mv':
        r = _cpMv(args, move: true);
      case 'rm':
        r = _rm(args);
      case 'cat':
        r = _cat(args);
      case 'echo':
        final words = (args.isNotEmpty && args.first == '-n') ? args.sublist(1) : args;
        r = _Result(words.join(' '));
      case 'clear':
        r = const _Result(kClearSequence);
      case 'help':
        r = _Result(_bashHelp());
      default:
        r = _Result.err('bash: $cmd: command not found');
    }
    return _finish(r, parsed, ps: false);
  }

  _Result _ls(List<String> args) {
    final (flags, operands) = _bashFlags(args);
    final long = flags.contains('l');
    final all = flags.contains('a');
    final targets = operands.isEmpty ? ['.'] : operands;
    final out = <String>[];
    var ok = true;

    String longLine(String name, VNode n) {
      final isDir = n is VDir;
      final size = isDir ? '4096' : '${(n as VFile).content.length}';
      return '${isDir ? 'drwxr-xr-x' : '-rw-r--r--'} 1 student student ${size.padLeft(5)} Jan 26 12:00 $name';
    }

    for (final t in targets) {
      final n = nodeAt(resolve(t));
      if (n == null) {
        out.add("ls: cannot access '$t': No such file or directory");
        ok = false;
        continue;
      }
      if (n is VFile) {
        out.add(long ? longLine(t, n) : t);
        continue;
      }
      if (targets.length > 1) out.add('$t:');
      final dir = n as VDir;
      final names = <String>[
        if (all) ...['.', '..'],
        ...dir.children.keys.where((k) => all || !k.startsWith('.')),
      ];
      for (final name in names) {
        final child = (name == '.' || name == '..') ? VDir() : dir.children[name]!;
        if (long) {
          out.add(longLine(name, child));
        } else {
          out.add(child is VDir && name != '.' && name != '..' ? '$name/' : name);
        }
      }
    }
    return _Result(out.join('\n'), ok);
  }

  _Result _cd(List<String> args) {
    final (_, operands) = _bashFlags(args);
    if (operands.length > 1) return const _Result.err('bash: cd: too many arguments');
    if (operands.isEmpty || operands.first == '~') {
      _previousPath = currentPath;
      currentPath = [...home];
      return const _Result('');
    }
    final target = operands.first;
    if (target == '-') {
      final tmp = currentPath;
      currentPath = _previousPath;
      _previousPath = tmp;
      return _Result(currentPathString);
    }
    final path = resolve(target);
    final node = nodeAt(path);
    if (node == null) return _Result.err('bash: cd: $target: No such file or directory');
    if (node is VFile) return _Result.err('bash: cd: $target: Not a directory');
    _previousPath = currentPath;
    currentPath = path;
    return const _Result('');
  }

  _Result _mkdir(List<String> args) {
    final (flags, operands) = _bashFlags(args);
    final parents = flags.contains('p');
    if (operands.isEmpty) return const _Result.err('mkdir: missing operand');
    final errors = <String>[];
    for (final t in operands) {
      final path = resolve(t);
      final existing = nodeAt(path);
      if (existing != null) {
        if (!(parents && existing is VDir)) {
          errors.add("mkdir: cannot create directory '$t': File exists");
        }
        continue;
      }
      if (parents) {
        VDir dir = root;
        for (final seg in path) {
          final child = dir.children[seg];
          if (child is VFile) {
            errors.add("mkdir: cannot create directory '$t': Not a directory");
            break;
          }
          dir = (child as VDir?) ?? (dir.children[seg] = VDir());
        }
      } else {
        final parent = _parentOf(path);
        if (parent == null) {
          errors.add("mkdir: cannot create directory '$t': No such file or directory");
        } else {
          parent.children[path.last] = VDir();
        }
      }
    }
    return _Result(errors.join('\n'), errors.isEmpty);
  }

  _Result _rmdir(List<String> args) {
    final (_, operands) = _bashFlags(args);
    if (operands.isEmpty) return const _Result.err('rmdir: missing operand');
    final errors = <String>[];
    for (final t in operands) {
      final path = resolve(t);
      final node = nodeAt(path);
      if (node == null) {
        errors.add("rmdir: failed to remove '$t': No such file or directory");
      } else if (node is VFile) {
        errors.add("rmdir: failed to remove '$t': Not a directory");
      } else if ((node as VDir).children.isNotEmpty) {
        errors.add("rmdir: failed to remove '$t': Directory not empty");
      } else if (path.isEmpty) {
        errors.add("rmdir: failed to remove '/': Device or resource busy");
      } else {
        _parentOf(path)!.children.remove(path.last);
        _afterRemoval(path);
      }
    }
    return _Result(errors.join('\n'), errors.isEmpty);
  }

  _Result _touch(List<String> args) {
    final (_, operands) = _bashFlags(args); // les options (-a, -m...) sont ignorées
    if (operands.isEmpty) return const _Result.err('touch: missing file operand');
    final errors = <String>[];
    for (final t in operands) {
      final path = resolve(t);
      if (nodeAt(path) != null) continue;
      final parent = _parentOf(path);
      if (parent == null) {
        errors.add("touch: cannot touch '$t': No such file or directory");
      } else {
        parent.children[path.last] = VFile();
      }
    }
    return _Result(errors.join('\n'), errors.isEmpty);
  }

  _Result _cpMv(List<String> args, {required bool move}) {
    final prog = move ? 'mv' : 'cp';
    final (flags, operands) = _bashFlags(args);
    final recursive = flags.contains('r') || flags.contains('R');
    if (operands.isEmpty) return _Result.err('$prog: missing file operand');
    if (operands.length == 1) {
      return _Result.err("$prog: missing destination file operand after '${operands.first}'");
    }
    final dstArg = operands.last;
    final dst = resolve(dstArg);
    final sources = operands.sublist(0, operands.length - 1);
    if (sources.length > 1 && nodeAt(dst) is! VDir) {
      return _Result.err("$prog: target '$dstArg' is not a directory");
    }
    final errors = <String>[];
    for (final s in sources) {
      final err = _transfer(resolve(s), dst, move: move, recursive: recursive);
      if (err == null) continue;
      errors.add(switch (err) {
        _TErr.srcMissing => "$prog: cannot stat '$s': No such file or directory",
        _TErr.needRecursive => "cp: -r not specified; omitting directory '$s'",
        _TErr.intoItself => move
            ? "mv: cannot move '$s' to a subdirectory of itself, '$dstArg/$s'"
            : "cp: cannot copy a directory, '$s', into itself, '$dstArg/$s'",
        _TErr.dstParentMissing => move
            ? "mv: cannot move '$s' to '$dstArg': No such file or directory"
            : "cp: cannot create regular file '$dstArg': No such file or directory",
        _TErr.overwriteDir => "$prog: cannot overwrite directory '$dstArg' with non-directory",
        _TErr.overwriteFile => "$prog: cannot overwrite non-directory '$dstArg' with directory '$s'",
        _TErr.same => "$prog: '$s' and '$dstArg' are the same file",
        _TErr.dirNotEmpty => "mv: cannot move '$s' to '$dstArg': Directory not empty",
      });
    }
    return _Result(errors.join('\n'), errors.isEmpty);
  }

  _Result _rm(List<String> args) {
    final (flags, operands) = _bashFlags(args);
    final recursive = flags.contains('r') || flags.contains('R');
    final force = flags.contains('f');
    if (operands.isEmpty) {
      return force ? const _Result('') : const _Result.err('rm: missing operand');
    }
    final errors = <String>[];
    for (final t in operands) {
      final last = t.split('/').where((s) => s.isNotEmpty).lastOrNull ?? '';
      if (last == '.' || last == '..') {
        errors.add("rm: refusing to remove '.' or '..' directory: skipping '$t'");
        continue;
      }
      final path = resolve(t);
      if (path.isEmpty) {
        errors.add(recursive
            ? "rm: it is dangerous to operate recursively on '/'"
            : "rm: cannot remove '/': Is a directory");
        continue;
      }
      final node = nodeAt(path);
      if (node == null) {
        if (!force) errors.add("rm: cannot remove '$t': No such file or directory");
        continue;
      }
      if (node is VDir && !recursive) {
        errors.add("rm: cannot remove '$t': Is a directory");
        continue;
      }
      _parentOf(path)!.children.remove(path.last);
      _afterRemoval(path);
    }
    return _Result(errors.join('\n'), errors.isEmpty);
  }

  _Result _cat(List<String> args) {
    final (_, operands) = _bashFlags(args);
    if (operands.isEmpty) return const _Result.err('cat: missing file operand');
    final out = <String>[];
    var ok = true;
    for (final t in operands) {
      final node = nodeAt(resolve(t));
      if (node == null) {
        out.add('cat: $t: No such file or directory');
        ok = false;
      } else if (node is VDir) {
        out.add('cat: $t: Is a directory');
        ok = false;
      } else {
        out.add((node as VFile).content);
      }
    }
    return _Result(out.join('\n'), ok);
  }

  String _bashHelp() => '''Commandes disponibles :
  pwd                 Afficher le dossier courant
  ls [-l] [-a] [chem] Lister un dossier
  cd [chemin|..|~|-]  Changer de dossier
  mkdir [-p] <nom>    Créer un dossier
  rmdir <nom>         Supprimer un dossier vide
  touch <fichier>     Créer un fichier vide
  cp [-r] <src> <dst> Copier
  mv <src> <dst>      Déplacer / renommer
  rm [-r] [-f] <nom>  Supprimer
  cat <fichier>       Afficher un fichier
  echo <texte>        Afficher du texte (echo x > f, echo x >> f)
  clear               Effacer le terminal
  help                Afficher cette aide''';

  // =======================================================================
  // PowerShell
  // =======================================================================

  static const Map<String, String> _psAliases = {
    'gl': 'get-location', 'pwd': 'get-location',
    'gci': 'get-childitem', 'ls': 'get-childitem', 'dir': 'get-childitem',
    'sl': 'set-location', 'cd': 'set-location', 'chdir': 'set-location',
    'ni': 'new-item', 'md': 'mkdir',
    'cpi': 'copy-item', 'cp': 'copy-item', 'copy': 'copy-item',
    'mi': 'move-item', 'mv': 'move-item', 'move': 'move-item',
    'ri': 'remove-item', 'rm': 'remove-item', 'del': 'remove-item',
    'erase': 'remove-item', 'rd': 'remove-item', 'rmdir': 'remove-item',
    'gc': 'get-content', 'cat': 'get-content', 'type': 'get-content',
    'echo': 'write-output', 'write': 'write-output',
    'cls': 'clear-host', 'clear': 'clear-host',
    'help': 'get-help', 'man': 'get-help',
  };

  String executePowerShellCommand(String line) {
    lastCommand = '';
    lastSucceeded = false;
    final parsed = _parseLine(line.trim());
    if (parsed.error != null) {
      return 'ParserError: The string is missing the terminator.';
    }
    if (parsed.words.isEmpty) return '';

    final typed = parsed.words.first;
    final lower = typed.toLowerCase(); // PowerShell n'est pas sensible à la casse
    final cmd = _psAliases[lower] ?? lower;
    final args = parsed.words.sublist(1);
    lastCommand = cmd == 'mkdir' ? 'new-item' : cmd;

    _Result r;
    try {
      switch (cmd) {
        case 'get-location':
          r = _Result('\nPath\n----\n${psDisplay(currentPath)}\n');
        case 'get-childitem':
          r = _getChildItem(args);
        case 'set-location':
          r = _setLocation(args);
        case 'new-item':
          r = _newItem(args, forceDirectory: false);
        case 'mkdir':
          r = _newItem(args, forceDirectory: true);
        case 'copy-item':
          r = _copyMoveItem(args, move: false);
        case 'move-item':
          r = _copyMoveItem(args, move: true);
        case 'remove-item':
          r = _removeItem(args);
        case 'get-content':
          r = _getContent(args);
        case 'write-output':
          r = _Result(args.join('\n'));
        case 'clear-host':
          r = const _Result(kClearSequence);
        case 'get-help':
          r = _Result(_psHelp());
        default:
          r = _Result.err(
              "$typed : The term '$typed' is not recognized as a name of a cmdlet, function, script file, or executable program.\n"
              'Check the spelling of the name, or if a path was included, verify that the path is correct and try again.');
      }
    } on _PsParamError catch (e) {
      r = _Result.err('${_psName(cmd)} : ${e.message}');
    }
    return _finish(r, parsed, ps: true);
  }

  static String _psName(String cmd) =>
      cmd.split('-').map((w) => w.isEmpty ? w : w[0].toUpperCase() + w.substring(1)).join('-');

  /// Analyse les paramètres nommés (préfixes acceptés, insensible à la casse).
  _PsArgs _psParse(List<String> args,
      {List<String> values = const [], List<String> switches = const []}) {
    final named = <String, String>{};
    final sw = <String>{};
    final positional = <String>[];
    final all = [...values, ...switches];
    for (var i = 0; i < args.length; i++) {
      final a = args[i];
      if (a.length > 1 && a.startsWith('-') && RegExp(r'[a-zA-Z]').hasMatch(a[1])) {
        final name = a.substring(1).split(':').first.toLowerCase();
        final exact = all.where((p) => p.toLowerCase() == name).toList();
        final matches = exact.isNotEmpty ? exact : all.where((p) => p.toLowerCase().startsWith(name)).toList();
        if (matches.isEmpty) {
          throw _PsParamError("A parameter cannot be found that matches parameter name '${a.substring(1)}'.");
        }
        if (matches.length > 1) {
          throw _PsParamError("Parameter cannot be processed because the parameter name '${a.substring(1)}' is ambiguous. Possible matches include: ${matches.map((m) => '-$m').join(' ')}.");
        }
        final p = matches.first;
        if (switches.contains(p)) {
          sw.add(p);
        } else {
          if (i + 1 >= args.length) throw _PsParamError("Missing an argument for parameter '$p'.");
          named[p] = args[++i];
        }
      } else {
        positional.add(a);
      }
    }
    return _PsArgs(named, sw, positional);
  }

  static List<String> _splitList(String v) =>
      v.split(',').map((s) => s.trim()).where((s) => s.isNotEmpty).toList();

  String _psTime() {
    final d = DateTime.now();
    String two(int n) => n.toString().padLeft(2, '0');
    return '${two(d.day)}/${two(d.month)}/${d.year} ${two(d.hour)}:${two(d.minute)}';
  }

  String _psRow(String name, VNode n) {
    final isDir = n is VDir;
    final length = isDir ? '' : '${(n as VFile).content.length}';
    return '${isDir ? 'd----' : '-a---'}       ${_psTime()} ${length.padLeft(14)} $name';
  }

  String _psHeader(List<String> dir) =>
      '\n    Directory: ${psDisplay(dir)}\n\n'
      'Mode                 LastWriteTime         Length Name\n'
      '----                 -------------         ------ ----';

  _Result _getChildItem(List<String> args) {
    final a = _psParse(args, values: ['Path', 'LiteralPath'], switches: ['Force', 'Name', 'Recurse']);
    final target = a.named['Path'] ?? a.named['LiteralPath'] ?? (a.positional.isNotEmpty ? a.positional.first : '.');
    final path = resolve(target, ps: true);
    final node = nodeAt(path);
    if (node == null) {
      return _Result.err("Get-ChildItem : Cannot find path '${psDisplay(path)}' because it does not exist.");
    }
    if (node is VFile) {
      return _Result(a.switches.contains('Name') ? path.last : '${_psHeader(path.sublist(0, path.length - 1))}\n${_psRow(path.last, node)}');
    }
    final dir = node as VDir;
    final names = dir.children.keys.where((k) => a.switches.contains('Force') || !k.startsWith('.')).toList();
    if (names.isEmpty) return const _Result('');
    if (a.switches.contains('Name')) return _Result(names.join('\n'));
    return _Result([_psHeader(path), ...names.map((n) => _psRow(n, dir.children[n]!))].join('\n'));
  }

  _Result _setLocation(List<String> args) {
    final a = _psParse(args, values: ['Path', 'LiteralPath']);
    final target = a.named['Path'] ?? a.named['LiteralPath'] ?? (a.positional.isNotEmpty ? a.positional.first : '~');
    if (target == '-') {
      final tmp = currentPath;
      currentPath = _previousPath;
      _previousPath = tmp;
      return const _Result('');
    }
    final path = resolve(target, ps: true);
    final node = nodeAt(path);
    if (node is! VDir) {
      return _Result.err("Set-Location : Cannot find path '${psDisplay(path)}' because it does not exist.");
    }
    _previousPath = currentPath;
    currentPath = path;
    return const _Result('');
  }

  _Result _newItem(List<String> args, {required bool forceDirectory}) {
    final a = _psParse(args, values: ['Path', 'Name', 'ItemType', 'Type', 'Value'], switches: ['Force']);
    final pathArg = a.named['Path'] ?? (a.positional.isNotEmpty ? a.positional[0] : null);
    final nameArg = a.named['Name'] ?? (a.positional.length > 1 ? a.positional[1] : null);
    final type = (forceDirectory ? 'directory' : (a.named['ItemType'] ?? a.named['Type'] ?? 'file')).toLowerCase();
    final isDir = type == 'directory' || type == 'container';
    if (!isDir && type != 'file') {
      return const _Result.err('New-Item : The type is not a known type for the file system. Only "file" and "directory" can be specified.');
    }
    if (pathArg == null && nameArg == null) {
      return const _Result.err("New-Item : Cannot bind argument to parameter 'Path' because it is null.");
    }
    final targets = pathArg == null
        ? [nameArg!]
        : _splitList(pathArg).map((p) => nameArg == null ? p : '$p/$nameArg').toList();

    final rows = <String>[];
    final errors = <String>[];
    List<String>? shownDir;
    for (final t in targets) {
      final path = resolve(t, ps: true);
      if (path.isEmpty) {
        errors.add("New-Item : An item with the specified name ${psDisplay(path)} already exists.");
        continue;
      }
      final existing = nodeAt(path);
      if (existing != null && !(a.switches.contains('Force') && existing is VFile && !isDir)) {
        errors.add('New-Item : An item with the specified name ${psDisplay(path)} already exists.');
        continue;
      }
      // Comme PowerShell : les dossiers intermédiaires sont créés pour un dossier ou avec -Force.
      VDir? parent = _parentOf(path);
      if (parent == null && (isDir || a.switches.contains('Force'))) {
        VDir dir = root;
        var blocked = false;
        for (final seg in path.sublist(0, path.length - 1)) {
          final child = dir.children[seg];
          if (child is VFile) {
            blocked = true;
            break;
          }
          dir = (child as VDir?) ?? (dir.children[seg] = VDir());
        }
        parent = blocked ? null : dir;
      }
      if (parent == null) {
        errors.add("New-Item : Could not find a part of the path '${psDisplay(path)}'.");
        continue;
      }
      final node = isDir ? VDir() : VFile(a.named['Value'] ?? '');
      parent.children[path.last] = node;
      final dirPath = path.sublist(0, path.length - 1);
      if (shownDir == null || shownDir.join('/') != dirPath.join('/')) {
        rows.add(_psHeader(dirPath));
        shownDir = dirPath;
      }
      rows.add(_psRow(path.last, node));
    }
    return _Result([...rows, ...errors].join('\n'), errors.isEmpty);
  }

  _Result _copyMoveItem(List<String> args, {required bool move}) {
    final name = move ? 'Move-Item' : 'Copy-Item';
    final a = _psParse(args,
        values: ['Path', 'Destination', 'LiteralPath'],
        switches: move ? ['Force'] : ['Recurse', 'Force', 'Container']);
    final pos = [...a.positional];
    final src = a.named['Path'] ?? a.named['LiteralPath'] ?? (pos.isNotEmpty ? pos.removeAt(0) : null);
    final dst = a.named['Destination'] ?? (pos.isNotEmpty ? pos.removeAt(0) : null);
    if (src == null) return _Result.err("$name : Cannot bind argument to parameter 'Path' because it is null.");
    if (dst == null) return _Result.err("$name : Missing an argument for parameter 'Destination'.");

    final dstPath = resolve(dst, ps: true);
    final errors = <String>[];
    for (final s in _splitList(src)) {
      final srcPath = resolve(s, ps: true);
      final err = _transfer(srcPath, dstPath,
          move: move, recursive: a.switches.contains('Recurse'), emptyDirIfNotRecursive: true);
      if (err == null) continue;
      errors.add(switch (err) {
        _TErr.srcMissing => "$name : Cannot find path '${psDisplay(srcPath)}' because it does not exist.",
        _TErr.intoItself => '$name : The destination folder is a subfolder of the source folder.',
        _TErr.dstParentMissing => "$name : Could not find a part of the path '${psDisplay(dstPath)}'.",
        _TErr.same => '$name : Cannot overwrite the item ${psDisplay(srcPath)} with itself.',
        _TErr.overwriteDir || _TErr.overwriteFile || _TErr.dirNotEmpty || _TErr.needRecursive =>
          "$name : An item with the specified name ${psDisplay(dstPath)} already exists.",
      });
    }
    return _Result(errors.join('\n'), errors.isEmpty);
  }

  _Result _removeItem(List<String> args) {
    final a = _psParse(args, values: ['Path', 'LiteralPath'], switches: ['Recurse', 'Force']);
    final raw = a.named['Path'] ?? a.named['LiteralPath'] ?? a.positional.join(',');
    final targets = _splitList(raw);
    if (targets.isEmpty) return const _Result.err("Remove-Item : Cannot bind argument to parameter 'Path' because it is null.");
    final errors = <String>[];
    for (final t in targets) {
      final path = resolve(t, ps: true);
      final node = nodeAt(path);
      if (node == null) {
        errors.add("Remove-Item : Cannot find path '${psDisplay(path)}' because it does not exist.");
        continue;
      }
      if (path.isEmpty) {
        errors.add("Remove-Item : Cannot remove the root directory '${psDisplay(path)}'.");
        continue;
      }
      if (node is VDir && node.children.isNotEmpty && !a.switches.contains('Recurse')) {
        errors.add('Remove-Item : The item at ${psDisplay(path)} has children and the Recurse parameter was not specified.');
        continue;
      }
      _parentOf(path)!.children.remove(path.last);
      _afterRemoval(path);
    }
    return _Result(errors.join('\n'), errors.isEmpty);
  }

  _Result _getContent(List<String> args) {
    final a = _psParse(args, values: ['Path', 'LiteralPath']);
    final raw = a.named['Path'] ?? a.named['LiteralPath'] ?? a.positional.join(',');
    final targets = _splitList(raw);
    if (targets.isEmpty) return const _Result.err("Get-Content : Cannot bind argument to parameter 'Path' because it is null.");
    final out = <String>[];
    var ok = true;
    for (final t in targets) {
      final path = resolve(t, ps: true);
      final node = nodeAt(path);
      if (node == null) {
        out.add("Get-Content : Cannot find path '${psDisplay(path)}' because it does not exist.");
        ok = false;
      } else if (node is VDir) {
        out.add("Get-Content : Unable to get content because it is a directory: '${psDisplay(path)}'.");
        ok = false;
      } else {
        out.add((node as VFile).content);
      }
    }
    return _Result(out.join('\n'), ok);
  }

  String _psHelp() => '''Cmdlets disponibles (alias entre parenthèses) :
  Get-Location (pwd, gl)              Dossier courant
  Get-ChildItem [-Force] (ls, dir)    Lister un dossier
  Set-Location <chemin> (cd)          Changer de dossier
  New-Item <nom> [-ItemType Directory] Créer un fichier / dossier
  mkdir <nom>[,<nom2>]                Créer un ou plusieurs dossiers
  Copy-Item <src> <dst> [-Recurse]    Copier (cp)
  Move-Item <src> <dst> (mv)          Déplacer / renommer
  Remove-Item <nom> [-Recurse] (rm)   Supprimer
  Get-Content <fichier> (cat)         Afficher un fichier
  Write-Output <texte> (echo)         Afficher du texte (> et >> acceptés)
  Clear-Host (cls)                    Effacer le terminal
  Get-Help (help)                     Afficher cette aide''';
}

class _PsArgs {
  final Map<String, String> named;
  final Set<String> switches;
  final List<String> positional;
  const _PsArgs(this.named, this.switches, this.positional);
}

class _PsParamError implements Exception {
  final String message;
  _PsParamError(this.message);
}

// ---------------------------------------------------------------------------
// Missions
// ---------------------------------------------------------------------------

class LabMission {
  final int id;
  final String title;
  final String objective;

  /// Exemples de commandes valides (affichés dans l'interface).
  final List<String> expectedCommands;
  final List<String> hints;

  /// Condition de réussite, vérifiée sur l'état réel du système de fichiers.
  final bool Function(VirtualFileSystem fs) isAchieved;
  bool isCompleted;

  LabMission({
    required this.id,
    required this.title,
    required this.objective,
    required this.expectedCommands,
    required this.hints,
    required this.isAchieved,
    this.isCompleted = false,
  });

  LabMission copy() => LabMission(
        id: id,
        title: title,
        objective: objective,
        expectedCommands: List.of(expectedCommands),
        hints: List.of(hints),
        isAchieved: isAchieved,
      );
}

const String _p = '/home/student/projects';

bool _ran(VirtualFileSystem fs, Set<String> commands) =>
    fs.lastSucceeded && commands.contains(fs.lastCommand);

final List<LabMission> labMissions = [
  LabMission(
    id: 1,
    title: 'Créez un dossier projects',
    objective: 'Utilisez la commande mkdir pour créer un dossier nommé "projects" dans votre dossier personnel (~).',
    expectedCommands: ['mkdir projects', 'New-Item -ItemType Directory projects'],
    hints: [
      'La commande mkdir crée un nouveau répertoire.',
      'Syntaxe : mkdir <nom_dossier>',
    ],
    isAchieved: (fs) => fs.isDir(_p),
  ),
  LabMission(
    id: 2,
    title: 'Entrez dans projects',
    objective: 'Utilisez la commande cd pour naviguer dans le dossier "projects" que vous venez de créer.',
    expectedCommands: ['cd projects', 'Set-Location projects'],
    hints: [
      'La commande cd change le répertoire de travail courant.',
      'Syntaxe : cd <chemin>',
    ],
    isAchieved: (fs) => fs.currentPathString == _p,
  ),
  LabMission(
    id: 3,
    title: 'Créez src et docs',
    objective: 'Dans projects, créez deux dossiers d\'un coup : "src" pour le code et "docs" pour la documentation.',
    expectedCommands: ['mkdir src docs', 'mkdir src,docs'],
    hints: [
      'Vous pouvez passer plusieurs noms à mkdir.',
      'Syntaxe : mkdir <dossier1> <dossier2> (PowerShell : séparez par une virgule)',
    ],
    isAchieved: (fs) => fs.isDir('$_p/src') && fs.isDir('$_p/docs'),
  ),
  LabMission(
    id: 4,
    title: 'Créez README.txt',
    objective: 'Créez un fichier vide nommé "README.txt" dans projects.',
    expectedCommands: ['touch README.txt', 'New-Item README.txt'],
    hints: [
      'La commande touch crée un fichier vide.',
      'Syntaxe : touch <nom_fichier>',
    ],
    isAchieved: (fs) => fs.isFile('$_p/README.txt') || fs.isFile('$_p/docs/README.txt'),
  ),
  LabMission(
    id: 5,
    title: 'Déplacez README.txt dans docs',
    objective: 'Déplacez le fichier README.txt de projects vers le dossier docs/',
    expectedCommands: ['mv README.txt docs/', 'Move-Item README.txt docs'],
    hints: [
      'La commande mv déplace ou renomme un fichier.',
      'Syntaxe : mv <source> <destination>',
    ],
    isAchieved: (fs) => fs.isFile('$_p/docs/README.txt') && fs.nodeAt(fs.resolve('$_p/README.txt')) == null,
  ),
  LabMission(
    id: 6,
    title: 'Listez le contenu',
    objective: 'Affichez la liste des fichiers et dossiers du répertoire courant.',
    expectedCommands: ['ls', 'ls -la', 'Get-ChildItem'],
    hints: [
      'La commande ls affiche le contenu d\'un dossier.',
      'En PowerShell, utilisez Get-ChildItem.',
    ],
    isAchieved: (fs) => _ran(fs, {'ls', 'get-childitem'}),
  ),
  LabMission(
    id: 7,
    title: 'Copiez src dans backup',
    objective: 'Copiez le dossier src vers un nouveau dossier nommé backup. Pensez à la récursivité !',
    expectedCommands: ['cp -r src backup', 'Copy-Item src backup -Recurse'],
    hints: [
      'Pour copier un dossier, il faut l\'option -r (récursif).',
      'Syntaxe : cp -r <source> <destination>',
    ],
    isAchieved: (fs) =>
        _ran(fs, {'cp', 'copy-item'}) && fs.isDir('$_p/backup') && fs.isDir('$_p/src'),
  ),
  LabMission(
    id: 8,
    title: 'Affichez le chemin courant',
    objective: 'Affichez le chemin complet du répertoire de travail actuel.',
    expectedCommands: ['pwd', 'Get-Location'],
    hints: [
      'La commande pwd signifie "Print Working Directory".',
      'En PowerShell, utilisez Get-Location.',
    ],
    isAchieved: (fs) => _ran(fs, {'pwd', 'get-location'}),
  ),
];

class LabEngine {
  final VirtualFileSystem fileSystem = VirtualFileSystem();
  final List<LabMission> missions = labMissions.map((m) => m.copy()).toList();
  int _currentMissionIndex = 0;
  LabMission? _justCompletedMission;

  LabMission? get justCompletedMission => _justCompletedMission;

  void clearJustCompleted() => _justCompletedMission = null;

  LabMission? get currentMission =>
      _currentMissionIndex < missions.length ? missions[_currentMissionIndex] : null;

  int get completedMissions => missions.where((m) => m.isCompleted).length;

  int get totalMissions => missions.length;

  bool get allMissionsCompleted => missions.every((m) => m.isCompleted);

  String get bashPrompt => 'student@bash-lab:${fileSystem.bashPromptPath}\$ ';

  String get psPrompt => 'PS ${fileSystem.psDisplay(fileSystem.currentPath)}> ';

  String processBashCommand(String cmd) {
    final result = fileSystem.executeBashCommand(cmd);
    _checkMissionCompletion();
    return result;
  }

  String processPowerShellCommand(String cmd) {
    final result = fileSystem.executePowerShellCommand(cmd);
    _checkMissionCompletion();
    return result;
  }

  /// Valide la mission courante d'après l'état obtenu (et enchaîne si l'élève a
  /// déjà réalisé les suivantes).
  void _checkMissionCompletion() {
    while (true) {
      final mission = currentMission;
      if (mission == null || mission.isCompleted) return;
      if (!mission.isAchieved(fileSystem)) return;
      mission.isCompleted = true;
      _justCompletedMission = mission;
      if (_currentMissionIndex >= missions.length - 1) return;
      _currentMissionIndex++;
    }
  }

  void resetAll() {
    fileSystem.reset();
    for (final m in missions) {
      m.isCompleted = false;
    }
    _currentMissionIndex = 0;
    _justCompletedMission = null;
  }
}
