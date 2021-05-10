import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:geocoding/geocoding.dart';
import 'package:my_cab/helpers&widgets/helpers/Language/appLocalizations.dart';
import 'package:my_cab/helpers&widgets/helpers/changeScreen.dart';
import 'package:my_cab/helpers&widgets/widgets/customButton.dart';
import 'package:my_cab/helpers&widgets/widgets/customText.dart';
import 'package:my_cab/helpers&widgets/widgets/loading.dart';
import 'package:my_cab/helpers&widgets/widgets/textField.dart';
import 'package:my_cab/models/userModel.dart';
import 'package:my_cab/services/placeServices.dart';
import 'package:my_cab/services/userServices.dart';
import 'package:my_cab/views/servicesAvailable/courierScreens/orderPlacement/addressSearch.dart';
import 'package:uuid/uuid.dart';

class AddressManagement extends StatefulWidget {
  const AddressManagement({Key key}) : super(key: key);
  @override
  _AddressManagementState createState() => _AddressManagementState();
}

class _AddressManagementState extends State<AddressManagement> {
  final nameController = new TextEditingController();
  final emailController = new TextEditingController();
  final addressController = new TextEditingController();
  final landMarkController = new TextEditingController();
  final phoneController = new TextEditingController();
  GeocodingPlatform geocodingPlatform = GeocodingPlatform.instance;
  Location senderLocation;

  final key = new GlobalKey<FormState>();
  final scaffoldKey = new GlobalKey<ScaffoldState>();
  bool readOnly = true;
  bool loading = false;
  UserServices _userServices = new UserServices();
  FirebaseAuth auth = FirebaseAuth.instance;
  @override
  void initState() {
    getCurrentUserAddress();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: Stack(
        children: [
          Column(
            children: [
              Container(
                color: Theme.of(context).primaryColor,
                height: 160,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    SizedBox(
                      height: MediaQuery.of(context).padding.top + 16,
                    ),
                    Padding(
                      padding: EdgeInsets.only(right: 14, left: 14),
                      child: GestureDetector(
                        onTap: () {
                          // Navigator.pop(context);
                          Navigator.of(context).pop(landMarkController.text);
                        },
                        child: Icon(
                          Icons.arrow_back_ios,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 32,
                    ),
                    Padding(
                      padding: EdgeInsets.only(right: 14, left: 14, bottom: 16),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          Text(
                            AppLocalizations.of('My Address'),
                            style: Theme.of(context).textTheme.headline.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Form(
                  key: key,
                  child: ListView(
                    shrinkWrap: true,
                    primary: false,
                    children: [
                      LoginTextField(
                        controller: addressController,
                        hint: 'Address',
                        callback: () => getAddress(),
                      ),
                      LoginTextField(
                        controller: nameController,
                        hint: 'Names',
                        validator: (v) {
                          if (v.isEmpty) return 'House Number cannot be empty';
                        },
                      ),
                      LoginTextField(
                        controller: phoneController,
                        hint: 'Phone Number',
                        validator: (v) {
                          if (v.isEmpty) return 'Street Address cannot be empty';
                        },
                      ),
                      LoginTextField(
                        controller: landMarkController,
                        hint: 'Land Mark',
                        validator: (v) {
                          if (v.isEmpty) return 'You need to specify a landmark';
                        },
                      ),
                      LoginTextField(
                          controller: emailController,
                          hint: 'Email Address',
                          validator: (v) {
                            if (v.isEmpty) return 'Zip code cannot be empty';
                          },
                          textInputType: TextInputType.emailAddress),
                      SizedBox(height: 20),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 48.0),
                        child: CustomFlatButton(
                          radius: 27,
                          text: 'Update Address',
                          icon: Icons.mail,
                          fontSize: 17,
                          callback: () => updateAddresses(),
                        ),
                      )
                    ],
                  ),
                ),
              )
            ],
          ),
          Visibility(visible: loading == true, child: Loading(text: 'Please wait...'))
        ],
      ),
    );
  }

  updateAddresses() async {
    if (key.currentState.validate()) {
      setState(() {
        loading = true;
      });
      await _userServices.updateUserAddress(
        {
          UserModel.SENDERNAME: nameController.text,
          UserModel.SENDEREMAIL: emailController.text,
          UserModel.SENDERADDRESS: addressController.text,
          UserModel.SENDERLANDMARK: landMarkController.text,
          UserModel.SENDERPHONE: phoneController.text,
          'updatedOn': DateTime.now()
        },
      ).then((value) => value == false
          ? Fluttertoast.showToast(msg: 'Address update failed')
          : ScaffoldMessenger.of(context).showSnackBar(SnackBar(
              content: CustomText(
              text: 'Address has been updated successfuly',
              textAlign: TextAlign.center,
              color: Colors.lightGreen,
            ))));
      setState(() {
        loading = false;
      });
    }
  }

  getCurrentUserAddress() async {
    await _userServices.getUserById(auth.currentUser.uid).then((value) {setState(() {
          nameController.text = value.names;
          emailController.text = value.email;
          landMarkController.text = value.landMark;
          addressController.text = value.senderAddress;
          phoneController.text = value.phoneNumber;
          // addressTrailingText = editAddress;
          // readOnlyAddreses = true;
        });
      if (value.userAddresses != null) {
        
      } else {
        Fluttertoast.showToast(msg: 'YOU HAVEN\'T UPDATED YOUR ADDRESS YET');
        setState(() {
          // addressTrailingText = updateAddress;
        });
      }
    });
  }

  getAddress() async {
    if (senderLocation == null) {
      final sessionToken = Uuid().v4();
      var test = await showSearch<Suggestion>(context: context, delegate: AddressSearch(sessionToken));
      if (test != null) {
        final location = await geocodingPlatform.locationFromAddress(test.description);
        setState(() {
          addressController.text = test.description;
          senderLocation = location[0];
          // recipientGeoPoint = GeoPoint(recipientLocation.latitude, recipientLocation.longitude);
        });
      }
    } else {
      Fluttertoast.showToast(msg: 'You need to fill in your address first');
    }
  }
}
