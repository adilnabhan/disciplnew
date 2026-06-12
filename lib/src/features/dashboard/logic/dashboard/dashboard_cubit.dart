import 'package:customer_mobile_app/imports_bindings.dart';

part 'dashboard_state.dart';
part 'dashboard_cubit.freezed.dart';

///
class DashboardCubit extends Cubit<DashboardState> {
  DashboardCubit({int? navIndex})
    : super(DashboardState(navIndex: navIndex ?? 0));

  //* Change nav index
  void changeNav({required int index}) {
    emit(state.copyWith(navIndex: index));
  }
  //* Fetch active membership data
  Future<void> fetchActiveMembership() async {
    print('calling emmemr');

    bool isCustomer;
    if (Feggy.read<AppCubit>()?.state.currentUser == null) {
      isCustomer = false;
    } else {
      isCustomer = true;
    }
    // print('isss---$isCustomer');
    if (isCustomer) {
      emit(state.copyWith(activeMembershipData: none()));
      final id = Feggy.read<AppCubit>()?.state.currentUser?.customer?.id;
      if (id == null) {
        print('ere-----');
        emit(
          state.copyWith(
            activeMembershipData: some(left(const ApiException.unknown())),
          ),
        );
        return;
      }
      final response = await CustomerMembershipRepository().activeMembership(
        id: id,
      );
      print('DashboardCubit: activeMembership response: $response');
      emit(state.copyWith(activeMembershipData: some(response)));
    }
  }
}
