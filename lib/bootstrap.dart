// import 'package:customer_mobile_app/firebase_options.dart';
import 'package:customer_mobile_app/core/storage/local_storage_service.dart';
import 'package:customer_mobile_app/imports_bindings.dart';

/// bootstraping
Future<void> bootstrap(FutureOr<Widget> Function() builder) async {
  //* ⚙️ widget binding
  WidgetsFlutterBinding.ensureInitialized();
  //*for log flutter global error 🐞
  //* Suppress hardware keyboard sync assertion error on emulators/desktop
  final originalOnError = FlutterError.onError;
  FlutterError.onError = (FlutterErrorDetails details) {
    final exceptionStr = details.exception.toString();
    if (exceptionStr.contains('KeyUpEvent') ||
        exceptionStr.contains('HardwareKeyboard') ||
        exceptionStr.contains('_pressedKeys.containsKey')) {
      return;
    }
    if (originalOnError != null) {
      originalOnError(details);
    } else {
      FlutterError.presentError(details);
    }
  };

  //* firebase configuration
  // await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  //* notification management
  // await NotificationServices.initialize();

  //* 🧪 bloc observer for manageing bloc lyfecyles
  Bloc.observer = const AppBlocObserver();

  // //* 🍪📦  session configuration
   HydratedBloc.storage = await HydratedStorage.build(
    storageDirectory:
        kIsWeb
            ? HydratedStorageDirectory.web
            : HydratedStorageDirectory(
              (await getApplicationDocumentsDirectory()).path,
            ),
  );

  //* 📦 Local Storage (Hive)
  await LocalStorageService().init();
  //* Environment variables
  await dotenv.load();

  //* 🏃 for integrate initial widget
  runApp(
    DevPreview(
      isEnabled: Platform.isLinux || Platform.isMacOS,
      // ||
      // Platform.isWindows ||
      // Platform.isIOS ||
      // Platform.isAndroid
      child: await builder(),
    ),
  );
}
