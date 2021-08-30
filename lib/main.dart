import 'package:campus_motorsport/provider/global/current_user.dart';
import 'package:campus_motorsport/repositories/firebase_crud/crud_user.dart';
import 'package:firebase_auth/firebase_auth.dart' as auth;
import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';

import 'package:campus_motorsport/routes/cm_router.dart';
import 'package:campus_motorsport/themes/color_theme.dart';
import 'package:campus_motorsport/routes/routes.dart';
import 'package:campus_motorsport/utilities/size_config.dart';
import 'package:campus_motorsport/themes/text_theme.dart';
import 'package:campus_motorsport/widgets/general/background/background_gradient.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import 'models/user.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  Paint.enableDithering = true;

  /// Remark : Might not work on some iOS devices.
  /// For possible fix see: https://stackoverflow.com/questions/49418332/flutter-how-to-prevent-device-orientation-changes-and-force-portrait
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  await Firebase.initializeApp();
  await Hive.initFlutter();

  Intl.defaultLocale = 'de';
  await initializeDateFormatting('de', null);

  runApp(MyApp());
}

/// Provider for controllers which need to be available globally should go here.
class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => CurrentUser()),
      ],
      child: MyMaterialApp(),
    );
  }
}

/// General app settings.
class MyMaterialApp extends StatelessWidget {
  const MyMaterialApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Dynamically switch themes here.
    final AppColorTheme colors = AppColorTheme();

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle(
        statusBarColor: colors.darkTheme.surface,
      ),
      child: MaterialApp(
        title: 'Campus Motorsport',
        onGenerateRoute: CustomRouter.generateRoute,
        initialRoute: initAppRoute,
        debugShowCheckedModeBanner: false,
        theme: ThemeData.from(
          colorScheme: colors.darkTheme,
          textTheme: textTheme,
        ),
        //checkerboardRasterCacheImages: true,
        //checkerboardOffscreenLayers: true,
      ),
    );
  }
}

/// Initialize SizeConfig.
///
/// Auto-Login can be checked here as well.
class InitApp extends StatefulWidget {
  const InitApp({Key? key}) : super(key: key);

  @override
  _InitAppState createState() => _InitAppState();
}

class _InitAppState extends State<InitApp> {
  bool? loggedIn;

  @override
  Future<void> didChangeDependencies() async {
    super.didChangeDependencies();

    /// Initialize the size values only once.
    SizeConfig().init(context);

    if (loggedIn == null) {
      if (auth.FirebaseAuth.instance.currentUser != null) {
        final User? currentUser = await CrudUser().getUser(
          auth.FirebaseAuth.instance.currentUser!.uid,
        );
        if (context.read<CurrentUser>().user != null &&
            context.read<CurrentUser>().user?.uid ==
                auth.FirebaseAuth.instance.currentUser!.uid) {
          setState(() {
            loggedIn = true;
          });
          return;
        }
        if (currentUser != null) {
          context.read<CurrentUser>().user = currentUser;
          setState(() {
            loggedIn = true;
          });
        } else {
          setState(() {
            loggedIn = false;
          });
        }
        setState(() {
          loggedIn = true;
        });
      } else {
        setState(() {
          loggedIn = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final child = BackgroundGradient(
      child: Center(
        child: CircularProgressIndicator(),
      ),
    );
    if (loggedIn == null) {
      return child;
    } else if (loggedIn == true) {
      /// Successful auto login. Go to home screen.
      WidgetsBinding.instance?.addPostFrameCallback((timeStamp) {
        Navigator.of(context).pushReplacementNamed(mainRoute);
      });
    } else {
      /// Failed auto login. Go to login screen.
      WidgetsBinding.instance?.addPostFrameCallback((timeStamp) {
        Navigator.of(context).pushReplacementNamed(loginRoute);
      });
    }
    return child;
  }
}
