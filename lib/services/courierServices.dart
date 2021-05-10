import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:my_cab/models/driverModel.dart';
import 'package:my_cab/models/deliveryModel.dart';
import 'package:my_cab/models/userModel.dart';
import 'package:uuid/uuid.dart';

class CourierServices {
  FirebaseAuth auth = FirebaseAuth.instance;
  FirebaseFirestore _firestore = FirebaseFirestore.instance;
  Future createService(
    String userId,
    String paymentMode,
    String packageType,
    String vechicleType,
    double earnings,
    GeoPoint senderGeoPoint,
    GeoPoint recipientGeoPoint,
    int orderNumber,
    int senderOtp,
    int recipientOtp,
    String arrivalTme,
    int distance,
    Map<String, dynamic> senderDetails,
    Map<String, dynamic> recipientDetails,
    String serviceId
  ) async {
   
    await _firestore.collection(UserModel.SERVICEREQUESTED).doc(serviceId).set(
      {
        UserModel.SENDERID: userId,
        DeliveryModel.SENDERDETAILS: senderDetails,
        DeliveryModel.RECIPIENTDETAILS: recipientDetails,
        DeliveryModel.PLACEDON: DateTime.now(),
        DeliveryModel.PACKAGETYPE: packageType,
        DeliveryModel.STATUS: 'Unasigned',
        DeliveryModel.EARNINGS: earnings.ceil(),
        DeliveryModel.PAYMENTMODE: paymentMode,
        DeliveryModel.SERVICEID: serviceId,
        DeliveryModel.SENDERLOCATION: senderGeoPoint,
        DeliveryModel.RECIPIENTLOCATION: recipientGeoPoint,
        DeliveryModel.ISNEW: true,
        DeliveryModel.ORDERNUMBER: orderNumber,
        DeliveryModel.SENDEROTP: senderOtp,
        DeliveryModel.RECIPIENTOTP: recipientOtp,
        DeliveryModel.VEHICLETYPE: vechicleType,
        DeliveryModel.ARRIVALTIME:arrivalTme,
        DeliveryModel.DISTANCE : distance
      },
    );
  }

  Future<List<DeliveryModel>> getDeliveries() async {
    List<DeliveryModel> deliveries = [];
    try {
      await _firestore.collection(DeliveryModel.SERVICEREQUESTS).where('senderID', isEqualTo: auth.currentUser.uid).get().then((value) {
        for (DocumentSnapshot snap in value.docs) {
          deliveries.add(DeliveryModel.fromSnapshot(snap));
        }
      });
    } catch (e) {
      print(e.toString());
    }
    return deliveries;
  }

  Future<List<DriverModel>> getCouriers() async {
    List<DriverModel> couriers = [];
    try {
      await _firestore.collection(DriverModel.USERS).get().then((value) {
        for (DocumentSnapshot snap in value.docs) {
          couriers.add(DriverModel.fromSnapshot(snap));
        }
      });
    } catch (e) {
      print(e.toString());
    }
    return couriers;
  }

  Future<DeliveryModel> listenToSingleService(String serviceId) async {
    DeliveryModel deliveryModel;
    try {
      await _firestore.collection(DeliveryModel.SERVICEREQUESTS).doc(serviceId).get().then((value) {
        deliveryModel = DeliveryModel.fromSnapshot(value);
      });
    } catch (e) {
      print(e.toString());
    }
    return deliveryModel;
  }
  // Future<DeliveryModel> getDeliveryById(String id) => _firestore.collection(DeliveryModel.SERVICEREQUESTS).doc(id).get().then((doc) {
  //       return DeliveryModel.fromSnapshot(doc);
  //     });
  
}
