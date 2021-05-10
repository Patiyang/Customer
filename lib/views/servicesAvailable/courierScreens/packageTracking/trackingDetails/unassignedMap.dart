import 'dart:async';
// import 'dart:ui';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:my_cab/constance/constance.dart';
import 'package:my_cab/constance/global.dart';
import 'package:my_cab/helpers&widgets/widgets/customText.dart';
import 'package:my_cab/helpers&widgets/widgets/loading.dart';
import 'package:my_cab/models/deliveryModel.dart';
import 'package:my_cab/models/utils.dart';
import 'package:uuid/uuid.dart';

class UnassignedMap extends StatefulWidget {
  final GeoPoint senderLocation;
  final GeoPoint recipientLocation;
  final DeliveryModel deliveryModel;
  const UnassignedMap({
    Key key,
    this.senderLocation,
    this.recipientLocation,
    this.deliveryModel,
  }) : super(key: key);
  @override
  _UnassignedMapState createState() => _UnassignedMapState();
}

class _UnassignedMapState extends State<UnassignedMap> {
  GeolocatorPlatform geolocatorPlatform = GeolocatorPlatform.instance;
  GeocodingPlatform geocodingPlatform;
  CameraPosition cameraPosition;
  LatLng currentPostion;
  LatLng lastPosition;
  double cameraZoom = 10;
  bool loading = false;
  List<Marker> restaurantMarkers = [];
  Map<PolylineId, Polyline> polylines = {};
  Completer<GoogleMapController> mapsController = Completer();
  GoogleMapController mapcontroller;
  PolylinePoints polylinePoints = PolylinePoints();
  List<LatLng> polylineCoordinates = [];
  // double _originLatitude = -2.4219983, _originLongitude = 38.084;
  BitmapDescriptor currentLocationIcon;
  BitmapDescriptor locationIndicatorIcon;
  BuildContext currentContext;
  @override
  void initState() {
    super.initState();
    _getUPickUpLocation();
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
            padding: const EdgeInsets.only(top: 23.0, right: 10),
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
    return FutureBuilder(
      future: _getUPickUpLocation(),
      builder: (BuildContext context, AsyncSnapshot snapshot) {
        cameraPosition = snapshot.data;
        // print(snapshot.connectionState);
        if (snapshot.hasData) {
          return Container(
            height: MediaQuery.of(context).size.height,
            width: MediaQuery.of(context).size.width,
            child: GoogleMap(
              zoomControlsEnabled: false,
              mapToolbarEnabled: false,
              compassEnabled: true,
              // onMapCreated: _onMapCreated,
              onMapCreated: (GoogleMapController controller) {
                controller.setMapStyle(Utils.mapStyles);

                mapsController.complete(controller);
              },
              markers: Set.from(restaurantMarkers),
              // myLocationEnabled: true,
              mapType: MapType.normal,
              initialCameraPosition: cameraPosition,
              onCameraMove: onCameraMove,
              polylines: Set<Polyline>.of(polylines.values),
            ),
          );
        }
        if (snapshot.hasError) {
          return Center(
            child: CustomText(
              text: 'Failed to load location data',
              textAlign: TextAlign.center,
            ),
          );
        }
        return Loading();
      },
    );
  }

  Future<CameraPosition> _getUPickUpLocation() async {
    var position = await GeolocatorPlatform.instance.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
    // currentPostion = LatLng(-2.4213, 38.084);
    currentPostion = LatLng(position.latitude, position.longitude);
    if (widget.senderLocation != null && widget.recipientLocation != null) {
      _getPolyline(widget.senderLocation.latitude, widget.senderLocation.longitude);
      restaurantMarkers.add(
        Marker(
          markerId: MarkerId(widget.deliveryModel.senderAddress),
          position: LatLng(widget.deliveryModel.senderLocation.latitude, widget.deliveryModel.senderLocation.longitude),
          infoWindow: InfoWindow(title: widget.deliveryModel.senderAddress, snippet: 'From: ${widget.deliveryModel.senderName}'),
          icon: locationIndicatorIcon,
        ),
      );
      restaurantMarkers.add(
        Marker(
          markerId: MarkerId(widget.deliveryModel.recipientAddress),
          position: LatLng(widget.deliveryModel.recipientLocation.latitude, widget.deliveryModel.recipientLocation.longitude),
          infoWindow: InfoWindow(title: widget.deliveryModel.recipientAddress, snippet: 'To: ${widget.deliveryModel.recipientname}'),
          icon: locationIndicatorIcon,
        ),
      );

      restaurantMarkers.add(Marker(
        markerId: MarkerId(widget.deliveryModel.recipientAddress),
        position: LatLng(currentPostion.latitude, currentPostion.longitude),
        infoWindow: InfoWindow(
          title: widget.deliveryModel.recipientAddress,
        ),
        icon: currentLocationIcon,
      ));
    }
    cameraPosition = CameraPosition(
        target: LatLng(widget.deliveryModel.senderLocation.latitude, widget.deliveryModel.senderLocation.longitude), zoom: cameraZoom, tilt: 50, bearing: 45);
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
    Polyline polyline = Polyline(polylineId: id, color: blue, points: polylineCoordinates, width: 3, endCap: Cap.roundCap, jointType: JointType.round);
    polylines[id] = polyline;
    if (mounted) {
      setState(() {});
    }
  }

  _getPolyline(double latitude, double longitude) async {
    PolylineResult result = await polylinePoints.getRouteBetweenCoordinates(
      googleKey,
      PointLatLng(widget.recipientLocation.latitude, widget.recipientLocation.longitude),
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
    controller.animateCamera(CameraUpdate.newCameraPosition(CameraPosition(target: currentPostion, zoom: 15, tilt: 50, bearing: 45)));
  }

  getLocationIcons(BuildContext context) async {
    if (currentContext == null) {
      currentContext = context;
      final ImageConfiguration currentLocatonConfiguration = createLocalImageConfiguration(currentContext, size: Size(10, 10));
      final ImageConfiguration locationIndicatorConfiguration = createLocalImageConfiguration(currentContext, size: Size(10, 10));

      currentLocationIcon = await BitmapDescriptor.fromAssetImage(currentLocatonConfiguration, ConstanceData.currentLocation);
      locationIndicatorIcon = await BitmapDescriptor.fromAssetImage(locationIndicatorConfiguration, ConstanceData.markerIcon);
    }
  }
}
