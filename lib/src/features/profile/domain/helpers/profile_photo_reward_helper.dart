import 'package:customer_mobile_app/src/features/profile/domain/models/profile_completion_model.dart';
import 'package:flutter/foundation.dart';

/// Testable helper containing business rules and visibility decision logic
/// for the Profile Photo Reward flow.
class ProfilePhotoRewardHelper {
  const ProfilePhotoRewardHelper._();

  /// Determines whether the promotional popup should be shown on the Home screen.
  ///
  /// Criteria:
  /// - User is authenticated (not a guest).
  /// - Completion data exists with a [ProfilePhotoRewardModel].
  /// - Backend flag `popup.should_show == true`.
  /// - User does not already have a profile photo (`has_profile_photo != true`).
  /// - Reward has not already been awarded (`is_awarded != true`).
  /// - Reward is not marked dismissed on backend.
  /// - Has not already been displayed/dismissed during the current session (`hasSeenInSession != true`).
  static bool shouldShowPromotionalPopup(
    ProfileCompletionModel? data, {
    bool hasSeenInSession = false,
    bool isGuest = false,
  }) {
    if (isGuest || data == null || hasSeenInSession) {
      return false;
    }

    final reward = data.profilePhotoReward;
    if (reward == null) {
      return false;
    }

    final popup = reward.popup;
    if (popup == null || popup.shouldShow != true) {
      return false;
    }

    // Guard: If backend indicates already has photo or already awarded
    if (reward.hasProfilePhoto == true) {
      debugPrint('ℹ️ [ProfilePhotoRewardHelper] Suppressed promo popup: user already has profile photo.');
      return false;
    }

    if (reward.isAwarded == true) {
      debugPrint('ℹ️ [ProfilePhotoRewardHelper] Suppressed promo popup: reward already awarded.');
      return false;
    }

    if (reward.dismissed == true) {
      debugPrint('ℹ️ [ProfilePhotoRewardHelper] Suppressed promo popup: reward is dismissed on backend.');
      return false;
    }

    return true;
  }

  /// Determines whether the promotional banner should be shown.
  ///
  /// Criteria:
  /// - User is authenticated (not a guest).
  /// - Completion data exists with a [ProfilePhotoRewardModel].
  /// - Backend flag `banner.should_show == true`.
  /// - Popup is not currently visible (avoid showing both simultaneously).
  /// - Has not been dismissed locally in the UI.
  static bool shouldShowRewardBanner(
    ProfileCompletionModel? data, {
    bool isPopupVisible = false,
    bool isDismissedLocally = false,
    bool isGuest = false,
  }) {
    if (isGuest || data == null || isPopupVisible || isDismissedLocally) {
      return false;
    }

    final reward = data.profilePhotoReward;
    if (reward == null) {
      return false;
    }

    final banner = reward.banner;
    if (banner == null || banner.shouldShow != true) {
      return false;
    }

    return true;
  }

  /// Determines whether backend authoritatively confirms the reward has been awarded.
  static bool isRewardConfirmedAwarded(ProfileCompletionModel? data) {
    if (data == null || data.profilePhotoReward == null) return false;
    final reward = data.profilePhotoReward!;
    return reward.isAwarded == true && (reward.success ?? true);
  }
}
