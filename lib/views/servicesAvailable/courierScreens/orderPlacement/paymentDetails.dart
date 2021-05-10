import 'dart:io';
import 'dart:math';
import 'package:intl/intl.dart';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_paystack/flutter_paystack.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:my_cab/constance/constance.dart';
import 'package:my_cab/constance/global.dart';
import 'package:my_cab/helpers&widgets/widgets/customButton.dart';
import 'package:my_cab/helpers&widgets/widgets/customListTIle.dart';
import 'package:my_cab/helpers&widgets/widgets/customText.dart';
import 'package:my_cab/helpers&widgets/widgets/loading.dart';
import 'package:my_cab/models/driverModel.dart';
import 'package:my_cab/models/historyModel.dart';
import 'package:my_cab/models/userModel.dart';
import 'package:my_cab/services/courierServices.dart';
import 'package:my_cab/services/emailService.dart';
import 'package:my_cab/services/notificationServices.dart';
import 'package:my_cab/services/pushNotifications.dart';
import 'package:my_cab/services/userServices.dart';
import 'package:uuid/uuid.dart';

import '../courierMainScreen.dart';

class PaymentDetails extends StatefulWidget {
  final double totalFees;
  final double deliveryCharge;
  final double serviceFee;
  final double payableAmount;
  final String selectedVehicle;
  final String packageType;
  final String driverId;
  final Map<String, dynamic> senderAddress;
  final Map<String, dynamic> recipientAddress;
  final GeoPoint senderGeoPoint;
  final GeoPoint recipientGeoPoint;
  final Timestamp timestamp;
  final double distance;
  final String tripDuration;

  const PaymentDetails(
      {Key key,
      this.totalFees,
      this.deliveryCharge,
      this.serviceFee,
      this.payableAmount,
      this.selectedVehicle,
      this.packageType,
      this.senderAddress,
      this.recipientAddress,
      this.driverId,
      this.senderGeoPoint,
      this.recipientGeoPoint,
      this.timestamp,
      this.distance,
      this.tripDuration})
      : super(key: key);
  @override
  _PaymentDetailsState createState() => _PaymentDetailsState();
}

class _PaymentDetailsState extends State<PaymentDetails> {
  var format = NumberFormat.simpleCurrency(locale: Platform.localeName);

  UserServices userServices = new UserServices();
  final scaffoldKey = new GlobalKey<FormState>();
  FirebaseAuth _auth = FirebaseAuth.instance;
  String currentUserEmail = '';
  String paymentMethod = '';
  double promoAmount = 0;
  CourierServices courierServices = new CourierServices();
  OneSignalPush _oneSignalPush = new OneSignalPush();
  EmailService _emailService = new EmailService();
  List<DriverModel> allCouriers = [];
  List<String> courierIds = [];
  Map<String, dynamic> notificationDetails = {};
  NotificationServices notificationServices = new NotificationServices();
  double baseCost = 0;
  final plugin = PaystackPlugin();
  Charge charge = Charge();
  bool loading = false;

