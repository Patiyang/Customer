import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:my_cab/helpers&widgets/helpers/Language/appLocalizations.dart';
import 'package:my_cab/constance/constance.dart';
import 'package:my_cab/helpers&widgets/helpers/routing.dart';
import 'package:my_cab/helpers&widgets/widgets/customButton.dart';
import 'package:my_cab/helpers&widgets/widgets/customText.dart';
import 'package:my_cab/services/userServices.dart';
import 'package:my_cab/views/setting/editAccountInfo.dart';
import 'package:my_cab/views/setting/manageAddresses.dart';

class MyProfile extends StatefulWidget {
  @override
  _MyProfileState createState() => _MyProfileState();
}

class _MyProfileState extends State<MyProfile> {
  FirebaseAuth _auth = FirebaseAuth.instance;
  UserServices _userServices = new UserServices();

  String names = '';
  String emailAddress = '';
  String profilePicture = '';
  String gender = '';
  String birthDay = '';
  String phoneNumber = '';
  File imageToUpload;

  @override
  void initState() {
    super.initState();
    getCurrentUserInfo();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: Column(
        children: <Widget>[
          Stack(
            children: <Widget>[
              Container(
                height: 160,
                color: Theme.of(context).primaryColor,
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  SizedBox(
                    height: MediaQuery.of(context).padding.top + 16,
                  ),
                  Padding(
                    padding: EdgeInsets.only(right: 14, left: 14),
                    child: GestureDetector(
                      onTap: () {
                        Navigator.pop(context);
                      },
                      child: Icon(
                        Icons.arrow_back_ios,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  SizedBox(
                    height: 16,
                  ),
                  Padding(
                    padding: EdgeInsets.only(right: 14, left: 14, bottom: 16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        Text(
                          AppLocalizations.of('My Account'),
                          style: Theme.of(context).textTheme.headline.copyWith(
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                        ),
                        CircleAvatar(
                          radius: 30,
                          backgroundImage: profilePicture != '' ? NetworkImage(profilePicture) : AssetImage(ConstanceData.noImage),
                        ),
                      ],
                    ),
                  ),
                ],
              )
            ],
          ),
          Expanded(
            child: ListView(
              padding: EdgeInsets.all(0),
              children: <Widget>[
                SizedBox(
                  height: 16,
                ),
                Container(
                  height: 1,
                  color: Theme.of(context).dividerColor,
                ),
                MyAccountInfo(
                  headText: AppLocalizations.of('Level'),
                  subtext: AppLocalizations.of('Gold member'),
                ),
                Container(
                  height: 1,
                  color: Theme.of(context).dividerColor,
                ),
                SizedBox(
                  height: 16,
                ),
                Container(
                  height: 1,
                  color: Theme.of(context).dividerColor,
                ),
                MyAccountInfo(
                  headText: AppLocalizations.of('Name'),
                  subtext: AppLocalizations.of(names),
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 16),
                  child: Container(
                    height: 1,
                    color: Theme.of(context).dividerColor,
                  ),
                ),
                MyAccountInfo(
                  headText: AppLocalizations.of('Email'),
                  subtext: AppLocalizations.of(emailAddress),
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 16),
                  child: Container(
                    height: 1,
                    color: Theme.of(context).dividerColor,
                  ),
                ),
                // MyAccountInfo(
                //   headText: AppLocalizations.of('Gender'),
                //   subtext: AppLocalizations.of(gender),
                // ),
                // Padding(
                //   padding: const EdgeInsets.only(left: 16),
                //   child: Container(
                //     height: 1,
                //     color: Theme.of(context).dividerColor,
                //   ),
                // ),
                // InkWell(
                //   onTap: () {
                //     showCupertinoModalPopup<void>(
                //       context: context,
                //       builder: (BuildContext context) {
                //         return _buildBottomPicker(
                //           CupertinoDatePicker(
                //             use24hFormat: true,
                //             mode: CupertinoDatePickerMode.date,
                //             initialDateTime: DateTime.now(),
                //             onDateTimeChanged: (DateTime newDateTime) {},
                //             maximumYear: 2021,
                //             minimumYear: 1995,
                //           ),
                //         );
                //       },
                //     );
                //   },
                //   child: MyAccountInfo(
                //     headText: AppLocalizations.of('Birthday'),
                //     subtext: AppLocalizations.of('April 16, 1988'),
                //   ),
                // ),
                // Padding(
                //   padding: const EdgeInsets.only(left: 16),
                //   child: Container(
                //     height: 1,
                //     color: Theme.of(context).dividerColor,
                //   ),
                // ),
                MyAccountInfo(
                  headText: AppLocalizations.of('Phone Number'),
                  subtext: AppLocalizations.of('+234$phoneNumber'),
                ),
                Container(
                  height: 1,
                  color: Theme.of(context).dividerColor,
                ),
                SizedBox(
                  height: 15,
                ),
                GestureDetector(
                  onTap: () async {
                    var update = await Navigator.push<String>(context, MaterialPageRoute(builder: (_) => ProfileEdit()));
                    if (update != null) {
                      getCurrentUserInfo();
                    } else {
                      // Fluttertoast.showToast(msg: 'kjkmd');
                    }
                  },
                  child: CustomText(
                    text: 'Edit',
                    textAlign: TextAlign.center,
                    size: 20,
                    letterSpacing: .2,
                    fontWeight: FontWeight.w600,
                  ),
                )
              ],
            ),
          ),
          CustomFlatButton(
            radius: 30,
            text: 'Manage Addresses',
            icon: Icons.mail,
            fontSize: 17,
            callback: () => changeScreen(context, AddressManagement()),
          ),
          SizedBox(height: 10)
        ],
      ),
    );
  }

  Widget _buildBottomPicker(Widget picker) {
    return Container(
      height: 240,
      padding: const EdgeInsets.only(top: 6.0),
      color: CupertinoColors.white,
      child: DefaultTextStyle(
        style: const TextStyle(
          color: CupertinoColors.black,
          fontSize: 22.0,
        ),
        child: GestureDetector(
          onTap: () {},
          child: SafeArea(
            top: false,
            child: picker,
          ),
        ),
      ),
    );
  }

  void getCurrentUserInfo() async {
    print(_auth.currentUser.uid);
    await _userServices.getUserById(_auth.currentUser.uid).then((value) {
      setState(() {
        names = value.names;
        phoneNumber = value.phoneNumber;
        emailAddress = value.email ?? 'Update your email in settings';
        profilePicture = value.profilePicture ?? '';
        gender = value.gender ?? 'Not Selected';
      });
      print(profilePicture);
    });
  }
}

class MyAccountInfo extends StatelessWidget {
  final String headText;
  final String subtext;

  const MyAccountInfo({Key key, this.headText, this.subtext}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Theme.of(context).backgroundColor,
      child: Padding(
        padding: const EdgeInsets.only(right: 10, left: 14, top: 8, bottom: 8),
        child: Row(
          children: <Widget>[
            Text(
              headText,
              style: Theme.of(context).textTheme.subhead.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).textTheme.title.color,
                  ),
            ),
            Expanded(child: SizedBox()),
            Text(
              subtext,
              style: Theme.of(context).textTheme.subtitle.copyWith(
                    color: Theme.of(context).disabledColor,
                  ),
            ),
            SizedBox(
              width: 2,
            ),
            Icon(
              Icons.arrow_forward_ios,
              size: 18,
              color: Theme.of(context).disabledColor,
            ),
          ],
        ),
      ),
    );
  }
}
