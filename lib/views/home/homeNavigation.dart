import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:my_cab/constance/constance.dart';
import 'package:my_cab/constance/global.dart';
import 'package:my_cab/helpers&widgets/helpers/routing.dart';
import 'package:my_cab/services/emailService.dart';
import 'package:my_cab/services/userServices.dart';
import 'package:my_cab/views/drawer/drawer.dart';
import 'package:my_cab/views/home/homePage.dart';
import 'package:my_cab/views/servicesAvailable/courierScreens/courierMainScreen.dart';
import 'package:my_cab/views/setting/setting_Screen.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';

enum Pages { homePage, profileScreen }

class HomeNavigation extends StatefulWidget {
  @override
  _HomeNavigationState createState() => _HomeNavigationState();
}

class _HomeNavigationState extends State<HomeNavigation> {
  Pages selectedPage = Pages.homePage;
  FirebaseAuth auth = FirebaseAuth.instance;
  UserServices _userServices = new UserServices();
  OneSignal oneSignal = new OneSignal();
  EmailService emailService = new EmailService();
  final key = GlobalKey<ScaffoldState>();
  String userName = '';
  String emailAddress = '';
  String profilePicture = '';
  String pushMessage = '';

  @override
  void initState() {
    super.initState();
    // print(oneSignal.)
    getCurrentUserInfo();
    initializeOneSIgnal();
  }

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height;

    return SafeArea(
      child: Scaffold(
          key: key,
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          drawer: AppDrawer(
            selectItemName: 'Home',
          ),
          body: Stack(
            children: [
              selectedScreen(),
              Container(
                // padding: EdgeInsets.all(20),
                alignment: Alignment.topLeft,
                child: Padding(
                  padding: const EdgeInsets.only(top: 13.0, left: 6),
                  child: GestureDetector(
                      onTap: () => key.currentState.openDrawer(),
                      child: Container(
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: LinearGradient(
                              begin: Alignment.centerLeft,
                              end: Alignment.centerRight,
                              colors:  [white, blue],
                            ),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(10.0),
                            child: Image.asset(ConstanceData.menuIcon, height: 20, width: 20),
                          ))),
                ),
              ),
            ],
          ),
          // floatingActionButton: FloatingActionButton(
          //   backgroundColor: Color(0xff1c2954),
          //   elevation: 0,
          //   shape: RoundedRectangleBorder(
          //       borderRadius: BorderRadius.only(
          //     topRight: Radius.circular(25.0),
          //     bottomRight: Radius.circular(25.0),
          //     bottomLeft: Radius.circular(25.0),
          //   )),
          //   child: Icon(
          //     Icons.add,
          //     size: 30,
          //     color: white,
          //   ),
          //   onPressed: () {
          //     emailService.sendWelcomeEmail('Patto', 'patiyang5@gmail.com');
          //   },
          // ),
          floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
          bottomNavigationBar: Container(
            decoration: BoxDecoration(
                          color:selectedPage==Pages.profileScreen?white: Color(0xff2581c8),
              // gradient: LinearGradient(
              //   begin: Alignment.centerLeft,
              //   end: Alignment.centerRight,
              //   colors: selectedPage == Pages.profileScreen ? [white.withOpacity(.4), white.withOpacity(.2)] : [blue.withOpacity(.7), darkBLue],
              // ),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.only(topLeft: Radius.circular(15.0), topRight: Radius.circular(15.0)),
              child: BottomAppBar(
                shape: CircularNotchedRectangle(),
                notchMargin: 4,
                color: darkBLue,
                child: Container(
                  height: 45,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: <Widget>[
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          MaterialButton(
                            child: Icon(
                              Icons.home,
                              color: selectedPage == Pages.homePage ? Colors.white : Colors.grey,
                            ),
                            // color: Colors.grey,
                            onPressed: () {
                              setState(() {
                                selectedPage = Pages.homePage;
                              });
                            },
                          ),
                        ],
                      ),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          MaterialButton(
                            onPressed: () {
                              setState(() {
                                selectedPage = Pages.profileScreen;
                              });
                            },
                            child: Icon(Icons.person, color: selectedPage == Pages.profileScreen ? Colors.white : Colors.grey),
                            // color: currentTab == 3 ? Colors.white : Colors.grey,
                          )
                        ],
                      )
                    ],
                  ),
                ),
              ),
            ),
          )),
    );
  }

  Widget selectedScreen() {
    switch (selectedPage) {
      case Pages.homePage:
        return HomePagePrimary();
        break;
      case Pages.profileScreen:
        return SettingScreen();
        break;
      default:
        return Container();
    }
  }

  void getCurrentUserInfo() async {
    print(auth.currentUser.uid);
    await _userServices.getUserById(auth.currentUser.uid).then((value) {
      setState(() {
        userName = value.names;
        emailAddress = value.email ?? 'Update your email in settings';
        profilePicture = value.profilePicture ?? '';
      });
    });
  }

  Future initializeOneSIgnal() async {
    OneSignal.shared.init(oneSignalAppId);
    OneSignal.shared.setInFocusDisplayType(OSNotificationDisplayType.notification);
    OneSignal.shared.setExternalUserId(auth.currentUser.uid);

    OneSignal.shared.setNotificationReceivedHandler((OSNotification notification) {
      print(notification.payload.title);
    });
    OneSignal.shared.setNotificationOpenedHandler((OSNotificationOpenedResult result) {
      print(result);
      changeScreenReplacement(context, CourierMain(selectedIndex: 1));
    });
    OneSignal.shared.setInAppMessageClickedHandler((OSInAppMessageAction action) {
      print('inapp clicked');
      // this.setState(() {
      //   _debugLabelString =
      //       "In App Message Clicked: \n${action.jsonRepresentation().replaceAll("\\n", "\n")}";
      // });
    });
    // OneSignal.shared.deleteTags(keys)
    // OneSignal.shared.se
  }
}
