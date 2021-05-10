import 'package:cloud_firestore/cloud_firestore.dart';

class HistoryModel {
  static const NOTIFICATIONDETAILS = 'notificationDetails';
  static const NOTIFICATIONID = 'notificationId';
  static const NOTIFICATIONTITLE = 'notificationTitle';
  static const NOTIFICATIONSUBTITLE = 'notificationSubtitle';
  static const PLACEDON = 'placedOn';
  static const DESCRIPTION = 'description';
  static const PICKUPLOCATION = 'pickUpLocation';
  static const DROPOFFLOCATION = 'dropOffLocation';
  static const EARNINGS = 'earnings';
  static const notification = 'Notifications';

  Map _notificationDetails;
  String _notificationId;
  String _notificationTitle;
  String _notificationSubtitle;
  int _placedOn;
  String _description;
  String _pickUpLocation;
  String _dropOffLocation;
  double _earnings;

  Map get notificationDetails => _notificationDetails;
  String get id => _notificationId;
  String get notificationTitle => _notificationTitle;
  String get notificationSubtitle => _notificationSubtitle;
  int get placedOn => _placedOn;
  String get description => _description;
  String get pickUpLocation => _pickUpLocation;
  String get dropOffLocation => _dropOffLocation;
  double get earnings => _earnings;

  HistoryModel.fromSnapshot(DocumentSnapshot snapshot) {
    _notificationDetails = snapshot.data()[NOTIFICATIONDETAILS];
    _notificationId = snapshot.data()[NOTIFICATIONID];
    _notificationTitle = snapshot.data()[NOTIFICATIONDETAILS][NOTIFICATIONTITLE];
    _notificationSubtitle = snapshot.data()[NOTIFICATIONDETAILS][NOTIFICATIONSUBTITLE];
    _placedOn = snapshot.data()[PLACEDON];
    _description = snapshot.data()[DESCRIPTION];
    _pickUpLocation = snapshot.data()[NOTIFICATIONDETAILS][PICKUPLOCATION];
    _dropOffLocation = snapshot.data()[NOTIFICATIONDETAILS][DROPOFFLOCATION];
    _earnings = snapshot.data()[NOTIFICATIONDETAILS][EARNINGS];
  }
}
