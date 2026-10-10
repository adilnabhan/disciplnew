class WorkoutPointItem {
  final String title;
  final String description;
  final int points;
  final bool isEarned;
  final String icon;

  const WorkoutPointItem({
    required this.title,
    required this.description,
    required this.points,
    required this.isEarned,
    required this.icon,
  });
}

class WorkoutPointsBreakdown {
  final int totalPoints;
  final bool hasPoints;
  final int? previousRank;
  final int? currentRank;
  final int baseWorkoutPoints;
  final int exerciseBonusPoints;
  final int durationBonusPoints;
  final int streakBonusPoints;
  final int trainerBonusPoints;
  final bool isDailyLimitReached;
  final List<WorkoutPointItem> items;

  const WorkoutPointsBreakdown({
    required this.totalPoints,
    required this.hasPoints,
    this.previousRank,
    this.currentRank,
    this.baseWorkoutPoints = 30,
    this.exerciseBonusPoints = 0,
    this.durationBonusPoints = 0,
    this.streakBonusPoints = 0,
    this.trainerBonusPoints = 0,
    this.isDailyLimitReached = false,
    this.items = const [],
  });

  /// Factory to parse from API response
  /// Schema when is_point = true:
  /// {
  ///   "is_point": true,
  ///   "point": 30,
  ///   "previous_rank_on_leaderboard": 5,
  ///   "current_rank_on_leaderboard": 4,
  ///   "previous rank on leaderboard": 5,
  ///   "current rank on leaderboard": 4
  /// }
  /// Schema when is_point = false:
  /// {
  ///   "is_point": false
  /// }
  factory WorkoutPointsBreakdown.fromApiResponse(Map<String, dynamic> json) {
    // If backend explicitly returned is_point: false -> no points!
    final dynamic isPointRaw = json['is_point'] ?? json['is_points'];
    if (isPointRaw == false) {
      return const WorkoutPointsBreakdown(
        totalPoints: 0,
        hasPoints: false,
        isDailyLimitReached: true,
      );
    }

    final rawPoint = json['point'] ??
        json['points'] ??
        json['earned_points'] ??
        json['workout_points'];
    final int parsedPoint = int.tryParse(rawPoint?.toString() ?? '') ?? 0;

    final bool hasPoints = (isPointRaw == true) || parsedPoint > 0;
    if (!hasPoints) {
      return const WorkoutPointsBreakdown(
        totalPoints: 0,
        hasPoints: false,
        isDailyLimitReached: true,
      );
    }

    final prevRank = int.tryParse(
      (json['previous_rank_on_leaderboard'] ??
              json['previous rank on leaderboard'])
          ?.toString() ??
          '',
    );
    final currRank = int.tryParse(
      (json['current_rank_on_leaderboard'] ??
              json['current rank on leaderboard'])
          ?.toString() ??
          '',
    );

    final finalPts = parsedPoint > 0 ? parsedPoint : 30;

    return WorkoutPointsBreakdown(
      totalPoints: finalPts,
      hasPoints: true,
      previousRank: prevRank,
      currentRank: currRank,
      baseWorkoutPoints: 30,
      exerciseBonusPoints: finalPts >= 35 ? 5 : 0,
      durationBonusPoints: finalPts >= 40 ? 5 : 0,
      streakBonusPoints: finalPts > 40 ? (finalPts - 40) : 0,
      items: [
        const WorkoutPointItem(
          title: 'Base Workout Completed',
          description: 'Completed workout with ≥ 1 set',
          points: 30,
          isEarned: true,
          icon: '🏋️',
        ),
        if (finalPts >= 35)
          const WorkoutPointItem(
            title: 'Exercise Count Bonus',
            description: 'Included ≥ 3 exercises',
            points: 5,
            isEarned: true,
            icon: '🔢',
          ),
        if (finalPts >= 40)
          const WorkoutPointItem(
            title: 'Duration Bonus',
            description: 'Session lasted ≥ 45 minutes',
            points: 5,
            isEarned: true,
            icon: '⏱️',
          ),
        if (finalPts > 40)
          WorkoutPointItem(
            title: 'Streak Consistency',
            description: 'Daily streak active',
            points: finalPts - 40,
            isEarned: true,
            icon: '🔥',
          ),
      ],
    );
  }

