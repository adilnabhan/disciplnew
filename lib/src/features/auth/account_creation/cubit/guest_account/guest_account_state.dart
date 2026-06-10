part of 'guest_account_cubit.dart';

@freezed
class GuestAccountState with _$GuestAccountState {
  const factory GuestAccountState({
    Option<Either<ApiException, LoginSuccessModel?>>? guestLogin,
    @Default(false) bool isLoading,
  }) = _GuestAccountState;
}
