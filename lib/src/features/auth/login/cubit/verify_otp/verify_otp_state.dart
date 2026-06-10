part of 'verify_otp_cubit.dart';

@freezed
class VerifyOtpState with _$VerifyOtpState {
  const factory VerifyOtpState({
    required SentOtpEntity sentOtpEntity,
    Option<Either<ApiException, LoginSuccessModel?>>? verifyOtp,
    Option<Either<ApiException, SentOtpEntity>>? resentOtp,
    Option<Either<ApiException, ConstantChoicesModel>>? constChoice,
    @Default(0) int resentOtpReminigTime,
  }) = _VerifyOtpState;
}