  /// Factory to parse from session data or calculate as fallback
  factory WorkoutPointsBreakdown.fromSessionData({
    required Map<String, dynamic>? sessionData,
    int? completedExercisesCount,
    int? durationSeconds,
    bool isFirstWorkoutToday = true,
    int currentStreak = 0,
  }) {
    // 0. Check direct API schema: "is_point": true/false
    if (sessionData != null) {
      if (sessionData.containsKey('is_point') ||
          sessionData.containsKey('is_points')) {
        return WorkoutPointsBreakdown.fromApiResponse(sessionData);
      }
      if (sessionData['points_data'] is Map) {
        return WorkoutPointsBreakdown.fromApiResponse(
          Map<String, dynamic>.from(sessionData['points_data'] as Map),
        );
      }
      if (sessionData['workout_points'] is Map) {
        return WorkoutPointsBreakdown.fromApiResponse(
          Map<String, dynamic>.from(sessionData['workout_points'] as Map),
        );
      }
      if (sessionData['session'] is Map) {
        final sessionMap = sessionData['session'] as Map;
        if (sessionMap.containsKey('is_point')) {
          return WorkoutPointsBreakdown.fromApiResponse(
            Map<String, dynamic>.from(sessionMap),
          );
        }
      }
    }

    // 1. Check if backend sent direct numeric points fields
    final rawPoints = sessionData?['earned_points'] ??
        sessionData?['points'] ??
        sessionData?['point'] ??
        sessionData?['workout_points'];
    if (rawPoints != null) {
      final parsed = int.tryParse(rawPoints.toString()) ?? 0;
      if (parsed > 0) {
        return WorkoutPointsBreakdown.fromApiResponse({
          'is_point': true,
          'point': parsed,
          ...?sessionData,
        });
      } else {
        return const WorkoutPointsBreakdown(
          totalPoints: 0,
          hasPoints: false,
          isDailyLimitReached: true,
        );
      }
    }

    // 2. Client-side evaluation following Discipl rules:
    // Any workout earns points as long as you complete at least 1 set.
    if (!isFirstWorkoutToday) {
      return const WorkoutPointsBreakdown(
        totalPoints: 0,
        hasPoints: false,
        isDailyLimitReached: true,
      );
    }

    // Inspect logs in sessionData to verify completed sets
    final List<dynamic> logs = (sessionData?['logs'] as List<dynamic>?) ??
        (sessionData?['exercise_logs'] as List<dynamic>?) ??
        (sessionData?['exercises'] as List<dynamic>?) ??
        [];

    int completedSetsCount = 0;
    int completedExercises = completedExercisesCount ?? 0;

    for (final log in logs) {
      if (log is Map) {
        final setLogs = log['set_logs'] as List? ?? log['sets'] as List? ?? [];
        bool exerciseHadCompletedSet = false;
        for (final set in setLogs) {
          if (set is Map) {
            final isCompleted = (set['is_completed'] == true) ||
                (set['checked'] == true) ||
                (set['status']?.toString().toLowerCase() == 'completed');
            if (isCompleted) {
              completedSetsCount++;
              exerciseHadCompletedSet = true;
            }
          }
        }
        if (exerciseHadCompletedSet && completedExercisesCount == null) {
          completedExercises++;
        }
      }
    }

    // If no sets are logged or completed, and no exercise count was passed, check fallback
    final hasCompletedSet = completedSetsCount > 0 || completedExercises > 0;
    if (!hasCompletedSet) {
      // 0 sets completed -> 0 points
      return const WorkoutPointsBreakdown(
        totalPoints: 0,
        hasPoints: false,
      );
    }

    // Calculate duration in minutes
    final rawElapsed = sessionData?['elapsed_seconds'] ??
        sessionData?['duration_seconds'] ??
        sessionData?['duration'] ??
        durationSeconds;
    final int elapsedSecs = int.tryParse(rawElapsed?.toString() ?? '') ?? 0;
    final int elapsedMinutes = elapsedSecs ~/ 60;

    const basePts = 30;
    final int exerciseBonus = (completedExercises >= 3) ? 5 : 0;
    final int durationBonus = (elapsedMinutes >= 45) ? 5 : 0;

    // Workout session capped at 40 points / day
    final int sessionTotal =
        (basePts + exerciseBonus + durationBonus).clamp(0, 40);

    // Streak points: +10 if streak > 0 or active consecutive workout
    final int streakBonus = (currentStreak > 0) ? 10 : 0;

    final int total = sessionTotal + streakBonus;

    final items = [
      const WorkoutPointItem(
        title: 'Base Workout Completed',
        description: 'Completed workout with ≥ 1 set',
        points: 30,
        isEarned: true,
        icon: '🏋️',
      ),
      WorkoutPointItem(
        title: 'Exercise Count Bonus',
        description:
            'Includes ≥ 3 exercises (${completedExercises >= 3 ? 'Achieved' : '$completedExercises/3'})',
        points: 5,
        isEarned: completedExercises >= 3,
        icon: '🔢',
      ),
      WorkoutPointItem(
        title: 'Duration Bonus',
        description:
            'Session lasts ≥ 45 minutes (${elapsedMinutes >= 45 ? '$elapsedMinutes min' : '$elapsedMinutes/45 min'})',
        points: 5,
        isEarned: elapsedMinutes >= 45,
        icon: '⏱️',
      ),
      if (currentStreak > 0)
        WorkoutPointItem(
          title: 'Daily Streak Bonus',
          description: '$currentStreak-day active workout streak',
          points: 10,
          isEarned: true,
          icon: '🔥',
        ),
    ];

    return WorkoutPointsBreakdown(
      totalPoints: total,
      hasPoints: total > 0,
      baseWorkoutPoints: basePts,
      exerciseBonusPoints: exerciseBonus,
      durationBonusPoints: durationBonus,
      streakBonusPoints: streakBonus,
      items: items,
    );
  }
}
