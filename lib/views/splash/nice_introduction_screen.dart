import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:my_cab/constance/sharedPreferences.dart';
import 'package:my_cab/helpers&widgets/helpers/Language/appLocalizations.dart';
import 'package:my_cab/constance/constance.dart';
import 'package:my_cab/constance/global.dart' as globals;
import 'package:my_cab/constance/themes.dart';
import 'package:my_cab/views/auth/login_screen.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class NiceIntroductionScreen extends StatefulWidget {
  @override
  _NiceIntroductionScreenState createState() => _NiceIntroductionScreenState();
}

class _NiceIntroductionScreenState extends State<NiceIntroductionScreen> with SingleTickerProviderStateMixin {
  AnimationController animationController;
  LatLng currentPostion;
  MySharedPreferences mySharedPreferences = new MySharedPreferences();

  @override
  void initState() {
    super.initState();
    animationController = new AnimationController(vsync: this, duration: Duration(milliseconds: 1000));
    animationController..forward();
  }

  @override
  Widget build(BuildContext context) {
    globals.locale = Localizations.localeOf(context);
    return Scaffold(
      backgroundColor: Theme.of(context).backgroundColor,
      body: Container(
        constraints: BoxConstraints(minHeight: MediaQuery.of(context).size.height, minWidth: MediaQuery.of(context).size.width),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Spacer(),
              Image.asset(ConstanceData.welcomeToArmotale, height: 200, width: 200),
              SizedBox(height: 20),
              Text(
                AppLocalizations.of('Welcome to armotale'),
                style: Theme.of(context).textTheme.headline.copyWith(fontWeight: FontWeight.bold),
              ),
              Spacer(),
              Container(
                            height: 48,
                            decoration: BoxDecoration(
                              color: Colors.blue,
                              borderRadius: BorderRadius.all(Radius.circular(24.0)),
                              boxShadow: <BoxShadow>[
                                BoxShadow(
                                  color: Theme.of(context).dividerColor,
                                  blurRadius: 8,
                                  offset: Offset(4, 4),
                                ),
                              ],
                            ),
                            child: Material(
                              color: Colors.transparent,
                              child: InkWell(
                                borderRadius: BorderRadius.all(Radius.circular(4.0)),
                                highlightColor: Colors.transparent,
                                onTap: () async {
                                  await _getCurrentLocation().then((value) async {
                                    if (value != null) {
                                      Navigator.pushReplacement(
                                        context,
                                        MaterialPageRoute(builder: (context) => LoginScreen()),
                                      );

                                    } else {
                                      Fluttertoast.showToast(msg: 'Please check your location settings');
                                    }
                                  });
                                },
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: <Widget>[
                                    Icon(
                                      Icons.near_me,
                                      color: Colors.white,
                                    ),
                                    SizedBox(
                                      width: 8,
                                    ),
                                    Text(
                                      AppLocalizations.of('Use current location'),
                                      style: Theme.of(context).textTheme.subhead.copyWith(
                                            color: Colors.black,
                                            fontWeight: FontWeight.bold,
                                          ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          Expanded(child: SizedBox())
              // Expanded(
              //   child: ClipRect(
              //     child: AnimatedBuilder(
              //       animation: animationController,
              //       builder: (BuildContext context, Widget child) {
              //         return Stack(
              //           alignment: Alignment.bottomCenter,
              //           children: <Widget>[
              //             Transform(
              //               transform: new Matrix4.translationValues(
              //                   0.0,
              //                   160 *
              //                           (1.0 -
              //                               (AlwaysStoppedAnimation(Tween(begin: 0.4, end: 1.0)
              //                                           .animate(CurvedAnimation(parent: animationController, curve: Curves.fastOutSlowIn)))
              //                                       .value)
              //                                   .value) -
              //                       16,
              //                   0.0),
              //               child: Image.asset(
              //                 ConstanceData.buildingImageBack,
              //                 color: Colors.blue,
              //               ),
              //             ),
              //             Transform(
              //               transform: new Matrix4.translationValues(
              //                   0.0,
              //                   160 *
              //                       (1.0 -
              //                           (AlwaysStoppedAnimation(Tween(begin: 0.8, end: 1.0)
              //                                       .animate(CurvedAnimation(parent: animationController, curve: Curves.fastOutSlowIn)))
              //                                   .value)
              //                               .value),
              //                   0.0),
              //               child: Image.asset(
              //                 ConstanceData.buildingImage,
              //                 color: Colors.black,
              //               ),
              //             ),
              //             SizedBox(
              //               width: 240,
              //               child: Image.asset(
              //                 ConstanceData.carImage,
              //               ),
              //             )
              //           ],
              //         );
              //       },
              //     ),
              //   ),
              // ),
              // Expanded(
              //   child: Column(
              //     children: <Widget>[
              //       Expanded(
              //         child: SizedBox(),
              //       ),
              //       // Expanded(
              //       //   child: Center(
              //       //     child: Text(
              //       //       AppLocalizations.of('Welcome to armotale'),
              //       //       style: Theme.of(context).textTheme.headline.copyWith(fontWeight: FontWeight.bold),
              //       //     ),
              //       //   ),
              //       // ),
              //       // Expanded(
              //       //   child: Center(
              //       //     child: Text(
              //       //       AppLocalizations.of(''),
              //       //       textAlign: TextAlign.center,
              //       //       style: Theme.of(context).textTheme.subhead,
              //       //     ),
              //       //   ),
              //       // ),
              //       // Expanded(
              //       //   flex: 2,
              //       //   child: Center(
              //       //     child: Padding(
              //       //       padding: const EdgeInsets.only(left: 24, right: 24, bottom: 8, top: 8),
              //       //       child: Container(
              //       //         height: 48,
              //       //         decoration: BoxDecoration(
              //       //           color: Colors.blue,
              //       //           borderRadius: BorderRadius.all(Radius.circular(24.0)),
              //       //           boxShadow: <BoxShadow>[
              //       //             BoxShadow(
              //       //               color: Theme.of(context).dividerColor,
              //       //               blurRadius: 8,
              //       //               offset: Offset(4, 4),
              //       //             ),
              //       //           ],
              //       //         ),
              //       //         child: Material(
              //       //           color: Colors.transparent,
              //       //           child: InkWell(
              //       //             borderRadius: BorderRadius.all(Radius.circular(4.0)),
              //       //             highlightColor: Colors.transparent,
              //       //             onTap: () async {
              //       //               await _getCurrentLocation().then((value) async {
              //       //                 if (value != null) {
              //       //                   Navigator.pushReplacement(
              //       //                     context,
              //       //                     MaterialPageRoute(builder: (context) => LoginScreen()),
              //       //                   );

              //       //                 } else {
              //       //                   Fluttertoast.showToast(msg: 'Please check your location settings');
              //       //                 }
              //       //               });
              //       //             },
              //       //             child: Row(
              //       //               mainAxisAlignment: MainAxisAlignment.center,
              //       //               children: <Widget>[
              //       //                 Icon(
              //       //                   Icons.near_me,
              //       //                   color: Colors.white,
              //       //                 ),
              //       //                 SizedBox(
              //       //                   width: 8,
              //       //                 ),
              //       //                 Text(
              //       //                   AppLocalizations.of('Use current location'),
              //       //                   style: Theme.of(context).textTheme.subhead.copyWith(
              //       //                         color: Colors.black,
              //       //                         fontWeight: FontWeight.bold,
              //       //                       ),
              //       //                 ),
              //       //               ],
              //       //             ),
              //       //           ),
              //       //         ),
              //       //       ),
              //       //     ),
              //       //   ),
              //       // ),
              //       // Expanded(
              //       //   child: SizedBox(),
              //       // ),
              //     ],
              //   ),
              // ),
            ],
          ),
        ),
      ),
    );
  }

  Future<LatLng> _getCurrentLocation() async {
    var position = await GeolocatorPlatform.instance.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
    currentPostion = LatLng(position.latitude, position.longitude);
    return currentPostion;
  }
}
