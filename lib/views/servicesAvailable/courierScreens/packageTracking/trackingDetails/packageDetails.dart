import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:my_cab/constance/global.dart';
import 'package:my_cab/models/deliveryModel.dart';
import 'package:my_cab/views/servicesAvailable/courierScreens/packageTracking/trackingDetails/pickUp.dart';

import 'package:persistent_bottom_nav_bar/persistent-tab-view.dart';

import 'delivery.dart';

class PackageDetails extends StatefulWidget {
  final DeliveryModel deliveryModel;

  const PackageDetails({Key key, this.deliveryModel}) : super(key: key);
  @override
  _PackageDetailsState createState() => _PackageDetailsState();
}

class _PackageDetailsState extends State<PackageDetails> {
  PersistentTabController _controller;

  @override
  Widget build(BuildContext context) {
    _controller = PersistentTabController(initialIndex: 0);

    return Scaffold(
      body: SafeArea(
        child: PersistentTabView(
          context,
          controller: _controller,
          screens: _buildScreens(),
          items: _navBarsItems(),
          confineInSafeArea: true,
          backgroundColor: Colors.white, // Default is Colors.white.
          handleAndroidBackButtonPress: true, // Default is true.
          resizeToAvoidBottomInset: true, // This needs to be true if you want to move up the screen when keyboard appears. Default is true.
          stateManagement: true, // Default is true.
          hideNavigationBarWhenKeyboardShows: true, // Recommended to set 'resizeToAvoidBottomInset' as true while using this argument. Default is true.
          decoration: NavBarDecoration(
            borderRadius: BorderRadius.circular(10.0),
            colorBehindNavBar: Theme.of(context).scaffoldBackgroundColor,
          ),
          popAllScreensOnTapOfSelectedTab: true,
          popActionScreens: PopActionScreensType.all,
          itemAnimationProperties: ItemAnimationProperties(
            // Navigation Bar's items animation properties.
            duration: Duration(milliseconds: 200),
            curve: Curves.bounceIn,
          ),
          screenTransitionAnimation: ScreenTransitionAnimation(
            // Screen transition animation on change of selected tab.
            animateTabTransition: true,
            curve: Curves.ease,
            duration: Duration(milliseconds: 200),
          ),
          navBarStyle: NavBarStyle.style1,
        ),
      ),
    );
  }

  List<Widget> _buildScreens() {
    return [
      PickUp(deliveryModel: widget.deliveryModel),
      Delivery(deliveryModel: widget.deliveryModel),
    ];
  }

  List<PersistentBottomNavBarItem> _navBarsItems() {
    return [
      PersistentBottomNavBarItem(
        icon: Icon(Icons.delivery_dining),
        title: ("Pick Up"),
        activeColorPrimary: blue,
        inactiveColorPrimary: grey,
      ),
      PersistentBottomNavBarItem(
        icon: Icon(Icons.local_shipping),
        title: ("Deliveries"),
        activeColorPrimary: CupertinoColors.activeBlue,
        inactiveColorPrimary: CupertinoColors.systemGrey,
      ),
    ];
  }
}
