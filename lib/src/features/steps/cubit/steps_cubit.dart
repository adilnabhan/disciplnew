import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:customer_mobile_app/src/features/steps/cubit/steps_state.dart';
import 'package:customer_mobile_app/src/features/steps/data/health_service.dart';

class StepsCubit extends Cubit<StepsState> {
  StepsCubit({HealthService? healthService})
      : _healthService = healthService ?? HealthService(),
        super(const StepsState());

  final HealthService _healthService;

  /// Initializes step tracking by checking Health Connect availability and permission state.
  Future<void> checkAndLoadSteps({bool showLoading = true}) async {
    if (showLoading && state.status == StepsStatus.initial) {
      emit(state.copyWith(status: StepsStatus.loading));
    } else {
      emit(state.copyWith(isButtonLoading: true, isRefreshing: true));
    }

    try {
      final isAvailable = await _healthService.isHealthConnectAvailable();
      if (!isAvailable) {
        emit(state.copyWith(
          status: StepsStatus.unavailable,
          isButtonLoading: false,
          isRefreshing: false,
        ));
        return;
      }

      final hasPermission = await _healthService.hasStepPermission();
      if (!hasPermission) {
        emit(state.copyWith(
          status: StepsStatus.permissionRequired,
          isButtonLoading: false,
          isRefreshing: false,
        ));
        return;
      }

      await _fetchSteps();
    } catch (e) {
      emit(state.copyWith(
        status: StepsStatus.error,
        errorMessage: 'Unable to connect to Health Connect.',
        isButtonLoading: false,
        isRefreshing: false,
      ));
    }
  }

  /// Requests permission from Health Connect with button loading.
  Future<void> requestPermission() async {
    emit(state.copyWith(isButtonLoading: true));
    try {
      final granted = await _healthService.requestStepPermission();
      if (granted) {
        await _fetchSteps();
      } else {
        emit(state.copyWith(
          status: StepsStatus.permissionDenied,
          isButtonLoading: false,
          isRefreshing: false,
        ));
      }
    } catch (e) {
      emit(state.copyWith(
        status: StepsStatus.permissionDenied,
        errorMessage: 'Permission request failed.',
        isButtonLoading: false,
        isRefreshing: false,
      ));
    }
  }

  /// Internal step fetcher after permission is confirmed.
  Future<void> _fetchSteps() async {
    final stepCount = await _healthService.getTodaySteps();
    if (stepCount != null) {
      emit(state.copyWith(
        status: StepsStatus.loaded,
        steps: stepCount,
        isButtonLoading: false,
        isRefreshing: false,
      ));
    } else {
      emit(state.copyWith(
        status: StepsStatus.error,
        errorMessage: 'Failed to read step count.',
        isButtonLoading: false,
        isRefreshing: false,
      ));
    }
  }

  /// Refreshes step count without full loader if already granted.
  Future<void> refreshSteps() async {
    await checkAndLoadSteps(showLoading: false);
  }
}
