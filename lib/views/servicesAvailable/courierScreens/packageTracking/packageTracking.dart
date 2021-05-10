import 'package:flutter/material.dart';
import 'package:my_cab/constance/constance.dart';
import 'package:my_cab/constance/global.dart';
import 'package:my_cab/helpers&widgets/helpers/changeScreen.dart';
import 'package:my_cab/helpers&widgets/widgets/customListTIle.dart';
import 'package:my_cab/helpers&widgets/widgets/customText.dart';
import 'package:my_cab/helpers&widgets/widgets/loading.dart';
import 'package:my_cab/models/deliveryModel.dart';
import 'package:my_cab/services/courierServices.dart';

import 'trackingDetails/packageDetails.dart';

class OrderTracking extends StatefulWidget {
  @override
  _OrderTrackingState createState() => _OrderTrackingState();
}

class _OrderTrackingState extends State<OrderTracking> {
  CourierServices _courierServices = new CourierServices();
  List<DeliveryModel> deliveries = [];
  bool loading = false;
  var containerColor;
  @override
  void initState() {
    getAllDeliveries();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: deliveries.length == 0
            ? Container(
                alignment: Alignment.center,
                child: loading == true
                    ? Loading(
                        spinkitColor: black,
                        size: 13,
                        text: 'Fetching your orders',
                        fontWeight: FontWeight.w700,
                      )
                    : Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          CustomText(text: 'You have no ongoing deliveries yet', color: grey[600], fontWeight: FontWeight.w700),
                          SizedBox(height: 10),
                          ClipRRect(
                            borderRadius: BorderRadius.all(Radius.circular(20)),
                            child: Image.asset(
                              ConstanceData.noData,
                              height: 170,
                              width: 170,
                            ),
                          )
                        ],
                      ),
              )
            : SingleChildScrollView(
                primary: false,
                child: Column(
                  children: deliveries.map((e) {
                    if (e.status == 'Unasigned') {
                      containerColor = grey;
                    }
                    if (e.status == 'Accepted') {
                      containerColor = Colors.amber[600];
                    }
                    if (e.status == 'In Transit') {
                      containerColor = Colors.purple[500];
                    }
                    if (e.status == 'Completed') {
                      containerColor = green;
                    }
                    return Container(
                      width: MediaQuery.of(context).size.width,
                      padding: EdgeInsets.symmetric(horizontal: 1, vertical: 3),
                      child: Row(
                        children: [
                          // Container(
                          //   width: 5,
                          //   child: Column(
                          //     children: [
                          //       Container(
                          //         height: 3,
                          //         width: 3,
                          //         decoration:
                          //             e.status == 'Deleted' ? BoxDecoration(color: Colors.red) : BoxDecoration(color: e.status == 'Unasigned' ? grey : green),
                          //       )
                          //     ],
                          //   ),
                          // ),
                          Container(
                            width: MediaQuery.of(context).size.width - 5,
                            child: Column(
                              children: [
                                CustomListTile(
                                  radius: 5,
                                  color: blue[100].withOpacity(.2),
                                  title: Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Container(
                                            width: MediaQuery.of(context).size.width - 40,
                                            child: Row(
                                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                              children: [
                                                CartItemRich(
                                                  lightFont: 'Pick Up -',
                                                  boldFont: '${e.placedOn.toDate().toString().substring(0, 16)}',
                                                ),
                                                Container(
                                                  height: 30,
                                                  width: 100,
                                                  decoration: BoxDecoration(color: containerColor, borderRadius: BorderRadius.all(Radius.circular(5))),
                                                  child: Center(
                                                    child: CustomText(
                                                      fontWeight: FontWeight.w600,
                                                      color: white,
                                                      size: 12,
                                                      text: e.status.toString().toUpperCase(),
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                          Container(
                                              width: MediaQuery.of(context).size.width - 40,
                                            child: CustomText(text: e.senderAddress, maxLines: 2,overflow: TextOverflow.ellipsis)),
                                          SizedBox(height: 10),
                                          CartItemRich(lightFont: 'OTP : ', boldFont: e.senderOtp.toString()),
                                          Divider(),
                                          SizedBox(height: 10),
                                          CartItemRich(
                                            lightFont: 'Delivery -',
                                            boldFont:
                                                '${DateTime.fromMillisecondsSinceEpoch(DateTime.now().millisecondsSinceEpoch + (double.parse(e.arrivalTime) ~/ 1000).toInt())}'
                                                    .toString()
                                                    .substring(0, 16),
                                          ),
                                          Container(
                                            width: MediaQuery.of(context).size.width - 40,
                                            child: Row(
                                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                              children: [
                                                Expanded(child: CustomText(text: e.recipientAddress, maxLines: 2)),
                                                GestureDetector(
                                                  onTap: () => changeScreen(context, PackageDetails(deliveryModel: e)),
                                                  child: Container(
                                                    height: 30,
                                                    width: 100,
                                                    decoration: BoxDecoration(color: containerColor, borderRadius: BorderRadius.all(Radius.circular(5))),
                                                    child: Center(
                                                      child: CustomText(
                                                        fontWeight: FontWeight.w600,
                                                        color: white,
                                                        size: 12,
                                                        text: 'View Order'.toUpperCase(),
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                          SizedBox(height: 10),
                                          CartItemRich(lightFont: 'OTP : ', boldFont: e.recipientOtp.toString()),
                                        ],
                                      ),
                                    ],
                                  ),
                                  // trailing:
                                )
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ),
              ));
  }

  void getAllDeliveries() async {
    setState(() {
      loading = true;
    });
    deliveries = await _courierServices.getDeliveries();
    setState(() {
      loading = false;
    });
    print(deliveries[0].earnings);
  }
}
