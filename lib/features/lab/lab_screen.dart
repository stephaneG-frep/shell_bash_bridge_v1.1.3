import 'package:flutter/material.dart';
import '../../core/app_settings.dart';
import '../../services/storage_service.dart';
import 'lab_missions.dart';

/// Incrémenté pour demander la réinitialisation du Lab depuis un autre écran
/// (ex. Profil). Ne touche à aucune autre donnée de l'utilisateur.
final ValueNotifier<int> labResetNotifier = ValueNotifier<int>(0);

class LabScreen extends StatefulWidget {
  const LabScreen({super.key});

  @override
  State<LabScreen> createState() => _LabScreenState();
}

class _LabScreenState extends State<LabScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final LabEngine _engine = LabEngine();

  // Separate controllers for each terminal
  final TextEditingController _bashInput = TextEditingController();
  final TextEditingController _psInput = TextEditingController();
  final ScrollController _bashScroll = ScrollController();
  final ScrollController _psScroll = ScrollController();

  final List<_TerminalLine> _bashLines = [];
  final List<_TerminalLine> _psLines = [];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    labResetNotifier.addListener(_onExternalReset);
    codeSizeNotifier.addListener(_onCodeSizeChanged);
    final saved = StorageService.loadLabState();
    final restored = saved != null && _engine.restore(saved);
    final welcome = _TerminalLine(
      text: 'Bienvenue dans le Shell Lab !\nTapez "help" pour voir les commandes disponibles.\n',
      isSystem: true,
    );
    _bashLines.add(welcome);
    _psLines.add(_TerminalLine(
      text: 'Bienvenue dans le PowerShell Lab !\nTapez "help" pour voir les commandes disponibles.\n',
      isSystem: true,
    ));
    if (restored) {
      final info = _TerminalLine(
        text: 'Session restaurée : dossier ${_engine.fileSystem.currentPathString}, '
            'missions ${_engine.completedMissions}/${_engine.totalMissions}.',
        isSystem: true,
      );
      _bashLines.add(info);
      _psLines.add(info);
    }
  }

  @override
  void dispose() {
    labResetNotifier.removeListener(_onExternalReset);
    codeSizeNotifier.removeListener(_onCodeSizeChanged);
    _tabController.dispose();
    _bashInput.dispose();
    _psInput.dispose();
    _bashScroll.dispose();
    _psScroll.dispose();
    super.dispose();
  }

  void _onCodeSizeChanged() {
    if (mounted) setState(() {});
  }

  void _save() => StorageService.saveLabState(_engine.toJson());

  void _onExternalReset() {
    if (mounted) _resetLab();
  }

  void _resetLab() {
    StorageService.clearLabState();
    setState(() {
      _engine.resetAll();
      _bashLines.clear();
      _psLines.clear();
      _bashLines.add(_TerminalLine(
        text: 'Terminal réinitialisé. Nouvelles missions disponibles !\nTapez "help" pour voir les commandes disponibles.\n',
        isSystem: true,
      ));
      _psLines.add(_TerminalLine(
        text: 'Terminal réinitialisé. Nouvelles missions disponibles !\nTapez "help" pour voir les commandes disponibles.\n',
        isSystem: true,
      ));
    });
  }

  bool get _isBashMode => _tabController.index == 0;

  List<_TerminalLine> get _currentLines => _isBashMode ? _bashLines : _psLines;
  TextEditingController get _currentInput => _isBashMode ? _bashInput : _psInput;
  ScrollController get _currentScroll => _isBashMode ? _bashScroll : _psScroll;

  void _executeCommand(String cmd) {
    if (cmd.trim().isEmpty) return;

    setState(() {
      final prompt = _isBashMode ? _engine.bashPrompt : _engine.psPrompt;
      _currentLines.add(_TerminalLine(text: '$prompt$cmd', isCommand: true));

      final result = _isBashMode
          ? _engine.processBashCommand(cmd)
          : _engine.processPowerShellCommand(cmd);

      if (result == kClearSequence) {
        _currentLines.clear();
        _currentLines.add(_TerminalLine(text: 'Terminal cleared.', isSystem: true));
      } else if (result.isNotEmpty) {
        _currentLines.add(_TerminalLine(text: result));
      }

      if (_engine.justCompletedMission != null) {
        final m = _engine.justCompletedMission!;
        _currentLines.add(_TerminalLine(
          text: 'Mission accomplie ! Bravo ! [${m.title}]',
          isSuccess: true,
        ));
        if (_engine.allMissionsCompleted) {
          _currentLines.add(_TerminalLine(
            text: 'Toutes les missions sont terminées ! Vous êtes un pro du terminal !',
            isSuccess: true,
          ));
        }
        _engine.clearJustCompleted();
      }
    });
    _save();

    _currentInput.clear();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_currentScroll.hasClients) {
        _currentScroll.animateTo(
          _currentScroll.position.maxScrollExtent,
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Shell Lab'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(icon: Icon(Icons.terminal), text: 'Bash Lab'),
            Tab(icon: Icon(Icons.code), text: 'PowerShell Lab'),
            Tab(icon: Icon(Icons.flag), text: 'Missions'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildTerminalTab(context, isBash: true),
          _buildTerminalTab(context, isBash: false),
          _buildMissionsTab(context),
        ],
      ),
    );
  }

  Widget _buildTerminalTab(BuildContext context, {required bool isBash}) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final prompt = isBash ? _engine.bashPrompt : _engine.psPrompt;
    final lines = isBash ? _bashLines : _psLines;
    final input = isBash ? _bashInput : _psInput;
    final scroll = isBash ? _bashScroll : _psScroll;

    return Column(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          color: colorScheme.surfaceContainerHighest,
          child: Row(
            children: [
              Icon(
                isBash ? Icons.terminal : Icons.code,
                size: 18,
                color: colorScheme.primary,
              ),
              const SizedBox(width: 8),
              Text(
                isBash ? 'Bash Lab' : 'PowerShell Lab',
                style: theme.textTheme.titleSmall?.copyWith(
                  color: colorScheme.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const Spacer(),
              Text(
                'Mission: ${_engine.completedMissions}/${_engine.totalMissions}',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: Container(
            color: const Color(0xFF1E1E1E),
            child: ListView.builder(
              controller: scroll,
              padding: const EdgeInsets.all(12),
              itemCount: lines.length,
              itemBuilder: (context, index) {
                final line = lines[index];
                Color textColor;
                if (line.isCommand) {
                  textColor = const Color(0xFF4EC9B0);
                } else if (line.isSystem) {
                  textColor = const Color(0xFF569CD6);
                } else if (line.isSuccess) {
                  textColor = const Color(0xFF6A9955);
                } else {
                  textColor = const Color(0xFFD4D4D4);
                }

                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 1),
                  child: Text(
                    line.text,
                    style: TextStyle(
                      fontFamily: 'monospace',
                      fontSize: codeSizeNotifier.value,
                      height: 1.4,
                      color: textColor,
                    ),
                  ),
                );
              },
            ),
          ),
        ),
        Container(
          color: const Color(0xFF252526),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          child: Row(
            children: [
              Text(
                prompt,
                style: TextStyle(
                  fontFamily: 'monospace',
                  fontSize: codeSizeNotifier.value,
                  color: const Color(0xFF4EC9B0),
                ),
              ),
              Expanded(
                child: TextField(
                  controller: input,
                  style: TextStyle(
                    fontFamily: 'monospace',
                    fontSize: codeSizeNotifier.value,
                    color: const Color(0xFFD4D4D4),
                  ),
                  decoration: const InputDecoration(
                    border: InputBorder.none,
                    isDense: true,
                    contentPadding: EdgeInsets.symmetric(vertical: 8),
                  ),
                  cursorColor: const Color(0xFFD4D4D4),
                  onSubmitted: _executeCommand,
                  // Garde le clavier ouvert après Entrée, comme dans un vrai terminal.
                  onEditingComplete: () {},
                  textInputAction: TextInputAction.send,
                  autocorrect: false,
                  enableSuggestions: false,
                  textCapitalization: TextCapitalization.none,
                ),
              ),
              IconButton(tooltip: 'Exécuter la commande', 
                icon: const Icon(Icons.send, size: 18),
                color: const Color(0xFF4EC9B0),
                onPressed: () => _executeCommand(_currentInput.text),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildMissionsTab(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.flag, color: colorScheme.primary),
                    const SizedBox(width: 8),
                    Text(
                      'Progression',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                LinearProgressIndicator(
                  value: _engine.totalMissions > 0
                      ? _engine.completedMissions / _engine.totalMissions
                      : 0,
                  minHeight: 8,
                  borderRadius: BorderRadius.circular(4),
                ),
                const SizedBox(height: 8),
                Text(
                  '${_engine.completedMissions}/${_engine.totalMissions} missions complétées',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        ..._engine.missions.map((mission) => _buildMissionCard(context, mission)),
        const SizedBox(height: 16),
        if (_engine.allMissionsCompleted)
          Card(
            color: colorScheme.primaryContainer,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Icon(Icons.emoji_events, color: colorScheme.onPrimaryContainer),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Toutes les missions sont terminées ! Vous maîtrisez les commandes de base !',
                      style: theme.textTheme.bodyLarge?.copyWith(
                        color: colorScheme.onPrimaryContainer,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        const SizedBox(height: 12),
        OutlinedButton.icon(
          onPressed: _resetLab,
          icon: const Icon(Icons.refresh),
          label: const Text('Réinitialiser le lab'),
        ),
      ],
    );
  }

  Widget _buildMissionCard(BuildContext context, LabMission mission) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ExpansionTile(
        leading: CircleAvatar(
          backgroundColor: mission.isCompleted
              ? Colors.green
              : colorScheme.surfaceContainerHighest,
          radius: 18,
          child: mission.isCompleted
              ? const Icon(Icons.check, color: Colors.white, size: 20)
              : Text(
                  '${mission.id}',
                  style: TextStyle(
                    color: colorScheme.onSurfaceVariant,
                    fontWeight: FontWeight.bold,
                  ),
                ),
        ),
        title: Text(
          mission.title,
          style: TextStyle(
            fontWeight: FontWeight.w600,
            decoration: mission.isCompleted ? TextDecoration.lineThrough : null,
            color: mission.isCompleted ? colorScheme.onSurfaceVariant : null,
          ),
        ),
        subtitle: Text(
          mission.objective,
          style: theme.textTheme.bodySmall?.copyWith(
            color: colorScheme.onSurfaceVariant,
          ),
        ),
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Divider(),
                const SizedBox(height: 8),
                Text(
                  'Exemples de commandes :',
                  style: theme.textTheme.labelLarge?.copyWith(
                    color: colorScheme.primary,
                  ),
                ),
                const SizedBox(height: 4),
                Wrap(
                  spacing: 8,
                  runSpacing: 4,
                  children: mission.expectedCommands.map((cmd) {
                    return Chip(
                      label: Text(
                        cmd,
                        style: const TextStyle(
                          fontFamily: 'monospace',
                          fontSize: 12,
                        ),
                      ),
                      backgroundColor: colorScheme.surfaceContainerHighest,
                    );
                  }).toList(),
                ),
                const SizedBox(height: 12),
                if (mission.hints.isNotEmpty)
                  ExpansionTile(
                    tilePadding: EdgeInsets.zero,
                    childrenPadding: EdgeInsets.zero,
                    title: Text(
                      'Indices',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: colorScheme.tertiary,
                      ),
                    ),
                    leading: const Icon(Icons.lightbulb_outline, size: 20),
                    children: mission.hints.map((hint) {
                      return Padding(
                        padding: const EdgeInsets.only(left: 32, bottom: 4),
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            '• $hint',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _TerminalLine {
  final String text;
  final bool isCommand;
  final bool isSystem;
  final bool isSuccess;

  const _TerminalLine({
    required this.text,
    this.isCommand = false,
    this.isSystem = false,
    this.isSuccess = false,
  });
}
