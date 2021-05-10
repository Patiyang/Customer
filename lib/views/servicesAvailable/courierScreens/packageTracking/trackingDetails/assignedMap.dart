import 'dart:async';
// import 'dart:ui';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:my_cab/constance/constance.dart';
import 'package:my_cab/constance/global.dart';
import 'package:my_cab/helpers&widgets/widgets/loading.dart';
import 'package:my_cab/models/deliveryModel.dart';
import 'package:my_cab/models/utils.dart';
import 'package:my_cab/services/courierServices.dart';
import 'package:uuid/uuid.dart';

class DeliveryMap extends StatefulWidget {
  final String serviceId;
  // final GeoPoint senderLocation;
  // final GeoPoint recipientLocation;
  // final DeliveryModel deliveryModel;
  const DeliveryMap({
    Key key,
    this.serviceId,
    // this.recipientLocation,
    // this.deliveryModel,
  }) : super(key: key);
  @override
  _DeliveryMapState createState() => _DeliveryMapState();
}

class _DeliveryMapState extends State<DeliveryMap> {
  GeolocatorPlatform geolocatorPlatform = GeolocatorPlatform.instance;
  CourierServices courierServices = new CourierServices();
  GeocodingPlatform geocodingPlatform;
  CameraPosition cameraPosition;
  LatLng currentPosition;
  LatLng lastPosition;
  double cameraZoom = 10;
  bool loading = false;
  List<Marker> markerList = [];
  DeliveryModel deliveryModel;
  Map<PolylineId, Polyline> polylines = {};
  Completer<GoogleMapController> mapsController = Completer();
  GoogleMapController mapcontroller;
  PolylinePoints polylinePoints = PolylinePoints();
  List<LatLng> polylineCoordinates = [];
  FirebaseAuth auth = FirebaseAuth.instance;
  // double _originLatitude = -2.4219983, _originLongitude = 38.084;
  BitmapDescriptor currentLocationIcon;
  BitmapDescriptor locationIndicatorIcon;
  BitmapDescriptor courierIndicatorIcon;
  String driverId = '';
  BuildContext currentContext;
  @override
  void initState() {
    super.initState();
    singleService();
    // _getUPickUpLocation();
  }

