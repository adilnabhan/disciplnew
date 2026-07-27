import 'package:customer_mobile_app/imports_bindings.dart';
import 'package:customer_mobile_app/src/features/home/domain/models/banner_model.dart';

part 'home_state.dart';
part 'home_cubit.freezed.dart';

class HomeCubit extends Cubit<HomeState> {
  HomeCubit() : super(const HomeState());

  Future<void> fetchHomeData({int? orgId}) async {
    print('home calling with orgId: $orgId');
    if (state.homeData.isNone()) {
      emit(state.copyWith(
        homeData: none(),
        gymBanners: none(),
        globalBanners: none(),
      ));
    }
    final response = await HomeRepository().home();
    
    // Fetch Banners
    final globalResponse = await HomeRepository().getGlobalBanners();
    
    Either<ApiException, List<BannerModel>>? gymResponse;
    if (orgId != null) {
      gymResponse = await HomeRepository().getGymBanners(orgId);
    }

    emit(state.copyWith(
      homeData: some(response),
      globalBanners: some(globalResponse),
      gymBanners: gymResponse != null ? some(gymResponse) : none(),
    ));
  }
}
