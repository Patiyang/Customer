import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:my_cab/constance/constance.dart';
import 'package:my_cab/constance/global.dart';
import 'package:my_cab/helpers&widgets/helpers/changeScreen.dart';
import 'package:my_cab/helpers&widgets/widgets/customListTIle.dart';
import 'package:my_cab/helpers&widgets/widgets/customText.dart';
import 'package:my_cab/helpers&widgets/widgets/loading.dart';
import 'package:my_cab/models/deliveryModel.dart';
import 'package:my_cab/models/historyModel.dart';
import 'package:my_cab/services/courierServices.dart';
import 'package:my_cab/views/servicesAvailable/courierScreens/packageTracking/trackingDetails/unassignedMap.dart';
import 'package:url_launcher/url_launcher.dart';

class HistoryDetails extends StatefulWidget {
  final String serviceId;

  const HistoryDetails({Key key, this.serviceId}) : super(key: key);
  @override
  _HistoryDetailsState createState() => _HistoryDetailsState();
}

class _HistoryDetailsState extends State<HistoryDetails> {
  DeliveryModel delivery;
  CourierServices courierServices = new CourierServices();
  bool loading = false;
  Color containerColor;
  FirebaseFirestore _firestore = FirebaseFirestore.instance;
  String profilePicture = '';
  String firstName = '';
  String lastName = '';
  String phoneNumber = '';
  @override
  void initState() {
    getOrderDetails();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: loading == true
          ? Loading(
              text: 'Fetching your order History...',
              fontWeight: FontWeight.w700,
            )
          : SingleChildScrollView(
            padding: EdgeInsets.symmetric(horizontal: 12),
            primary: false,
            scrollDirection: Axis.vertical,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                SizedBox(height: 20),
                Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.all(Radius.circular(20)),
                      color: containerColor,
                    ),
                    padding: EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                    child: CustomText(
                      color: white,
                      text: '#${delivery.orderNumber.toString()}',
                      size: 20,
                      letterSpacing: .3,
                      fontWeight: FontWeight.w800,
                    )),
                SizedBox(height: 10),
                // SizedBox(height: 10),
                Container(
                  width: MediaQuery.of(context).size.width,
                  padding: EdgeInsets.all(5),
                  decoration: BoxDecoration(
                      border: Border.all(color: grey),
                      borderRadius: BorderRadius.all(
                        Radius.circular(10),
                      )),
                  child: StreamBuilder(
                    stream: courierServices.listenToSingleService(delivery.serviceId).asStream(),
                    builder: (BuildContext context, AsyncSnapshot snapshot) {
                      if (snapshot.hasData) {
                        DeliveryModel delivery = snapshot.data;
                        if (delivery.status == 'Unasigned') {
                          return Column(
                            children: [
                              Row(
                                children: [
                                  Expanded(
                                      child: CustomText(text: 'Order #${delivery.orderNumber}', size: 15, letterSpacing: .1, fontWeight: FontWeight.bold)),
                                  Container(
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.all(Radius.circular(5)),
                                      color: grey[300],
                                    ),
                                    padding: EdgeInsets.all(4),
                                    child: CustomText(text: delivery.status, size: 13),
                                  )
                                ],
                              ),
                              SizedBox(height: 10),
                              CustomText(
                                text: 'Sorry, your order has not been assigned to one of our pilots yet We\'re working on it',
                                maxLines: 3,
                                textAlign: TextAlign.center,
                                size: 14,
                                fontWeight: FontWeight.w700,
                                color: grey[700],
                              ),
                              SizedBox(height: 10),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  GestureDetector(
                                    onTap: () => makePhoneCall('tel: 0723942008'),
                                    child: Container(
                                      decoration: BoxDecoration(shape: BoxShape.circle, color: blue[400]),
                                      padding: EdgeInsets.all(13),
                                      child: Icon(Icons.call, color: white),
                                    ),
                                  ),
                                  SizedBox(width: 20),
                                  GestureDetector(
                                    onTap: () => writeMessgae('sms: 0723942008'),
                                    child: Container(
                                      decoration: BoxDecoration(shape: BoxShape.circle, color: blue[400]),
                                      padding: EdgeInsets.all(13),
                                      child: Icon(Icons.message, color: white),
                                    ),
                                  ),
                                  SizedBox(width: 20),
                                  GestureDetector(
                                    onTap: () => showEmailDialog(),
                                    // createEmail('mailto:ohwotemuphillip@gmail.com?subject=Order # ${widget.deliveryModel.orderNumber}&body=New%20plugin'),
                                    child: Container(
                                      decoration: BoxDecoration(shape: BoxShape.circle, color: blue[400]),
                                      padding: EdgeInsets.all(13),
                                      child: Icon(Icons.email, color: white),
                                    ),
                                  )
                                ],
                              ),
                              SizedBox(height: 10),
                              CustomText(text: 'Contact us', size: 16, fontWeight: FontWeight.bold, color: grey[800]),
                              SizedBox(height: 10),
                              // Container(
                              //   decoration: BoxDecoration(
                              //     borderRadius: BorderRadius.all(Radius.circular(30)),
                              //     color: blue[400],
                              //   ),
                              //   padding: EdgeInsets.all(13),
                              //   child: CustomText(text: 'Export to CVS', size: 13, color: white,),
                              // ),
                              SizedBox(height: 10),
                            ],
                          );
                        }
                        if (delivery.status == 'Accepted') {
                          _firestore.collection('drivers').doc(delivery.driverId).get().then((value) {
                            if (mounted) {
                              setState(() {
                                profilePicture = value.data()['profilePicture'];
                                firstName = value.data()['firstName'];
                                lastName = value.data()['lastName'];
                                phoneNumber = value.data()['phoneNumber'];
                              });
                            }
                            // print(phoneNumber);
                          });
                          return Column(
                            children: [
                              Row(
                                children: [
                                  Expanded(
                                      child: CustomText(text: 'Order #${delivery.orderNumber}', size: 15, letterSpacing: .1, fontWeight: FontWeight.bold)),
                                  Container(
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.all(Radius.circular(5)),
                                      color: Colors.amber[600],
                                    ),
                                    padding: EdgeInsets.all(8),
                                    child: CustomText(
                                      text: 'Accepted',
                                      size: 13,
                                      fontWeight: FontWeight.w700,
                                      color: white,
                                      letterSpacing: .3,
                                    ),
                                  )
                                ],
                              ),
                              SizedBox(height: 10),

                              ClipOval(
                                  child: Container(
                                child: profilePicture == null || profilePicture == ''
                                    ? Image.asset(
                                        ConstanceData.noImage,
                                        fit: BoxFit.fill,
                                        height: 70,
                                        width: 70,
                                      )
                                    : Image.network(
                                        profilePicture,
                                        fit: BoxFit.cover,
                                        height: 70,
                                        width: 70,
                                      ),
                              )),
                              SizedBox(height: 10),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  GestureDetector(
                                    onTap: () => makePhoneCall('tel: 234$phoneNumber'),
                                    child: Container(
                                      decoration: BoxDecoration(shape: BoxShape.circle, color: blue[400]),
                                      padding: EdgeInsets.all(13),
                                      child: Icon(Icons.call, color: white),
                                    ),
                                  ),
                                  SizedBox(width: 20),
                                  GestureDetector(
                                    onTap: () => writeMessgae('sms: $phoneNumber'),
                                    child: Container(
                                      decoration: BoxDecoration(shape: BoxShape.circle, color: blue[400]),
                                      padding: EdgeInsets.all(13),
                                      child: Icon(Icons.message, color: white),
                                    ),
                                  ),
                                  SizedBox(width: 20),
                                  GestureDetector(
                                    onTap: () => showEmailDialog(),
                                    // createEmail('mailto:ohwotemuphillip@gmail.com?subject=Order # ${widget.deliveryModel.orderNumber}&body=New%20plugin'),
                                    child: Container(
                                      decoration: BoxDecoration(shape: BoxShape.circle, color: blue[400]),
                                      padding: EdgeInsets.all(13),
                                      child: Icon(Icons.email, color: white),
                                    ),
                                  )
                                ],
                              ),
                              SizedBox(height: 10),
                              CustomText(text: 'Contact $firstName $lastName', size: 16, fontWeight: FontWeight.bold, color: grey[800]),
                              SizedBox(height: 10),
                              // Container(
                              //   decoration: BoxDecoration(
                              //     borderRadius: BorderRadius.all(Radius.circular(30)),
                              //     color: blue[400],
                              //   ),
                              //   padding: EdgeInsets.all(13),
                              //   child: CustomText(text: 'Export to CVS', size: 13,color: white,),
                              // ),
                            ],
                          );
                        }

                        if (delivery.status == 'In Transit') {
                          _firestore.collection('drivers').doc(delivery.driverId).get().then((value) {
                            if (mounted) {
                              setState(() {
                                profilePicture = value.data()['profilePicture'];
                                firstName = value.data()['firstName'];
                                lastName = value.data()['lastName'];
                                phoneNumber = value.data()['phoneNumber'];
                              });
                            }
                            // print(phoneNumber);
                          });
                          return Column(
                            children: [
                              Row(
                                children: [
                                  Expanded(
                                      child: CustomText(text: 'Order #${delivery.orderNumber}', size: 15, letterSpacing: .1, fontWeight: FontWeight.bold)),
                                  Container(
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.all(Radius.circular(5)),
                                      color: Colors.purple[500],
                                    ),
                                    padding: EdgeInsets.all(8),
                                    child: CustomText(
                                      text: delivery.status,
                                      size: 13,
                                      fontWeight: FontWeight.bold,
                                      letterSpacing: .3,
                                      color: white,
                                    ),
                                  )
                                ],
                              ),
                              SizedBox(height: 10),

                              ClipOval(
                                  child: Container(
                                child: profilePicture == null || profilePicture == ''
                                    ? Image.asset(
                                        ConstanceData.noImage,
                                        fit: BoxFit.fill,
                                        height: 70,
                                        width: 70,
                                      )
                                    : Image.network(
                                        profilePicture,
                                        fit: BoxFit.cover,
                                        height: 70,
                                        width: 70,
                                      ),
                              )),
                              SizedBox(height: 10),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  GestureDetector(
                                    onTap: () => makePhoneCall('tel: 234$phoneNumber'),
                                    child: Container(
                                      decoration: BoxDecoration(shape: BoxShape.circle, color: blue[400]),
                                      padding: EdgeInsets.all(13),
                                      child: Icon(Icons.call, color: white),
                                    ),
                                  ),
                                  SizedBox(width: 20),
                                  GestureDetector(
                                    onTap: () => writeMessgae('sms: $phoneNumber'),
                                    child: Container(
                                      decoration: BoxDecoration(shape: BoxShape.circle, color: blue[400]),
                                      padding: EdgeInsets.all(13),
                                      child: Icon(Icons.message, color: white),
                                    ),
                                  ),
                                  SizedBox(width: 20),
                                  GestureDetector(
                                    onTap: () => showEmailDialog(),
                                    // createEmail('mailto:ohwotemuphillip@gmail.com?subject=Order # ${widget.deliveryModel.orderNumber}&body=New%20plugin'),
                                    child: Container(
                                      decoration: BoxDecoration(shape: BoxShape.circle, color: blue[400]),
                                      padding: EdgeInsets.all(13),
                                      child: Icon(Icons.email, color: white),
                                    ),
                                  )
                                ],
                              ),
                              SizedBox(height: 10),
                              CustomText(text: 'Contact $firstName $lastName', size: 16, fontWeight: FontWeight.bold, color: grey[800]),
                              SizedBox(height: 10),
                              // Container(
                              //   decoration: BoxDecoration(
                              //     borderRadius: BorderRadius.all(Radius.circular(30)),
                              //     color: blue[400],
                              //   ),
                              //   padding: EdgeInsets.all(13),
                              //   child: CustomText(text: 'Export to CVS', size: 13,color: white,),
                              // ),
                            ],
                          );
                        }
                        if (delivery.status == 'Completed') {
                          _firestore.collection('drivers').doc(delivery.driverId).get().then((value) {
                            if (mounted) {
                              setState(() {
                                profilePicture = value.data()['profilePicture'];
                                firstName = value.data()['firstName'];
                                lastName = value.data()['lastName'];
                                phoneNumber = value.data()['phoneNumber'];
                              });
                            }
                            // print(phoneNumber);
                          });
                          return Column(
                            children: [
                              Row(
                                children: [
                                  Expanded(
                                      child: CustomText(text: 'Order #${delivery.orderNumber}', size: 15, letterSpacing: .1, fontWeight: FontWeight.bold)),
                                  Container(
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.all(Radius.circular(5)),
                                      color: green,
                                    ),
                                    padding: EdgeInsets.all(8),
                                    child: CustomText(
                                      text: 'Completed',
                                      size: 13,
                                      letterSpacing: .3,
                                      fontWeight: FontWeight.w600,
                                      color: white,
                                    ),
                                  )
                                ],
                              ),
                              SizedBox(height: 10),
                              ClipOval(
                                child: Container(
                                  child: profilePicture == null || profilePicture == ''
                                      ? Image.asset(
                                          ConstanceData.noImage,
                                          fit: BoxFit.fill,
                                          height: 70,
                                          width: 70,
                                        )
                                      : Image.network(
                                          profilePicture,
                                          fit: BoxFit.cover,
                                          height: 70,
                                          width: 70,
                                        ),
                                ),
                              ),
                              SizedBox(height: 10),
                              CustomText(
                                text: 'THIS ORDER WAS COMPLETED SUCCESSFULY BY $firstName $lastName'.toUpperCase(),
                                maxLines: 3,
                                textAlign: TextAlign.center,
                                size: 14,
                                fontWeight: FontWeight.w700,
                                color: grey[700],
                              ),
                              SizedBox(height: 10),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  GestureDetector(
                                    onTap: () => makePhoneCall('tel: 0723942008'),
                                    child: Container(
                                      decoration: BoxDecoration(shape: BoxShape.circle, color: blue[400]),
                                      padding: EdgeInsets.all(13),
                                      child: Icon(Icons.call, color: white),
                                    ),
                                  ),
                                  SizedBox(width: 20),
                                  GestureDetector(
                                    onTap: () => writeMessgae('sms: 0723942008'),
                                    child: Container(
                                      decoration: BoxDecoration(shape: BoxShape.circle, color: blue[400]),
                                      padding: EdgeInsets.all(13),
                                      child: Icon(Icons.message, color: white),
                                    ),
                                  ),
                                  SizedBox(width: 20),
                                  GestureDetector(
                                    onTap: () => showEmailDialog(),
                                    // createEmail('mailto:ohwotemuphillip@gmail.com?subject=Order # ${widget.deliveryModel.orderNumber}&body=New%20plugin'),
                                    child: Container(
                                      decoration: BoxDecoration(shape: BoxShape.circle, color: blue[400]),
                                      padding: EdgeInsets.all(13),
                                      child: Icon(Icons.email, color: white),
                                    ),
                                  ),
                                  SizedBox(width: 20),
                                  Container(
                                      padding: EdgeInsets.all(13),
                                      decoration: BoxDecoration(shape: BoxShape.circle, color: blue),
                                      child: GestureDetector(
                                        onTap: () => changeScreen(
                                          context, //HomeScreen()
                                          UnassignedMap(
                                            deliveryModel: delivery,
                                            senderLocation: delivery.senderLocation,
                                            recipientLocation: delivery.recipientLocation,
                                          ),
                                        ),
                                        child: Icon(
                                          Icons.directions,
                                          color: white,
                                        ),
                                      ))
                                ],
                              ),
                              SizedBox(height: 10),
                              CustomText(text: 'Contact us', size: 16, fontWeight: FontWeight.bold, color: grey[800]),
                              SizedBox(height: 10),
                              // Container(
                              //   decoration: BoxDecoration(
                              //     borderRadius: BorderRadius.all(Radius.circular(30)),
                              //     color: blue[400],
                              //   ),
                              //   padding: EdgeInsets.all(13),
                              //   child: CustomText(text: 'Export to CVS', size: 13,color: white,),
                              // ),
                              SizedBox(height: 10),
                              GestureDetector(
                                onTap: () => showRatingDialog(),
                                child: Container(
                                  decoration: BoxDecoration(color: grey[300], borderRadius: BorderRadius.all(Radius.circular(30))),
                                  padding: EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                  child: Column(
                                    children: [
                                      CustomText(
                                        text: 'Leave Rating',
                                        size: 15,
                                        fontWeight: FontWeight.w700,
                                      ),
                                      RatingBar.builder(
                                        initialRating: 3,
                                        minRating: 1,
                                        direction: Axis.horizontal,
                                        allowHalfRating: true,
                                        itemCount: 5,
                                        ignoreGestures: true,
                                        itemSize: 17,
                                        itemPadding: EdgeInsets.symmetric(horizontal: 3.0),
                                        itemBuilder: (context, _) => Icon(
                                          Icons.star,
                                          color: Colors.amber,
                                        ),
                                        onRatingUpdate: (rating) {
                                          print(rating);
                                        },
                                      ),
                                    ],
                                  ),
                                ),
                              )
                            ],
                          );
                        }
                      }
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return Loading(
                          size: 13,
                        );
                      }
                      return Container();
                    },
                  ),
                ),
                SizedBox(height: 10),
                CartItemRich(
                  lightFont: 'Trip status: ',
                  boldFont: delivery.status,
                  boldFontSize: 18,
                  lightFontSize: 15,
                ),
                SizedBox(height: 10),
                CartItemRich(
                  lightFont: 'Package Type: ',
                  boldFont: delivery.packageType,
                  boldFontSize: 18,
                  lightFontSize: 15,
                ),
                SizedBox(height: 10),
                CartItemRich(
                  lightFont: 'Placed On: ',
                  boldFont: delivery.placedOn.toDate().toString().substring(0, 16),
                  boldFontSize: 18,
                  lightFontSize: 15,
                ),
                SizedBox(height: 10),
                CartItemRich(
                  lightFont: 'Accepted On: ',
                  boldFont: Timestamp.fromMillisecondsSinceEpoch(delivery.acceptedTransitOn).toDate().toString().substring(0, 16),
                  boldFontSize: 18,
                  lightFontSize: 15,
                ),
                SizedBox(height: 10),
                CartItemRich(
                  lightFont: 'Started transit On: ',
                  boldFont: Timestamp.fromMillisecondsSinceEpoch(delivery.startedTransitOn).toDate().toString().substring(0, 16),
                  boldFontSize: 18,
                  lightFontSize: 15,
                ),
                SizedBox(height: 10),
                CartItemRich(
                  lightFont: 'Completed On: ',
                  boldFont: delivery.completedTransitON == 0
                      ? 'TBD'
                      : Timestamp.fromMillisecondsSinceEpoch(delivery.completedTransitON).toDate().toString().substring(0, 16),
                  boldFontSize: 18,
                  lightFontSize: 15,
                ),
                SizedBox(height: 10),
                CartItemRich(
                  lightFont: 'Payment Mode: ',
                  boldFont: delivery.paymentMode,
                  boldFontSize: 18,
                  lightFontSize: 15,
                ),
                SizedBox(height: 20),
                CartItemRich(
                  lightFont: 'Trip Cost: ',
                  boldFont: '${ConstanceData.naira}${delivery.earnings.ceilToDouble()}0',
                  boldFontSize: 22,
                  lightFontSize: 15,
                )
              ],
            ),
          ),
    );
  }

  showEmailDialog() {}
  showRatingDialog() {}
  getOrderDetails() async {
    setState(() {
      loading = true;
    });
    delivery = await courierServices.listenToSingleService(widget.serviceId);
    if (delivery.status == 'Unasigned') containerColor = grey;
    if (delivery.status == 'Accepted') containerColor = Colors.amberAccent;
    if (delivery.status == 'In Transit') containerColor = Colors.purple[500];
    if (delivery.status == 'Completed') containerColor = green;
    // print(Timestamp.fromMillisecondsSinceEpoch(delivery.completedTransitON).toDate().toString());
    setState(() {
      loading = false;
    });
  }

  Future<void> makePhoneCall(String url) async {
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }

  Future<void> writeMessgae(String url) async {
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }

  Future<void> createEmail(String url) async {
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }
}
