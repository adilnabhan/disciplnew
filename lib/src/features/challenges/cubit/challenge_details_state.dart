import 'package:flutter/foundation.dart';
import 'package:customer_mobile_app/src/features/challenges/domain/models/challenge_details_model.dart';

@immutable
class ChallengeDetailsState {
  final ChallengeDetailsResponse? challenge;
  final bool isLoading;
  final String? error;
  final bool isJoining;

  const ChallengeDetailsState({
    this.challenge,
    this.isLoading = false,
    this.error,
    this.isJoining = false,
  });

  ChallengeDetailsState copyWith({
    ChallengeDetailsResponse? challenge,
    bool? isLoading,
    String? error,
    bool? isJoining,
  }) {
    return ChallengeDetailsState(
      challenge: challenge ?? this.challenge,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      isJoining: isJoining ?? this.isJoining,
    );
  }
}
