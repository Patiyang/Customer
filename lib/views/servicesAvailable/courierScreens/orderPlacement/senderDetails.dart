import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dio/dio.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:my_cab/constance/global.dart';
import 'package:my_cab/helpers&widgets/helpers/changeScreen.dart';
import 'package:my_cab/helpers&widgets/widgets/customButton.dart';
import 'package:my_cab/helpers&widgets/widgets/customText.dart';
import 'package:my_cab/helpers&widgets/widgets/textField.dart';
import 'package:my_cab/models/deliveryModel.dart';
import 'package:my_cab/models/userModel.dart';
import 'package:my_cab/services/placeServices.dart';
import 'package:my_cab/services/userServices.dart';
import 'package:my_cab/views/setting/manageAddresses.dart';
import 'package:country_pickers/country.dart';
import 'package:country_pickers/country_picker_dialog.dart';
import 'package:country_pickers/utils/utils.dart';
import 'package:uuid/uuid.dart';

import 'addressSearch.dart';
import 'courierSelection.dart';

class SenderDetails extends StatefulWidget {
  @override
  _SenderDetailsState createState() => _SenderDetailsState();
}

class _SenderDetailsState extends State<SenderDetails> {
  GeocodingPlatform geocodingPlatform = GeocodingPlatform.instance;
  GeoPoint senderGeoPoint;
  GeoPoint recipientGeoPoint;
  Location senderLocation;
  Location recipientLocation;
  double distanceBetweenLocation;
  Country _selectedDialogCountry = CountryPickerUtils.getCountryByIsoCode('NG');
  Dio dio = new Dio();
  double timeCost = 0;
  @override
  void initState() {
    super.initState();
    getCurrentUserAddress();
  }

  final senderAddressController = new TextEditingController();
  final emailController = new TextEditingController();
  final landMarkController = new TextEditingController();
  final phoneController = new TextEditingController();
  final nameController = new TextEditingController();
  bool readOnlyAddreses = false;
// RECIPIET VARIABLES
  final recipientAddress = new TextEditingController();
  final recipientLandMark = new TextEditingController();
  final recipientNames = new TextEditingController();
  final recipientPhoneNumber = new TextEditingController();
  final recipientEmailAddress = new TextEditingController();

  UserServices userServices = new UserServices();
  FirebaseAuth auth = FirebaseAuth.instance;
  final formKey = new GlobalKey<FormState>();
  final scaffoldKey = new GlobalKey<ScaffoldState>();
  String addressTrailingText = '';
  String updateAddress = 'Update Addresses';
  String editAddress = 'Edit Addresses';

