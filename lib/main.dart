import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:fp2/firebase_options.dart';
// import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:fp2/components/life_cycle_event_handler.dart';
import 'package:fp2/landing/landing_page.dart';
import 'package:fp2/screens/mainscreen.dart';
import 'package:fp2/services/user_service.dart';
import 'package:fp2/utils/config.dart';
import 'package:fp2/utils/constants.dart';
import 'package:fp2/utils/providers.dart';
import 'package:fp2/view_models/theme/theme_view_model.dart';
import 'package:firebase_app_check/firebase_app_check.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  FirebaseAppCheck appCheck = FirebaseAppCheck.instance;
 await appCheck.activate();
  FirebaseFirestore.instance.settings = const Settings(
    persistenceEnabled: true,
  );
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(
      LifecycleEventHandler(
        detachedCallBack: () => UserService().setUserStatus(false),
        resumeCallBack: () => UserService().setUserStatus(true),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: providers,
      child: Consumer<ThemeProvider>(
        builder: (context, ThemeProvider notifier, Widget? child) {
          return MaterialApp(
            title: Constants.appName,
            debugShowCheckedModeBanner: false,
            theme: themeData(
              notifier.dark ? Constants.darkTheme : Constants.lightTheme,
            ),
            home: StreamBuilder(
              stream: FirebaseAuth.instance.authStateChanges(),
              builder: ((BuildContext context, snapshot) {
                if (snapshot.hasData) {
                  return TabScreen();
                } else
                  return Landing();
              }),
            ),
          );
        },
      ),
    );
  }

ThemeData themeData(ThemeData theme) {
  return theme.copyWith(
    textTheme: theme.textTheme.copyWith(
      // Define your own text styles here
      // Example:
      // headline1: TextStyle(
      //   fontFamily: 'YourFontFamily',
      //   fontSize: 24.0,
      //   fontWeight: FontWeight.bold,
      // ),
    ),
  );
}

}

