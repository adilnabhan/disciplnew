import 'package:flutter/foundation.dart';

enum StepsStatus {
  initial,
  loading,
  unavailable,
  permissionRequired,
  permissionDenied,
  loaded,
  error,
}

@immutable
class StepsState {
  const StepsState({
    this.status = StepsStatus.initial,
    this.steps = 0,
    this.errorMessage,
    this.isRefreshing = false,
    this.isButtonLoading = false,
  });

  final StepsStatus status;
  final int steps;
  final String? errorMessage;
  final bool isRefreshing;
  final bool isButtonLoading;

  StepsState copyWith({
    StepsStatus? status,
    int? steps,
    String? errorMessage,
    bool? isRefreshing,
    bool? isButtonLoading,
  }) {
    return StepsState(
      status: status ?? this.status,
      steps: steps ?? this.steps,
      errorMessage: errorMessage,
      isRefreshing: isRefreshing ?? this.isRefreshing,
      isButtonLoading: isButtonLoading ?? this.isButtonLoading,
    );
  }
}
