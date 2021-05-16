import 'package:flutter/material.dart';
import 'package:my_cab/constance/constance.dart';
import 'package:my_cab/constance/global.dart';
import 'package:my_cab/helpers&widgets/helpers/routing.dart';
import 'package:my_cab/helpers&widgets/widgets/customText.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:my_cab/views/servicesAvailable/courierScreens/courierMainScreen.dart';
import 'package:my_cab/views/servicesAvailable/foodScreens/foodMainScreen.dart';
import 'package:my_cab/views/servicesAvailable/groceryScreens/groceryMainScreen.dart';
import 'package:my_cab/views/servicesAvailable/laundryScreen/laundryMainScreen.dart';
import 'package:my_cab/views/servicesAvailable/pharmacyScreen/pharmacyMainScreen.dart';
import 'package:my_cab/views/servicesAvailable/towingScreens/towingMainScreen.dart';
import 'package:my_cab/views/servicesAvailable/utilityBills/utilityBillsMainScreen.dart';
import 'package:my_cab/views/servicesAvailable/wineScreens/wineMainScreen.dart';

class HomePagePrimary extends StatefulWidget {
  @override
  _HomePagePrimaryState createState() => _HomePagePrimaryState();
}

class _HomePagePrimaryState extends State<HomePagePrimary> {
  final key = GlobalKey<ScaffoldState>();
  int curentIndex = 0;
  List items = [ConstanceData.sliderDual, ConstanceData.sliderPerson, ConstanceData.sliderVan];
  @override
  Widget build(BuildContext context) {
    List<ServiceIcons> serviceImages = [
      ServiceIcons(ConstanceData.courierBike, 'Courier', () => changeScreen(context, CourierMain())),
      ServiceIcons(ConstanceData.towing, 'Towing', () => changeScreen(context, TowingMain())),
      ServiceIcons(ConstanceData.groceries, 'Groceries', () => changeScreen(context, GroceryMain())),
      ServiceIcons(ConstanceData.food, 'Food', () => changeScreen(context, FoodMain())),
      ServiceIcons(ConstanceData.pharmacy, 'Pharmacy', () => changeScreen(context, PharmacyMain())),
      ServiceIcons(ConstanceData.laundry, 'Laundry', () => changeScreen(context, LaundryMain())),
      ServiceIcons(ConstanceData.utilities, 'Utility bills', () => changeScreen(context, UtilityBillsMain())),
      ServiceIcons(ConstanceData.wine, 'Wines & Spirits', () => changeScreen(context, WineMain())),
    ];
    return Container(
      height: MediaQuery.of(context).size.height,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Container(
            decoration: BoxDecoration(
              color: Color(0xff2581c8),

              // gradient: LinearGradient(
              //   begin: Alignment.bottomLeft,
              //   end: Alignment.topRight,
              //   colors: [blue.withOpacity(.7),darkBLue],
              // ),
            ),
            alignment: Alignment.topCenter,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [Spacer(), Image.asset(ConstanceData.topRight, height: 130)],
            ),
          ),
          Container(
            width: MediaQuery.of(context).size.width,
            alignment: Alignment.center,
            child: Column(
              children: [
                // SizedBox(height: 10),
                Container(
                  decoration: BoxDecoration(
                    color: Colors.transparent,
                    borderRadius: BorderRadius.all(Radius.circular(9)),
                  ),
                  child: Stack(
                    alignment: Alignment.bottomCenter,
                    children: [
                      CarouselSlider(
                          items: items
                              .map((e) => ClipRRect(
                                  borderRadius: BorderRadius.all(Radius.circular(1)),
                                  child: Container(
                                      width: double.infinity,
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.all(Radius.circular(20)),
                                        color: Colors.white,
                                      ),
                                      child: Image.asset(
                                        e,
                                        fit: BoxFit.cover,
                                      ))))
                              .toList(),
                          options: CarouselOptions(
                            autoPlay: true,
                            viewportFraction: 1.0,
                            //enlargeCenterPage: true,

                            aspectRatio: 2.0,
                            onPageChanged: (index, ctx) {
                              setState(() {
                                curentIndex = index;
                              });
                            },
                            scrollDirection: Axis.horizontal,
                          )),
                      Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: items.map((e) {
                            int index = items.indexOf(e);
                            return Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 5.0),
                              child: Container(
                                width: 8.0,
                                height: 8.0,
                                // margin: EdgeInsets.symmetric(vertical: 10.0, horizontal: 2.0),
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: curentIndex == index ? Colors.grey : Colors.black,
                                ),
                              ),
                            );
                          }).toList())
                    ],
                  ),
                ),

                Expanded(
                  child: GridView(
                    padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 10),
                    gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
                      maxCrossAxisExtent: 200,
                      childAspectRatio: 0.9,
                      crossAxisSpacing: 10,
                      mainAxisSpacing: 15,
                    ),
                    children: serviceImages
                        .map((e) => Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 4),
                              child: InkWell(
                                onTap: e.callback,
                                child: Card(
                                  color: lighterBLue,
                                  elevation: 4,
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(9))),
                                  child: Column(
                                    children: [
                                      Image.asset(
                                        e.image,
                                        color: white,
                                      ),
                                      FittedBox(
                                          fit: BoxFit.contain,
                                          child: CustomText(
                                            text: e.serviceName,
                                            color: white,
                                          )),
                                    ],
                                  ),
                                ),
                              ),
                            ))
                        .toList(),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class ServiceIcons {
  final String image;
  final String serviceName;
  final VoidCallback callback;

  ServiceIcons(this.image, this.serviceName, this.callback);
}
