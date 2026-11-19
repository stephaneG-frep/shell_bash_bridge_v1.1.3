class UserProgress {
  final Map<String, bool> completedLessons;
  final Map<String, bool> completedExercises;
  final Map<String, bool> completedChallenges;
  final Map<String, bool> completedProjects;
  final Map<String, int> scores;
  final List<String> favorites;
  final List<String> badges;
  final double bashProgress;
  final double psProgress;

  const UserProgress({
    this.completedLessons = const {},
    this.completedExercises = const {},
    this.completedChallenges = const {},
    this.completedProjects = const {},
    this.scores = const {},
    this.favorites = const [],
    this.badges = const [],
    this.bashProgress = 0.0,
    this.psProgress = 0.0,
  });

  UserProgress copyWith({
    Map<String, bool>? completedLessons,
    Map<String, bool>? completedExercises,
    Map<String, bool>? completedChallenges,
    Map<String, bool>? completedProjects,
    Map<String, int>? scores,
    List<String>? favorites,
    List<String>? badges,
    double? bashProgress,
    double? psProgress,
  }) {
    return UserProgress(
      completedLessons: completedLessons ?? this.completedLessons,
      completedExercises: completedExercises ?? this.completedExercises,
      completedChallenges: completedChallenges ?? this.completedChallenges,
      completedProjects: completedProjects ?? this.completedProjects,
      scores: scores ?? this.scores,
      favorites: favorites ?? this.favorites,
      badges: badges ?? this.badges,
      bashProgress: bashProgress ?? this.bashProgress,
      psProgress: psProgress ?? this.psProgress,
    );
  }

  Map<String, dynamic> toJson() => {
    'completedLessons': completedLessons,
    'completedExercises': completedExercises,
    'completedChallenges': completedChallenges,
    'completedProjects': completedProjects,
    'scores': scores,
    'favorites': favorites,
    'badges': badges,
    'bashProgress': bashProgress,
    'psProgress': psProgress,
  };

  factory UserProgress.fromJson(Map<String, dynamic> json) => UserProgress(
    completedLessons: _boolMap(json['completedLessons']),
    completedExercises: _boolMap(json['completedExercises']),
    completedChallenges: _boolMap(json['completedChallenges']),
    completedProjects: _boolMap(json['completedProjects']),
    scores: _intMap(json['scores']),
    favorites: _stringList(json['favorites']),
    badges: _stringList(json['badges']),
    bashProgress: _toDouble(json['bashProgress']),
    psProgress: _toDouble(json['psProgress']),
  );

  // Lecture tolérante : un champ au mauvais type est ignoré au lieu de lever une exception.
  static Map<String, bool> _boolMap(dynamic v) {
    if (v is! Map) return const {};
    return {
      for (final e in v.entries)
        if (e.value is bool) e.key.toString(): e.value as bool,
    };
  }

  static Map<String, int> _intMap(dynamic v) {
    if (v is! Map) return const {};
    return {
      for (final e in v.entries)
        if (e.value is num) e.key.toString(): (e.value as num).toInt(),
    };
  }

  static List<String> _stringList(dynamic v) {
    if (v is! List) return const [];
    return v.whereType<String>().toList();
  }

  static double _toDouble(dynamic v) => v is num ? v.toDouble() : 0.0;
}