  RegExp reg = new RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))');
  Function mathFunc = (Match match) => '${match[1]},';

  Random random = new Random();

  int orderNumber = 0;
  int senderOtp = 0;
  int recipientOtp = 0;
  @override
  void initState() {
    getCourierIds();
    getCurrentUserDetails();
    plugin.initialize(publicKey: publicKey);
    generateOtp();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: scaffoldKey,
      appBar: AppBar(
        elevation: .2,
        backgroundColor: Theme.of(context).backgroundColor,
        leading: IconButton(onPressed: () => Navigator.pop(context), icon: Icon(Icons.arrow_back, color: Colors.black)),
        centerTitle: true,
        title: Text('Payment', style: TextStyle(color: Colors.black)),
      ),
      body: Stack(
        children: [
          Container(
            height: MediaQuery.of(context).size.height,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4),
              child: SingleChildScrollView(
                scrollDirection: Axis.vertical,
                primary: false,
                child: Column(
                  children: [
                    // CustomListTile(
                    //   color: grey[200],
                    //   radius: 25,
                    //   leading: Icon(Icons.brightness_5_sharp),
                    //   title: CustomText(text: 'Promo Code'),
                    //   trailing: CustomText(
                    //     text: 'Add',
                    //     color: Colors.green[400],
                    //     fontWeight: FontWeight.w700,
                    //   ),
                    // ),
                    SizedBox(height: 15),
                    FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 18.0),
                        child: Container(
                          height: 100,
                          width: MediaQuery.of(context).size.width,
                          padding: EdgeInsets.symmetric(horizontal: 66, vertical: 3),
                          decoration: BoxDecoration(borderRadius: BorderRadius.all(Radius.circular(16)), color: grey[200]),
                          child: Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: [
                            CustomText(
                              text: 'Total: ',
                              size: 22,
                              fontWeight: FontWeight.w600,
                              letterSpacing: .2,
                            ),
                            CustomText(
                              text: '${ConstanceData.naira}${widget.totalFees.ceilToDouble()}0'.replaceAllMapped(reg, mathFunc),
                              size: 26,
                              fontWeight: FontWeight.w900,
                              letterSpacing: .2,
                            ),
                          ]),
                          // Column(
                          //   mainAxisAlignment: MainAxisAlignment.center,
                          //   children: [
                          //     CartItemRich(
                          //       lightFont: 'Distance to cover: ',
                          //       boldFont: '${widget.distance.ceilToDouble()} Kms',
                          //       lightFontSize: 16,
                          //       boldFontSize: 19,
                          //     ),
                          //     SizedBox(height: 6),
                          //     CartItemRich(
                          //       lightFont: 'Trip duration: ',
                          //       boldFont: widget.tripDuration,
                          //       lightFontSize: 16,
                          //       boldFontSize: 19,
                          //     ),
                          //     SizedBox(height: 6),
                          //     CartItemRich(
                          //       lightFont: 'Payable Amount: ',
                          //       boldFont: widget.payableAmount.toString(),
                          //       lightFontSize: 16,
                          //       boldFontSize: 19,
                          //     ),
                          //     SizedBox(height: 6),
                          //     Padding(
                          //       padding: const EdgeInsets.all(8.0),
                          //       child: Row(
                          //         mainAxisAlignment: MainAxisAlignment.spaceAround,
                          //         children: [
                          //           CustomText(
                          //             text: 'Subtotal: ',
                          //             size: 18,
                          //             fontWeight: FontWeight.w600,
                          //             letterSpacing: .2,
                          //           ),
                          //           CustomText(
                          //             text: widget.totalFees.ceilToDouble().toString(),
                          //             size: 21,
                          //             fontWeight: FontWeight.w800,
                          //             letterSpacing: .2,
                          //           ),
                          //         ],
                          //       ),
                          //     )
                          //   ],
                          // ),
                        ),
                      ),
                    ),
                    SizedBox(height: 17),
                    // Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: [
                    //   CustomText(
                    //     text: 'Total: ',
                    //     size: 18,
                    //     fontWeight: FontWeight.w600,
                    //     letterSpacing: .2,
                    //   ),
                    //   CustomText(
                    //     text: '${ConstanceData.naira}${widget.totalFees.ceilToDouble()}',
                    //     size: 21,
                    //     fontWeight: FontWeight.w900,
                    //     letterSpacing: .2,
                    //   ),
                    // ]),
                    // SizedBox(height: 17),
                    CustomListTile(
                      color: grey[200],
                      radius: 25,
                      // leading:
                      title: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                              flex: 1,
                              child: CustomText(
                                text: ConstanceData.naira,
                                size: 22,
                                fontWeight: FontWeight.w700,
                                letterSpacing: .2,
                              )),
                          Expanded(
                              flex: 3,
                              child: CustomText(
                                text: 'Payment Methods',
                                size: 17,
                                fontWeight: FontWeight.w700,
                                letterSpacing: .2,
                              )),
                        ],
                      ),
                      // trailing: CustomText(text: 'Add'),
                    ),
                    SizedBox(height: 17),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8.0),
                      child: Container(
                        padding: EdgeInsets.all(12),
                        decoration: BoxDecoration(borderRadius: BorderRadius.all(Radius.circular(5)), border: Border.all(color: grey[400]), color: white),
                        child: Row(
                          children: [
                            Icon(Icons.money),
                            SizedBox(width: 17),
                            CustomText(text: 'Pay At Pick Up'),
                            Spacer(),
                            GestureDetector(
                              onTap: () {
                                setState(() {
                                  paymentMethod = 'cash';
                                });
                              },
                              child: Container(
                                height: 20,
                                width: 20,
                                decoration: BoxDecoration(
                                    color: paymentMethod == 'cash' ? green : white, shape: BoxShape.circle, border: Border.all(color: Colors.grey)),
                                child: paymentMethod == 'cash'
                                    ? Icon(
                                        Icons.check,
                                        color: white,
                                        size: 14,
                                      )
                                    : SizedBox.shrink(),
                              ),
                            )
                          ],
                        ),
                      ),
                    ),
                    SizedBox(height: 17),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8.0),
                      child: Container(
                        padding: EdgeInsets.all(12),
                        decoration: BoxDecoration(borderRadius: BorderRadius.all(Radius.circular(5)), border: Border.all(color: grey[400]), color: white),
                        child: Row(
                          children: [
                            Icon(Icons.credit_card_rounded),
                            SizedBox(width: 17),
                            CustomText(text: 'Pay By Card'),
                            Spacer(),
                            GestureDetector(
                              onTap: () {
                                setState(() {
                                  paymentMethod = 'card';
                                });
                              },
                              child: Container(
                                alignment: Alignment.center,
                                height: 20,
                                width: 20,
                                decoration: BoxDecoration(
                                    color: paymentMethod == 'card' ? green : white, shape: BoxShape.circle, border: Border.all(color: Colors.grey)),
                                child: paymentMethod == 'card'
                                    ? Icon(
                                        Icons.check,
                                        color: white,
                                        size: 14,
                                      )
                                    : SizedBox.shrink(),
                              ),
                            )
                          ],
                        ),
                      ),
                    ),
                    SizedBox(height: 15),
                    Stack(
                      children: [
                        Visibility(
                            visible: paymentMethod == 'card',
                            child: CustomFlatButton(
                              icon: Icons.credit_card,
                              color: green,
                              callback: () {
                                cardPayment(context);
                              },
                              text: 'Pay ${ConstanceData.naira}${widget.totalFees.ceilToDouble() - promoAmount}0'.replaceAllMapped(reg, mathFunc)+' Via Card',
                              iconSize: 17,
                              fontSize: 16,
                              radius: 30,
                              textColor: white,
                            )),
                        Visibility(
                            visible: paymentMethod == 'cash',
                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal:28.0),
                              child: CustomFlatButton(
                                // width: 260,
                                icon: Icons.money,
                                color: green,
                                callback: () {
                                  saveOrderRequest();
                                },
                                text: 'Pay ${ConstanceData.naira}${widget.totalFees.ceilToDouble() - promoAmount}0'.replaceAllMapped(reg, mathFunc)+' At pick up',
                                iconSize: 17,
                                fontSize: 16,
                                radius: 30,
                                textColor: white,
                              ),
                            )),
                      ],
                    )
                  ],
                ),
              ),
            ),
          ),
          Visibility(
              visible: loading == true,
              child: Loading(
                text: 'Saving Records\nPlease wait...',
                spinkitColor: Colors.blue[300],
              ))
        ],
      ),
    );
  }

  getCurrentUserDetails() async {
    await userServices.getUserById(_auth.currentUser.uid).then((value) {
      setState(() {
        currentUserEmail = value.email;
        paymentMethod = 'cash';
      });
      print(currentUserEmail);
    });
  }

  cardPayment(BuildContext context) async {
    charge
      ..amount = widget.totalFees.ceilToDouble().toInt() * 100
      ..reference = _getReference()
      ..email = currentUserEmail;
    CheckoutResponse response = await plugin.checkout(
      context,
      method: CheckoutMethod.card,
      charge: charge,
    );
    print(response.status);
    if (response.status == true) {
      print(response.card.number);
      saveOrderRequest();
    } else {
      Fluttertoast.showToast(msg: response.message);
    }
  }

  saveOrderRequest() async {
    // Uuid id = Uuid();
    // var serviceId = id.v4();
    // notificationServices.createNotification({
    //   HistoryModel.NOTIFICATIONTITLE: '${orderNumber.toString()} created',
    //   HistoryModel.NOTIFICATIONSUBTITLE: 'You made an order request for ${widget.selectedVehicle}',
    // }, serviceId);
    setState(() {
      loading = true;
    });
    createService(). //then((value) async {
        //   await _emailService.sendPickUpOtp(
        //       widget.senderAddress['senderEmail'], senderOtp.toString(), widget.senderAddress['senderName'], orderNumber.toString());
        //   await _emailService.sendDropOffOtp(
        //       widget.recipientAddress['recipientEmailAddress'], recipientOtp.toString(), widget.recipientAddress['recipientNames'], orderNumber.toString());
        // })
        // .
        then((value) async {
      String message = 'Order request $orderNumber from ${widget.senderAddress[UserModel.SENDERNAME]} is Unassigned. Check it out.';
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: CustomText(
        text: 'Order placed successfully',
        color: green,
        fontWeight: FontWeight.w800,
        letterSpacing: .1,
        size: 15,
      )));
      await _oneSignalPush.sendNotification(context, courierIds, message, 'You are needed at ${widget.senderAddress[UserModel.SENDERADDRESS]}');
    }).then((value) => Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(
                builder: (_) => CourierMain(
                      selectedIndex: 1,
                    )),
            (route) => false));
  }

  createService() async {
    Uuid id = Uuid();
    var serviceId = id.v4();
    await courierServices
        .createService(
            _auth.currentUser.uid,
            paymentMethod,
            widget.packageType,
            widget.selectedVehicle,
            widget.totalFees,
            widget.senderGeoPoint,
            widget.recipientGeoPoint,
            orderNumber,
            senderOtp,
            recipientOtp,
            '${widget.timestamp.microsecondsSinceEpoch}',
            widget.distance.toInt(),
            widget.senderAddress,
            widget.recipientAddress,
            serviceId)
        .then((value) => notificationServices.createNotification(
              {
                HistoryModel.NOTIFICATIONTITLE: '${orderNumber.toString()} created',
                HistoryModel.NOTIFICATIONSUBTITLE: 'You made an order request for ${widget.selectedVehicle}',
                HistoryModel.PICKUPLOCATION: widget.senderAddress[UserModel.SENDERADDRESS],
                HistoryModel.DROPOFFLOCATION: widget.recipientAddress[UserModel.RECEPIENTADDRESS],
                HistoryModel.EARNINGS: widget.totalFees,
              },
              serviceId,
            ));
  }

  generateOtp() {
    setState(() {
      orderNumber = random.nextInt(1000000);
      recipientOtp = random.nextInt(10000) + 1000;
      senderOtp = random.nextInt(10000) + 1000;
    });
  }

  String _getReference() {
    String platform;
    if (Platform.isIOS) {
      platform = 'iOS';
    } else {
      platform = 'Android';
    }
    return 'ChargedFrom${platform}_On_${DateTime.now()}\n Cost: ${widget.totalFees - promoAmount}\n Placed On: ${DateTime.now().toString()}';
  }

  getCourierIds() async {
    allCouriers = await courierServices.getCouriers();
    setState(() {});
    for (var i = 0; i < allCouriers.length; i++) {
      courierIds.add(allCouriers[i].id);
    }
    print(courierIds);
  }
}
