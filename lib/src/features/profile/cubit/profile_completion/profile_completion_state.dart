import 'package:customer_mobile_app/src/features/profile/domain/models/profile_completion_model.dart';
import 'package:flutter/foundation.dart';

@immutable
class ProfileCompletionState {
  const ProfileCompletionState({
    this.isLoading = false,
    this.data,
    this.isDismissedLocally = false,
  });

  final bool isLoading;
  final ProfileCompletionModel? data;
  final bool isDismissedLocally;

  ProfileCompletionState copyWith({
    bool? isLoading,
    ProfileCompletionModel? data,
    bool? isDismissedLocally,
  }) {
    return ProfileCompletionState(
      isLoading: isLoading ?? this.isLoading,
      data: data ?? this.data,
      isDismissedLocally: isDismissedLocally ?? this.isDismissedLocally,
    );
  }
}
