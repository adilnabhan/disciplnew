import 'package:customer_mobile_app/core/network/dio_client.dart';
import 'package:customer_mobile_app/imports_bindings.dart';
import 'package:customer_mobile_app/src/features/auth/account_creation/presentation/screens/create_options_screen.dart';

class AppView extends StatefulWidget {
  const AppView({super.key});

  @override
  State<AppView> createState() => _AppViewState();
}

class _AppViewState extends State<AppView> {
  late final AppCubit _cubit;

  @override
  void initState() {
    super.initState();
    _cubit = AppCubit();
    DioClient().registerAuthInterceptor(_cubit);

    /// 🔥 IMPORTANT: wait until HydratedCubit restores state
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final user = _cubit.state.currentUser;
      if (user?.refresh?.isNotEmpty == true) {
        _cubit.refreshToken();
      }
    });
  }

  @override
  void dispose() {
    _cubit.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Sizer.init(
      child: MultiBlocProvider(
        providers: [BlocProvider.value(value: _cubit)],
        child: BlocBuilder<AppCubit, AppState>(
          builder: (context, state) {
            return FeggyApp(
              commonErrorHandlers: (error) {
                return ApiCommonErrors.handleNonFieldError(error: error);
              },

              fixedHeaders: {'X-Platform': platformSource, 'user_role': 45},

              /// ✅ Correct prefix
              token: () {
                final access = _cubit.state.currentUser?.access;
                return access != null ? 'JWT $access' : null;
              },

              /// 🔥 Do NOT logout immediately
              onTokenError: () async {
                await _cubit.refreshToken();
              },

              child: MaterialApp(
                navigatorKey: Feggy.navKey,
                debugShowCheckedModeBanner: false,
                themeMode: state.themeMode,
                theme: AppThemes.light,
                darkTheme: AppThemes.dark,
                locale: state.locale,
                home: BlocBuilder<AppCubit, AppState>(
                  buildWhen: (p, c) => false,
                  builder: (context, state) => getScreen(state),
                ),
              ));
            },
          ),
        ),
      // )
    );
  }

  Widget getScreen(AppState state) {
    print('the stored new ---${state.currentUser?.access}');

    if (state.currentUser == null) {
      return const CreateOptionsScreen();
    }
    return const DashboardScreen();
  }
}
