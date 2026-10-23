import 'package:customer_mobile_app/imports_bindings.dart';
import 'package:customer_mobile_app/src/features/profile/domain/models/customer_details_model.dart';
import 'package:customer_mobile_app/src/features/profile/domain/repositories/customer_details_repository.dart';
import 'package:customer_mobile_app/src/features/profile/presentation/screens/pages/profile_details_screen.dart';
import 'package:customer_mobile_app/src/features/scorecard/presentation/screens/score_card_screen.dart';

/// Helper that maps API action values and targets to existing app routes safely.
class ProfileRewardNavigationHelper {
  ProfileRewardNavigationHelper._();

  static bool _isNavigating = false;

  /// Handles action received from popup or banner safely without crashing on unknown routes.
  static Future<void> handleAction(
    BuildContext context, {
    String? action,
    String? targetScreen,
    String? targetRoute,
    bool autoOpenImagePicker = false,
    VoidCallback? onBeforeNavigate,
  }) async {
    if (_isNavigating) return;
    _isNavigating = true;

    try {
      onBeforeNavigate?.call();

      final cleanAction = action?.toLowerCase().trim() ?? '';
      final cleanScreen = targetScreen?.toLowerCase().trim() ?? '';
      final cleanRoute = targetRoute?.toLowerCase().trim() ?? '';

      // Target: Profile Edit / Profile Details
      if (cleanAction == 'open_profile_edit' ||
          cleanScreen == 'profile_edit' ||
          cleanScreen == 'profile' ||
          cleanRoute == '/profile' ||
          cleanRoute == '/profile/edit') {
        await navigateToProfileEdit(
          context,
          autoOpenImagePicker: autoOpenImagePicker,
        );
        return;
      }

      // Target: Score Card
      if (cleanAction == 'open_score_card' ||
          cleanAction == 'view_score_card' ||
          cleanScreen == 'score_card' ||
          cleanRoute == '/score-card' ||
          cleanRoute == '/scorecard') {
        navigateToScoreCard(context);
        return;
      }

      debugPrint(
        '⚠️ [ProfileRewardNavigationHelper] Unknown action: $action, screen: $targetScreen, route: $targetRoute',
      );
    } catch (e, stack) {
      debugPrint('❌ [ProfileRewardNavigationHelper] Navigation error: $e\n$stack');
    } finally {
      _isNavigating = false;
    }
  }

  /// Safely navigates to the Profile Edit screen ([ProfileDetailsScreen]) with [autoOpenImagePicker].
  static Future<void> navigateToProfileEdit(
    BuildContext context, {
    required bool autoOpenImagePicker,
  }) async {
    CustomerDetailsModel? details;
    final customerId = Feggy.read<AppCubit>()?.state.currentUser?.customer?.id;

    if (customerId != null) {
      final repo = CustomerDetailsRepository();
      final result = await repo.customerDetails(id: customerId);
      result.fold(
        (err) => debugPrint('Could not fetch customer details: ${err.msg}'),
        (d) => details = d,
      );
    }

    if (!context.mounted) return;

    if (details != null && context.mounted) {
      final profileCubit = ProfileCubit();
      await Navigator.of(context).push(
        MaterialPageRoute<void>(
          builder: (_) => BlocProvider.value(
            value: profileCubit,
            child: ProfileDetailsScreen(
              customerDetailsModel: details!,
              autoOpenImagePicker: autoOpenImagePicker,
            ),
          ),
        ),
      );
      unawaited(profileCubit.close());
    } else if (context.mounted) {
      // Fallback: switch to Dashboard's Profile tab
      try {
        context.read<DashboardCubit>().navigateToProfile();
      } catch (e) {
        debugPrint('Fallback navigation to profile tab failed: $e');
      }
    }
  }

  /// Safely navigates to the Score Card screen ([ScoreCardScreen]).
  static void navigateToScoreCard(BuildContext context) {
    try {
      final dashboardCubit = context.read<DashboardCubit>();
      if (dashboardCubit.hasActiveGym) {
        dashboardCubit.changeNav(index: 2);
        return;
      }
    } catch (_) {}

    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => const ScoreCardScreen(),
      ),
    );
  }
}
