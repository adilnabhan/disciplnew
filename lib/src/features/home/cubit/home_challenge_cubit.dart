import 'package:customer_mobile_app/imports_bindings.dart';
import 'package:customer_mobile_app/src/features/challenges/domain/models/challenge_list_model.dart';
import 'package:customer_mobile_app/src/features/challenges/domain/repositories/challenge_repository.dart';

class HomeChallengeCubit extends Cubit<HomeChallengeState> {
  HomeChallengeCubit() : super(const HomeChallengeState());

  final HomeRepository _repository = HomeRepository();
  final ChallengeRepository _challengeRepository = ChallengeRepository();

  Future<void> loadHomeChallenges({bool isRefresh = false}) async {
    if (isClosed) return;
    if (state.challenges.isEmpty || isRefresh) {
      emit(state.copyWith(isLoading: true));
    }
    try {
      final challenges = await _repository.getHomeChallenges();
      if (isClosed) return;
      emit(state.copyWith(challenges: challenges, isLoading: false));
    } catch (e) {
      debugPrint('Error loading home challenges: $e');
      if (isClosed) return;
      emit(state.copyWith(
        challenges: state.challenges,
        isLoading: false,
        errorMessage: state.challenges.isEmpty ? e.toString() : null,
      ));
    }
  }

  Future<JoinChallengeResponse> joinChallenge(int challengeId) async {
    final response = await _challengeRepository.joinChallenge(challengeId);
    if (response.status) {
      unawaited(loadHomeChallenges());
    }
    return response;
  }
}
