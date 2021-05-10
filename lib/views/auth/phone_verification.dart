import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:my_cab/constance/constance.dart';
import 'package:my_cab/constance/global.dart' as globals;
import 'package:my_cab/constance/routes.dart';
import 'package:my_cab/constance/themes.dart';
import 'package:my_cab/helpers&widgets/helpers/Language/appLocalizations.dart';
import 'package:my_cab/services/userServices.dart';

class PhoneVerification extends StatefulWidget {
  final String names;
  final String phoneNumber;
  final String emailAddress;
  final String verificationId;

  const PhoneVerification({Key key, this.names, this.phoneNumber, this.emailAddress, this.verificationId}) : super(key: key);

  @override
  _PhoneVerificationState createState() => _PhoneVerificationState();
}

class _PhoneVerificationState extends State<PhoneVerification> with SingleTickerProviderStateMixin {
  AnimationController animationController;
  var otpController = new TextEditingController();
  UserServices _userServices = new UserServices();
  bool errorEncountered = false;
  bool loading = false;
  final key = GlobalKey<FormState>();
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
        child: Stack(
          children: <Widget>[
            SingleChildScrollView(
              child: SizedBox(
                height: MediaQuery.of(context).size.height,
                child: Column(
                  mainAxisSize: MainAxisSize.max,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Expanded(
                      child: ClipRect(
                        child: Container(
                          color: Colors.blue,
                          child: AnimatedBuilder(
                            animation: animationController,
                            builder: (BuildContext context, Widget child) {
                              return Stack(
                                alignment: Alignment.bottomCenter,
                                children: <Widget>[
                                  Transform(
                                    transform: new Matrix4.translationValues(
                                        0.0,
                                        160 *
                                                (1.0 -
                                                    (AlwaysStoppedAnimation(Tween(begin: 0.4, end: 1.0)
                                                                .animate(CurvedAnimation(parent: animationController, curve: Curves.fastOutSlowIn)))
                                                            .value)
                                                        .value) -
                                            16,
                                        0.0),
                                    child: Image.asset(
                                      ConstanceData.buildingImageBack,
                                      color: Colors.black,
                                    ),
                                  ),
                                  Transform(
                                    transform: new Matrix4.translationValues(
                                        0.0,
                                        160 *
                                            (1.0 -
                                                (AlwaysStoppedAnimation(Tween(begin: 0.8, end: 1.0)
                                                            .animate(CurvedAnimation(parent: animationController, curve: Curves.fastOutSlowIn)))
                                                        .value)
                                                    .value),
                                        0.0),
                                    child: Image.asset(
                                      ConstanceData.buildingImage,
                                      color: Colors.black,
                                    ),
                                  ),
                                ],
                              );
                            },
                          ),
                        ),
                      ),
                    ),
                    Expanded(child: SizedBox()),
                  ],
                ),
              ),
            ),
            SingleChildScrollView(
              padding: EdgeInsets.all(0.0),
              child: SizedBox(
                height: MediaQuery.of(context).size.height,
                child: Column(
                  children: <Widget>[
                    SizedBox(
                      height: (MediaQuery.of(context).size.height / 2) - (MediaQuery.of(context).size.width < 360 ? 124 : 86),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Card(
                        margin: EdgeInsets.all(0),
                        elevation: 8,
                        child: Column(
                          children: <Widget>[
                            _loginTextUI(),
                            _emailUI(),
                            _getVerifyUI(),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: Column(
                children: <Widget>[
                  SizedBox(
                    height: MediaQuery.of(context).padding.top,
                  ),
                  SizedBox(
                    height: AppBar().preferredSize.height,
                    child: Container(
                      padding: EdgeInsets.only(top: 0, left: 8),
                      alignment: Alignment.centerLeft,
                      child: SizedBox(
                        width: AppBar().preferredSize.height - 8,
                        height: AppBar().preferredSize.height - 8,
                        child: Material(
                          color: Colors.transparent,
                          child: InkWell(
                            borderRadius: new BorderRadius.circular(AppBar().preferredSize.height),
                            child: Icon(
                              Icons.arrow_back_ios,
                              color: Colors.white,
                              size: 26,
                            ),
                            onTap: () {
                              Navigator.of(context).pop();
                            },
                          ),
                        ),
                      ),
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.only(top: 0, left: 8),
                    alignment: Alignment.centerLeft,
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Padding(
                            padding: const EdgeInsets.all(4.0),
                            child: Text(
                              AppLocalizations.of('Phone Verification'),
                              style: Theme.of(context).textTheme.headline.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _emailUI() {
    return Stack(
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.only(top: 0, left: 16, right: 16),
          child: getOtpTextUI(otptxt: otpController.text),
        ),
        Opacity(
          opacity: 0.0,
          child: Row(
            children: <Widget>[
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.green,
                    borderRadius: BorderRadius.all(Radius.circular(10)),
                    border: Border.all(color: Theme.of(context).dividerColor),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.only(left: 16),
                    child: Row(
                      children: <Widget>[
                        Expanded(
                          child: Form(
                            key: key,
                            child: TextFormField(
                              controller: otpController,
                              maxLength: 6,
                              onChanged: (String txt) {
                                // setState(() {
                                //   print(otpController.text);
                                // });
                                setState(() {});
                              },
                              onTap: () {},
                              cursorColor: Theme.of(context).primaryColor,
                              decoration: new InputDecoration(
                                errorText: null,
                                border: InputBorder.none,
                                labelStyle: TextStyle(
                                  color: Theme.of(context).disabledColor,
                                ),
                              ),
                              keyboardType: TextInputType.number,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _loginTextUI() {
    return Padding(
      padding: const EdgeInsets.only(left: 24, right: 16, top: 30, bottom: 30),
      child: Container(
        alignment: Alignment.centerLeft,
        child: Text(
          AppLocalizations.of('Enter your OTP code here'),
          style: Theme.of(context).textTheme.body1.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
      ),
    );
  }

  Widget _getVerifyUI() {
    return Padding(
      padding: const EdgeInsets.only(left: 16, right: 16, bottom: 16),
      child: Container(
        height: 48,
        decoration: BoxDecoration(
          color: Colors.black,
          borderRadius: BorderRadius.all(Radius.circular(24.0)),
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.all(Radius.circular(24.0)),
            highlightColor: Colors.transparent,
            onTap: () {
              if (key.currentState.validate()) {
                signIn(otpController.text);
              }
            },
            child: Center(
              child: Text(
                AppLocalizations.of("Verify now"),
                style: Theme.of(context).textTheme.subhead.copyWith(color: Colors.white, fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ),
      ),
    );
  }

//
//
//
  String smssent;
  FirebaseAuth auth = FirebaseAuth.instance;
  Future<void> signIn(String smsCode) async {
    print(widget.verificationId);
    final AuthCredential credential = PhoneAuthProvider.credential(
      verificationId: widget.verificationId,
      smsCode: smsCode,
    );
    FirebaseAuth.instance.signInWithCredential(credential).then((value) async {
      widget.names != null
          ? await _userServices.createUser(value.user.uid, widget.names, widget.phoneNumber.substring(4, widget.phoneNumber.length), widget.emailAddress, context)
          : print('Logging in..');
    }).catchError((onError) {
      Fluttertoast.showToast(msg: 'WRONG OTP PLEASE RETRY AGAIN!!');
      setState(() {
        errorEncountered = true;
      });
      print('the error is' + onError.toString());
    }).then((user) async {
      if (errorEncountered == false) {
        Navigator.pushNamedAndRemoveUntil(context, Routes.HOME, (Route<dynamic> route) => false);
        Fluttertoast.showToast(msg: 'OTP CODE VERIFIED');
      }
    });
  }

//
//
//
  Widget getOtpTextUI({String otptxt = ""}) {
    List<Widget> otplist = List<Widget>();
    Widget getUI({String otxt = ""}) {
      return Expanded(
        child: Padding(
          padding: const EdgeInsets.only(left: 4, right: 4),
          child: AspectRatio(
            aspectRatio: 1,
            child: Container(
              decoration: BoxDecoration(
                color: Theme.of(context).backgroundColor,
                borderRadius: BorderRadius.all(Radius.circular(8)),
                border: Border.all(color: Theme.of(context).dividerColor, width: 1.0),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Text(otxt, style: Theme.of(context).textTheme.headline.copyWith(fontWeight: FontWeight.bold)),
                ],
              ),
            ),
          ),
        ),
      );
    }

    for (var i = 0; i < 6; i++) {
      otplist.add(getUI(otxt: otptxt.length > i ? otptxt[i] : "-"));
    }
    return Row(
      children: otplist,
    );
  }
}
