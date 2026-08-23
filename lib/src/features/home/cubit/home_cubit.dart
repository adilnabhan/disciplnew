import 'package:customer_mobile_app/imports_bindings.dart';

part 'home_state.dart';
part 'home_cubit.freezed.dart';

class HomeCubit extends Cubit<HomeState> {
  HomeCubit() : super(const HomeState());

  Future<void> fetchHomeData() async {
    print('home calling');
    emit(state.copyWith(homeData: none()));
    final response = await HomeRepository().home();
    emit(state.copyWith(homeData: some(response)));
  }
}
