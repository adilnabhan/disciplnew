import 'package:flutter_test/flutter_test.dart';
import 'package:customer_mobile_app/src/features/profile/domain/helpers/profile_photo_reward_helper.dart';
import 'package:customer_mobile_app/src/features/profile/domain/models/profile_completion_model.dart';

void main() {
  group('ProfileCompletionModel and ProfilePhotoRewardModel JSON parsing', () {
    test('Correctly parses full payload matching backend contract', () {
      final json = <String, dynamic>{
        'completion_percentage': 100,
        'is_completed': true,
        'dismissed': false,
        'title': 'Profile Complete! 🎉',
        'message': 'Your profile is 100% complete!',
        'completed_fields': ['Profile Photo', 'Full Name'],
        'missing_fields': <dynamic>[],
        'next_screen': 'profile',
        'profile_photo_reward': <String, dynamic>{
          'success': true,
          'should_show': false,
          'has_profile_photo': true,
          'reward_points': 100,
          'is_awarded': true,
          'current_score': 983,
          'score_after_reward': 983,
          'title': 'Profile Photo Added',
          'message': 'You have earned 100 points for adding your profile photo!',
          'description':
              'Your profile photo is set and 100 Discipl Score points have been credited to your score card.',
          'profile_photo_url': 'https://example.com/photo.jpg',
          'banner': <String, dynamic>{
            'should_show': false,
            'title': 'Profile Photo Added',
            'message': '100 points earned!',
            'badge_text': '+100 PTS',
            'button_text': 'View Profile',
            'action': 'open_profile_edit',
            'target_screen': 'profile_edit',
            'target_route': '/profile',
            'dismissable': true,
          },
          'popup': <String, dynamic>{
            'should_show': false,
            'title': 'Claim 100 Free Points! 🎁',
            'subtitle': 'Add Your Profile Photo',
            'message':
                'Upload your profile photo now and get 100 Discipl Score points credited directly to your score card!',
            'reward_points': 100,
            'current_score': 983,
            'new_score': 983,
            'icon': 'camera_award',
            'primary_button_text': 'Upload Photo (+100 pts)',
            'secondary_button_text': 'Maybe Later',
            'action': 'open_profile_edit',
            'target_screen': 'profile_edit',
            'target_route': '/profile',
            'dismissable': true,
          },
          'dismissed': false,
          'dismissed_at': null,
          'reappears_after_hours': 48,
        },
      };

      final model = ProfileCompletionModel.fromJson(json);

      expect(model.completionPercentage, 100);
      expect(model.isCompleted, true);
      expect(model.dismissed, false);
      expect(model.completedFields, ['Profile Photo', 'Full Name']);
      expect(model.missingFields, isEmpty);

      final reward = model.profilePhotoReward;
      expect(reward, isNotNull);
      expect(reward!.success, true);
      expect(reward.hasProfilePhoto, true);
      expect(reward.rewardPoints, 100);
      expect(reward.isAwarded, true);
      expect(reward.currentScore, 983);
      expect(reward.scoreAfterReward, 983);
      expect(reward.reappearsAfterHours, 48);

      final banner = reward.banner;
      expect(banner, isNotNull);
      expect(banner!.shouldShow, false);
      expect(banner.badgeText, '+100 PTS');
      expect(banner.buttonText, 'View Profile');
      expect(banner.action, 'open_profile_edit');

      final popup = reward.popup;
      expect(popup, isNotNull);
      expect(popup!.shouldShow, false);
      expect(popup.primaryButtonText, 'Upload Photo (+100 pts)');
      expect(popup.secondaryButtonText, 'Maybe Later');
      expect(popup.rewardPoints, 100);
    });

    test('Safely parses missing and null fields without throwing exceptions', () {
      final json = <String, dynamic>{};
      final model = ProfileCompletionModel.fromJson(json);

      expect(model.completionPercentage, 0);
      expect(model.isCompleted, false);
      expect(model.dismissed, false);
      expect(model.completedFields, isEmpty);
      expect(model.missingFields, isEmpty);
      expect(model.profilePhotoReward, isNull);
    });
  });

  group('ProfilePhotoRewardHelper eligibility rules', () {
    test('Scenario 1: User has no photo and popup.should_show == true -> show promo popup', () {
      final data = ProfileCompletionModel(
        completionPercentage: 80,
        isCompleted: false,
        dismissed: false,
        title: 'Complete Profile',
        message: 'Finish your profile',
        completedFields: [],
        missingFields: ['Profile Photo'],
        nextScreen: 'profile',
        profilePhotoReward: ProfilePhotoRewardModel(
          success: true,
          shouldShow: true,
          hasProfilePhoto: false,
          rewardPoints: 100,
          isAwarded: false,
          popup: const RewardPopupModel(
            shouldShow: true,
            title: 'Claim 100 Free Points! 🎁',
            primaryButtonText: 'Upload Photo (+100 pts)',
            secondaryButtonText: 'Maybe Later',
            dismissable: true,
          ),
        ),
      );

      final shouldShow = ProfilePhotoRewardHelper.shouldShowPromotionalPopup(
        data,
        hasSeenInSession: false,
        isGuest: false,
      );

      expect(shouldShow, isTrue);
    });

    test('Scenario 2: User dismissed popup in session -> do NOT show again in same session', () {
      final data = ProfileCompletionModel(
        completionPercentage: 80,
        isCompleted: false,
        dismissed: false,
        title: 'Complete Profile',
        message: 'Finish your profile',
        completedFields: [],
        missingFields: ['Profile Photo'],
        nextScreen: 'profile',
        profilePhotoReward: const ProfilePhotoRewardModel(
          hasProfilePhoto: false,
          isAwarded: false,
          popup: RewardPopupModel(shouldShow: true),
        ),
      );

      final shouldShow = ProfilePhotoRewardHelper.shouldShowPromotionalPopup(
        data,
        hasSeenInSession: true, // Dismissed in session
        isGuest: false,
      );

      expect(shouldShow, isFalse);
    });

    test('Scenario 3: User is a guest -> never show popup', () {
      final data = ProfileCompletionModel(
        completionPercentage: 0,
        isCompleted: false,
        dismissed: false,
        title: 'Title',
        message: 'Msg',
        completedFields: [],
        missingFields: [],
        nextScreen: 'profile',
        profilePhotoReward: const ProfilePhotoRewardModel(
          popup: RewardPopupModel(shouldShow: true),
        ),
      );

      final shouldShow = ProfilePhotoRewardHelper.shouldShowPromotionalPopup(
        data,
        hasSeenInSession: false,
        isGuest: true,
      );

      expect(shouldShow, isFalse);
    });

    test('Scenario 4: User already has photo or reward already awarded -> do NOT show promo popup', () {
      final dataWithPhoto = ProfileCompletionModel(
        completionPercentage: 100,
        isCompleted: true,
        dismissed: false,
        title: 'Done',
        message: 'Done',
        completedFields: ['Profile Photo'],
        missingFields: [],
        nextScreen: 'profile',
        profilePhotoReward: const ProfilePhotoRewardModel(
          hasProfilePhoto: true,
          isAwarded: false,
          popup: RewardPopupModel(shouldShow: true),
        ),
      );

      expect(
        ProfilePhotoRewardHelper.shouldShowPromotionalPopup(
          dataWithPhoto,
          hasSeenInSession: false,
          isGuest: false,
        ),
        isFalse,
      );

      final dataAlreadyAwarded = ProfileCompletionModel(
        completionPercentage: 100,
        isCompleted: true,
        dismissed: false,
        title: 'Done',
        message: 'Done',
        completedFields: ['Profile Photo'],
        missingFields: [],
        nextScreen: 'profile',
        profilePhotoReward: const ProfilePhotoRewardModel(
          hasProfilePhoto: false,
          isAwarded: true,
          popup: RewardPopupModel(shouldShow: true),
        ),
      );

      expect(
        ProfilePhotoRewardHelper.shouldShowPromotionalPopup(
          dataAlreadyAwarded,
          hasSeenInSession: false,
          isGuest: false,
        ),
        isFalse,
      );
    });

    test('Scenario 5: Backend indicates dismissed == true -> do NOT show promo popup', () {
      final dataDismissed = ProfileCompletionModel(
        completionPercentage: 50,
        isCompleted: false,
        dismissed: false,
        title: 'Title',
        message: 'Msg',
        completedFields: [],
        missingFields: ['Profile Photo'],
        nextScreen: 'profile',
        profilePhotoReward: const ProfilePhotoRewardModel(
          hasProfilePhoto: false,
          isAwarded: false,
          dismissed: true,
          popup: RewardPopupModel(shouldShow: true),
        ),
      );

      expect(
        ProfilePhotoRewardHelper.shouldShowPromotionalPopup(
          dataDismissed,
          hasSeenInSession: false,
          isGuest: false,
        ),
        isFalse,
      );
    });

    test('Scenario 6: Banner visibility logic obeys popup state and local dismissal', () {
      final dataWithBanner = ProfileCompletionModel(
        completionPercentage: 80,
        isCompleted: false,
        dismissed: false,
        title: 'Title',
        message: 'Msg',
        completedFields: [],
        missingFields: [],
        nextScreen: 'profile',
        profilePhotoReward: const ProfilePhotoRewardModel(
          banner: RewardBannerModel(shouldShow: true),
        ),
      );

      // Should show when popup is NOT visible and not locally dismissed
      expect(
        ProfilePhotoRewardHelper.shouldShowRewardBanner(
          dataWithBanner,
          isPopupVisible: false,
          isDismissedLocally: false,
        ),
        isTrue,
      );

      // Should NOT show when popup IS visible
      expect(
        ProfilePhotoRewardHelper.shouldShowRewardBanner(
          dataWithBanner,
          isPopupVisible: true,
          isDismissedLocally: false,
        ),
        isFalse,
      );

      // Should NOT show when dismissed locally
      expect(
        ProfilePhotoRewardHelper.shouldShowRewardBanner(
          dataWithBanner,
          isPopupVisible: false,
          isDismissedLocally: true,
        ),
        isFalse,
      );
    });

    test('Scenario 7: Reward confirmation check requires isAwarded == true', () {
      final notAwarded = ProfileCompletionModel(
        completionPercentage: 50,
        isCompleted: false,
        dismissed: false,
        title: 'Title',
        message: 'Msg',
        completedFields: [],
        missingFields: [],
        nextScreen: 'profile',
        profilePhotoReward: const ProfilePhotoRewardModel(isAwarded: false),
      );
      expect(ProfilePhotoRewardHelper.isRewardConfirmedAwarded(notAwarded), isFalse);

      final awarded = ProfileCompletionModel(
        completionPercentage: 100,
        isCompleted: true,
        dismissed: false,
        title: 'Title',
        message: 'Msg',
        completedFields: [],
        missingFields: [],
        nextScreen: 'profile',
        profilePhotoReward: const ProfilePhotoRewardModel(isAwarded: true, success: true),
      );
      expect(ProfilePhotoRewardHelper.isRewardConfirmedAwarded(awarded), isTrue);
    });
  });
}
