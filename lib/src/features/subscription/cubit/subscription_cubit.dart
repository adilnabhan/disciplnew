import 'package:customer_mobile_app/imports_bindings.dart';

part 'subscription_cubit.freezed.dart';
part 'subscription_state.dart';

class SubscriptionCubit extends Cubit<SubscriptionState> {
  SubscriptionCubit({required this.orgId}) : super(const SubscriptionState()) {
    _razorpay = Razorpay();
    _razorpay
      ..on(Razorpay.EVENT_PAYMENT_SUCCESS, _handlePaymentSuccess)
      ..on(Razorpay.EVENT_PAYMENT_ERROR, _handlePaymentError)
      ..on(Razorpay.EVENT_EXTERNAL_WALLET, _handleExternalWallet);
  }

  late final Razorpay _razorpay;
  final int orgId;

  Future<void> fetchSubscriptions() async {
    emit(state.copyWith(plans: none()));
    final res = await FitnesscenterRepository().fitnesscenterMembershipPlans(
      id: orgId,
    );
    res.fold((l) {}, (plans) {
      if (plans.isNotEmpty) {
        emit(state.copyWith(selectedSubscriptionModel: plans.first));
      }
    });
    emit(state.copyWith(plans: some(res)));
  }

  void selectSubscription({
    required FitnesscenterMembershipPlansModel model,
    int? emiId,
  }) {
    emit(state.copyWith(selectedSubscriptionModel: model, emiId: emiId));
  }

  Future<void> payment() async {
    emit(state.copyWith(payment: none(), isPaymentLoading: true));
    if (state.selectedSubscriptionModel?.id == null) {
      emit(
        state.copyWith(
          payment: some(
            left(const ApiException.notFound(msg: 'Please select a plan!')),
          ),
          isPaymentLoading: true,
        ),
      );
      return;
    }
    final res = await SubscriptionRepository().initiateRazorpayOrder(
      body: {
        'plan_id': state.selectedSubscriptionModel!.id,
        // 'organization_id': orgId,
        if (state.emiId != null) 'emi_plan_id': state.emiId,
      },
    );
    await res.fold(
      (l) async {
        emit(state.copyWith(payment: some(left(l)), isPaymentLoading: false));
      },
      (rozarpayOrder) async {
        return openRazorpayCheckout(
          rozarpayOrder: rozarpayOrder,
          isSubscription: rozarpayOrder.subscriptionId != null,
        );
      },
    );
  }

  Future<void> openRazorpayCheckout({
    required InitiateRazorpayOrderModel rozarpayOrder,
    required bool isSubscription,
  }) async {
    emit(state.copyWith(payment: none(), isPaymentLoading: true));

    final razorpayApiKey = dotenv.get('RAZORPAY_API_KEY');
    try {
      final discountAmount = rozarpayOrder.amount?.toNum ?? 0;
      if (isSubscription) {
        final subscriptionId = rozarpayOrder.subscriptionId;
        if (subscriptionId == null) {
          emit(
            state.copyWith(
              payment: some(
                left(
                  const ApiException.notFound(msg: 'Subscription ID missing'),
                ),
              ),
              isPaymentLoading: false,
            ),
          );
          return;
        }
        final subscriptionOptions = {
          'key': razorpayApiKey,
          'subscription_id': subscriptionId,
          'name':
              '${rozarpayOrder.user?.firstName ?? ''} ${rozarpayOrder.user?.lastName ?? ''}'
                  .trim(),
          'description':
              state.selectedSubscriptionModel?.name ?? 'Subscription Plan',
          'timeout': 300,
          'prefill': {
            'contact': rozarpayOrder.user?.mobileNumber ?? '',
            'email': rozarpayOrder.user?.email ?? '',
          },
        };
        _razorpay.open(subscriptionOptions);
      } else {
        final razorpayOrderId = rozarpayOrder.orderId;

        if (discountAmount <= 0) {
          emit(
            state.copyWith(
              isPaymentLoading: false,
              payment: some(
                left(const ApiException.notFound(msg: 'Select a valid plan')),
              ),
            ),
          );
          return;
        }

        if (razorpayOrderId == null) {
          emit(
            state.copyWith(
              isPaymentLoading: false,
              payment: some(
                left(
                  const ApiException.notFound(
                    msg: 'Payment Failed! Please try again',
                  ),
                ),
              ),
            ),
          );
          return;
        }

        final options = {
          'key': razorpayApiKey,
          'amount': discountAmount, // in paise
          'name':
              '${rozarpayOrder.user?.firstName ?? ''} ${rozarpayOrder.user?.lastName ?? ''}'
                  .trim(),
          'order_id': razorpayOrderId,
          'description': state.selectedSubscriptionModel?.name,
          'timeout': 300,
          'prefill': {
            'contact': rozarpayOrder.user?.mobileNumber ?? '',
            'email': rozarpayOrder.user?.email ?? '',
          },
        };

        _razorpay.open(options);
      }
    } catch (e) {
      emit(
        state.copyWith(
          isPaymentLoading: false,
          payment: some(
            left(const ApiException.notFound(msg: 'Payment Failed')),
          ),
        ),
      );
    }
  }

  void _handlePaymentSuccess(PaymentSuccessResponse response) {
    /// Do something when payment succeeds
    // fetchLastPaymentStatus(response);
    print('responec is--${response.data}');
    print('responec is--${response.signature}');
    print('responec is--${response.orderId}');
    print('responec is--${response.paymentId}');
    emit(
      state.copyWith(payment: some(right(response)), isPaymentLoading: false),
    );
  }

  void _handlePaymentError(PaymentFailureResponse response) {
    /// Do something when payment fails
    emit(
      state.copyWith(
        isPaymentLoading: false,
        payment: some(
          left(
            ApiException.notFound(msg: response.message ?? 'Payment Failed'),
          ),
        ),
      ),
    );
  }

  void _handleExternalWallet(ExternalWalletResponse response) {
    /// Do something when an external wallet is selected
    // emit(state.copyWith(payment: some(left(response))));
  }

  @override
  Future<void> close() {
    _razorpay.clear();
    return super.close();
  }
}
