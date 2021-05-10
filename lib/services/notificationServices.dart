import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:my_cab/models/deliveryModel.dart';
import 'package:my_cab/models/historyModel.dart';
import 'package:my_cab/models/userModel.dart';

class NotificationServices {
  FirebaseAuth auth = FirebaseAuth.instance;
  FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future createNotification(Map<String, dynamic> notification, String serviceId) async {
    try {
      await _firestore.collection(UserModel.USERS).doc(auth.currentUser.uid).collection(HistoryModel.notification).doc(serviceId).set(
        {
          HistoryModel.NOTIFICATIONID: serviceId,
          HistoryModel.NOTIFICATIONDETAILS: notification,
          HistoryModel.PLACEDON: Timestamp.now().millisecondsSinceEpoch,
        },
      );
      
    } catch (e) {
      print(e.toString());
    }
  }

  Future<List<HistoryModel>> getNotifications() async {
    List<HistoryModel> notifications = [];
    try {
      await _firestore.collection(UserModel.USERS).doc(auth.currentUser.uid).collection(HistoryModel.notification).get().then((value) {
        for (DocumentSnapshot snap in value.docs) {
          notifications.add(HistoryModel.fromSnapshot(snap));
        }
      });
    } catch (e) {
      print(e.toString());
      return null;
    }
    return notifications;
  }


}
