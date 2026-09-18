import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:customer_mobile_app/src/features/challenges/cubit/challenge_details_state.dart';
import 'package:customer_mobile_app/src/features/challenges/domain/repositories/challenge_repository.dart';

class ChallengeDetailsCubit extends Cubit<ChallengeDetailsState> {
  final ChallengeRepository _repository;

  ChallengeDetailsCubit({ChallengeRepository? repository})
      : _repository = repository ?? ChallengeRepository(),
        super(const ChallengeDetailsState());

  Future<void> loadChallengeDetails(int challengeId) async {
    if (isClosed) return;
    emit(state.copyWith(isLoading: true, error: null));
    try {
      final details = await _repository.getChallengeDetails(challengeId);
      if (isClosed) return;
      if (details != null) {
        emit(state.copyWith(challenge: details, isLoading: false, error: null));
      } else {
        emit(state.copyWith(
          isLoading: false,
          error: 'Failed to load challenge details. Please try again.',
        ));
      }
    } catch (e) {
      if (isClosed) return;
      emit(state.copyWith(
        isLoading: false,
        error: 'An unexpected error occurred. Please try again.',
      ));
    }
  }

  Future<void> refreshChallengeDetails(int challengeId) async {
    try {
      final details = await _repository.getChallengeDetails(challengeId);
      if (isClosed) return;
      if (details != null) {
        emit(state.copyWith(challenge: details, isLoading: false, error: null));
      }
    } catch (_) {}
  }

  Future<bool> joinChallenge(int challengeId) async {
    if (isClosed) return false;
    emit(state.copyWith(isJoining: true));
    final res = await _repository.joinChallenge(challengeId);
    if (res.status) {
      await refreshChallengeDetails(challengeId);
    }
    if (isClosed) return res.status;
    emit(state.copyWith(isJoining: false));
    return res.status;
  }
}
