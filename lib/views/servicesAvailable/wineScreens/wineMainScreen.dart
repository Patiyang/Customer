import 'package:flutter/material.dart';
import 'package:my_cab/constance/constance.dart';
import 'package:my_cab/constance/global.dart';
import 'package:my_cab/helpers&widgets/widgets/customText.dart';

class WineMain extends StatefulWidget {
  @override
  _WineMainState createState() => _WineMainState();
}

class _WineMainState extends State<WineMain> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.bottomLeft,
                end: Alignment.topRight,
                colors: [blue.withOpacity(.2), white.withOpacity(.2)],
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset(ConstanceData.logo, height: 100, width: 300, fit: BoxFit.contain),
                Image.asset(ConstanceData.mainLogo, height: 100, width: 100, fit: BoxFit.fill),
                SizedBox(height: 10),
                CircleAvatar(
                  backgroundImage: AssetImage(ConstanceData.wineService),
                  radius: 70,
                ),
                SizedBox(height: 10),
                Image.asset(ConstanceData.comingSoonService, fit: BoxFit.cover, height: 170, width: MediaQuery.of(context).size.width),
                SizedBox(height: 60),
                CustomText(
                    text: 'Armotale Wines will be launching in your area soon. We\'ve got you covered...',
                    textAlign: TextAlign.center,
                    size: 20,
                    letterSpacing: .2,
                    maxLines: 3,
                    fontWeight: FontWeight.w600),
              ],
            ),
          ),
        ],
      ),
    );
  }
}