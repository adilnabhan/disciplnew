import 'package:flutter/foundation.dart';
import 'package:customer_mobile_app/src/features/home/domain/models/home_challenge_model.dart';

@immutable
class HomeChallengeState {
  final List<HomeChallenge> challenges;
  final bool isLoading;
  final String? errorMessage;

  const HomeChallengeState({
    this.challenges = const [],
    this.isLoading = false,
    this.errorMessage,
  });

  HomeChallengeState copyWith({
    List<HomeChallenge>? challenges,
    bool? isLoading,
    String? errorMessage,
  }) {
    return HomeChallengeState(
      challenges: challenges ?? this.challenges,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
    );
  }
}
