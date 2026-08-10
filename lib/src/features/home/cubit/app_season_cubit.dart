import 'package:customer_mobile_app/imports_bindings.dart';
import 'package:customer_mobile_app/src/features/home/domain/models/app_season_model.dart';
import 'package:customer_mobile_app/src/features/home/domain/repositories/home_repository.dart';

class AppSeasonState {
  final bool isLoading;
  final AppSeasonModel seasonModel;

  const AppSeasonState({
    this.isLoading = false,
    this.seasonModel = const AppSeasonModel(isActive: false),
  });

  bool get isActive => seasonModel.isActive;
  String get seasonName => seasonModel.name ?? 'Onam';
  String get seasonCode => seasonModel.code ?? 'onam';

  AppSeasonState copyWith({
    bool? isLoading,
    AppSeasonModel? seasonModel,
  }) {
    return AppSeasonState(
      isLoading: isLoading ?? this.isLoading,
      seasonModel: seasonModel ?? this.seasonModel,
    );
  }
}

class AppSeasonCubit extends Cubit<AppSeasonState> {
  AppSeasonCubit()
      : super(
          AppSeasonState(
            seasonModel: HomeRepository.cachedSeasonModel ??
                const AppSeasonModel(isActive: false),
          ),
        );

  Future<void> fetchAppSeason() async {
    emit(state.copyWith(isLoading: true));
    final seasonModel = await HomeRepository().fetchAppSeason();
    emit(state.copyWith(isLoading: false, seasonModel: seasonModel));
  }
}
