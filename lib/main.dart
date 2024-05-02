import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'bindings.dart';
import 'firebase_options.dart';
import 'loadingScreen.dart';
import 'notif/notifCtr.dart';

SharedPreferences? sharedPrefs;
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
Future<void> initFirebase() async {
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
}

void main() async {
  print('##run_main');

  WidgetsFlutterBinding.ensureInitialized();
  ///initialize firebase
  await initFirebase();

  ///PREFS
  sharedPrefs = await SharedPreferences.getInstance();

  ///initilize notif
  // setup local NOTIF
  if (!kIsWeb) {//if mobile
    await setupFlutterNotifications();
  }
  // Firebase msging BG listen
  FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);

  /// RUN_APP
  runApp(MyApp()); //should contain materialApp
}

class MyApp extends StatefulWidget {
  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {


  @override
  void initState() {
    super.initState();
  }

  /// ///////////////////
  @override
  Widget build(BuildContext context) {
    return ResponsiveSizer(

        builder: (context, orientation, deviceType) {
          return GetMaterialApp(
            navigatorKey: navigatorKey,
            debugShowCheckedModeBanner: false,
            title: 'Clubs',

            themeMode: ThemeMode.light,
            //light

            initialBinding: GetxBinding(),
            getPages: [
              GetPage(name: '/', page: () => LoadingScreen()),
              //GetPage(name: '/', page: () => ScreenManager()), //in test mode
            ],
          );
        });
  }
}

