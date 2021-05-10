import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:my_cab/constance/constance.dart';
import 'package:my_cab/constance/global.dart';
import 'package:my_cab/constance/themes.dart';
import 'package:my_cab/helpers&widgets/helpers/Language/appLocalizations.dart';
import 'package:my_cab/helpers&widgets/helpers/routing.dart';
import 'package:my_cab/helpers&widgets/widgets/customText.dart';
import 'package:my_cab/helpers&widgets/widgets/loading.dart';
import 'package:my_cab/models/historyModel.dart';
import 'package:my_cab/services/notificationServices.dart';
import 'package:my_cab/views/history/historyDetails.dart';
import 'package:my_cab/views/rating/rating_screen.dart';
import 'package:my_cab/views/widgets/cardWidget.dart';

class HistoryScreen extends StatefulWidget {
  @override
  _HistoryScreenState createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  List<HistoryModel> historyItems = [];
  NotificationServices _notificationServices = new NotificationServices();
  RegExp reg = new RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))');
  Function mathFunc = (Match match) => '${match[1]},';
  bool loading = false;
  @override
  void initState() {
    getHistoryItems();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: Stack(
        children: <Widget>[
          Container(
            height: MediaQuery.of(context).size.height / 3.5,
            color: Theme.of(context).primaryColor,
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              SizedBox(
                height: MediaQuery.of(context).padding.top + 16,
              ),
              Padding(
                padding: EdgeInsets.only(right: 14, left: 14),
                child: GestureDetector(
                  onTap: () {
                    Navigator.pop(context);
                  },
                  child: Icon(
                    Icons.arrow_back_ios,
                    color: Colors.white,
                  ),
                ),
              ),
              SizedBox(
                height: 16,
              ),
              Padding(
                padding: EdgeInsets.only(right: 14, left: 14, bottom: 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Text(
                      AppLocalizations.of('History'),
                      style: Theme.of(context).textTheme.headline.copyWith(
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                    ),
                    // ClipRect(
                    //   child: BackdropFilter(
                    //     filter: new ImageFilter.blur(sigmaX: 10.0, sigmaY: 10.0),
                    //     child: Container(
                    //       decoration: new BoxDecoration(
                    //         color: Colors.grey.shade200.withOpacity(0.5),
                    //         borderRadius: BorderRadius.all(
                    //           Radius.circular(20),
                    //         ),
                    //       ),
                    //       child: Padding(
                    //         padding: const EdgeInsets.all(4),
                    //         child: Row(
                    //           children: <Widget>[
                    //             Padding(
                    //               padding: const EdgeInsets.only(left: 2),
                    //               child: Text(
                    //                 AppLocalizations.of('Oct 15,2020'),
                    //                 style: Theme.of(context).textTheme.subtitle.copyWith(
                    //                       color: Colors.white,
                    //                     ),
                    //               ),
                    //             ),
                    //             SizedBox(
                    //               width: 8,
                    //             ),
                    //             Icon(
                    //               Icons.keyboard_arrow_down,
                    //               color: Colors.white,
                    //             )
                    //           ],
                    //         ),
                    //       ),
                    //     ),
                    //   ),
                    // ),
                  ],
                ),
              ),
              Expanded(
                child: historyItems.length == 0
                    ? Center(
                        child: loading == true
                            ? Loading(color: white, text: 'Fetching your records')
                            : Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  ClipRRect(
                                    borderRadius: BorderRadius.all(Radius.circular(10)),
                                    child: Image.asset(
                                      ConstanceData.noData,
                                      height: 180,
                                      width: 180,
                                      fit: BoxFit.cover,
                                    ),
                                  )
                                ],
                              ),
                      )
                    : Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 18.0),
                        child: RefreshIndicator(
                          onRefresh: () async {
                            getHistoryItems();
                            Fluttertoast.showToast(msg: 'Your history list has been updated');
                          },
                          child: ListView(
                              children: historyItems
                                  .map(
                                    (e) => Padding(
                                      padding: const EdgeInsets.symmetric(vertical: 4.0),
                                      child: CardWidget(
                                        fromAddress: AppLocalizations.of(e.pickUpLocation),
                                        toAddress: AppLocalizations.of(e.dropOffLocation),
                                        price: "${e.earnings.ceilToDouble()}0".replaceAllMapped(reg, mathFunc),
                                        status: AppLocalizations.of('View'),
                                        statusColor: HexColor("#3638FE"),
                                        callback: () => changeScreen(context, HistoryDetails(serviceId: e.id)),
                                      ),
                                    ),
                                  )
                                  .toList()),
                        ),
                      ),
              )
            ],
          ),
        ],
      ),
    );
  }

  gotorating() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => RatingScreen(),
      ),
    );
  }

  getHistoryItems() async {
    setState(() {
      loading = true;
    });
    historyItems = await _notificationServices.getNotifications();
    setState(() {
      loading = false;
    });
    print(historyItems.length);
  }
}
