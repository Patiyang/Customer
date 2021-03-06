import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:my_cab/constance/constance.dart';
import 'package:my_cab/constance/global.dart';
import 'package:my_cab/helpers&widgets/helpers/Language/appLocalizations.dart';
import 'package:my_cab/helpers&widgets/widgets/customListTIle.dart';
import 'package:my_cab/helpers&widgets/widgets/customText.dart';
import 'package:my_cab/helpers&widgets/widgets/textField.dart';
import 'package:my_cab/models/userModel.dart';
import 'package:my_cab/services/userServices.dart';

class PasswordReset extends StatefulWidget {
  @override
  _PasswordResetState createState() => _PasswordResetState();
}

class _PasswordResetState extends State<PasswordReset> {
  UserServices _userServices = new UserServices();
  final emailController = new TextEditingController();
  List<UserModel> users = [];
  List<String> phoneNumbers = [];
  List<String> emailAddresses = [];
  bool loading = false;
  final formKey = new GlobalKey<FormState>();
  @override
  void initState() {
    super.initState();
    getUserList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: lighterBLue,
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(horizontal: 8),
        child: Container(
          height: MediaQuery.of(context).size.height,
          child: Form(
            key: formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                SizedBox(height: 30),
                CustomListTile(
                  color: lighterBLue,
                  title: Row(
                    children: [
                      GestureDetector(onTap: () => Navigator.pop(context), child: Icon(Icons.arrow_back_ios, color: white)),
                      SizedBox(width: 50),
                      CustomText(
                        text: 'Password Reset',
                        color: white,
                        size: 20,
                      )
                    ],
                  ),
                ),
                SizedBox(
                  height: 40,
                ),
                Image.asset(
                  ConstanceData.resetPassword,
                  height: 90,
                  width: MediaQuery.of(context).size.width,
                  fit: BoxFit.contain,
                  color: white,
                ),
                SizedBox(height: 20),
                CustomText(
                  text: 'Forgot your password?',
                  size: 25,
                  fontWeight: FontWeight.w700,
                  letterSpacing: .2,
                  textAlign: TextAlign.center,
                  color: white,
                ),
                SizedBox(height: 10),
                CustomText(
                  text:
                      'That is okay, we\'ve got you covered. To reset your password, enter your registered email address below and we\'ll send a password reset link to you',
                  size: 19,
                  fontWeight: FontWeight.w700,
                  letterSpacing: .2,
                  maxLines: 5,
                  textAlign: TextAlign.center,
                  color: white,
                ),
                SizedBox(height: 30),
                CustomTextField(
                  iconOne: Icon(Icons.alternate_email_outlined),
                  radius: 8,
                  hint: 'Email Address',
                  controller: emailController,
                  textInputType: TextInputType.emailAddress,
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
                SizedBox(height: 15),
                InkWell(
                  highlightColor: Colors.transparent,
                  splashColor: Colors.transparent,
                  onTap: () => resetPassword(),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 40.0),
                    child: Container(
                      height: 40,
                      decoration: BoxDecoration(borderRadius: BorderRadius.circular(3), color: darkBLue),
                      child: Center(
                        child: loading == true
                            ? Container(width: 200, child: SpinKitCircle(color: white, size: 20))
                            : Text(
                                AppLocalizations.of('PROCEED'),
                                style: Theme.of(context).textTheme.button.copyWith(
                                      fontWeight: FontWeight.bold,
                                      color: Theme.of(context).scaffoldBackgroundColor,
                                    ),
                              ),
                      ),
                    ),
                  ),
                ),
                Spacer(),
                Image.asset(ConstanceData.logoWhite, width: 200, height: 100),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future getUserList() async {
    users = await _userServices.getAllCustomers();
    setState(() {});
    for (int i = 0; i < users.length; i++) {
      phoneNumbers.add(users[i].phoneNumber);
      emailAddresses.add(users[i].email);
      // print(users[i].phoneNumber);
      // print(users[i].email);
    }
    // print(users);
  }

  resetPassword() async {
    if (formKey.currentState.validate()) {
      await _userServices.resetPassword(emailController.text, context);
    }
  }
}
