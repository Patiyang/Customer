import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_page_indicator/flutter_page_indicator.dart';
import 'package:my_cab/constance/constance.dart';
import 'package:my_cab/constance/global.dart';
import 'package:my_cab/constance/sharedPreferences.dart';
import 'package:my_cab/helpers&widgets/helpers/Language/appLocalizations.dart';
import 'package:my_cab/views/auth/login_screen.dart';
import 'package:my_cab/views/splash/nice_introduction_screen.dart';

class IntroductionScreen extends StatefulWidget {
  @override
  _IntroductionScreenState createState() => _IntroductionScreenState();
}

class _IntroductionScreenState extends State<IntroductionScreen> {
  var pageController = PageController(initialPage: 0);
  var pageViewModelData = List<PageViewData>();
  MySharedPreferences mySharedPreferences = new MySharedPreferences();
  Timer sliderTimer;
  var currentShowIndex = 0;
  bool loading = false;
  bool firstTime = false;
  @override
  void initState() {
    print(firstTime);
    checkFirstTime();
    pageViewModelData.add(PageViewData(
      titleText: AppLocalizations.of('Confirm your Rider'),
      subText: AppLocalizations.of('Our huge riders network guarantees your package delivery is swift and safe'),
      assetsImage: ConstanceData.confirmRider,
    ));

    pageViewModelData.add(PageViewData(
      titleText: AppLocalizations.of('Book a Courier Service'),
      subText: AppLocalizations.of('Be it our sprinters , or movers or carriers or towing van! We are a click away.'),
      assetsImage: ConstanceData.bookRider,
    ));

    pageViewModelData.add(PageViewData(
      titleText: AppLocalizations.of('Track your package'),
      subText: AppLocalizations.of('View real-time your package location ON-THE-GO.'),
      assetsImage: ConstanceData.trackPackage,
    ));

    sliderTimer = Timer.periodic(Duration(seconds: 4), (timer) {
      if (currentShowIndex == 1) {
        pageController.animateTo(MediaQuery.of(context).size.width, duration: Duration(seconds: 1), curve: Curves.fastOutSlowIn);
      } else if (currentShowIndex == 1) {
        pageController.animateTo(MediaQuery.of(context).size.width * 2, duration: Duration(seconds: 1), curve: Curves.fastOutSlowIn);
      } else if (currentShowIndex == 2) {
        pageController.animateTo(0, duration: Duration(seconds: 1), curve: Curves.fastOutSlowIn);
      }
    });
    super.initState();
  }

  @override
  void dispose() {
    sliderTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return firstTime == false
        ? Container(
            child: Scaffold(
              backgroundColor: Theme.of(context).scaffoldBackgroundColor,
              body: Column(
                children: <Widget>[
                  SizedBox(
                    height: MediaQuery.of(context).padding.top,
                  ),
                  Expanded(
                    child: PageView(
                      controller: pageController,
                      pageSnapping: true,
                      onPageChanged: (index) {
                        currentShowIndex = index;
                      },
                      scrollDirection: Axis.horizontal,
                      children: <Widget>[
                        PagePopup(imageData: pageViewModelData[0]),
                        PagePopup(imageData: pageViewModelData[1]),
                        PagePopup(imageData: pageViewModelData[2]),
                      ],
                    ),
                  ),
                  PageIndicator(
                    layout: PageIndicatorLayout.WARM,
                    size: 10.0,
                    controller: pageController,
                    space: 5.0,
                    count: 3,
                    color: Theme.of(context).dividerColor,
                    activeColor: Colors.black,
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 48, right: 48, bottom: 8, top: 32),
                    child: Container(
                      height: 48,
                      decoration: BoxDecoration(
                        color: Colors.black,
                        borderRadius: BorderRadius.all(Radius.circular(24.0)),
                        boxShadow: <BoxShadow>[
                          BoxShadow(
                            color: Theme.of(context).dividerColor,
                            blurRadius: 8,
                            offset: Offset(4, 4),
                          ),
                        ],
                      ),
                      child: Material(
                        borderRadius: BorderRadius.all(Radius.circular(24.0)) ,
                        color: blue,
                        child: InkWell(
                          borderRadius: BorderRadius.all(Radius.circular(24.0)),
                          highlightColor: Colors.transparent,
                          onTap: () async {
                            await mySharedPreferences.setIsFirstTime(true);
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => NiceIntroductionScreen()),
                            );
                          },
                          child: Center(
                            child: Text(
                              AppLocalizations.of('GET STARTED!'),
                              style: Theme.of(context).textTheme.subhead.copyWith(color: Colors.white, fontWeight: FontWeight.bold),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(
                    height: 16 + MediaQuery.of(context).padding.bottom,
                  )
                ],
              ),
            ),
          )
        : LoginScreen();
  }

  checkFirstTime() async {
    setState(() {
      loading = true;
    });
    firstTime = await mySharedPreferences.getIsFirstTime();
    setState(() {
      loading = false;
    });
  }
}

class PagePopup extends StatelessWidget {
  final PageViewData imageData;

  const PagePopup({Key key, this.imageData}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 14, left: 14),
      child: Column(mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Center(
            child: Container(
              width: MediaQuery.of(context).size.width - 120,
              child: Image.asset(
                imageData.assetsImage,
                fit: BoxFit.contain,
                height: 200,width: 200,
              ),
            ),
          ),
          Column(
            children: <Widget>[
              Text(
                imageData.titleText,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.headline.copyWith(fontWeight: FontWeight.bold,letterSpacing: .4),
              ),
              SizedBox(
                height: 16,
              ),
              Text(
                imageData.subText,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.subhead.copyWith(fontSize: 22,letterSpacing: .3),
                
              )
            ],
          ),
          Flexible(
            flex: 1,
            child: SizedBox(),
          ),
        ],
      ),
    );
  }
}

class PageViewData {
  final String titleText;
  final String subText;
  final String assetsImage;
  final double textSize;

  PageViewData( {this.textSize,this.titleText, this.subText, this.assetsImage});
}



