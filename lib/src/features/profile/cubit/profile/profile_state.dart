part of 'profile_cubit.dart';

@freezed
class ProfileState with _$ProfileState {
  const factory ProfileState({
    @Default(None()) Option<Either<ApiException, CustomerDetailsModel>> customerDetails,
    Option<Either<ApiException, void>>? updateProfileDetails,
    Option<Either<ApiException, ConstantChoicesModel>>? constChoice,
  }) = _ProfileState;
}
