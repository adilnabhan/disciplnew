import 'package:customer_mobile_app/imports_bindings.dart';

part 'payments_state.dart';
part 'payments_cubit.freezed.dart';

class PaymentsCubit extends Cubit<PaymentsState> {
  PaymentsCubit() : super(const PaymentsState());

  Future<void> fetchPaymentHistory({bool isPagination = false}) async {
    final paymentHistory = state.paymentHistory.data.fold(
      () => null,
      (t) => t.fold((l) => null, (r) => r),
    );
    if (isPagination && (paymentHistory?.next?.isEmpty ?? true)) {
      return;
    }
    emit(
      state.copyWith(
        paymentHistory: (
          data: isPagination ? state.paymentHistory.data : none(),
          isPagination: isPagination,
        ),
      ),
    );
    final response = await PaymentRepository().paymentHistory(
      queryParameters: {},
      nextUrl: isPagination ? paymentHistory?.next : null,
    );
    if (isPagination) {
      await response.fold(
        (l) {
          emit(
            state.copyWith(
              paymentHistory: (
                data: state.paymentHistory.data,
                isPagination: false,
              ),
            ),
          );
          return Dialogs.showSnack(msg: l.msg);
        },
        (r) {
          final data = r.copyWith(
            results: [...?paymentHistory?.results, ...?r.results],
          );
          emit(
            state.copyWith(
              paymentHistory: (data: some(right(data)), isPagination: false),
            ),
          );
        },
      );
    } else {
      emit(
        state.copyWith(
          paymentHistory: (data: some(response), isPagination: isPagination),
        ),
      );
    }
  }



  Future<void> fetchPaymentHistoryDetails() async {
    // Clear previous details state
    emit(
      state.copyWith(
        paymentHistoryDetails: (data: none()),
      ),
    );

    // Call the correct repository function
    final response = await PaymentRepository().paymentHistoryDetails();

    // Handle result
    await response.fold(
          (l) {
        Dialogs.showSnack(msg: l.msg);
        emit(
          state.copyWith(
            paymentHistoryDetails: (data: some(left(l))),
          ),
        );
      },
          (r) {
        emit(
          state.copyWith(
            paymentHistoryDetails: (data: some(right(r))),
          ),
        );
      },
    );
  }




}
