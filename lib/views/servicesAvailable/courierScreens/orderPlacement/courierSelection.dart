import 'dart:io';
import 'package:country_pickers/country.dart';
import 'package:currency_pickers/utils/utils.dart';
import 'package:intl/intl.dart';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:my_cab/constance/constance.dart';
import 'package:my_cab/helpers&widgets/helpers/routing.dart';
import 'package:my_cab/helpers&widgets/widgets/customText.dart';
import 'package:my_cab/helpers&widgets/widgets/textField.dart';
import 'package:my_cab/models/userModel.dart';

import 'paymentDetails.dart';

class CourierSelection extends StatefulWidget {
  final Map<String, dynamic> senderAddress;
  final Map<String, dynamic> recipientAddress;
  final GeoPoint senderGeoPoint;
  final GeoPoint recipientGeoPoint;
  final double distancebetween;
  final Timestamp timestamp;
  final String tripDuration;

  const CourierSelection(
      {Key key,
      this.senderAddress,
      this.recipientAddress,
      this.senderGeoPoint,
      this.recipientGeoPoint,
      this.distancebetween,
      this.timestamp,
      this.tripDuration})
      : super(key: key);
  @override
  _CourierSelectionState createState() => _CourierSelectionState();
}

class _CourierSelectionState extends State<CourierSelection> {
  var format = NumberFormat.simpleCurrency(locale: 'en_NG').currencySymbol;
  String country = CurrencyPickerUtils.getCountryByIsoCode('NG').isoCode;

  int selectedIndex = 0;
  String packageType = '';
  String vehicleType = '';
  List<String> packages = ['Food and Beverage', 'Clothing', 'Groceries', 'Health Products', 'Documents', 'Electronics', 'Jewels and Accessories'];
  List<bool> dropDownListTile = [];
  List<VehicleTypes> vehicles = [
    VehicleTypes(ConstanceData.sprinters, 'ARMOTALE', 'SPRINTERS', 12, 11, 50),
    VehicleTypes(ConstanceData.carriers, 'ARMOTALE', 'CARRIERS', 16, 30, 30),
    VehicleTypes(ConstanceData.movers, 'ARMOTALE', 'MOVERS', 87, 11, 30),
  ];
  String vehicleSelected = 'ARMOTALE SPRINTERS';
  double deliveryCharge = 0;
  double serviceFee = 0;
  double payableAmount = 0;
  bool sprintersOnly = true;
  double totalFees = 0;
  double basePrice = 500;

