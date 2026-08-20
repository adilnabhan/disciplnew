import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:customer_mobile_app/imports_bindings.dart';
import 'package:customer_mobile_app/src/features/dashboard/domain/models/active_membership_model.dart';

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
    final currentUser = Feggy.read<AppCubit>()?.state.currentUser;
    final bool isCustomer = currentUser != null;

    if (isCustomer) {
      // ⚡ Step 1: Load from local cache immediately (0ms delay)
      if (state.activeMembershipData.isNone()) {
        try {
          final prefs = await SharedPreferences.getInstance();
          final cachedJsonStr = prefs.getString('cached_active_membership');
          if (cachedJsonStr != null && cachedJsonStr.isNotEmpty) {
            final cachedModel = ActiveMembershipModel.fromJson(
              jsonDecode(cachedJsonStr) as Map<String, dynamic>,
            );
            emit(state.copyWith(activeMembershipData: some(right(cachedModel))));
            print('⚡ DashboardCubit: Restored active membership from local cache');
          }
        } catch (e) {
          print('⚠️ DashboardCubit: Cache load error: $e');
        }
      }

      final id = currentUser?.customer?.id;
      if (id == null) {
        if (state.activeMembershipData.isNone()) {
          emit(
            state.copyWith(
              activeMembershipData: some(left(const ApiException.unknown())),
            ),
          );
        }
        return;
      }

      // ⚡ Step 2: Fetch fresh data from backend
      final response = await CustomerMembershipRepository().activeMembership(
        id: id,
      );
      print('DashboardCubit: activeMembership response: $response');

      // ⚡ Step 3: Update local cache with fresh data
      response.fold(
        (_) {},
        (model) async {
          try {
            final prefs = await SharedPreferences.getInstance();
            if (model != null) {
              await prefs.setString(
                'cached_active_membership',
                jsonEncode(model.toJson()),
              );
            } else {
              await prefs.remove('cached_active_membership');
            }
          } catch (e) {
            print('⚠️ DashboardCubit: Cache save error: $e');
          }
        },
      );

      emit(state.copyWith(activeMembershipData: some(response)));
    }
  }
}
