part of 'home_cubit.dart';

@freezed
class HomeState with _$HomeState {
  const factory HomeState({@Default(None()) Option<Either<ApiException, HomeModel>> homeData}) = _HomeState;
}