  RegExp reg = new RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))');
  Function mathFunc = (Match match) => '${match[1]},';

  final pickUpAddressController = new TextEditingController();
  final droppingAddressController = new TextEditingController();
  @override
  void initState() {
    print(format);
    setAddresses();
    getPaymentInfo();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        elevation: .2,
        backgroundColor: Theme.of(context).backgroundColor,
        leading: IconButton(onPressed: () => Navigator.pop(context), icon: Icon(Icons.arrow_back, color: Colors.black)),
        centerTitle: true,
        title: Text('Send Package', style: TextStyle(color: Colors.black)),
      ),
      body: SingleChildScrollView(
        scrollDirection: Axis.vertical,
        primary: false,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: Container(
                color: Colors.white,
                child: Column(
                  children: [
                    CourierTextField(
                      readOnly: true,
                      controller: pickUpAddressController,
                      icon: Icon(Icons.location_on),
                      hint: 'Pick up address',
                    ),
                    CourierTextField(
                      readOnly: true,
                      controller: droppingAddressController,
                      icon: Icon(Icons.local_shipping),
                      hint: 'Dropping address',
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 8),
                color: Colors.white,
                child: Column(
                  children: [
                    Row(
                      children: [
                        Container(
                          height: 20,
                          width: 20,
                          color: Colors.blue,
                        ),
                        SizedBox(width: 20),
                        CustomText(text: 'SELECT PACKAGE TYPE', color: Colors.blue, size: 13, fontWeight: FontWeight.w800),
                        // SizedBox(height: 20),
                      ],
                    ),
                    SizedBox(height: 20),
                    Container(
                      child: Container(
                        decoration: BoxDecoration(borderRadius: BorderRadius.circular(30.0), color: Colors.grey[200]),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 2),
                          child: DropdownButtonHideUnderline(
                              child: FittedBox(
                            fit: BoxFit.scaleDown,
                            child: DropdownButton(
                                onTap: () => print('object'),
                                value: packageType.isNotEmpty ? packageType : null,
                                hint: Text('Select the type of package'),
                                onChanged: (val) {
                                  setState(() {
                                    packageType = val;
                                  });
                                },
                                items: packages
                                    .map((e) => DropdownMenuItem(
                                          child: Text(e),
                                          value: e,
                                          onTap: () {
                                            setState(() {
                                              packageType = e;
                                            });
                                          },
                                        ))
                                    .toList()),
                          )),
                        ),
                      ),
                    ),
                    SizedBox(height: 15),
                    CustomText(text: 'Click to select the vehicle type', size: 15, fontWeight: FontWeight.w700),
                    SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: vehicles
                          .map((e) => Column(
                                children: [
                                  GestureDetector(
                                    onTap: () {
                                      setState(() {
                                        selectedIndex = vehicles.indexOf(e);
                                        deliveryCharge = e.delivery;
                                        // serviceFee = e.serviceFee;
                                        // payableAmount = e.payable;
                                        // packageType = packageType;
                                        vehicleSelected = '${e.vehicleTitle} ${e.vehicleSubtitle}';
                                        // totalFees = widget.distancebetween / payableAmount * 100;
                                      });
                                      print(vehicleSelected);
                                      // print(packageType);
                                      // print(payableAmount);
                                    },
                                    child: Container(
                                        padding: EdgeInsets.all(8),
                                        height: 80,
                                        width: 80,
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          color: selectedIndex == vehicles.indexOf(e) ? Colors.blue[200] : Colors.grey[100],
                                          border: Border.all(color: Colors.white),
                                          boxShadow: [BoxShadow(color: Colors.grey[300], blurRadius: 2, spreadRadius: 1, offset: Offset(2, 3))],
                                        ),
                                        child: Image.asset(e.vehicleImage)),
                                  ),
                                  SizedBox(height: 10),
                                  CustomText(
                                    text: e.vehicleTitle,
                                    size: 18,
                                    fontWeight: FontWeight.w400,
                                    color: Colors.blue[400],
                                  ),
                                  CustomText(
                                    text: e.vehicleSubtitle,
                                    size: 13,
                                    fontWeight: FontWeight.w400,
                                    color: Colors.blue[400],
                                  )
                                ],
                              ))
                          .toList(),
                    ),
                    SizedBox(
                      height: 20,
                    ),
                    Visibility(
                      visible: vehicleSelected == 'ARMOTALE SPRINTERS',
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 58.0),
                        child: Column(
                          children: [
                            CustomText(
                              text: 'TOTAL PAYABLE AMOUNT',
                              textAlign: TextAlign.start,
                              size: 18,
                              fontWeight: FontWeight.w400,
                              color: Colors.blue[400],
                            ),

                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                CustomText(
                                  text: ConstanceData.naira,
                                  color: Theme.of(context).textTheme.title.color,
                                  size: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                                CustomText(
                                  text: '${totalFees.ceilToDouble()}0'.replaceAllMapped(reg, mathFunc),
                                  fontWeight: FontWeight.w800,
                                  size: 30,
                                ),
                              ],
                            ),
                            // Row(children: [
                            //   CustomText(text: 'Delivery charge', fontWeight: FontWeight.w600, size: 13),
                            //   Spacer(),
                            //   CustomText(text: deliveryCharge.toString(), fontWeight: FontWeight.w600, size: 13)
                            // ]),
                            // SizedBox(height: 15),
                            // Row(children: [
                            //   CustomText(text: 'Service Fee', fontWeight: FontWeight.w600, size: 13),
                            //   Spacer(),
                            //   CustomText(text: serviceFee.toString(), fontWeight: FontWeight.w600, size: 13, color: Colors.black)
                            // ]),
                            // SizedBox(height: 15),
                            // Row(children: [
                            //   CustomText(text: 'Amount To Pay', fontWeight: FontWeight.w600, size: 13),
                            //   Spacer(),
                            //   CustomText(text: payableAmount.toString(), fontWeight: FontWeight.w600, size: 13)
                            // ]),
                          ],
                        ),
                      ),
                    ),
                    Visibility(
                        visible: vehicleSelected != 'ARMOTALE SPRINTERS',
                        child: ClipRRect(
                          borderRadius: BorderRadius.all(Radius.circular(8)),
                          child: Image.asset(
                            ConstanceData.comingSoon,
                            height: 150,
                            width: 250,
                            fit: BoxFit.cover,
                          ),
                        )),
                    SizedBox(height: 15)
                  ],
                ),
              ),
            )
          ],
        ),
      ),
      bottomNavigationBar: GestureDetector(
        onTap: () {
          packageType != ''
              ? changeScreen(
                  context,
                  PaymentDetails(
                      timestamp: widget.timestamp,
                      totalFees: totalFees,
                      deliveryCharge: deliveryCharge,
                      packageType: packageType,
                      payableAmount: payableAmount,
                      serviceFee: serviceFee,
                      selectedVehicle: vehicleSelected,
                      recipientAddress: widget.recipientAddress,
                      senderAddress: widget.senderAddress,
                      senderGeoPoint: widget.senderGeoPoint,
                      recipientGeoPoint: widget.recipientGeoPoint,
                      distance: widget.distancebetween,
                      tripDuration: widget.tripDuration))
              : Fluttertoast.showToast(msg: 'You have not chosen a package type yet');
          print(packageType);
          print(widget.recipientAddress);
          print(widget.senderAddress);
          setState(() {});
        },
        child: Container(
          child: Center(
              child: CustomText(
            text: 'PROCEED TO PAYMENT',
            color: Colors.white,
          )),
          color: Colors.blue[400],
          height: 65,
        ),
      ),
    );
  }

  setAddresses() {
    setState(() {
      pickUpAddressController.text = widget.senderAddress[UserModel.SENDERADDRESS];
      droppingAddressController.text = widget.recipientAddress[UserModel.RECEPIENTADDRESS];
      deliveryCharge = vehicles[0].delivery;
      serviceFee = vehicles[0].serviceFee;
      payableAmount = vehicles[0].payable;
      // totalFees = deliveryCharge + serviceFee + payableAmount;
    });
  }

  getPaymentInfo() {
    int seconds = widget.timestamp.seconds;
    double timeTakenFee = (seconds / 60).toDouble() * 15;
    double distanceFee = widget.distancebetween * payableAmount;
    totalFees = distanceFee + basePrice;

    print('the pay rate per km$payableAmount');
    // print('the fee for $timeTakenFee');
    print('the distance fee is $distanceFee');
    print('the distance between is ${widget.distancebetween}');
    setState(() {});
  }
}

class VehicleTypes {
  final String vehicleImage;
  final String vehicleTitle;
  final String vehicleSubtitle;
  final double delivery;
  final double serviceFee;
  final double payable;

  VehicleTypes(this.vehicleImage, this.vehicleTitle, this.vehicleSubtitle, this.delivery, this.serviceFee, this.payable);
}
