import 'package:flutter/material.dart';
import 'package:my_cab/constance/global.dart';
import 'package:my_cab/helpers&widgets/widgets/customText.dart';

import 'orderPlacement/senderDetails.dart';
import 'packageTracking/packageTracking.dart';

class CourierMain extends StatefulWidget {
  final String title;
  final int selectedIndex;
  const CourierMain({Key key, this.title, this.selectedIndex}) : super(key: key);
  @override
  _CourierMainState createState() => _CourierMainState();
}

class _CourierMainState extends State<CourierMain> with SingleTickerProviderStateMixin {
  TabController _controller;
  int _selectedIndex;
  List<Widget> list = [Tab(text: 'SHIPMENT DETAILS', icon: Icon(Icons.local_shipping)), Tab(text: 'DELIVERIES', icon: Icon(Icons.timer))];
  void initState() {
    checkIndex();

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: CustomText(text: _selectedIndex == 0 ? 'SHIPMENT DETAILS' : 'DELIVERIES', color: white, fontWeight: FontWeight.bold),
        bottom: TabBar(onTap: (index) {}, controller: _controller, tabs: list),
      ),
      body: TabBarView(
        children: [
          SenderDetails(),
          OrderTracking(),
        ],
        controller: _controller,
      ),
    );
  }

  void checkIndex() {
    setState(() {
      _selectedIndex = widget.selectedIndex ?? 0;
    });
    _controller = TabController(length: list.length, vsync: this, initialIndex: _selectedIndex);
    _controller.addListener(() {
      setState(() {
        _selectedIndex = _controller.index;
      });
      print("Selected Index: " + _controller.index.toString());
    });
  }
}
