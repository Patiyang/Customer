import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:my_cab/constance/constance.dart';
import 'package:my_cab/constance/global.dart';
import 'package:my_cab/helpers&widgets/helpers/routing.dart';
import 'package:my_cab/helpers&widgets/widgets/customButton.dart';
import 'package:my_cab/helpers&widgets/widgets/customListTIle.dart';
import 'package:my_cab/helpers&widgets/widgets/customText.dart';
import 'package:my_cab/helpers&widgets/widgets/loading.dart';
import 'package:my_cab/helpers&widgets/widgets/textField.dart';
import 'package:my_cab/models/deliveryModel.dart';
import 'package:my_cab/services/courierServices.dart';
import 'package:my_cab/views/servicesAvailable/courierScreens/packageTracking/trackingDetails/assignedMap.dart';
import 'package:url_launcher/url_launcher.dart';

import 'unassignedMap.dart';

class PickUp extends StatefulWidget {
  final DeliveryModel deliveryModel;

  const PickUp({Key key, this.deliveryModel}) : super(key: key);
  @override
  _PickUpState createState() => _PickUpState();
}

class _PickUpState extends State<PickUp> {
  CourierServices courierServices = new CourierServices();
  final emailController = new TextEditingController();
  final formKey = GlobalKey<FormState>();
  FirebaseFirestore _firestore = FirebaseFirestore.instance;
  String profilePicture = '';
  String firstName = '';
  String lastName = '';
  String phoneNumber = '';
    RegExp reg = new RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))');
  Function mathFunc = (Match match) => '${match[1]},';
  @override
  Widget build(BuildContext context) {
    DeliveryModel pickUp = widget.deliveryModel;

    return Scaffold(
      body: SingleChildScrollView(
        scrollDirection: Axis.vertical,
        padding: EdgeInsets.symmetric(vertical: 10, horizontal: 20),
        primary: false,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            CustomText(text: '#${pickUp.orderNumber.toString()}', size: 19, letterSpacing: .3, fontWeight: FontWeight.bold),
            SizedBox(height: 10),
            Container(
              width: MediaQuery.of(context).size.width,
              padding: EdgeInsets.all(10),
              decoration: BoxDecoration(
                  border: Border.all(color: grey),
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(30),
                    topRight: Radius.circular(5),
                    bottomLeft: Radius.circular(5),
                    bottomRight: Radius.circular(5),
                  )),
              child: StreamBuilder(
                stream: courierServices.listenToSingleService(pickUp.serviceId).asStream(),
                builder: (BuildContext context, AsyncSnapshot snapshot) {
                  if (snapshot.hasData) {
                    DeliveryModel delivery = snapshot.data;
                    if (delivery.status == 'Unasigned') {
                      return Column(
                        children: [
                          Row(
                            children: [
                              Expanded(child: CustomText(text: 'Order #${delivery.orderNumber}', size: 15, letterSpacing: .1, fontWeight: FontWeight.bold)),
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
                          Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.all(Radius.circular(30)),
                              color: blue[400],
                            ),
                            padding: EdgeInsets.all(13),
                            child: CustomText(text: 'Export to CVS', size: 13, color: white,),
                          ),
                          SizedBox(height: 10),
                    
                        ],
                      );
                    }
                    if (delivery.status == 'Accepted') {
                      _firestore.collection('drivers').doc(pickUp.driverId).get().then((value) {
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
                              Expanded(child: CustomText(text: 'Order #${delivery.orderNumber}', size: 15, letterSpacing: .1, fontWeight: FontWeight.bold)),
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
                          Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.all(Radius.circular(30)),
                              color: blue[400],
                            ),
                            padding: EdgeInsets.all(13),
                            child: CustomText(text: 'Export to CVS', size: 13,color: white,),
                          ),
            
                        ],
                      );
                    }

                    if (delivery.status == 'In Transit') {
                      _firestore.collection('drivers').doc(pickUp.driverId).get().then((value) {
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
                              Expanded(child: CustomText(text: 'Order #${delivery.orderNumber}', size: 15, letterSpacing: .1, fontWeight: FontWeight.bold)),
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
                          Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.all(Radius.circular(30)),
                              color: blue[400],
                            ),
                            padding: EdgeInsets.all(13),
                            child: CustomText(text: 'Export to CVS', size: 13,color: white,),
                          ),
                    
                        ],
                      );
                    }
                    if (delivery.status == 'Completed') {
                      _firestore.collection('drivers').doc(pickUp.driverId).get().then((value) {
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
                              Expanded(child: CustomText(text: 'Order #${delivery.orderNumber}', size: 15, letterSpacing: .1, fontWeight: FontWeight.bold)),
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
                                        deliveryModel: pickUp,
                                        senderLocation: pickUp.senderLocation,
                                        recipientLocation: pickUp.recipientLocation,
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
                          Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.all(Radius.circular(30)),
                              color: blue[400],
                            ),
                            padding: EdgeInsets.all(13),
                            child: CustomText(text: 'Export to CVS', size: 13,color: white,),
                          ),
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
            SizedBox(height: 20),
            CustomListTile(
              color: grey[100],
              title: Center(
                  child: CartItemRich(
                lightFont: 'Your OTP is: ',
                boldFont: pickUp.senderOtp.toString(),
                boldFontSize: 20,
                lightFontSize: 15,
              )),
            ),
            SizedBox(height: 10),
            CustomListTile(
              color: Colors.transparent,
              leading: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CustomText(text: 'Name', color: grey[600], size: 12, fontWeight: FontWeight.w700),
                  SizedBox(height: 4),
                  CustomText(text: pickUp.senderName, size: 14, fontWeight: FontWeight.w700),
                ],
              ),
            ),
            SizedBox(height: 7),
            CustomListTile(
              color: Colors.transparent,
              leading: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CustomText(text: 'Address', color: grey[600], size: 12, fontWeight: FontWeight.w700),
                  SizedBox(height: 4),
                  CustomText(text: pickUp.senderAddress, size: 14, fontWeight: FontWeight.w700),
                ],
              ),
            ),
            SizedBox(height: 7),
            CustomListTile(
              color: Colors.transparent,
              leading: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CustomText(text: 'Placed On', color: grey[600], size: 12, fontWeight: FontWeight.w700),
                  SizedBox(height: 4),
                  CustomText(text: pickUp.placedOn.toDate().toLocal().toString().substring(0, 16), size: 14, fontWeight: FontWeight.w700),
                ],
              ),
            ),
            SizedBox(height: 10),
            CustomListTile(
              color: Colors.transparent,
              leading: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CustomText(text: 'Contact', color: grey[600], size: 12, fontWeight: FontWeight.w700),
                  SizedBox(height: 4),
                  CustomText(text: pickUp.senderPhone, size: 14, fontWeight: FontWeight.w700),
                ],
              ),
            ),
            SizedBox(height: 7),
            CustomListTile(
              color: Colors.transparent,
              leading: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CustomText(text: 'Email', color: grey[600], size: 12, fontWeight: FontWeight.w700),
                  SizedBox(height: 4),
                  CustomText(text: pickUp.senderEmail, size: 14, fontWeight: FontWeight.w700),
                ],
              ),
            ),
            SizedBox(height: 7),
            Visibility(
              visible: pickUp.paymentMode == 'cash',
              child: Container(
                child: Column(
                  children: [
                    CustomListTile(
                      color: Colors.transparent,
                      leading: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          CustomText(text: 'Total fare', color: grey[600], size: 12, fontWeight: FontWeight.w700),
                          SizedBox(height: 4),
                          CustomText(text: '${pickUp.earnings.ceilToDouble().toString().replaceAllMapped(reg, mathFunc)}0', size: 14, fontWeight: FontWeight.w700),
                        ],
                      ),
                    ),
                    SizedBox(height: 10),
                    CustomListTile(
                      color: Colors.transparent,
                      leading: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          CustomText(text: 'Payment Mode', color: grey[600], size: 12, fontWeight: FontWeight.w700),
                          SizedBox(height: 4),
                          CustomText(text: pickUp.paymentMode, size: 14, fontWeight: FontWeight.w700),
                        ],
                      ),
                    ),
                    SizedBox(height: 7),
                    CustomListTile(
                      color: Colors.transparent,
                      leading: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          CustomText(text: 'Amount to collect', color: grey[600], size: 12, fontWeight: FontWeight.w700),
                          SizedBox(height: 4),
                          CustomText(text: "${pickUp.earnings.ceilToDouble().toString().replaceAllMapped(reg, mathFunc)}0", size: 14, fontWeight: FontWeight.w700),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Visibility(
              visible: pickUp.paymentMode == 'card',
              child: CustomListTile(
                color: Colors.transparent,
                leading: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CustomText(text: 'Payment Mode', color: grey[600], size: 12, fontWeight: FontWeight.w700),
                    SizedBox(height: 4),
                    CustomText(text: pickUp.paymentMode, size: 14, fontWeight: FontWeight.w700),
                  ],
                ),
              ),
            )
          ],
        ),
      ),
      floatingActionButton: Container(
        padding: EdgeInsets.all(13),
        decoration: BoxDecoration( color: blue, borderRadius: BorderRadius.all(Radius.circular(30))),
        child: GestureDetector(
          onTap: () {
            if (pickUp.status == 'Unasigned') {
              Navigator.push(
                context,
                ScaleRoute(
                  page: UnassignedMap(
                    deliveryModel: pickUp,
                    senderLocation: pickUp.senderLocation,
                    recipientLocation: pickUp.recipientLocation,
                  ),
                ),
              );
            } else {
              Navigator.push(
                context,
                ScaleRoute(
                  page: DeliveryMap(serviceId: pickUp.serviceId),
                ),
              );
            }
          },
          child: FittedBox(fit:BoxFit.scaleDown,
                      child: Row(
              children: [
                CustomText(text: 'Track your order',color: white,),
                SizedBox(width: 15,),
                Icon(Icons.directions, color: white),
              ],
            ),
          ),
        ),
      ),
    );
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

  showEmailDialog() {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return Dialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(9.0)),
            child: FittedBox(
              fit: BoxFit.fitHeight,
              child: Container(
                  padding: EdgeInsets.symmetric(vertical: 30),
                  width: MediaQuery.of(context).size.width,
                  // height: 200,
                  child: Form(
                    key: formKey,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CustomText(
                          text: 'Please type in the email to send below',
                          size: 15,
                          fontWeight: FontWeight.w600,
                          textAlign: TextAlign.center,
                        ),
                        SizedBox(
                          height: 20,
                        ),
                        Container(
                          padding: EdgeInsets.symmetric(horizontal: 12),
                          width: MediaQuery.of(context).size.width,
                          child: LoginTextField(
                            maxLines: 4,
                            hint: 'Enter your email message',
                            controller: emailController,
                            validator: (v) {
                              if (v.isEmpty)
                                return 'email message cannot be empty';
                              else
                                return null;
                            },
                          ),
                        ),
                        SizedBox(
                          height: 15,
                        ),
                        CustomFlatButton(
                          icon: Icons.send,
                          radius: 30,
                          text: 'Send',
                          textColor: white,
                          fontSize: 16,
                          callback: () {
                            if (formKey.currentState.validate()) {
                              createEmail(
                                      'mailto:patiyang6@gmail.com?subject=Order # ${widget.deliveryModel.orderNumber} follow up by ${widget.deliveryModel.senderName}&body=${emailController.text}')
                                  .then((value) => Navigator.pop(context));
                            }
                          },
                        )
                      ],
                    ),
                  )),
            ),
          );
        });
  }

  showRatingDialog() {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return Dialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(9.0)),
            child: FittedBox(
              fit: BoxFit.fitHeight,
              child: Container(
                  padding: EdgeInsets.symmetric(vertical: 30),
                  width: MediaQuery.of(context).size.width,
                  // height: 200,
                  child: Form(
                    key: formKey,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CustomText(
                          text: 'Please Leave a feedback for $firstName $lastName',
                          size: 15,
                          fontWeight: FontWeight.w600,
                          textAlign: TextAlign.center,
                        ),
                        SizedBox(
                          height: 10,
                        ),
                        Container(
                          decoration: BoxDecoration(color: grey[100], borderRadius: BorderRadius.all(Radius.circular(30))),
                          padding: EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          child: RatingBar.builder(
                            initialRating: 3,
                            minRating: 1,
                            direction: Axis.horizontal,
                            allowHalfRating: true,
                            itemCount: 5,
                            ignoreGestures: false,
                            itemSize: 33,
                            itemPadding: EdgeInsets.symmetric(horizontal: 3.0),
                            itemBuilder: (context, _) => Icon(
                              Icons.star,
                              color: Colors.amber,
                            ),
                            onRatingUpdate: (rating) {
                              print(rating);
                            },
                          ),
                        ),
                        Container(
                          padding: EdgeInsets.symmetric(horizontal: 12),
                          width: MediaQuery.of(context).size.width,
                          child: LoginTextField(
                            maxLines: 2,
                            hint: 'Enter your feedback message',
                            controller: emailController,
                            validator: (v) {
                              if (v.isEmpty)
                                return 'email message cannot be empty';
                              else
                                return null;
                            },
                          ),
                        ),
                        SizedBox(
                          height: 15,
                        ),
                        CustomFlatButton(
                          icon: Icons.chat,
                          radius: 30,
                          text: 'Post',
                          textColor: white,
                          fontSize: 16,
                          callback: () {
                            if (formKey.currentState.validate()) {
                              Navigator.pop(context);
                            }
                          },
                        )
                      ],
                    ),
                  )),
            ),
          );
        });
  }
}
