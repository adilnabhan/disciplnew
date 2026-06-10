part of 'payments_cubit.dart';

@freezed
class PaymentsState with _$PaymentsState {
  const factory PaymentsState({
    @Default((data: None(), isPagination: false))
    ({
      Option<Either<ApiException, PaymentHistoryModel>> data,
      bool isPagination,
    })
    paymentHistory,

    @Default((data: None()))
    ({Option<Either<ApiException, PaymentHistoryDetailsModel>> data})
    paymentHistoryDetails,
  }) = _PaymentsState;
}
