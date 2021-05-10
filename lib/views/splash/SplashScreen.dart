import 'dart:convert';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:my_cab/helpers&widgets/helpers/Language/LanguageData.dart';
import 'package:my_cab/helpers&widgets/helpers/Language/appLocalizations.dart';
import 'package:my_cab/constance/constance.dart';
import 'package:my_cab/constance/global.dart' as globals;
import 'package:my_cab/constance/routes.dart';
import 'package:my_cab/constance/themes.dart';

import 'package:my_cab/constance/constance.dart' as constance;
import 'package:transparent_image/transparent_image.dart';

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with SingleTickerProviderStateMixin {
  AnimationController animationController;
  BuildContext myContext;
  FirebaseAuth auth = FirebaseAuth.instance;

  @override
  void initState() {
    myContext = context;
    _loadNextScreen();
    animationController = new AnimationController(vsync: this, duration: Duration(milliseconds: 1000));
    animationController.forward();
    super.initState();
  }

  _loadNextScreen() async {
    await Future.delayed(const Duration(milliseconds: 1100));
    if (!mounted) return;
    if (constance.allTextData == null) {
      constance.allTextData = AllTextData.fromJson(json.decode(await DefaultAssetBundle.of(myContext).loadString("assets/jsonFile/languagetext.json")));
    }
    checkUserStatus();
  }

  checkUserStatus() {
    auth.currentUser == null ? Navigator.pushReplacementNamed(context, Routes.INTRODUCTION) : Navigator.pushReplacementNamed(context, Routes.HOME);
  }

  @override
  void dispose() {
    animationController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    globals.locale = Localizations.localeOf(context);
    return Scaffold(
      backgroundColor: Colors.blue,
      body: Stack(
        children: [
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SpinKitCircle(color: globals.white),
            ],
          ),
 
          Image.asset(
            ConstanceData.splashMod,
            fit: BoxFit.values[2],
            height: MediaQuery.of(context).size.height,
            width: MediaQuery.of(context).size.width,
          )
        ],
      ),

      // Image.asset(ConstanceData.splashMod, fit: BoxFit.cover,height: MediaQuery.of(context).size.height,width: MediaQuery.of(context).size.width,)

      // Container(
      //   constraints: BoxConstraints(minHeight: MediaQuery.of(context).size.height, minWidth: MediaQuery.of(context).size.width),
      //   child: Center(
      //     child: Column(
      //       mainAxisSize: MainAxisSize.max,
      //       mainAxisAlignment: MainAxisAlignment.center,
      //       children: <Widget>[
      //         Expanded(
      //           child: SizedBox(),
      //         ),
      //         SizedBox(
      //           width: 80,
      //           height: 80,
      //           child: AnimatedBuilder(
      //             animation: animationController,
      //             builder: (BuildContext context, Widget child) {
      //               return Transform(
      //                 transform: new Matrix4.translationValues(
      //                     0.0,
      //                     80 *
      //                         (1.0 -
      //                             (AlwaysStoppedAnimation(
      //                                         Tween(begin: 0.0, end: 1.0).animate(CurvedAnimation(parent: animationController, curve: Curves.fastOutSlowIn)))
      //                                     .value)
      //                                 .value),
      //                     0.0),
      //                 child: Card(
      //                   shape: RoundedRectangleBorder(
      //                     borderRadius: BorderRadius.circular(15.0),
      //                   ),
      //                   elevation: 12,
      //                   child: Image.asset(ConstanceData.appIcon),
      //                 ),
      //               );
      //             },
      //           ),
      //         ),
      //         AnimatedBuilder(
      //           animation: animationController,
      //           builder: (BuildContext context, Widget child) {
      //             return Transform(
      //               transform: new Matrix4.translationValues(
      //                   0.0,
      //                   120 *
      //                       (1.0 -
      //                           (AlwaysStoppedAnimation(
      //                                       Tween(begin: 0.2, end: 1.0).animate(CurvedAnimation(parent: animationController, curve: Curves.fastOutSlowIn)))
      //                                   .value)
      //                               .value),
      //                   0.0),
      //               child: Padding(
      //                 padding: const EdgeInsets.all(8.0),
      //                 child: Opacity(
      //                   opacity: animationController.value,
      //                   child: Text(
      //                     AppLocalizations.of('Armotale'),
      //                     style: Theme.of(context).textTheme.display2.copyWith(color: Colors.white, fontWeight: FontWeight.bold, fontFamily: 'Helvetica'),
      //                   ),
      //                 ),
      //               ),
      //             );
      //           },
      //         ),
      //         Expanded(
      //           child: SizedBox(),
      //         ),
      //         AnimatedBuilder(
      //           animation: animationController,
      //           builder: (BuildContext context, Widget child) {
      //             return Stack(
      //               alignment: AlignmentDirectional.bottomCenter,
      //               children: <Widget>[
      //                 Transform(
      //                   transform: new Matrix4.translationValues(
      //                       0.0,
      //                       160 *
      //                           (1.0 -
      //                               (AlwaysStoppedAnimation(
      //                                           Tween(begin: 0.4, end: 1.0).animate(CurvedAnimation(parent: animationController, curve: Curves.fastOutSlowIn)))
      //                                       .value)
      //                                   .value),
      //                       0.0),
      //                   child: Image.asset(
      //                     ConstanceData.buildingImageBack,
      //                     color: Colors.black,
      //                   ),
      //                 ),
      //                 Transform(
      //                   transform: new Matrix4.translationValues(
      //                       0.0,
      //                       160 *
      //                           (1.0 -
      //                               (AlwaysStoppedAnimation(
      //                                           Tween(begin: 0.8, end: 1.0).animate(CurvedAnimation(parent: animationController, curve: Curves.fastOutSlowIn)))
      //                                       .value)
      //                                   .value),
      //                       0.0),
      //                   child: Image.asset(
      //                     ConstanceData.buildingImage,
      //                     color: Colors.black,
      //                   ),
      //                 ),
      //               ],
      //             );
      //           },
      //         ),
      //       ],
      //     ),
      //   ),
      // ),
    );
  }
}
