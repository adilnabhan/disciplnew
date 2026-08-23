// import 'package:customer_mobile_app/imports_bindings.dart';
//
// part 'app_cubit.freezed.dart';
// part 'app_state.dart';
//
// class AppCubit extends HydratedCubit<AppState> {
//   AppCubit() : super(const AppState()) {}
//
//   void updateProfilePicture(dynamic profilePic) {
//     emit(
//       state.copyWith(
//         currentUser: state.currentUser?.copyWith(profilePicture: profilePic),
//       ),
//     );
//   }
//
//   void updateTokenAndRefresh({String? token, String? refresh}) {
//     emit(
//       state.copyWith(
//         currentUser: state.currentUser?.copyWith(
//           access: token,
//           refresh: refresh,
//         ),
//       ),
//     );
//   }
//
//   //*
//   Future<void> changeThemeMode(ThemeMode theme) async {
//     //  await SessionService().storeTheme(theme);
//     emit(state.copyWith(themeMode: theme));
//     // await NotificationServices.createNotification(
//     //   title: 'Theme Changed',
//     //   body: 'Current theme mode is ${theme.name}',
//     // );
//   }
//
//   //
//   void changeLocale(Locale locale) {
//     emit(state.copyWith(locale: locale));
//   }
//
//   void addUser(LoginSuccessModel user) {
//     emit(state.copyWith(currentUser: user));
//   }
//
//   void removeUser() {
//     emit(state.copyWith(currentUser: null));
//   }
//
//   @override
//   AppState? fromJson(Map<String, dynamic> json) {
//     final currentUser =
//         json['currentUser'] != null
//             ? LoginSuccessModel.fromJson(
//               json['currentUser'] as Map<String, dynamic>,
//             )
//             : null;
//     return AppState(
//       themeMode: switch (json['theme_mode']) {
//         'dark' => ThemeMode.dark,
//         _ => ThemeMode.light,
//       },
//       locale: Locale(json['language_code'] as String),
//       currentUser: currentUser,
//     );
//   }
//
//   @override
//   Map<String, dynamic>? toJson(AppState state) {
//     return {
//       'theme_mode': state.themeMode.name,
//       'language_code': state.locale.languageCode,
//       'currentUser': state.currentUser?.toJson(),
//     };
//   }
//
//   // Future<void> fetchConstChoices() async {
//   //   emit(state.copyWith(constChoice: none()));
//   //   final response = await AuthRepository().fetchConstChoices();
//   //   emit(state.copyWith(constChoice: some(response)));
//   //
//   // }
//
//
//   Future<void> refreshToken() async {
//     final refreshToken = state.currentUser?.refresh;
//
//     if (refreshToken == null || refreshToken.isEmpty) {
//       emit(state.copyWith(currentUser: null));
//       return;
//     }
//
//     final result = await AuthRepository().refreshToken(refreshToken);
//
//     result.fold(
//           (error) {
//         emit(state.copyWith(currentUser: null));
//       },
//           (data) {
//             print('abc----${data['access']}');
//         updateTokenAndRefresh(
//           token: data['access']?.toString(),
//           refresh: data['refresh']?.toString(),
//         );
//         print('new token is ----${jsonEncode(state.currentUser?.access)}');
//       },
//     );
//   }
//
// }

import 'package:customer_mobile_app/imports_bindings.dart';

part 'app_cubit.freezed.dart';
part 'app_state.dart';

class AppCubit extends HydratedCubit<AppState> {
  AppCubit() : super(const AppState());

  bool _isRefreshing = false;

  // bool _isRefreshing = false;

  // ---------------- USER ----------------

  void addUser(LoginSuccessModel user) {
    LocalStorageService().saveUser(user);
    emit(state.copyWith(currentUser: user));
  }

  void updateOrganizationId(int? organizationId) {
    final user = state.currentUser;
    if (user != null && user.customer != null) {
      final updatedCustomer = user.customer!.copyWith(organizationId: organizationId);
      final updatedUser = user.copyWith(customer: updatedCustomer);
      LocalStorageService().saveUser(updatedUser);
      emit(state.copyWith(currentUser: updatedUser));
    }
  }

  void removeUser() {
    LocalStorageService().clearUser();
    emit(state.copyWith(currentUser: null));
  }

  void updateProfilePicture(dynamic profilePic) {
    emit(
      state.copyWith(
        currentUser: state.currentUser?.copyWith(profilePicture: profilePic),
      ),
    );
  }

  void updateTokenAndRefresh({
    required String access,
    required String refresh,
  }) {
    emit(
      state.copyWith(
        currentUser: state.currentUser?.copyWith(
          access: access,
          refresh: refresh,
        ),
      ),
    );
  }

  // ---------------- SETTINGS ----------------

  Future<void> changeThemeMode(ThemeMode theme) async {
    emit(state.copyWith(themeMode: theme));
  }

  void changeLocale(Locale locale) {
    emit(state.copyWith(locale: locale));
  }

