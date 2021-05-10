import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:my_cab/constance/constance.dart';
import 'package:my_cab/constance/global.dart';
import 'package:my_cab/constance/routes.dart';
import 'package:my_cab/helpers&widgets/helpers/Language/appLocalizations.dart';
import 'package:my_cab/helpers&widgets/helpers/routing.dart';
import 'package:my_cab/services/userServices.dart';
import 'package:my_cab/views/auth/login_screen.dart';
import 'package:my_cab/views/history/history_Screen.dart';
import 'package:my_cab/views/inviteFriends/inviteFriends_Screen.dart';
import 'package:my_cab/views/notification/notification_Screen.dart';
import 'package:my_cab/views/setting/setting_Screen.dart';
import 'package:my_cab/views/wallet/myWallet.dart';

class AppDrawer extends StatefulWidget {
  final String selectItemName;

  const AppDrawer({Key key, this.selectItemName}) : super(key: key);

  @override
  _AppDrawerState createState() => _AppDrawerState();
}

class _AppDrawerState extends State<AppDrawer> {
  // Pages selectedPage = Pages.homePage;
  FirebaseAuth auth = FirebaseAuth.instance;
  UserServices _userServices = new UserServices();

  String userName = '';
  String emailAddress = '';
  String profilePicture = '';
  @override
  void initState() {
    getCurrentUserInfo();

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Row(
        children: [
          Container(
            width: 280,
            decoration: BoxDecoration(
                                    borderRadius: BorderRadius.all(Radius.circular(0)),
                                    color: Color(0xff2581c8),
                                    gradient: LinearGradient(
                                      begin: Alignment.bottomLeft,
                                      end: Alignment.topRight,
                                      colors: [blue[100], grey[200]],
                                    ),
                                  ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.start,
              children: <Widget>[
                Stack(
                  alignment: AlignmentDirectional.centerStart,
                  children: <Widget>[
                    Container(
                      color: Theme.of(context).primaryColor,
                      height: 200,
                    ),
                    SizedBox(
                      height: 200,
                      child: Stack(
                        children: <Widget>[
                          Positioned(
                            left: -150,
                            right: -10,
                            top: -800,
                            bottom: 80,
                            child: SizedBox(
                              height: 800,
                              child: Card(
                                elevation: 0,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(500),
                                ),
                                margin: EdgeInsets.all(0),
                                color: Colors.black.withOpacity(0.06),
                              ),
                            ),
                          ),
                          Positioned(
                            left: -200,
                            right: 110,
                            top: -50,
                            bottom: -5,
                            child: SizedBox(
                              height: 400,
                              child: Card(
                                elevation: 0,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(500),
                                ),
                                margin: EdgeInsets.all(0),
                                color: Colors.black.withOpacity(0.06),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(left: 16, top: 16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Card(
                            margin: EdgeInsets.all(0),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(50),
                            ),
                            child: Container(
                              color: Theme.of(context).cardColor,
                              padding: EdgeInsets.all(2),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(50),
                                child: CircleAvatar(
                                  backgroundImage: profilePicture != '' ? NetworkImage(profilePicture) : AssetImage(ConstanceData.noImage),
                                  radius: 40,
                                ),
                              ),
                            ),
                          ),
                          SizedBox(height: 8),
                          Text(
                            AppLocalizations.of(userName),
                            style: Theme.of(context).textTheme.subtitle.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: Theme.of(context).backgroundColor,
                                  fontSize: 17
                                ),
                          ),
                          SizedBox(height: 3),
                          Text(
                            AppLocalizations.of(emailAddress),
                            style: Theme.of(context).textTheme.subtitle.copyWith(
                                  fontWeight: FontWeight.w500,
                                  color: Theme.of(context).backgroundColor,
                                ),
                          ),
                          SizedBox(
                            height: 8,
                          ),
                          // Row(
                          //   children: <Widget>[
                          //     Card(
                          //       shape: RoundedRectangleBorder(
                          //         borderRadius: BorderRadius.circular(36.0),
                          //       ),
                          //       child: Padding(
                          //         padding: const EdgeInsets.all(4),
                          //         child: Row(
                          //           children: <Widget>[
                          //             Text(
                          //               AppLocalizations.of("Cash"),
                          //               style: Theme.of(context).textTheme.button.copyWith(
                          //                     fontWeight: FontWeight.bold,
                          //                     color: Theme.of(context).textTheme.title.color,
                          //                   ),
                          //             ),
                          //             SizedBox(
                          //               width: 4,
                          //             ),
                          //             Text(
                          //               "2500",
                          //               style: Theme.of(context).textTheme.subtitle.copyWith(
                          //                     fontWeight: FontWeight.bold,
                          //                     color: Theme.of(context).primaryColor,
                          //                   ),
                          //             ),
                          //             SizedBox(
                          //               width: 4,
                          //             ),
                          //             Icon(
                          //               Icons.arrow_forward_ios,
                          //               color: Theme.of(context).disabledColor,
                          //               size: 16,
                          //             )
                          //           ],
                          //         ),
                          //       ),
                          //     ),
                          //   ],
                          // )
                        ],
                      ),
                    ),
                  ],
                ),
                Expanded(
                  child: SingleChildScrollView(
                    child: Padding(
                      padding: const EdgeInsets.only(left: 16),
                      child: Column(
                        children: <Widget>[
                          SizedBox(
                            height: 26,
                          ),
                          Row(
                            children: <Widget>[
                              widget.selectItemName == 'Home' ? selectedData() : SizedBox(),
                              Icon(
                                Icons.home,
                                size: 28,
                                color: widget.selectItemName == 'Home' ? Theme.of(context).primaryColor : Theme.of(context).disabledColor.withOpacity(0.2),
                              ),
                              SizedBox(
                                width: 8,
                              ),
                              Text(
                                AppLocalizations.of('Home'),
                                style: Theme.of(context).textTheme.subtitle.copyWith(
                                      fontWeight: FontWeight.bold,
                                      color: Theme.of(context).textTheme.title.color,
                                    ),
                              ),
                            ],
                          ),
                          // SizedBox(
                          //   height: 32,
                          // ),
                          // InkWell(
                          //   highlightColor: Colors.transparent,
                          //   splashColor: Colors.transparent,
                          //   onTap: () {
                          //     Navigator.pop(context);
                          //     Navigator.push(
                          //       context,
                          //       MaterialPageRoute(
                          //         builder: (context) => MyWallet(),
                          //       ),
                          //     );
                          //   },
                          //   child: Padding(
                          //     padding: const EdgeInsets.only(left: 4),
                          //     child: Row(
                          //       children: <Widget>[
                          //         widget.selectItemName == 'MyWallet' ? selectedData() : SizedBox(),
                          //         Icon(
                          //           FontAwesomeIcons.wallet,
                          //           size: 20,
                          //           color: widget.selectItemName == 'MyWallet' ? Theme.of(context).primaryColor : Theme.of(context).disabledColor.withOpacity(0.2),
                          //         ),
                          //         SizedBox(
                          //           width: 10,
                          //         ),
                          //         Text(
                          //           AppLocalizations.of('My Wallet'),
                          //           style: Theme.of(context).textTheme.subtitle.copyWith(
                          //                 fontWeight: FontWeight.bold,
                          //                 color: Theme.of(context).textTheme.title.color,
                          //               ),
                          //         ),
                          //       ],
                          //     ),
                          //   ),
                          // ),
                          SizedBox(
                            height: 32,
                          ),
                          InkWell(
                            highlightColor: Colors.transparent,
                            splashColor: Colors.transparent,
                            onTap: () {
                              Navigator.pop(context);
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => HistoryScreen(),
                                ),
                              );
                            },
                            child: Padding(
                              padding: const EdgeInsets.only(left: 4),
                              child: Row(
                                children: <Widget>[
                                  widget.selectItemName == 'History' ? selectedData() : SizedBox(),
                                  Icon(
                                    FontAwesomeIcons.history,
                                    size: 20,
                                    color:
                                        widget.selectItemName == 'History' ? Theme.of(context).primaryColor : Theme.of(context).disabledColor.withOpacity(0.2),
                                  ),
                                  SizedBox(
                                    width: 10,
                                  ),
                                  Text(
                                    AppLocalizations.of('History'),
                                    style: Theme.of(context).textTheme.subtitle.copyWith(
                                          fontWeight: FontWeight.bold,
                                          color: Theme.of(context).textTheme.title.color,
                                        ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          // SizedBox(
                          //   height: 32,
                          // ),
                          // InkWell(
                          //   highlightColor: Colors.transparent,
                          //   splashColor: Colors.transparent,
                          //   onTap: () {
                          //     Navigator.pop(context);
                          //     Navigator.push(
                          //       context,
                          //       MaterialPageRoute(
                          //         builder: (context) => NotificationScreen(),
                          //       ),
                          //     );
                          //   },
                          //   child: Padding(
                          //     padding: const EdgeInsets.only(left: 4),
                          //     child: Row(
                          //       children: <Widget>[
                          //         widget.selectItemName == 'Notification' ? selectedData() : SizedBox(),
                          //         Icon(
                          //           FontAwesomeIcons.solidBell,
                          //           size: 20,
                          //           color:
                          //               widget.selectItemName == 'Notification' ? Theme.of(context).primaryColor : Theme.of(context).disabledColor.withOpacity(0.2),
                          //         ),
                          //         SizedBox(
                          //           width: 10,
                          //         ),
                          //         Text(
                          //           AppLocalizations.of('Notification'),
                          //           style: Theme.of(context).textTheme.subtitle.copyWith(
                          //                 fontWeight: FontWeight.bold,
                          //                 color: Theme.of(context).textTheme.title.color,
                          //               ),
                          //         ),
                          //       ],
                          //     ),
                          //   ),
                          // ),
                          // SizedBox(
                          //   height: 32,
                          // ),
                          // InkWell(
                          //   highlightColor: Colors.transparent,
                          //   splashColor: Colors.transparent,
                          //   onTap: () {
                          //     Navigator.pop(context);
                          //     Navigator.push(
                          //       context,
                          //       MaterialPageRoute(
                          //         builder: (context) => InviteFriendsScreen(),
                          //       ),
                          //     );
                          //   },
                          //   child: Padding(
                          //     padding: const EdgeInsets.only(left: 4),
                          //     child: Row(
                          //       children: <Widget>[
                          //         widget.selectItemName == 'Invite' ? selectedData() : SizedBox(),
                          //         Icon(
                          //           FontAwesomeIcons.gifts,
                          //           size: 18,
                          //           color: widget.selectItemName == 'Invite' ? Theme.of(context).primaryColor : Theme.of(context).disabledColor.withOpacity(0.2),
                          //         ),
                          //         SizedBox(
                          //           width: 10,
                          //         ),
                          //         Text(
                          //           AppLocalizations.of('Invite Friends'),
                          //           style: Theme.of(context).textTheme.subtitle.copyWith(
                          //                 fontWeight: FontWeight.bold,
                          //                 color: Theme.of(context).textTheme.title.color,
                          //               ),
                          //         ),
                          //       ],
                          //     ),
                          //   ),
                          // ),
                          SizedBox(
                            height: 32,
                          ),
                          InkWell(
                            highlightColor: Colors.transparent,
                            splashColor: Colors.transparent,
                            onTap: () {
                              Navigator.pop(context);
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => SettingScreen(),
                                ),
                              );
                            },
                            child: Padding(
                              padding: const EdgeInsets.only(left: 4),
                              child: Row(
                                children: <Widget>[
                                  widget.selectItemName == 'Setting' ? selectedData() : SizedBox(),
                                  Icon(
                                    FontAwesomeIcons.cog,
                                    size: 20,
                                    color:
                                        widget.selectItemName == 'Setting' ? Theme.of(context).primaryColor : Theme.of(context).disabledColor.withOpacity(0.2),
                                  ),
                                  SizedBox(
                                    width: 10,
                                  ),
                                  Text(
                                    AppLocalizations.of('Setting'),
                                    style: Theme.of(context).textTheme.subtitle.copyWith(
                                          fontWeight: FontWeight.bold,
                                          color: Theme.of(context).textTheme.title.color,
                                        ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          SizedBox(
                            height: 32,
                          ),
                          InkWell(
                            highlightColor: Colors.transparent,
                            splashColor: Colors.transparent,
                            onTap: () {
                              // Navigator.pushNamedAndRemoveUntil(context, Routes.INTRODUCTION, (Route<dynamic> route) => false);
                              auth.signOut().then((value) => changeScreenReplacement(context, LoginScreen()));
                            },
                            child: Padding(
                              padding: const EdgeInsets.only(left: 4),
                              child: Row(
                                children: <Widget>[
                                  Icon(
                                    FontAwesomeIcons.signOutAlt,
                                    size: 20,
                                    color: Theme.of(context).disabledColor.withOpacity(0.2),
                                  ),
                                  SizedBox(
                                    width: 10,
                                  ),
                                  Text(
                                    AppLocalizations.of('Logout'),
                                    style: Theme.of(context).textTheme.subtitle.copyWith(
                                          fontWeight: FontWeight.bold,
                                          color: Theme.of(context).textTheme.title.color,
                                        ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                )
              ],
            ),
          ),
          Expanded(
              child: GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Container(
                    color: Colors.transparent,
                    height: MediaQuery.of(context).size.height,
                  )))
        ],
      ),
    );
  }

  Widget selectedData() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Container(
          height: 28,
          width: 4,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            color: Theme.of(context).primaryColor,
          ),
        ),
        SizedBox(
          width: 10,
        ),
      ],
    );
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
}
