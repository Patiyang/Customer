import 'package:animator/animator.dart';
import 'package:country_pickers/country.dart';
import 'package:country_pickers/country_picker_dialog.dart';
import 'package:country_pickers/utils/utils.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:my_cab/constance/constance.dart';
import 'package:my_cab/constance/global.dart';
import 'package:my_cab/helpers&widgets/helpers/Language/appLocalizations.dart';
import 'package:my_cab/helpers&widgets/helpers/routing.dart';
import 'package:my_cab/helpers&widgets/widgets/customText.dart';
import 'package:my_cab/helpers&widgets/widgets/textField.dart';
import 'package:my_cab/models/userModel.dart';
import 'package:my_cab/services/emailService.dart';
import 'package:my_cab/services/userServices.dart';
import 'package:my_cab/views/auth/phone_verification.dart';
import 'package:wc_form_validators/wc_form_validators.dart';
import 'login_screen.dart';

class SignUp extends StatefulWidget {
  @override
  _SignUpState createState() => _SignUpState();
}

class _SignUpState extends State<SignUp> {
  final key = GlobalKey<FormState>();
  UserServices userServices = new UserServices();
  List<UserModel> users = [];
  List<String> phoneNumbers = [];
  List<String> emails = [];
  final namesController = new TextEditingController();
  final passwordController = new TextEditingController();
  final confirmPasswordController = new TextEditingController();
  final verifyPassController = new TextEditingController();
  final emailController = new TextEditingController();
  final phoneNumberController = new TextEditingController();
  EmailService _emailService = new EmailService();

  bool loading = false;
  bool obscurePass = true;
  bool obscureConfirmPass = true;
  bool textIputReadOnly = false;
  bool numberError = false;

  String phoneNumber = '';
  var appBarheight = 0.0;
  // UserServices userServices = new UserServices();

  String smssent, verificationId;

  Country _selectedDialogCountry = CountryPickerUtils.getCountryByIsoCode('NG');
  @override
  void initState() {
    super.initState();
    getUserList();
  }

