part of 'home_cubit.dart';

@freezed
class HomeState with _$HomeState {
  const factory HomeState({
    @Default(None()) Option<Either<ApiException, HomeModel>> homeData,
    @Default(None()) Option<Either<ApiException, List<BannerModel>>> gymBanners,
    @Default(None()) Option<Either<ApiException, List<BannerModel>>> globalBanners,
  }) = _HomeState;
}
