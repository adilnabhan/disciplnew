import 'package:customer_mobile_app/src/features/profile/domain/models/profile_completion_model.dart';
import 'package:flutter/foundation.dart';

@immutable
class ProfileCompletionState {
  const ProfileCompletionState({
    this.isLoading = false,
    this.data,
    this.isDismissedLocally = false,
    this.isRewardPopupDismissedInSession = false,
    this.isRewardBannerDismissedLocally = false,
    this.errorMessage,
  });

  final bool isLoading;
  final ProfileCompletionModel? data;
  final bool isDismissedLocally;
  final bool isRewardPopupDismissedInSession;
  final bool isRewardBannerDismissedLocally;
  final String? errorMessage;

  ProfileCompletionState copyWith({
    bool? isLoading,
    ProfileCompletionModel? data,
    bool? isDismissedLocally,
    bool? isRewardPopupDismissedInSession,
    bool? isRewardBannerDismissedLocally,
    String? errorMessage,
  }) {
    return ProfileCompletionState(
      isLoading: isLoading ?? this.isLoading,
      data: data ?? this.data,
      isDismissedLocally: isDismissedLocally ?? this.isDismissedLocally,
      isRewardPopupDismissedInSession:
          isRewardPopupDismissedInSession ?? this.isRewardPopupDismissedInSession,
      isRewardBannerDismissedLocally:
          isRewardBannerDismissedLocally ?? this.isRewardBannerDismissedLocally,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}