  @override
  Widget build(BuildContext context) {
    appBarheight = AppBar().preferredSize.height + MediaQuery.of(context).padding.top;
    return Scaffold(
      backgroundColor: lighterBLue,
      body: Padding(
        padding: const EdgeInsets.only(right: 6, left: 6),
        child: Form(
          key: key,
          child: Container(
            alignment: Alignment.center,
            height: MediaQuery.of(context).size.height,
            child: SingleChildScrollView(
              padding: EdgeInsets.symmetric(horizontal: 45),
              primary: false,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  // SizedBox(height: 10),
                  Image.asset(
                    ConstanceData.register,
                    height: 120,
                    width: 130,
                    fit: BoxFit.contain,
                    color: white,
                  ),
                  CustomText(text: 'SIGN UP', fontWeight: FontWeight.w700, color: white, size: 20),
                  SizedBox(
                    height: 10,
                  ),
                  CustomTextField(iconOne: SizedBox(),
                    iconTwo: SizedBox(),
                    align: TextAlign.center,
                    readOnly: textIputReadOnly,
                    // obscure: obscure,
                    // iconOne: Icon(Icons.person),
                    radius: 10,
                    hint: 'Name',
                    controller: namesController,
                    validator: (v) {
                      if (v.isEmpty) {
                        return 'The password field cannot be empty';
                      } else
                        return null;
                    },
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  Container(
                    decoration: BoxDecoration(),
                    child: CustomTextField(iconOne: SizedBox(),
                    iconTwo: SizedBox(),
                      align: TextAlign.center,
                      textInputType: TextInputType.emailAddress,
                      // iconOne: Icon(Icons.email),
                      validator: (v) {
                        if (v.isEmpty) return 'email cannot be empty';
                        if (emails.contains(emailController.text)) return 'This email is already registered';

                        Pattern pattern =
                            r'^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$';
                        RegExp regex = new RegExp(pattern);
                        if (!regex.hasMatch(v))
                          return 'Please use a valid email format without spaces';
                        else
                          return null;
                      },
                      controller: emailController,
                      hint: 'Email',
                    ),
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  CustomTextField(
                    iconOne: Padding(
                      padding: const EdgeInsets.symmetric(horizontal:8.0),
                      child: Image.asset(ConstanceData.flag, height: 30,width: 5,),
                    ),
                    iconTwo: SizedBox(),
                    align: TextAlign.center,
                    textInputType: TextInputType.numberWithOptions(),
                    validator: (v) {
                      if (v.isEmpty) return 'Mobile number cannot be empty';
                      if (phoneNumbers.contains(phoneNumberController.text)) return 'Phone Number is already registered';
                      return null;
                    },
                    controller: phoneNumberController,
                    hint: 'Phone Number',
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  // Padding(
                  //   padding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 13),
                  //   child: Container(
                  //     decoration: BoxDecoration(
                  //       borderRadius: BorderRadius.all(Radius.circular(5)),
                  //       border: Border.all(color: grey),
                  //       color: Theme.of(context).backgroundColor,
                  //     ),
                  //     child: Row(
                  //       children: <Widget>[
                  //         Container(
                  //           width: 86,
                  //           child: ListTile(
                  //             onTap: _openCountryPickerDialog,
                  //             title: _selectedCountry(
                  //               CountryPickerUtils.getCountryByIsoCode(_selectedDialogCountry.isoCode),
                  //             ),
                  //           ),
                  //         ),
                  //         Expanded(
                  //           child: TextFormField(
                  //             style: Theme.of(context).textTheme.body1.copyWith(
                  //                   color: Theme.of(context).textTheme.title.color,
                  //                 ),
                  //             keyboardType: TextInputType.number,
                  //             validator: (v) {
                  //               if (v.isEmpty) return 'Mobile number cannot be empty';
                  //               if (phoneNumbers.contains(phoneNumberController.text)) return 'Phone Number is already registered';
                  //               return null;
                  //             },
                  //             controller: phoneNumberController,
                  //             // maxLength: 10,
                  //             decoration: InputDecoration(
                  //               hintText: AppLocalizations.of('7485738475'),
                  //               hintStyle: Theme.of(context).textTheme.body1.copyWith(
                  //                     color: Theme.of(context).dividerColor,
                  //                   ),
                  //               border: InputBorder.none,
                  //             ),
                  //           ),
                  //         ),
                  //       ],
                  //     ),
                  //   ),
                  // ),
                  CustomTextField(
                      align: TextAlign.center,
                      obscure: obscurePass,
                      iconOne: SizedBox(),
                      iconTwo: GestureDetector(
                        child: Icon(obscurePass == true ? Icons.visibility_off : Icons.visibility_off),
                        onTap: () {
                          setState(() {
                            obscurePass = !obscurePass;
                          });
                        },
                      ),
                      radius: 10,
                      hint: 'Password',
                      controller: passwordController,
                      validator: Validators.compose([
                        Validators.required('password field cannot be empty'),
                        Validators.minLength(6, 'The password must be greater than 6'),
                        Validators.patternRegExp(RegExp(r'[!@#$%^&*(),.?":{}|<>]'), 'Password must have one special character'),
                        Validators.patternRegExp(RegExp(r'[a-z]'), 'Password must have at least one lower case letter'),
                        Validators.patternRegExp(RegExp(r'[A-Z]'), 'Password must have at least one upper case letter'),
                        Validators.patternRegExp(RegExp(r'[0-9]'), 'Password must have at least one integer')
                      ])),
                  SizedBox(height: 10),
                  CustomTextField(
                    align: TextAlign.center,
                    obscure: obscureConfirmPass,
                    iconOne: SizedBox(),
                    iconTwo: GestureDetector(
                      child: Icon(obscureConfirmPass == true ? Icons.visibility_off : Icons.visibility_off),
                      onTap: () {
                        setState(() {
                          obscureConfirmPass = !obscureConfirmPass;
                        });
                      },
                    ),
                    radius: 10,
                    hint: 'Confirm Password',
                    controller: confirmPasswordController,
                    validator: (v) {
                      if (v.isEmpty) {
                        return 'This field cannot be empty';
                      }
                      if (passwordController.text != confirmPasswordController.text) {
                        return 'Your passwords do not match';
                      } else
                        return null;
                    },
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 0.0),
                    child: InkWell(
                      highlightColor: Colors.transparent,
                      splashColor: Colors.transparent,
                      onTap: () async {
                        // _emailService.sendWelcomeEmail(namesController.text, emailController.text);
                        await register();
                        // if (loading == true) {
                        //   Fluttertoast.showToast(msg: 'signing you up');
                        // } else {
                        //   await register();
                        // }

                        print(phoneNumber);
                      },
                      child: Container(
                        height: 40,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(5),
                          color: darkBLue,
                        ),
                        child: Center(
                          child: loading == true
                              ? Container(
                                  width: 200,
                                  child: SpinKitCircle(
                                    color: white,
                                    size: 20,
                                  ))
                              : Text(
                                  AppLocalizations.of('SIGN UP'),
                                  style: Theme.of(context).textTheme.button.copyWith(
                                        fontWeight: FontWeight.bold,
                                        color: Theme.of(context).scaffoldBackgroundColor,
                                      ),
                                ),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(
                    height: 15,
                  ),
                  CartItemRich(
                    lightFont: 'Already have an account? ',
                    lightColor: Colors.white70,
                    boldColor: white,
                    boldFont: 'Sign In',
                    callback: () => changeScreenReplacement(context, LoginScreen()),
                    lightFontSize: 17,
                    boldFontSize: 20,
                  ),
                  SizedBox(
                    height: 30,
                  ),
                  Image.asset(
                    ConstanceData.logoWhite,
                    width: 200,
                    height: 50,
                    fit: BoxFit.contain,
                  ),
                  // SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ),
      ),

      //                   SizedBox(
      //                     height: 30,
      //                   ),
      //                   CartItemRich(
      //                     lightFont: 'Already have an account? ',
      //                     boldFont: 'Sign In',
      //                     callback: () => changeScreenReplacement(context, LoginScreen()),
      //                     lightFontSize: 17,
      //                     boldFontSize: 20,
      //                   ),
      //                   SizedBox(
      //                     height: 30,
      //                   ),

      // Padding(
      //   padding: const EdgeInsets.only(right: 14, left: 14),
      //   child: Column(
      //     children: <Widget>[
      //       Expanded(
      //         child: ListView(
      //           children: <Widget>[
      //             SizedBox(
      //               height: appBarheight,
      //             ),
      //             Card(
      //               color: Theme.of(context).scaffoldBackgroundColor,
      //               shape: RoundedRectangleBorder(
      //                 borderRadius: BorderRadius.circular(15.0),
      //               ),
      //               child: Column(
      //                 children: <Widget>[
      //                   Container(
      //                     height: 200,
      //                     decoration: BoxDecoration(
      //                       color: Colors.blue,
      //                       borderRadius: BorderRadius.only(
      //                         topLeft: Radius.circular(15),
      //                         topRight: Radius.circular(15),
      //                       ),
      //                     ),
      //                     child: Stack(
      //                       alignment: AlignmentDirectional.bottomCenter,
      //                       children: <Widget>[
      //                         Animator(
      //                           tween: Tween<Offset>(
      //                             begin: Offset(0, 0.4),
      //                             end: Offset(0, 0),
      //                           ),
      //                           duration: Duration(seconds: 1),
      //                           cycles: 1,
      //                           builder: (anim) => SlideTransition(
      //                             position: anim,
      //                             child: Image.asset(
      //                               ConstanceData.buildingImage,
      //                               fit: BoxFit.cover,
      //                               color: Colors.white.withOpacity(0.2),
      //                             ),
      //                           ),
      //                         ),
      //                         Padding(
      //                           padding: const EdgeInsets.only(top: 20, left: 18, right: 18),
      //                           child: Column(
      //                             children: <Widget>[
      //                               Row(
      //                                 crossAxisAlignment: CrossAxisAlignment.start,
      //                                 children: <Widget>[
      //                                   Text(
      //                                     AppLocalizations.of('Sign Up'),
      //                                     style: Theme.of(context).textTheme.display1.copyWith(
      //                                           fontWeight: FontWeight.bold,
      //                                           color: ConstanceData.secoundryFontColor,
      //                                         ),
      //                                   ),
      //                                   Padding(
      //                                     padding: const EdgeInsets.only(top: 10),
      //                                     child: Text(
      //                                       AppLocalizations.of(' With'),
      //                                       style: Theme.of(context).textTheme.headline.copyWith(
      //                                             color: ConstanceData.secoundryFontColor,
      //                                           ),
      //                                     ),
      //                                   ),
      //                                 ],
      //                               ),
      //                               Row(
      //                                 crossAxisAlignment: CrossAxisAlignment.start,
      //                                 children: <Widget>[
      //                                   Text(
      //                                     AppLocalizations.of('email and phone'),
      //                                     style: Theme.of(context).textTheme.headline.copyWith(
      //                                           color: ConstanceData.secoundryFontColor,
      //                                         ),
      //                                   ),
      //                                 ],
      //                               ),
      //                               Row(
      //                                 crossAxisAlignment: CrossAxisAlignment.start,
      //                                 children: <Widget>[
      //                                   Text(
      //                                     AppLocalizations.of('number'),
      //                                     style: Theme.of(context).textTheme.headline.copyWith(
      //                                           color: ConstanceData.secoundryFontColor,
      //                                         ),
      //                                   ),
      //                                 ],
      //                               ),
      //                             ],
      //                           ),
      //                         ),
      //                       ],
      //                     ),
      //                   ),
      //                   SizedBox(
      //                     height: 14,
      //                   ),
      //                   Padding(
      //                     padding: const EdgeInsets.only(right: 6, left: 6),
      //                     child: Form(
      //                       key: key,
      //                       child: Column(
      //                         children: <Widget>[
      //                           CustomTextField(
      //                             readOnly: textIputReadOnly,
      //                             // obscure: obscure,
      //                             iconOne: Icon(Icons.person),
      //                             radius: 10,
      //                             hint: 'Full Names',
      //                             controller: namesController,
      //                             validator: (v) {
      //                               if (v.isEmpty) {
      //                                 return 'The password field cannot be empty';
      //                               } else
      //                                 return null;
      //                             },
      //                           ),
      //                           Container(
      //                             decoration: BoxDecoration(),
      //                             child: CustomTextField(
      //                               textInputType: TextInputType.emailAddress,
      //                               iconOne: Icon(Icons.email),
      //                               validator: (v) {
      //                                 if (v.isEmpty) return 'email cannot be empty';
      //                                 if (emails.contains(emailController.text)) return 'This email is already registered';

      //                                 Pattern pattern =
      //                                     r'^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$';
      //                                 RegExp regex = new RegExp(pattern);
      //                                 if (!regex.hasMatch(v))
      //                                   return 'Please use a valid email format without spaces';
      //                                 else
      //                                   return null;
      //                               },
      //                               controller: emailController,
      //                               hint: 'name@example.com',
      //                             ),
      //                           ),
      //                           Padding(
      //                             padding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 3),
      //                             child: Container(
      //                               decoration: BoxDecoration(
      //                                 borderRadius: BorderRadius.all(Radius.circular(15)),
      //                                 border: Border.all(color: grey),
      //                                 color: Theme.of(context).backgroundColor,
      //                               ),
      //                               child: Row(
      //                                 children: <Widget>[
      //                                   Container(
      //                                     width: 86,
      //                                     child: ListTile(
      //                                       onTap: _openCountryPickerDialog,
      //                                       title: _selectedCountry(
      //                                         CountryPickerUtils.getCountryByIsoCode(_selectedDialogCountry.isoCode),
      //                                       ),
      //                                     ),
      //                                   ),
      //                                   Expanded(
      //                                     child: TextFormField(
      //                                       style: Theme.of(context).textTheme.body1.copyWith(
      //                                             color: Theme.of(context).textTheme.title.color,
      //                                           ),
      //                                       keyboardType: TextInputType.number,
      //                                       validator: (v) {
      //                                         if (v.isEmpty) return 'Mobile number cannot be empty';
      //                                         if (phoneNumbers.contains(phoneNumberController.text)) return 'Phone Number is already registered';
      //                                         return null;
      //                                       },
      //                                       controller: phoneNumberController,
      //                                       // maxLength: 10,
      //                                       decoration: InputDecoration(
      //                                         hintText: AppLocalizations.of('7485738475'),
      //                                         hintStyle: Theme.of(context).textTheme.body1.copyWith(
      //                                               color: Theme.of(context).dividerColor,
      //                                             ),
      //                                         border: InputBorder.none,
      //                                       ),
      //                                     ),
      //                                   ),
      //                                 ],
      //                               ),
      //                             ),
      //                           ),
      //                           CustomTextField(
      //                               obscure: obscurePass,
      //                               iconTwo: IconButton(
      //                                   onPressed: () {
      //                                     setState(() {
      //                                       obscurePass = !obscurePass;
      //                                     });
      //                                   },
      //                                   icon: Icon(obscurePass == true ? Icons.lock : Icons.lock_open)),
      //                               radius: 10,
      //                               hint: 'Password',
      //                               controller: passwordController,
      //                               validator: Validators.compose([
      //                                 Validators.required('password field cannot be empty'),
      //                                 Validators.minLength(6, 'The password must be greater than 6'),
      //                                 Validators.patternRegExp(RegExp(r'[!@#$%^&*(),.?":{}|<>]'), 'Password must have one special character'),
      //                                 Validators.patternRegExp(RegExp(r'[a-z]'), 'Password must have at least one lower case letter'),
      //                                 Validators.patternRegExp(RegExp(r'[A-Z]'), 'Password must have at least one upper case letter'),
      //                                 Validators.patternRegExp(RegExp(r'[0-9]'), 'Password must have at least one integer')
      //                               ])),
      //                           CustomTextField(
      //                             obscure: obscureConfirmPass,
      //                             // obscure: obscure,
      //                             iconTwo: IconButton(
      //                                 onPressed: () {
      //                                   setState(() {
      //                                     obscureConfirmPass = !obscureConfirmPass;
      //                                   });
      //                                 },
      //                                 icon: Icon(obscureConfirmPass == true ? Icons.lock : Icons.lock_open)),
      //                             radius: 10,
      //                             hint: 'Confirm Password',
      //                             controller: confirmPasswordController,
      //                             validator: (v) {
      //                               if (v.isEmpty) {
      //                                 return 'This field cannot be empty';
      //                               }
      //                               if (passwordController.text != confirmPasswordController.text) {
      //                                 return 'Your passwords do not match';
      //                               } else
      //                                 return null;
      //                             },
      //                           ),
      //                           InkWell(
      //                             highlightColor: Colors.transparent,
      //                             splashColor: Colors.transparent,
      //                             onTap: () async {
      //                                         _emailService.sendWelcomeEmail(namesController.text, emailController.text);

      //                                 // await register();
      //                                 // if (loading == true) {
      //                                 //   Fluttertoast.showToast(msg: 'signing you up');
      //                                 // } else {
      //                                 //   await register();
      //                                 // }

      //                               print(phoneNumber);
      //                             },
      //                             child: Container(
      //                               height: 40,
      //                               decoration: BoxDecoration(
      //                                 borderRadius: BorderRadius.circular(30),
      //                                 color: Theme.of(context).textTheme.title.color,
      //                               ),
      //                               child: Center(
      //                                 child: loading == true
      //                                     ? Container(
      //                                         width: 200,
      //                                         child: SpinKitCircle(
      //                                           color: white,
      //                                           size: 20,
      //                                         ))
      //                                     : Text(
      //                                         AppLocalizations.of('SIGN UP'),
      //                                         style: Theme.of(context).textTheme.button.copyWith(
      //                                               fontWeight: FontWeight.bold,
      //                                               color: Theme.of(context).scaffoldBackgroundColor,
      //                                             ),
      //                                       ),
      //                               ),
      //                             ),
      //                           ),
      //                         ],
      //                       ),
      //                     ),
      //                   ),
      //                   SizedBox(
      //                     height: 30,
      //                   ),
      //                   CartItemRich(
      //                     lightFont: 'Already have an account? ',
      //                     boldFont: 'Sign In',
      //                     callback: () => changeScreenReplacement(context, LoginScreen()),
      //                     lightFontSize: 17,
      //                     boldFontSize: 20,
      //                   ),
      //                   SizedBox(
      //                     height: 30,
      //                   ),
      //                 ],
      //               ),
      //             ),
      //             SizedBox(
      //               height: 20,
      //             ),
      //           ],
      //         ),
      //       )
      //     ],
      //   ),
      // ),
    );
  }

  register() async {
    if (key.currentState.validate()) {
      setState(() {
        loading = true;
      });
      // setState(() {
      //   phoneNumber = '+${_selectedDialogCountry.phoneCode}${phoneNumberController.text}';
      // });
      // await verfiyPhone().onError((error, stackTrace) => () {
      //       print(error.toString());
      //     });
      await userServices
          .createUser(namesController.text, phoneNumberController.text, emailController.text, passwordController.text, context)
          .then((value) => setState(() {
                loading = false;
              }));
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
      print('Code sent');
      setState(() {
        this.verificationId = verId;
      });
      print(verificationId);
      changeScreen(
          context,
          PhoneVerification(
            names: namesController.text,
            emailAddress: emailController.text,
            phoneNumber: phoneNumber,
            verificationId: verificationId,
          ));
    };
    final PhoneVerificationCompleted verifiedSuccess = (AuthCredential auth) {};
    final PhoneVerificationFailed verifyFailed = (FirebaseAuthException e) {
      Navigator.push(context, MaterialPageRoute(builder: (_) => SignUp()));
      Fluttertoast.showToast(msg: 'ERROR ENCOUTERED WHILE SENDING OTP');
      print('the error' + e.toString());
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
      emails.add(users[i].email);
      // print(users[i].phoneNumber);
      // print(users[i].email);
    }
  }

  bool validateStructure(String value) {
    String pattern = r'^(?=.*?[A-Z])(?=.*?[a-z])(?=.*?[0-9])(?=.*?[!@#\$&*~]).{8,}$';
    RegExp regExp = new RegExp(pattern);
    return regExp.hasMatch(value);
  }
}
