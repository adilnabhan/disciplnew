import 'package:customer_mobile_app/imports_bindings.dart';
import 'package:customer_mobile_app/src/features/profile/domain/repositories/profile_completion_repository.dart';
import 'package:customer_mobile_app/src/features/profile/cubit/profile_completion/profile_completion_state.dart';

export 'profile_completion_state.dart';

class ProfileCompletionCubit extends Cubit<ProfileCompletionState> {
  ProfileCompletionCubit({ProfileCompletionRepository? repository})
    : _repository = repository ?? ProfileCompletionRepository(),
      super(const ProfileCompletionState());

  final ProfileCompletionRepository _repository;

  Future<void> fetchProfileCompletion() async {
    final currentUser = Feggy.read<AppCubit>()?.state.currentUser;
    if (currentUser == null) {
      emit(state.copyWith(isLoading: false, data: null));
      return;
    }

    if (!state.isDismissedLocally && state.data == null) {
      emit(state.copyWith(isLoading: true));
    }

    final result = await _repository.getProfileCompletion();
    if (isClosed) return;
    result.fold(
      (error) {
        // Fail silently on error without showing snackbar
        emit(state.copyWith(isLoading: false));
      },
      (data) {
        // Backend controls dismissal cooldown (48 hours).
        // If backend returns dismissed == false & isCompleted == false, reset local dismissal flag.
        final bool isStillDismissed = data.dismissed || data.isCompleted;
        emit(
          state.copyWith(
            isLoading: false,
            data: data,
            isDismissedLocally: isStillDismissed ? true : false,
          ),
        );
      },
    );
  }

  Future<void> dismissBanner() async {
    // Hide immediately locally with animation
    emit(state.copyWith(isDismissedLocally: true));
    // Asynchronously call backend to persist dismissal
    await _repository.dismissProfileCompletion();
  }
}
