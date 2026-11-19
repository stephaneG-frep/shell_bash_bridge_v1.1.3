import '../../core/app_fonts.dart';
import 'package:flutter/material.dart';
import '../../data/exercises.dart';
import '../../models/exercise.dart';
import '../../core/theme.dart';
import '../../services/progress_service.dart';
import '../../shared/widgets/shell_badge.dart';
import '../../shared/widgets/terminal_container.dart';

class ExercisesScreen extends StatefulWidget {
  final String? shellFilter;
  const ExercisesScreen({super.key, this.shellFilter});

  @override
  State<ExercisesScreen> createState() => _ExercisesScreenState();
}

class _ExercisesScreenState extends State<ExercisesScreen> {
  String _selectedShell = 'Tous';
  String _selectedType = 'Tous';
  // Clés = exercise.id (et non l'index), pour rester correct quand on change de filtre.
  final Map<String, String?> _selectedAnswers = {};
  final Map<String, bool> _showResult = {};
  final Map<String, String> _textInputs = {};

  static String _normalize(String s) =>
      s.trim().replaceAll(RegExp(r'\s+'), ' ').toLowerCase();

  String _typeDisplayName(ExerciseType type) {
    switch (type) {
      case ExerciseType.qcm: return 'QCM';
      case ExerciseType.chooseCommand: return 'Choisir';
      case ExerciseType.completeCommand: return 'Compléter';
      case ExerciseType.correctCommand: return 'Corriger';
      case ExerciseType.predictOutput: return 'Prédire';
      case ExerciseType.writeCommand: return 'Écrire';
      case ExerciseType.miniScript: return 'Script';
      case ExerciseType.labMission: return 'Lab';
    }
  }

  List<Exercise> get _filteredExercises {
    return ExerciseData.allExercises.where((e) {
      final matchesShell = _selectedShell == 'Tous' ||
          e.shell.toLowerCase() == _selectedShell.toLowerCase();
      final matchesType = _selectedType == 'Tous' ||
          _typeDisplayName(e.type) == _selectedType;
      return matchesShell && matchesType;
    }).toList();
  }

  @override
  void initState() {
    super.initState();
    if (widget.shellFilter != null) {
      _selectedShell = widget.shellFilter!;
    }
  }

