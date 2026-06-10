part of 'workout_log_cubit.dart';

@freezed
class WorkoutLogState with _$WorkoutLogState {
  const factory WorkoutLogState({
    @Default((data: None(), isPagination: false))
    ({
      Option<Either<ApiException, PaymentHistoryModel>> data,
      bool isPagination,
    })
    paymentHistory,
  }) = _WorkoutLogState;
}
