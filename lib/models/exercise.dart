enum ExerciseType { qcm, completeCommand, correctCommand, chooseCommand, predictOutput, writeCommand, miniScript, labMission }

class Exercise {
  final String id;
  final String title;
  final String shell;
  final ExerciseType type;
  final String question;
  final List<String>? options;
  final String correctAnswer;
  final String explanation;
  final int difficulty;

  const Exercise({
    required this.id,
    required this.title,
    required this.shell,
    required this.type,
    required this.question,
    this.options,
    required this.correctAnswer,
    required this.explanation,
    this.difficulty = 1,
  });
}
