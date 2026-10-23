import 'package:customer_mobile_app/imports_bindings.dart';
import 'package:customer_mobile_app/src/features/profile/domain/models/profile_completion_model.dart';
import 'package:customer_mobile_app/src/features/profile/domain/repositories/profile_completion_repository.dart';
import 'package:customer_mobile_app/src/features/profile/cubit/profile_completion/profile_completion_state.dart';

export 'profile_completion_state.dart';

class ProfileCompletionCubit extends Cubit<ProfileCompletionState> {
  ProfileCompletionCubit({ProfileCompletionRepository? repository})
    : _repository = repository ?? ProfileCompletionRepository(),
      super(const ProfileCompletionState());

  final ProfileCompletionRepository _repository;

  /// Fetches profile completion and reward data from backend.
  ///
  /// Safe to call from screen initialization, pull-to-refresh, or navigation callbacks.
  Future<void> fetchProfileCompletion({bool force = false}) async {
    final currentUser = Feggy.read<AppCubit>()?.state.currentUser;
    if (currentUser == null) {
      emit(state.copyWith(isLoading: false, data: null));
      return;
    }

    if (!force && state.isLoading) {
      return;
    }

    if (!state.isDismissedLocally && state.data == null) {
      emit(state.copyWith(isLoading: true));
    }

    final result = await _repository.getProfileCompletion();
    if (isClosed) return;

    result.fold(
      (error) {
        debugPrint('⚠️ [ProfileCompletionCubit] Failed to fetch completion: ${error.msg}');
        emit(state.copyWith(isLoading: false, errorMessage: error.msg));
      },
      (data) {
        final bool isStillDismissed = data.dismissed || data.isCompleted;
        emit(
          state.copyWith(
            isLoading: false,
            data: data,
            isDismissedLocally: isStillDismissed,
            errorMessage: null,
          ),
        );
      },
    );
  }

  /// Refreshes and returns the latest completion & reward model.
  Future<ProfileCompletionModel?> refreshRewardState() async {
    final result = await _repository.getProfileCompletion();
    if (isClosed) return null;

    ProfileCompletionModel? freshData;
    result.fold(
      (error) {
        debugPrint('⚠️ [ProfileCompletionCubit] Refresh reward state error: ${error.msg}');
      },
      (data) {
        freshData = data;
        final bool isStillDismissed = data.dismissed || data.isCompleted;
        emit(
          state.copyWith(
            isLoading: false,
            data: data,
            isDismissedLocally: isStillDismissed,
            errorMessage: null,
          ),
        );
      },
    );
    return freshData;
  }

  /// Dismisses the general profile completion progress banner.
  Future<void> dismissBanner() async {
    emit(state.copyWith(isDismissedLocally: true));
    await _repository.dismissProfileCompletion();
  }

  /// Dismisses the promotional reward popup for this session.
  /// If [callBackend] is true, persists cooldown to server.
  Future<void> dismissRewardPopup({bool callBackend = true}) async {
    emit(state.copyWith(isRewardPopupDismissedInSession: true));
    if (callBackend) {
      await _repository.dismissProfileCompletion();
    }
  }

  /// Dismisses the promotional reward banner locally.
  Future<void> dismissRewardBanner({bool callBackend = false}) async {
    emit(state.copyWith(isRewardBannerDismissedLocally: true));
    if (callBackend) {
      await _repository.dismissProfileCompletion();
    }
  }
}
