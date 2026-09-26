import 'dart:math' as math;

enum WorkoutFeedbackType {
  firstTime,
  stronger,
}

class WorkoutSetFeedbackResult {
  final WorkoutFeedbackType type;
  final String? percentage;

  const WorkoutSetFeedbackResult({
    required this.type,
    this.percentage,
  });

  @override
  String toString() =>
      'WorkoutSetFeedbackResult(type: $type, percentage: $percentage)';
}

class WorkoutFeedbackEvaluator {
  /// Safely extracts numeric weight and reps/duration/distance from a formatted previous string
  /// such as '2 FW × 2', '80kgX10', '0 × 12', '10 reps', '30 s', etc.
  static ({double weight, double reps}) parsePreviousString(String previous) {
    final clean = previous.trim();
    if (clean.isEmpty || clean.toLowerCase() == 'no data') {
      return (weight: 0.0, reps: 0.0);
    }

    // Split by '×', 'x', or 'X'
    final parts = clean.split(RegExp(r'[×xX]'));
    if (parts.length >= 2) {
      // Left part has weight (e.g., '2 FW', '80kg', '20 kg', '0')
      final wMatch = RegExp(r'(\d+(?:\.\d+)?)').firstMatch(parts[0]);
      // Right part has reps/duration/distance (e.g., '2', '10', '45 sec', '12')
      final rMatch = RegExp(r'(\d+(?:\.\d+)?)').firstMatch(parts[1]);

      final w = wMatch != null ? double.tryParse(wMatch.group(1)!) ?? 0.0 : 0.0;
      final r = rMatch != null ? double.tryParse(rMatch.group(1)!) ?? 0.0 : 0.0;
      return (weight: w, reps: r);
    } else {
      // Single numeric value (e.g. '10 reps', '30 s', '5 km')
      final match = RegExp(r'(\d+(?:\.\d+)?)').firstMatch(clean);
      final val = match != null ? double.tryParse(match.group(1)!) ?? 0.0 : 0.0;
      return (weight: 0.0, reps: val);
    }
  }

  /// Evaluates feedback for a completed workout set
  static WorkoutSetFeedbackResult? evaluateFeedback({
    required Map<String, dynamic> set,
    required Map<String, dynamic> exercise,
  }) {
    final previousStr = (set['previous']?.toString() ?? '').trim();
    final isNoData = previousStr.isEmpty ||
        previousStr.toLowerCase() == 'no data' ||
        previousStr == '-' ||
        previousStr.toLowerCase() == 'null';

    // Case 1: No previous workout data
    if (isNoData) {
      return const WorkoutSetFeedbackResult(type: WorkoutFeedbackType.firstTime);
    }

    // Check if raw previous values exist first
    final rawKg = set['raw_prev_kg'];
    final rawReps = set['raw_prev_reps'];
    double? prevWeight = rawKg != null ? double.tryParse(rawKg.toString()) : null;
    double? prevReps = rawReps != null ? double.tryParse(rawReps.toString()) : null;

    // Fallback to safe parsing of formatted string if raw values are unavailable
    if (prevWeight == null || prevReps == null) {
      final parsed = parsePreviousString(previousStr);
      prevWeight ??= parsed.weight;
      prevReps ??= parsed.reps;
    }

    // If both previous weight and reps are 0, treat as first time
    if (prevWeight == 0.0 && prevReps == 0.0) {
      return const WorkoutSetFeedbackResult(type: WorkoutFeedbackType.firstTime);
    }

    final currentWeight = double.tryParse(set['kg']?.toString() ?? '0') ?? 0.0;
    final currentReps = double.tryParse(set['reps']?.toString() ?? '0') ?? 0.0;

    final weightType = (exercise['weight_type']?.toString() ?? 'KG')
        .toUpperCase()
        .replaceAll(' ', '');
    final trackBy = (exercise['track_by']?.toString() ?? 'rep').toLowerCase();

    bool isStronger = false;
    double percentage = 0.0;

    if (weightType == 'BW') {
      // Bodyweight: compare reps directly
      if (prevReps > 0 && currentReps > prevReps) {
        isStronger = true;
        percentage = ((currentReps - prevReps) / prevReps) * 100.0;
      }
    } else if (trackBy == 'time' || trackBy == 'distance') {
      // Time or distance based: compare duration or distance directly
      if (prevReps > 0 && currentReps > prevReps) {
        isStronger = true;
        percentage = ((currentReps - prevReps) / prevReps) * 100.0;
      }
    } else {
      // Weight-based (KG, FW)
      if (prevWeight > 0 && currentWeight > 0) {
        if (currentWeight == prevWeight) {
          if (currentReps > prevReps && prevReps > 0) {
            isStronger = true;
            percentage = ((currentReps - prevReps) / prevReps) * 100.0;
          }
        } else {
          // Epley 1RM formula: Weight * (1 + Reps / 30)
          final current1RM = currentWeight * (1.0 + (currentReps / 30.0));
          final prev1RM = prevWeight * (1.0 + (prevReps / 30.0));
          if (current1RM > prev1RM && prev1RM > 0) {
            isStronger = true;
            percentage = ((current1RM - prev1RM) / prev1RM) * 100.0;
          }
        }
      } else if (prevWeight == 0 && currentWeight > 0) {
        // Transitioned from unweighted (e.g. '0 × 12') to adding weight (e.g. '2 × 12')
        if (prevReps > 0) {
          if (currentReps >= prevReps) {
            isStronger = true;
            final repBonus = ((currentReps - prevReps) / prevReps) * 100.0;
            percentage = repBonus > 0 ? (20.0 + repBonus) : 20.0;
          } else if (currentReps >= (prevReps * 0.7)) {
            isStronger = true;
            percentage = 15.0;
          }
        } else if (currentReps > 0) {
          isStronger = true;
          percentage = 20.0;
        }
      } else if (prevWeight == 0 && currentWeight == 0) {
        // Zero weight on both, compare reps
        if (prevReps > 0 && currentReps > prevReps) {
          isStronger = true;
          percentage = ((currentReps - prevReps) / prevReps) * 100.0;
        }
      } else if (prevWeight > 0 && prevReps == 0) {
        if (currentWeight > prevWeight) {
          isStronger = true;
          percentage = ((currentWeight - prevWeight) / prevWeight) * 100.0;
        } else if (currentWeight == prevWeight && currentReps > 0) {
          isStronger = true;
          percentage = 15.0;
        }
      }
    }

    if (isStronger) {
      final rounded = math.max(1, percentage.round());
      return WorkoutSetFeedbackResult(
        type: WorkoutFeedbackType.stronger,
        percentage: '+$rounded%',
      );
    }

    return null;
  }
}
