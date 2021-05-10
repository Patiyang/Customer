import 'dart:io';
import 'package:firebase_core/firebase_core.dart';
import 'package:my_cab/views/home/homeNavigation.dart';
import 'constance/constance.dart' as constance;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:my_cab/constance/themes.dart';
import 'package:my_cab/views/home/home_screen.dart';
import 'package:my_cab/views/splash/SplashScreen.dart';
import 'package:my_cab/views/splash/introductionScreen.dart';
import 'package:my_cab/constance/global.dart' as globals;
import 'package:my_cab/constance/routes.dart';


import 'helpers&widgets/helpers/Language/appLocalizations.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
   await Firebase.initializeApp();
  //  await DotEnv().load('.env');
  await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp, DeviceOrientation.portraitDown]).then((_) => runApp(new MyApp()));
}

class MyApp extends StatefulWidget {
  static changeTheme(BuildContext context) {
    _MyAppState state = context.findAncestorStateOfType<_MyAppState>();
    state.changeTheme();
  }

  static setCustomeLanguage(BuildContext context, String languageCode) {
    final _MyAppState state = context.findAncestorStateOfType<_MyAppState>();
    state.setLanguage(languageCode);
  }

  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  Key key = new UniqueKey();

  void changeTheme() {
    this.setState(() {
      globals.isLight = !globals.isLight;
    });
  }

  String locale = "en";
  setLanguage(String languageCode) {
    setState(() {
      locale = languageCode;
      constance.locale = languageCode;
    });
  }

  @override
  Widget build(BuildContext context) {
    constance.locale = locale;
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: globals.isLight ? Brightness.dark : Brightness.light,
      statusBarBrightness: Platform.isAndroid ? Brightness.dark : Brightness.light,
      systemNavigationBarColor: CoustomTheme.getThemeData().cardColor,
      systemNavigationBarDividerColor: CoustomTheme.getThemeData().disabledColor,
      systemNavigationBarIconBrightness: globals.isLight ? Brightness.dark : Brightness.light,
    ));
    return Container(
      key: key,
      color: CoustomTheme.getThemeData().backgroundColor,
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              CoustomTheme.getThemeData().backgroundColor,
              CoustomTheme.getThemeData().backgroundColor,
              CoustomTheme.getThemeData().backgroundColor.withOpacity(0.8),
              CoustomTheme.getThemeData().backgroundColor.withOpacity(0.7)
            ],
          ),
        ),
        child: MaterialApp(
          localizationsDelegates: [
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: [
            const Locale('en'), // English
            const Locale('fr'), // French
            const Locale('ar'), // Arabic
          ],
          debugShowCheckedModeBanner: false,
          title: AppLocalizations.of('My Cab'),
          routes: routes,
          theme: CoustomTheme.getThemeData(),
          builder: (BuildContext context, Widget child) {
            return Directionality(
              textDirection: TextDirection.ltr,
              child: Builder(
                builder: (BuildContext context) {
                  return MediaQuery(
                    data: MediaQuery.of(context).copyWith(
                      textScaleFactor: 1.0,
                    ),
                    child: child,
                  );
                },
              ),
            );
          },
        ),
      ),
    );
  }

  var routes = <String, WidgetBuilder>{
    Routes.SPLASH: (BuildContext context) => SplashScreen(),
    Routes.INTRODUCTION: (BuildContext context) => IntroductionScreen(),
    Routes.HOME: (BuildContext context) => HomeNavigation(),
  };
}
