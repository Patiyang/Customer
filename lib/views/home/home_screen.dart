import 'dart:async';
import 'dart:io';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:my_cab/helpers&widgets/helpers/Language/appLocalizations.dart';
import 'package:my_cab/constance/constance.dart';
import 'package:my_cab/constance/themes.dart';
import 'package:my_cab/main.dart';
import 'package:my_cab/constance/global.dart' as globals;
import 'package:my_cab/views/drawer/drawer.dart';
// import 'package:my_cab/views/drawer/drawer.dart';
import 'package:my_cab/views/home/MapPinSelectionView.dart';
import 'package:my_cab/views/home/addressSelctionView.dart';
import 'package:my_cab/views/home/requset_view.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with SingleTickerProviderStateMixin {
  AnimationController animationController;

  GoogleMapController _mapController;
  final _londonLatLong = LatLng(51.505939, -0.088727);
  var _scaffoldKey = new GlobalKey<ScaffoldState>();

  bool isSerchMode = false;
  bool isUp = true;
  BitmapDescriptor carMapBitmapDescriptor;
  BitmapDescriptor startMapBitmapDescriptor;
  BitmapDescriptor endMapBitmapDescriptor;
  BuildContext currentcontext;
  TextEditingController serachController = TextEditingController();

  ProsseType prosseType = ProsseType.dropOff;

  int carOneIndex = 0, carTwoIndex = 0, carThreeIndex = 0, carFourIndex = 0, carFiveIndex = 0;
  List<LatLng> carPointOne = [], carPointTwo = [], carPointThree = [], carPointFour = [], carPointFive = [], poliList = [];

  void setMakerPinSize(BuildContext context) async {
    if (currentcontext == null) {
      currentcontext = context;
      final ImageConfiguration imagesStartConfiguration = createLocalImageConfiguration(currentcontext);
      carMapBitmapDescriptor = await BitmapDescriptor.fromAssetImage(imagesStartConfiguration, ConstanceData.mapCar);
      final ImageConfiguration startStartConfiguration = createLocalImageConfiguration(currentcontext);
      startMapBitmapDescriptor = await BitmapDescriptor.fromAssetImage(startStartConfiguration, ConstanceData.startmapPin);
      final ImageConfiguration endStartConfiguration = createLocalImageConfiguration(currentcontext);
      endMapBitmapDescriptor = await BitmapDescriptor.fromAssetImage(endStartConfiguration, ConstanceData.endmapPin);
    }
  }

  final _random = new math.Random();
  int next(int min, int max) => min + _random.nextInt(max - min);

  @override
  void initState() {
    serachController.text = AppLocalizations.of('105 William st, Chicago, US');
    animationController = new AnimationController(vsync: this, duration: Duration(milliseconds: 480));
    animationController..animateTo(1);
    super.initState();
    _carPinInitState();
  }

  void _carPinInitState() {
    carPointOne = ConstanceData.getCarOnePolyLineList();
    carPointTwo = ConstanceData.getCarTwoPolyLineList();
    carPointThree = ConstanceData.getCarThreePolyLineList();
    carPointFour = ConstanceData.getCarFourPolyLineList();
    // carPointFive = ConstanceData.getCarFivePolyLineList();
    poliList = ConstanceData.getRoutePolyLineList();
    Timer(Duration(milliseconds: next(1200, 4000)), carOnePin);
    Timer(Duration(milliseconds: next(1200, 4000)), carTwoPin);
    Timer(Duration(milliseconds: next(1200, 4000)), carThreePin);
    Timer(Duration(milliseconds: next(1200, 4000)), carFourPin);
    // Timer(Duration(milliseconds: next(1200, 4000)), carFivePin);
  }

  Future carOnePin() async {
    if (carOneIndex + 1 < carPointOne.length) {
      carOneIndex += 1;
    } else {
      carOneIndex = 0;
    }
    if (mounted) setState(() {});
    Timer(Duration(milliseconds: next(1200, 4000)), carOnePin);
  }

  Future carTwoPin() async {
    if (carTwoIndex + 1 < carPointTwo.length) {
      carTwoIndex += 1;
    } else {
      carTwoIndex = 0;
    }
    if (mounted) setState(() {});
    Timer(Duration(milliseconds: next(1200, 4000)), carTwoPin);
  }

  Future carThreePin() async {
    if (carThreeIndex + 1 < carPointThree.length) {
      carThreeIndex += 1;
    } else {
      carThreeIndex = 0;
    }
    if (mounted) setState(() {});
    Timer(Duration(milliseconds: next(1200, 4000)), carThreePin);
  }

  Future carFourPin() async {
    if (carFourIndex + 1 < carPointFour.length) {
      carFourIndex += 1;
    } else {
      carFourIndex = 0;
    }
    if (mounted) setState(() {});
    Timer(Duration(milliseconds: next(1200, 4000)), carFourPin);
  }

  // Future carFivePin() async {
  //   if (carFiveIndex + 1 < carPointFive.length) {
  //     carFiveIndex += 1;
  //   } else {
  //     carFiveIndex = 0;
  //   }
  //   if (mounted) setState(() {});
  //   Timer(Duration(milliseconds: next(1200, 4000)), carFivePin);
  // }

  Map<MarkerId, Marker> getMarkerList(BuildContext context) {
    Map<MarkerId, Marker> markers = <MarkerId, Marker>{};
    if (carMapBitmapDescriptor != null) {
      for (var i = 0; i < 4; i++) {
        LatLng startPoint = i == 0
            ? carPointOne[carOneIndex]
            : i == 1 ? carPointTwo[carTwoIndex] : i == 2 ? carPointThree[carThreeIndex] : carPointFour[carFourIndex];
        LatLng lastPoint = i == 0
            ? carPointOne[carOneIndex - 1 == -1 ? carPointOne.length - 1 : carOneIndex - 1]
            : i == 1
                ? carPointTwo[carTwoIndex - 1 == -1 ? carPointTwo.length - 1 : carTwoIndex - 1]
                : i == 2
                    ? carPointThree[carThreeIndex - 1 == -1 ? carPointThree.length - 1 : carThreeIndex - 1]
                    : carPointFour[carFourIndex - 1 == -1 ? carPointFour.length - 1 : carFourIndex - 1];

        final MarkerId markerId2 = MarkerId('$i');
        final Marker marker2 = Marker(
            markerId: markerId2,
            position: startPoint,
            anchor: Offset(0.5, 0.5),
            icon: carMapBitmapDescriptor,
            rotation: ConstanceData.getCarAngle(startPoint, lastPoint));
        markers.addAll({markerId2: marker2});
      }
    }

    if (startMapBitmapDescriptor != null && endMapBitmapDescriptor != null && prosseType == ProsseType.requset) {
      final MarkerId markerId2 = MarkerId('start');
      final Marker marker2 = Marker(
        markerId: markerId2,
        position: poliList.first,
        anchor: Offset(0.5, 0.5),
        icon: startMapBitmapDescriptor,
      );
      markers.addAll({markerId2: marker2});

      final MarkerId markerId = MarkerId('end');
      final Marker marker = Marker(
        markerId: markerId,
        position: poliList.last,
        anchor: Offset(0.5, 1.0),
        icon: endMapBitmapDescriptor,
      );
      markers.addAll({markerId: marker});
    }

    return markers;
  }

  Map<PolylineId, Polyline> getPolilineData() {
    Map<PolylineId, Polyline> _polylines = <PolylineId, Polyline>{};
    if (poliList.length > 2 && prosseType == ProsseType.requset) {
      final PolylineId polylineId = PolylineId('123');
      final Polyline polyline = Polyline(
        polylineId: polylineId,
        color: HexColor(globals.primaryRiderColorString),
        consumeTapEvents: false,
        points: poliList,
        width: Platform.isAndroid ? 4 : 2,
        startCap: Cap.roundCap,
        endCap: Cap.roundCap,
      );
      _polylines.addAll({polylineId: polyline});
    }
    return _polylines;
  }

  @override
  Widget build(BuildContext context) {
    setMakerPinSize(context);
    // polylineList.clear();
    // _carPinInitState();
    return Scaffold(
      key: _scaffoldKey,
      drawer: SizedBox(
        width: MediaQuery.of(context).size.width * 0.75 < 400 ? MediaQuery.of(context).size.width * 0.72 : 350,
        child: Drawer(
          child: AppDrawer(
            selectItemName: 'Home',
          ),
        ),
      ),
      body: Stack(
        children: <Widget>[
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: MediaQuery.of(context).size.height,
            child: GoogleMap(
              initialCameraPosition: CameraPosition(
                target: _londonLatLong,
                tilt: 30.0,
                zoom: 16,
              ),
              onCameraMoveStarted: () {
                // if (clipOvalController.status == AnimationStatus.completed) {
                //   clipOvalController.reverse();
                // }
              },

              // mapType: mapIndex.index != 2 ? MapType.normal : MapType.hybrid,
              mapType: MapType.normal,
              // mapType: ConstanceData.isLowSpecMobile() ? MapType.terrain : MapType.normal,
              markers: Set<Marker>.of(getMarkerList(context).values),
              onCameraMove: (CameraPosition position) {
                // print(position.zoom);
                // liveZoomLevel = position.zoom;
                // if (position.target != null) {
                //   mapCenterlocation = GeoPoint(
                //     position.target.latitude,
                //     position.target.longitude,
                //   );
                //   _mapIdleSubscription?.cancel();
                //   _mapIdleSubscription = Future.delayed(Duration(milliseconds: 1000)).asStream().listen((_) {
                //     riderTripsBloc.setCameraIdle(LatLng(mapCenterlocation.latitude, mapCenterlocation.longitude));
                //   });
                //   if (mapCenterlocation != null && mapCenterlocation.latitude != null && mapCenterlocation.longitude != null) {
                //     riderTripsBloc.setMapCenterLatlong(LatLng(mapCenterlocation.latitude, mapCenterlocation.longitude), context);
                //   }
                // }
              },
              polylines: Set<Polyline>.of(getPolilineData().values),
              onCameraIdle: () {},
              compassEnabled: false,
              myLocationButtonEnabled: false,
              rotateGesturesEnabled: false,
              tiltGesturesEnabled: false,
              myLocationEnabled: false,
              buildingsEnabled: false,
              onMapCreated: (GoogleMapController controller) async {
                _mapController = controller;
                setMapStyle();
              },
            ),
          ),
          prosseType != ProsseType.mapPin && prosseType != ProsseType.requset ? _getAppBarUI() : SizedBox(),
          prosseType == ProsseType.dropOff
              ? AddressSelctionView(
                  animationController: animationController,
                  isSerchMode: isSerchMode,
                  isUp: isUp,
                  mapCallBack: () {
                    animationController.animateTo(1, duration: Duration(milliseconds: 480)).then((f) {
                      setState(() {
                        prosseType = ProsseType.mapPin;
                      });
                    });
                  },
                  onSerchMode: (onSerchMode) {
                    if (isSerchMode != onSerchMode) {
                      setState(() {
                        isSerchMode = onSerchMode;
                      });
                    }
                  },
                  onUp: (onUp) {
                    if (isUp != onUp) {
                      setState(() {
                        isUp = onUp;
                      });
                    }
                  },
                  serachController: serachController,
                  gpsClick: () {
                    if (_mapController != null) {
                      _mapController.animateCamera(
                        CameraUpdate.newCameraPosition(
                          CameraPosition(
                            target: _londonLatLong,
                            zoom: 16.0,
                            tilt: 24.0,
                          ),
                        ),
                      );
                    }
                    MyApp.changeTheme(context);
                    setMapStyle();
                  },
                )
              : prosseType == ProsseType.mapPin
                  ? MapPinSelectionView(
                      barText: AppLocalizations.of('105 William st, Chicago, US'),
                      onBackClick: () {
                        setState(() {
                          prosseType = ProsseType.dropOff;
                        });
                      },
                      gpsClick: () {
                        if (_mapController != null) {
                          _mapController.animateCamera(
                            CameraUpdate.newCameraPosition(
                              CameraPosition(
                                target: _londonLatLong,
                                zoom: 16.0,
                                tilt: 24.0,
                              ),
                            ),
                          );
                        }
                        MyApp.changeTheme(context);
                        setMapStyle();
                      },
                      callback: () {
                        setState(() {
                          prosseType = ProsseType.requset;
                        });
                      },
                    )
                  : RequsetView(
                      onBack: () {
                        setState(() {
                          prosseType = ProsseType.dropOff;
                        });
                      },
                    )
        ],
      ),
    );
  }

  Widget _getAppBarUI() {
    return Column(
      children: <Widget>[
        Padding(
          padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top, left: 8, right: 8),
          child: Row(
            children: <Widget>[
              SizedBox(
                height: AppBar().preferredSize.height,
                width: AppBar().preferredSize.height,
                child: Padding(
                  padding: const EdgeInsets.all(4.0),
                  child: Card(
                    margin: EdgeInsets.all(0),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(32.0),
                    ),
                    child: Container(
                      color: Theme.of(context).cardColor,
                      padding: EdgeInsets.all(2),
                      child: InkWell(
                        onTap: () {
                          _scaffoldKey.currentState.openDrawer();
                        },
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(32.0),
                          child: Image.asset(ConstanceData.userImage),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  void setMapStyle() async {
    if (_mapController != null) {
      if (globals.isLight)
        _mapController.setMapStyle(await DefaultAssetBundle.of(context).loadString("assets/jsonFile/light_mapstyle.json"));
      else
        _mapController.setMapStyle(await DefaultAssetBundle.of(context).loadString("assets/jsonFile/dark_mapstyle.json"));
    }
  }
}

enum ProsseType {
  dropOff,
  mapPin,
  requset,
}