  // ---------------- REFRESH TOKEN ----------------

  // Future<void> refreshToken() async {
  //   if (_isRefreshing) return;
  //   _isRefreshing = true;
  //   print('refresh token calling ---');
  //   final refreshToken = state.currentUser?.refresh;

  //   if (refreshToken == null || refreshToken.isEmpty) {
  //     emit(state.copyWith(currentUser: null));
  //     _isRefreshing = false;
  //     return;
  //   }

  //   final result = await AuthRepository().refreshToken(refreshToken);

  //   result.fold(
  //     (error) {
  //       /// ❌ refresh failed → logout
  //       emit(state.copyWith(currentUser: null));
  //     },
  //     (data) {
  //       print('new token is ---${data['access']}');

  //       final access = data['access']?.toString();
  //       final refresh = data['refresh']?.toString();

  //       if (access != null && refresh != null) {
  //         emit(
  //           state.copyWith(
  //             currentUser: state.currentUser?.copyWith(
  //               access: access,
  //               refresh: refresh,
  //             ),
  //           ),
  //         );
  //       } else {
  //         emit(state.copyWith(currentUser: null));
  //       }
  //     },
  //   );

  //   _isRefreshing = false;
  // }

  // ---------------- HYDRATED ----------------

  @override
  AppState? fromJson(Map<String, dynamic> json) {
    var currentUser =
        json['currentUser'] != null
            ? LoginSuccessModel.fromJson(
              json['currentUser'] as Map<String, dynamic>,
            )
            : null;

    // 🛡️ Fallback: Check Hive if HydratedBloc lost the user (e.g. cache cleared)
    if (currentUser == null) {
      final localUser = LocalStorageService().getUser();
      if (localUser != null) {
        print('✅ AppCubit: Restored user from Hive storage.');
        currentUser = localUser;
      }
    }

    return AppState(
      themeMode:
          json['theme_mode'] == 'dark' ? ThemeMode.dark : ThemeMode.light,
      locale: Locale(json['language_code'] as String),
      currentUser:
          json['currentUser'] != null
              ? LoginSuccessModel.fromJson(
                json['currentUser'] as Map<String, dynamic>,
              )
              : null,
    );
  }

  @override
  Map<String, dynamic>? toJson(AppState state) {
    return {
      
      'theme_mode': state.themeMode.name,
     
      'language_code': state.locale.languageCode,
     
      'currentUser': state.currentUser?.toJson(),
    
    };
  }

  Future<void> refreshToken() async {
    if (_isRefreshing) return;
    _isRefreshing = true;
    print('🔄 AppCubit: Starting token refresh process...');

    try {
      final user = state.currentUser;
      final refreshToken = user?.refresh;

      // 🚪 No refresh token → logout
      if (refreshToken == null || refreshToken.isEmpty) {
        print('❌ AppCubit: No refresh token found. Logging out.');
        if (state.currentUser != null) {
          emit(state.copyWith(currentUser: null));
        }
        return;
      }

      final result = await AuthRepository().refreshToken(refreshToken);

      result.fold(
        (error) {
          print('❌ AppCubit: Token refresh API failed. Error: $error');

          error.maybeWhen(
            network: (msg) {
              print(
                '🌐 AppCubit: Network issue detected ($msg). Keeping current session for offline access.',
              );
              // 🚪 Do NOT logout if it's just a network issue.
              // This allows the user to see cached data while offline.
            },
            orElse: () {
              print(
                '🚫 AppCubit: Token refresh failed (Invalid token). Logging out.',
              );
              if (state.currentUser != null) {
                emit(state.copyWith(currentUser: null));
                Feggy.pushAndRemoveUntil(const SentOtpScreen());
              }
            },
          );
        },
        (data) {
          print('✅ AppCubit: Token refresh API success.');
          print('🔑 New Access Token: ${data['access']}');
          print('🔄 New Refresh Token: ${data['refresh']}');

          final access = data['access']?.toString();
          final refresh = data['refresh']?.toString();

          // ❌ Invalid response → logout
          if (access == null) {
            print('❌ AppCubit: New access token is null. Logging out.');
            emit(state.copyWith(currentUser: null));
            return;
          }

          // ✅ Update tokens
          print('✅ AppCubit: Updating user with new tokens.');

          final updatedUser = user!.copyWith(
            access: access,
            refresh: refresh ?? user.refresh,
          );

          // 💾 Save to Hive
          LocalStorageService().saveUser(updatedUser);

          emit(state.copyWith(currentUser: updatedUser));
        },
      );
    } catch (e) {
      print('❌ AppCubit: Exception during token refresh: $e');
      // 🚪 On unexpected error, we keep the session to avoid aggressive logouts
      // especially during transient network issues or offline startup.
      print(
        '⚠️ AppCubit: Failed to pre-emptively refresh token. Keeping current session.',
      );
    } finally {
      _isRefreshing = false;
    }
  }
}