  @override
  Widget build(BuildContext context) {
    getLocationIcons(context);
    return Scaffold(
      body: Stack(
        alignment: Alignment.topRight,
        children: [
          mapsScreen(),
          Padding(
            padding: const EdgeInsets.only(bottom: 23.0, right: 10),
            child: Align(alignment: Alignment.bottomRight, child: zoomButtons()),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 43.0, right: 10),
            child: Align(
              alignment: Alignment.topRight,
              child: GestureDetector(
                onTap: () {
                  cameraZoom++;
                  _getUserLocation();
                },
                child: Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: white,
                    boxShadow: [BoxShadow(color: Colors.grey[300], blurRadius: 2, spreadRadius: 1, offset: Offset(2, 3))],
                  ),
                  padding: EdgeInsets.all(4),
                  child: Icon(
                    Icons.my_location_rounded,
                    // color: white,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
      // bottomNavigationBar: ,
    );
  }

  Widget zoomButtons() {
    return Container(
      height: 80,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          GestureDetector(
            onTap: () {
              cameraZoom++;
              zoomIn(cameraZoom);
            },
            child: Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: white,
                boxShadow: [BoxShadow(color: Colors.grey[300], blurRadius: 2, spreadRadius: 1, offset: Offset(2, 3))],
              ),
              padding: EdgeInsets.all(4),
              child: Icon(
                Icons.add,
                // color: white,
              ),
            ),
          ),
          GestureDetector(
            onTap: () {
              cameraZoom--;
              zoomOut(cameraZoom);
            },
            child: Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: white,
                boxShadow: [BoxShadow(color: Colors.grey[300], blurRadius: 2, spreadRadius: 1, offset: Offset(1, 1))],
              ),
              padding: EdgeInsets.all(4),
              child: Icon(Icons.remove),
            ),
          ),
        ],
      ),
    );
  }

  Widget mapsScreen() {
    return StreamBuilder(
      stream: _getUPickUpLocation().asStream(),
      builder: (BuildContext context, AsyncSnapshot snapshot) {
        cameraPosition = snapshot.data;
        // print(snapshot.connectionState);
        if (snapshot.hasData) {
          return Container(
            height: MediaQuery.of(context).size.height,
            width: MediaQuery.of(context).size.width,
            child: GoogleMap(
              tiltGesturesEnabled: false,
              compassEnabled: false,
              zoomControlsEnabled: false,
              mapToolbarEnabled: false,
              onMapCreated: (GoogleMapController controller) async {
                controller.setMapStyle(Utils.mapStyles);
                mapsController.complete(controller);
              },
              // onCameraMoveStarted: ,
              markers: Set.from(markerList),
              myLocationEnabled: true,
              myLocationButtonEnabled: false,
              trafficEnabled: false,
              mapType: MapType.normal,
              initialCameraPosition: cameraPosition,
              onCameraMove: onCameraMove,
              polylines: Set<Polyline>.of(polylines.values),
            ),
          );
        }
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Loading(
            text: 'Please wait..preparing your location data',
            size: 14,
            // color: primaryColor.withOpacity(.4),
            textColor: grey[900],
            fontWeight: FontWeight.w700,
          );
        }
        // if (snapshot.hasError) {
        //   return Center(
        //     child: CustomText(
        //       text: 'Failed to load location data',
        //       textAlign: TextAlign.center,
        //     ),
        //   );
        // }
        return Container();
      },
    );
  }

  Future<CameraPosition> _getUPickUpLocation() async {
    driverId = auth.currentUser.uid;
    var position = await GeolocatorPlatform.instance.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
    await courierServices.listenToSingleService(deliveryModel.serviceId).then((value) {
      _getPolyline(value.courierLocation.latitude, value.courierLocation.longitude);
      markerList.remove(MarkerId(driverId));
      markerList.add(Marker(
        markerId: MarkerId(driverId),
        position: LatLng(value.courierLocation.latitude, value.courierLocation.longitude),
        icon: courierIndicatorIcon,
      ));
    });
    currentPosition = LatLng(position.latitude, position.longitude);
    if (deliveryModel.senderLocation != null && deliveryModel.recipientLocation != null) {
      markerList.add(
        Marker(
          markerId: MarkerId(deliveryModel.senderAddress),
          position: LatLng(deliveryModel.senderLocation.latitude, deliveryModel.senderLocation.longitude),
          infoWindow: InfoWindow(title: deliveryModel.senderAddress, snippet: 'Pick UP: ${deliveryModel.senderName}'),
          icon: locationIndicatorIcon,
        ),
      );
      markerList.add(
        Marker(
          markerId: MarkerId(deliveryModel.recipientAddress),
          position: LatLng(deliveryModel.recipientLocation.latitude, deliveryModel.recipientLocation.longitude),
          infoWindow: InfoWindow(title: deliveryModel.recipientAddress, snippet: 'Drop Off: ${deliveryModel.recipientname}'),
          icon: locationIndicatorIcon,
        ),
      );
    }
    cameraPosition = CameraPosition(
      target: LatLng(deliveryModel.courierLocation.latitude, deliveryModel.courierLocation.longitude),
      zoom: cameraZoom,
      tilt: 50,
      bearing: 45,
    );
    return cameraPosition;
  }

  onCameraMove(CameraPosition position) {
    if (mounted) {
      setState(() {
        lastPosition = position.target;
      });
    }
  }

  _addPolyLine(String polyId) {
    PolylineId id = PolylineId(polyId);
    Polyline polyline = Polyline(polylineId: id, color: blue, points: polylineCoordinates, width: 3, endCap: Cap.buttCap, jointType: JointType.round);
    polylines[id] = polyline;
    if (mounted) {
      setState(() {});
    }
  }

  _getPolyline(double latitude, double longitude) async {
    PolylineResult result = await polylinePoints.getRouteBetweenCoordinates(
      googleKey,
      PointLatLng(deliveryModel.recipientLocation.latitude, deliveryModel.recipientLocation.longitude),
      PointLatLng(latitude, longitude),
    );

    // print(result.status);
    if (result.points.isNotEmpty) {
      polylineCoordinates.clear();
      result.points.forEach((PointLatLng point) {
        polylineCoordinates.add(LatLng(point.latitude, point.longitude));
        
      });
    }
    var id = Uuid();
    String polyId = id.v1();
    _addPolyLine(polyId);
  }

  Future<void> zoomIn(double zoomValue) async {
    final GoogleMapController controller = await mapsController.future;
    controller.animateCamera(CameraUpdate.zoomIn());
  }

  Future<void> zoomOut(double zoomValue) async {
    final GoogleMapController controller = await mapsController.future;
    controller.animateCamera(CameraUpdate.zoomOut());
  }

  Future<void> _getUserLocation() async {
    final GoogleMapController controller = await mapsController.future;
    controller.animateCamera(CameraUpdate.newCameraPosition(CameraPosition(
      target: currentPosition,
      zoom: 15,
      tilt: 50,
      bearing: 45,
    )));
  }

  getLocationIcons(BuildContext context) async {
    if (currentContext == null) {
      currentContext = context;
      final ImageConfiguration currentLocatonConfiguration = createLocalImageConfiguration(currentContext, size: Size(10, 10));
      final ImageConfiguration locationIndicatorConfiguration = createLocalImageConfiguration(currentContext, size: Size(10, 10));

      currentLocationIcon = await BitmapDescriptor.fromAssetImage(currentLocatonConfiguration, ConstanceData.currentLocation);
      locationIndicatorIcon = await BitmapDescriptor.fromAssetImage(locationIndicatorConfiguration, ConstanceData.markerIcon);
      courierIndicatorIcon = await BitmapDescriptor.fromAssetImage(locationIndicatorConfiguration, ConstanceData.carLocation);
    }
  }

  void singleService() async {
    deliveryModel = await courierServices.listenToSingleService(widget.serviceId);
    setState(() {});
  }
}