  void _checkAnswer(Exercise exercise) {
    final id = exercise.id;
    final userAnswer = _selectedAnswers[id] ?? _textInputs[id] ?? '';
    final isCorrect = _normalize(userAnswer) == _normalize(exercise.correctAnswer);
    setState(() {
      _showResult[id] = isCorrect;
    });
    if (isCorrect) {
      ProgressService.completeExercise(exercise.id, 100);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.scaffoldBg(context),
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text('Exercices', style: AppFonts.inter(color: AppTheme.textColor(context))),
        backgroundColor: AppTheme.cardBg(context),
        elevation: 0,
      ),
      body: Column(
        children: [
          _buildShellFilter(),
          _buildTypeFilter(),
          Expanded(
            child: _filteredExercises.isEmpty
                ? Center(
                    child: Text(
                      'Aucun exercice trouvé',
                      style: AppFonts.inter(color: AppTheme.textSecColor(context), fontSize: 16),
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: _filteredExercises.length,
                    itemBuilder: (context, index) {
                      return _buildExerciseCard(_filteredExercises[index]);
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildShellFilter() {
    final shells = ['Tous', 'Bash', 'PowerShell'];
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: shells.map((shell) {
          final isSelected = _selectedShell == shell;
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: ChoiceChip(
              label: Text(shell, style: AppFonts.inter(fontSize: 13)),
              selected: isSelected,
              onSelected: (selected) {
                if (selected) {
                  setState(() => _selectedShell = shell);
                }
              },
              selectedColor: AppTheme.accent.withValues(alpha: 0.2),
              backgroundColor: AppTheme.cardBg(context),
              labelStyle: TextStyle(
                color: isSelected ? AppTheme.accent : AppTheme.textSecColor(context),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildTypeFilter() {
    // Généré depuis les types réellement présents : aucun exercice n'est caché.
    final present = ExerciseData.allExercises.map((e) => e.type).toSet();
    final types = [
      'Tous',
      for (final t in ExerciseType.values)
        if (present.contains(t)) _typeDisplayName(t),
    ];
    return Container(
      height: 40,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: types.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final type = types[index];
          final isSelected = _selectedType == type;
          return ChoiceChip(
            label: Text(type, style: AppFonts.inter(fontSize: 12)),
            selected: isSelected,
            onSelected: (selected) {
              if (selected) {
                setState(() => _selectedType = type);
              }
            },
            selectedColor: AppTheme.accent.withValues(alpha: 0.2),
            backgroundColor: AppTheme.cardBg(context),
            labelStyle: TextStyle(
              color: isSelected ? AppTheme.accent : AppTheme.textSecColor(context),
            ),
          );
        },
      ),
    );
  }

  Widget _buildExerciseCard(Exercise exercise) {
    final isQCM = exercise.type == ExerciseType.qcm || exercise.type == ExerciseType.chooseCommand;
    final showResult = _showResult.containsKey(exercise.id);
    final isCorrect = _showResult[exercise.id] ?? false;

    return Card(
      key: ValueKey(exercise.id),
      margin: const EdgeInsets.only(bottom: 16),
      color: AppTheme.cardBg(context),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildCardHeader(exercise),
            const SizedBox(height: 12),
            Text(
              exercise.question,
              style: AppFonts.inter(color: AppTheme.textColor(context), fontSize: 15),
            ),
            const SizedBox(height: 12),
            if (isQCM) _buildQCMOptions(exercise),
            if (!isQCM) _buildTextInput(exercise),
            const SizedBox(height: 12),
            if (!showResult)
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => _checkAnswer(exercise),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.accent,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  child: Text('Vérifier', style: AppFonts.inter(fontWeight: FontWeight.w600)),
                ),
              ),
            if (showResult) _buildResult(exercise, isCorrect),
          ],
        ),
      ),
    );
  }

  Widget _buildCardHeader(Exercise exercise) {
    return Row(
      children: [
        Expanded(
          child: Text(
            exercise.title,
            style: AppFonts.inter(color: AppTheme.textColor(context), fontSize: 16, fontWeight: FontWeight.bold),
          ),
        ),
        ShellBadge(shell: exercise.shell),
        const SizedBox(width: 8),
        _buildTypeBadge(exercise),
        const SizedBox(width: 8),
        _buildDifficultyStars(exercise.difficulty),
      ],
    );
  }

  Widget _buildTypeBadge(Exercise exercise) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: AppTheme.chipBg(context),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        _typeDisplayName(exercise.type),
        style: AppFonts.inter(color: AppTheme.textSecColor(context), fontSize: 11, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _buildDifficultyStars(int difficulty) {
    return Row(
      children: List.generate(5, (index) {
        return Icon(
          index < difficulty ? Icons.star : Icons.star_border,
          color: index < difficulty ? AppTheme.warning : AppTheme.textSecColor(context),
          size: 16,
        );
      }),
    );
  }

  Widget _buildQCMOptions(Exercise exercise) {
    final options = exercise.options ?? [];
    final locked = _showResult.containsKey(exercise.id);
    return RadioGroup<String>(
      groupValue: _selectedAnswers[exercise.id],
      onChanged: (value) {
        if (locked) return;
        setState(() => _selectedAnswers[exercise.id] = value);
      },
      child: Column(
        children: options.map((option) {
          return RadioListTile<String>(
            title: Text(option, style: AppFonts.inter(color: AppTheme.textColor(context), fontSize: 14)),
            value: option,
            enabled: !locked,
            activeColor: AppTheme.accent,
            contentPadding: EdgeInsets.zero,
            dense: true,
          );
        }).toList(),
      ),
    );
  }

  Widget _buildTextInput(Exercise exercise) {
    return TextFormField(
      key: ValueKey('input_${exercise.id}'),
      initialValue: _textInputs[exercise.id],
      enabled: !_showResult.containsKey(exercise.id),
      onChanged: (value) {
        _textInputs[exercise.id] = value;
      },
      decoration: InputDecoration(
        hintText: 'Entrez votre réponse...',
        hintStyle: AppFonts.inter(color: AppTheme.textSecColor(context)),
        filled: true,
        fillColor: AppTheme.chipBg(context),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: AppTheme.textSecColor(context).withValues(alpha: 0.3)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: AppTheme.accent),
        ),
      ),
      style: AppFonts.firaCode(color: AppTheme.textColor(context), fontSize: 14),
    );
  }

  Widget _buildResult(Exercise exercise, bool isCorrect) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: isCorrect
                ? AppTheme.bashGreen.withValues(alpha: 0.1)
                : AppTheme.error.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: isCorrect
                  ? AppTheme.bashGreen.withValues(alpha: 0.3)
                  : AppTheme.error.withValues(alpha: 0.3),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    isCorrect ? Icons.check_circle : Icons.cancel,
                    color: isCorrect ? AppTheme.bashGreen : AppTheme.error,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    isCorrect ? 'Correct !' : 'Incorrect',
                    style: AppFonts.inter(
                      color: isCorrect ? AppTheme.bashGreen : AppTheme.error,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
              if (!isCorrect) ...[
                const SizedBox(height: 8),
                Text(
                  'Réponse attendue : ${exercise.correctAnswer}',
                  style: AppFonts.inter(color: AppTheme.textSecColor(context), fontSize: 13),
                ),
              ],
            ],
          ),
        ),
        const SizedBox(height: 8),
        if (exercise.explanation.isNotEmpty)
          TerminalContainer(
            text: exercise.explanation,
            isBash: exercise.shell.toLowerCase() == 'bash',
          ),
      ],
    );
  }
}
