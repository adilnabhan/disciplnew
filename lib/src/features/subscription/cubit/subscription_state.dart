part of 'subscription_cubit.dart';

@freezed
class SubscriptionState with _$SubscriptionState {
  const factory SubscriptionState({
    @Default(None())
    Option<Either<ApiException, List<FitnesscenterMembershipPlansModel>>> plans,
    FitnesscenterMembershipPlansModel? selectedSubscriptionModel,
    Option<Either<ApiException, PaymentSuccessResponse>>? payment,
    int? emiId,
    @Default(false) bool isPaymentLoading,
  }) = _SubscriptionState;
}