  @override
  Widget build(BuildContext context) {
    return Form(
      key: formKey,
      child: SingleChildScrollView(
        primary: false,
        child: Column(
          children: [
            Container(
              child: Column(
                children: [
                  ListTile(
                    tileColor: Colors.white,
                    leading: Icon(Icons.shopping_cart_sharp),
                    title: CustomText(text: 'Sender Details'),
                    trailing: GestureDetector(onTap: () => addressHandling(), child: CustomText(text: addressTrailingText, color: Colors.red)),
                    // contentPadding: EdgeInsets.all(2),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8.0),
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        boxShadow: [BoxShadow(color: Colors.grey[300], blurRadius: 2, spreadRadius: 3, offset: Offset(1, 2))],
                      ),
                      // color: Colors.white,
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Column(
                          children: [
                            CourierTextField(
                              onTap: () => getSenderAddresses(),
                              readOnly: true,
                              hint: 'Address',
                              controller: senderAddressController,
                              iconOne: Icon(Icons.map_outlined),
                              validator: (v) {
                                if (v.isEmpty) return 'Address field cannot be empty';
                              },
                            ),
                            CourierTextField(
                              readOnly: readOnlyAddreses,
                              hint: 'Full Names',
                              controller: nameController,
                              iconOne: Icon(Icons.person),
                              validator: (v) {
                                if (v.isEmpty) return 'You need to fill in your full names';
                              },
                            ),
                            CourierTextField(
                              readOnly: readOnlyAddreses,
                              hint: 'Land mark close by',
                              controller: landMarkController,
                              iconOne: Icon(Icons.circle),
                              validator: (v) {
                                if (v.isEmpty) return 'Please enter a land mark close to you';
                              },
                            ),
                            CourierTextField(
                              readOnly: readOnlyAddreses,
                              hint: 'Email Address',
                              controller: emailController,
                              iconOne: Icon(Icons.email),
                              validator: (v) {
                                if (v.isEmpty) return 'email cannot be empty';
                                Pattern pattern =
                                    r'^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$';
                                RegExp regex = new RegExp(pattern);
                                if (!regex.hasMatch(v))
                                  return 'Please use a valid email format without spaces';
                                else
                                  return null;
                              },
                            ),
                            CourierTextField(
                              textInputType: TextInputType.numberWithOptions(),
                              readOnly: readOnlyAddreses,
                              hint: 'Phone Number',
                              controller: phoneController,
                              iconOne: Container(
                                width: 60,
                                height: 50,
                                child: ListTile(
                                  contentPadding: EdgeInsets.only(left: 9),
                                  onTap: _openCountryPickerDialog,
                                  title: _selectedCountry(
                                    _selectedDialogCountry,
                                  ),
                                ),
                              ),
                              validator: (v) {
                                if (v.isEmpty) return 'Zip code cannot be empty cannot be empty';
                              },
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Container(
              child: Column(
                children: [
                  ListTile(
                    tileColor: Colors.white,
                    leading: Icon(Icons.shopping_cart_sharp),
                    title: CustomText(
                      text: 'Recipient Details',
                      fontWeight: FontWeight.bold,
                      color: blue,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8.0),
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        boxShadow: [BoxShadow(color: Colors.grey[300], blurRadius: 2, spreadRadius: 3, offset: Offset(1, 2))],
                      ),
                      // color: Colors.white,
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Column(
                          // shrinkWrap: true,
                          // primary: false,
                          children: [
                            CourierTextField(
                              readOnly: senderLocation == null ? true : true,
                              onTap: () => getRecipientAddress(),
                              hint: 'Address',
                              controller: recipientAddress,
                              iconOne: Icon(Icons.home),
                              validator: (v) {
                                if (v.isEmpty) return 'the address cannot be empty';
                              },
                            ),
                            CourierTextField(
                              iconOne: Icon(Icons.local_convenience_store_rounded),
                              hint: 'Landmark',
                              controller: recipientLandMark,
                              validator: (v) {
                                if (v.isEmpty) return 'you need to enter a landmark near you';
                              },
                            ),
                            CourierTextField(
                              iconOne: Icon(Icons.edit),
                              hint: 'Full name',
                              controller: recipientNames,
                              validator: (v) {
                                if (v.isEmpty) return 'the full names of recipient cannot be empty';
                              },
                            ),
                            CourierTextField(
                              textInputType: TextInputType.numberWithOptions(),
                              iconOne: Container(
                                width: 60,
                                height: 50,
                                child: ListTile(
                                  contentPadding: EdgeInsets.only(left: 9),
                                  onTap: _openCountryPickerDialog,
                                  title: _selectedCountry(
                                    _selectedDialogCountry,
                                  ),
                                ),
                              ),
                              // iconOne: Icons.house_siding_rounded,
                              hint: 'Phone Number',
                              controller: recipientPhoneNumber,
                              validator: (v) {
                                if (v.isEmpty) return 'the house number of the recipient cannot be empty';
                              },
                            ),
                            CourierTextField(
                              iconOne: Icon(Icons.location_city),
                              hint: 'Email Address',
                              controller: recipientEmailAddress,
                              validator: (v) {
                                if (v.isEmpty) return 'email cannot be empty';
                                Pattern pattern =
                                    r'^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$';
                                RegExp regex = new RegExp(pattern);
                                if (!regex.hasMatch(v))
                                  return 'Please use a valid email format without spaces';
                                else
                                  return null;
                              },
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal:38.0),
              child: CustomFlatButton(
                radius: 30,
                callback: () => placeOrder(),
                text: 'Proceed to shipment',
                textColor: white,
                icon: Icons.delivery_dining,
                iconSize: 25,
                fontSize: 15,
              ),
            ),
            SizedBox(
              height: 30,
            )
          ],
        ),
      ),
    );
  }

  placeOrder() async {
    if (formKey.currentState.validate()) {
      var position = GeolocatorPlatform.instance;

      distanceBetweenLocation =
          position.distanceBetween(senderLocation.latitude, senderLocation.longitude, recipientLocation.latitude, recipientLocation.longitude);
      Response response = await dio.get(
          "https://maps.googleapis.com/maps/api/distancematrix/json?units=imperial&origins=${senderLocation.latitude},${senderLocation.longitude}&destinations=${recipientLocation.latitude},${recipientLocation.longitude}&key=$googleKey");

      int duration = response.data['rows'][0]['elements'][0]['duration']['value'];
      String tripDuration = response.data['rows'][0]['elements'][0]['duration']['text'];
      Timestamp time = Timestamp.fromMillisecondsSinceEpoch(duration * 1000);
      print( time);
      changeScreen(
          context,
          CourierSelection(
            senderAddress: {
              DeliveryModel.SENDERADDRESS: senderAddressController.text,
              DeliveryModel.SENDERNAME: nameController.text,
              DeliveryModel.SENDERLANDMARK: landMarkController.text,
              DeliveryModel.SENDERPHONE: phoneController.text,
              DeliveryModel.SENDEREMAIL: emailController.text,
              UserModel.UID: auth.currentUser.uid,
            },
            recipientAddress: {
              DeliveryModel.RECEPIENTADDRESS: recipientAddress.text,
              DeliveryModel.RECEPIENTLANDMARK: recipientLandMark.text,
              DeliveryModel.RECEPIENTNAMES: recipientNames.text,
              DeliveryModel.RECEPIENTPHONENUMBER: recipientPhoneNumber.text,
              DeliveryModel.RECEPIENTEMAILADDRESS: recipientEmailAddress.text
            },
            senderGeoPoint: senderGeoPoint,
            recipientGeoPoint: recipientGeoPoint,
            distancebetween: distanceBetweenLocation / 1000,
            timestamp: time,
            tripDuration: tripDuration,
          ));

      // print(distanceBetweenLocation);
    }
  }

  getCurrentUserAddress() async {
    await userServices.getUserById(auth.currentUser.uid).then((value) {
      if (value.userAddresses != null) {
        if (mounted) {
          setState(() {
            // senderAddressController.text = value.senderAddress;
            emailController.text = value.senderEmail;
            landMarkController.text = value.landMark;
            nameController.text = value.senderName;
            phoneController.text = value.senderPhone;
            addressTrailingText = editAddress;
            readOnlyAddreses = true;
          });
        }
      } else {
        Fluttertoast.showToast(msg: 'YOU HAVEN\'T UPDATED YOUR ADDRESS YET');
        setState(() {
          addressTrailingText = updateAddress;
        });
      }
    });
  }

  addressHandling() async {
    if (addressTrailingText == updateAddress) {
      final test = await Navigator.push<String>(context, MaterialPageRoute(builder: (_) => AddressManagement()));
      if (test != null) {
        // print(test.);
        getCurrentUserAddress();
      }
    } else {
      setState(() {
        readOnlyAddreses = false;
      });
    }
  }

  getSenderAddresses() async {
    final sessionToken = Uuid().v4();
    // print(sessionToken);
    var test = await showSearch<Suggestion>(context: context, delegate: AddressSearch(sessionToken));
    if (test != null) {
      final location = await geocodingPlatform.locationFromAddress(test.description);
      setState(() {
        senderLocation = location[0];
        senderGeoPoint = GeoPoint(senderLocation.latitude, senderLocation.longitude);
        senderAddressController.text = test.description;
      });
    }
  }

  getRecipientAddress() async {
    if (senderLocation != null) {
      final sessionToken = Uuid().v4();
      var test = await showSearch<Suggestion>(context: context, delegate: AddressSearch(sessionToken));
      if (test != null) {
        final location = await geocodingPlatform.locationFromAddress(test.description);
        setState(() {
          recipientAddress.text = test.description;
          recipientLocation = location[0];
          recipientGeoPoint = GeoPoint(recipientLocation.latitude, recipientLocation.longitude);
        });
      }
    } else {
      Fluttertoast.showToast(msg: 'You need to fill in your address first');
    }
  }

  Widget _selectedCountry(Country country) => Center(
        child: Padding(
          padding: const EdgeInsets.only(bottom: 2),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
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
}
