// import 'package:my_cab/helpers&widgets/helpers/sharedPrefs.dart';
import 'package:animator/animator.dart';
import 'package:country_pickers/country.dart';
import 'package:country_pickers/country_picker_dialog.dart';
import 'package:country_pickers/utils/utils.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:my_cab/constance/constance.dart';
import 'package:my_cab/constance/global.dart';
import 'package:my_cab/helpers&widgets/helpers/Language/appLocalizations.dart';
import 'package:my_cab/helpers&widgets/helpers/routing.dart';
import 'package:my_cab/helpers&widgets/widgets/customText.dart';
import 'package:my_cab/helpers&widgets/widgets/textField.dart';
import 'package:my_cab/models/userModel.dart';
import 'package:my_cab/services/userServices.dart';
import 'package:my_cab/views/auth/SignUp.dart';
import 'package:flutter/material.dart';
import 'package:my_cab/views/auth/passwordReset.dart';
import 'package:my_cab/views/auth/phone_verification.dart';

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final phoneController = new TextEditingController();
  final emailController = new TextEditingController();
  final passwordController = new TextEditingController();
  final formKey = GlobalKey<FormState>();
  String phoneNumber = '';
  String smssent, verificationId;
  bool loading = false;
  bool obscure = true;

  Country _selectedDialogCountry = CountryPickerUtils.getCountryByIsoCode('NG');
  UserServices userServices = new UserServices();
  List<UserModel> users = [];
  List<String> phoneNumbers = [];
  List<String> emailAddresses = [];
  @override
  void initState() {
    getUserList();
    super.initState();
    // saveIntroBool(true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: lighterBLue,
      body: Padding(
        padding: const EdgeInsets.only(right: 14, left: 14),
        child: SizedBox(
          height: MediaQuery.of(context).size.height,
          child: Form(
            key: formKey,
            child: SingleChildScrollView(
              padding: EdgeInsets.symmetric(horizontal: 40),
              primary: false,
              scrollDirection: Axis.vertical,
              child: Container(
                height: MediaQuery.of(context).size.height,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Spacer(),
                    Image.asset(ConstanceData.loginPersonScreen, height: 170, width: 150, fit: BoxFit.contain),
                    CustomText(text: 'LOG IN', fontWeight: FontWeight.w700, color: white, size: 20),
                    SizedBox(height: 20),
                    Container(
                      child: Row(
                        children: <Widget>[
                          Expanded(
                            child: CustomTextField(
                              align: TextAlign.center,
                              radius: 10,
                              hint: 'Email Address',
                              controller: emailController,
                              validator: (v) {
                                if (v.isEmpty) {
                                  return 'Email Cannot be empty';
                                }
                                if (!emailAddresses.contains(emailController.text)) return 'This email is not yet registered';
                                Pattern pattern =
                                    r'^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$';
                                RegExp regex = new RegExp(pattern);
                                if (!regex.hasMatch(v))
                                  return 'Please make sure your email address format is valid';
                                else
                                  return null;
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    Row(
                      children: <Widget>[
                        Expanded(
                          child: CustomTextField(
                            align: TextAlign.center,
                            obscure: obscure,
                            // iconTwo: GestureDetector(
                            //     onTap: () {
                            //       setState(() {
                            //         obscure = !obscure;
                            //       });
                            //     },
                            //     child: Icon(obscure == true ? Icons.lock : Icons.lock_open)),
                            radius: 10,
                            hint: 'Password',
                            controller: passwordController,
                            validator: (v) {
                              if (v.isEmpty) {
                                return 'The password field cannot be empty';
                              } else
                                return null;
                            },
                          ),
                        ),
                      ],
                    ),
                    SizedBox(
                      height: 15,
                    ),
                    InkWell(
                      highlightColor: Colors.transparent,
                      splashColor: Colors.transparent,
                      onTap: () => loginUser(),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 0.0),
                        child: Container(
                          height: 40,
                          decoration: BoxDecoration(borderRadius: BorderRadius.circular(3), color: darkBLue),
                          child: Center(
                            child: loading == true
                                ? Container(width: 200, child: SpinKitCircle(color: white, size: 20))
                                : Text(
                                    AppLocalizations.of('NEXT'),
                                    style: Theme.of(context).textTheme.button.copyWith(
                                          fontWeight: FontWeight.bold,
                                          color: Theme.of(context).scaffoldBackgroundColor,
                                        ),
                                  ),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: 20),
                    CartItemRich(
                      lightFont: 'Don\'t have an account? ',
                      lightColor: Colors.white70,
                      boldColor: white,
                      boldFont: 'Sign Up',
                      callback: () => changeScreenReplacement(context, SignUp()),
                      lightFontSize: 15,
                      boldFontSize: 17,
                    ),
                    SizedBox(height: 20),
                    GestureDetector(
                      onTap: () async {},
                      child: CustomText(
                        text: 'FORGOT PASSWORD?',
                        fontWeight: FontWeight.w800,
                        letterSpacing: .3,
                        color: white,
                        textAlign: TextAlign.center,
                      ),
                    ),
                    Spacer(),
                    Image.asset(ConstanceData.logoWhite, width: 200, height: 100),
                    SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  loginUser() async {
    if (formKey.currentState.validate()) {
      setState(() {
        loading = true;
      });
      userServices.loginUser(emailController.text, passwordController.text, context).then((value) => setState(() {
            loading = false;
          }));
      // setState(() {
      //   phoneNumber = '+${_selectedDialogCountry.phoneCode}${phoneController.text}';
      // });
      // await verfiyPhone().onError((error, stackTrace) => () {
      //       print(error.toString());
      //     });

    }
  }

  Widget _selectedCountry(Country country) => Center(
        child: Padding(
          padding: const EdgeInsets.only(bottom: 2),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              SizedBox(
                child: CountryPickerUtils.getDefaultFlagImage(country),
                height: 20,
                width: 20,
              ),
              SizedBox(
                width: 6,
              ),
              Icon(
                Icons.keyboard_arrow_down,
                color: Colors.black,
              )
            ],
          ),
        ),
      );

  _openCountryPickerDialog() => showDialog(
        context: context,
        builder: (context) => CountryPickerDialog(
            searchCursorColor: Theme.of(context).primaryColor,
            searchInputDecoration: InputDecoration(hintText: 'Search...'),
            isSearchable: true,
            title: Text(
              'Select your phone code',
              style: Theme.of(context).textTheme.body1.copyWith(
                    color: Theme.of(context).textTheme.title.color,
                    fontWeight: FontWeight.bold,
                  ),
            ),
            onValuePicked: (Country country) => setState(
                  () => _selectedDialogCountry = country,
                ),
            itemBuilder: _buildDialogItem),
      );

  Widget _buildDialogItem(Country country) => Row(
        children: <Widget>[
          CountryPickerUtils.getDefaultFlagImage(country),
          SizedBox(width: 8.0),
          Expanded(
            child: Text(
              getCountryString(country.name),
            ),
          ),
          Container(
            child: Text(
              "+${country.phoneCode}",
              textAlign: TextAlign.end,
            ),
          ),
        ],
      );

  String getCountryString(String str) {
    var newString = '';
    var isFirstdot = false;
    for (var i = 0; i < str.length; i++) {
      if (isFirstdot == false) {
        if (str[i] != ',') {
          newString = newString + str[i];
        } else {
          isFirstdot = true;
        }
      }
    }
    return newString;
  }

  Future<void> verfiyPhone() async {
    final PhoneCodeAutoRetrievalTimeout autoRetrieve = (String verId) {
      this.verificationId = verId;
    };
    final PhoneCodeSent smsCodeSent = (String verId, [int forceCodeResent]) {
      setState(() {
        this.verificationId = verId;
      });
      print(verificationId);
      changeScreen(
          context,
          PhoneVerification(
            phoneNumber: phoneNumber,
            verificationId: verificationId,
          ));
    };
    final PhoneVerificationCompleted verifiedSuccess = (AuthCredential auth) {};
    final PhoneVerificationFailed verifyFailed = (FirebaseAuthException e) {
      Navigator.push(context, MaterialPageRoute(builder: (_) => LoginScreen()));
      Fluttertoast.showToast(msg: 'ERROR ENCOUTERED WHILE SENDING OTP'); //0700803354
      // print(widget.phoneNumber);
      print(e.toString());
    };
    await FirebaseAuth.instance.verifyPhoneNumber(
      phoneNumber: phoneNumber,
      timeout: const Duration(seconds: 45),
      verificationCompleted: verifiedSuccess,
      verificationFailed: verifyFailed,
      codeSent: smsCodeSent,
      codeAutoRetrievalTimeout: autoRetrieve,
    );
  }

  Future getUserList() async {
    users = await userServices.getAllCustomers();
    setState(() {});
    for (int i = 0; i < users.length; i++) {
      phoneNumbers.add(users[i].phoneNumber);
      emailAddresses.add(users[i].email);
      // print(users[i].phoneNumber);
      // print(users[i].email);
    }
    // print(users);
  }
}
