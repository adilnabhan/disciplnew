import 'package:customer_mobile_app/imports_bindings.dart';


part 'guest_account_state.dart';
part 'guest_account_cubit.freezed.dart';

class GuestAccountCubit extends Cubit<GuestAccountState> {
  GuestAccountCubit({SentOtpEntity? sentOtp})
      : super(GuestAccountState());

  // Future<void> loginAsGuest() async {
  //   if (state.guestLogin?.isNone() ?? false) {
  //     return;
  //   }
  //   emit(state.copyWith(guestLogin: none()));
  //   final response = await AuthRepository().loginAsGuest();
  //   response.fold(
  //         (l) => emit(state.copyWith(guestLogin: some(left(l)))),
  //         (r) => emit(state.copyWith(guestLogin: some(right(r)))),
  //   );
  // }
}
