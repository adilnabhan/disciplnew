import 'package:customer_mobile_app/imports_bindings.dart';
import 'package:customer_mobile_app/src/features/challenges/domain/models/challenge_list_model.dart';
import 'package:customer_mobile_app/src/features/challenges/domain/repositories/challenge_repository.dart';
import 'package:customer_mobile_app/src/features/home/domain/models/home_challenge_model.dart';
import 'package:customer_mobile_app/src/features/home/domain/repositories/home_repository.dart';
import 'package:customer_mobile_app/src/features/home/cubit/home_challenge_state.dart';

class HomeChallengeCubit extends Cubit<HomeChallengeState> {
  HomeChallengeCubit() : super(const HomeChallengeState());

  final HomeRepository _repository = HomeRepository();
  final ChallengeRepository _challengeRepository = ChallengeRepository();

  Future<void> loadHomeChallenges() async {
    emit(state.copyWith(isLoading: true, errorMessage: null));
    try {
      final challenges = await _repository.getHomeChallenges();
      emit(state.copyWith(challenges: challenges, isLoading: false));
    } catch (e) {
      debugPrint('Error loading home challenges: $e');
      emit(state.copyWith(
        challenges: [],
        isLoading: false,
        errorMessage: e.toString(),
      ));
    }
  }

  Future<JoinChallengeResponse> joinChallenge(int challengeId) async {
    final response = await _challengeRepository.joinChallenge(challengeId);
    if (response.status) {
      loadHomeChallenges();
    }
    return response;
  }
}
