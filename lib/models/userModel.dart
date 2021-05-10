import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  static const UID = 'userId';
  static const EMAIL = 'emailAddress';
  static const PHONENUMBER = 'phoneNumber';
  static const PASSWORD = 'password';
  static const NAMES = 'customerNames';
  static const GENDER = 'gender';
  static const BIRTHDAY = 'birthDay';
  static const PROFILEPICTURE = 'profilePicture';
  static const ADDRESS = 'userAddress';
  static const SENDERID = 'senderID';
  static const USERS = 'users';
  static const SERVICEREQUESTED = 'serviceRequests';
  static const SENDERDETAILS = 'senderDetails';
  static const RECIPIENTDETAILS = 'recipientDetails';
//addresses
  static const SENDERPHONE = 'senderPhone';
  static const SENDERNAME = 'senderName';
  static const SENDERADDRESS = 'senderAddress';
  static const SENDERLANDMARK = 'landMark';
  static const SENDEREMAIL = 'senderEmail';
//Recipient addresses
  static const RECEPIENTADDRESS = 'recipientAddress';
  static const RECEPIENTLANDMARK = 'recipientLandMark';
  static const RECEPIENTNAMES = 'recipientNames';
  static const RECEPIENTPHONENUMBER = 'recipientPhoneNumber';
  static const RECEPIENTEMAILADDRESS = 'recipientEmailAddress';

  String _userId;
  String _email;
  String _phoneNumber;
  String _names;
  String _gender;
  DateTime _birthDay;
  String _profilePicture;
  String _senderName;
  String _senderPhone;
  String _senderEmail;
  String _landMark;
  String _senderAddress;
  String _zipCode;
  Map _userAddress;

  String get id => _userId;
  String get email => _email;
  String get phoneNumber => _phoneNumber;
  String get names => _names;
  String get gender => _gender;
  DateTime get birthDay => _birthDay;
  String get profilePicture => _profilePicture;
  String get senderName => _senderName;
  String get senderPhone => _senderPhone;
  String get senderEmail => _senderEmail;
  String get landMark => _landMark;
  String get senderAddress => _senderAddress;
  String get zipCode => _zipCode;
  Map get userAddresses => _userAddress;

  UserModel.fromSnapshot(DocumentSnapshot snapshot) {
    _userId = snapshot.data()[UID];
    _email = snapshot.data()[EMAIL];
    _phoneNumber = snapshot.data()[PHONENUMBER];
    _names = snapshot.data()[NAMES];
    _gender = snapshot.data()[GENDER];
    _birthDay = snapshot.data()[BIRTHDAY];
    _profilePicture = snapshot.data()[PROFILEPICTURE];
    _senderName = snapshot.data()[ADDRESS] != null ? snapshot.data()[ADDRESS][SENDERNAME] : '';
    _senderEmail = snapshot.data()[ADDRESS] != null ? snapshot.data()[ADDRESS][SENDEREMAIL] : '';
    _senderPhone = snapshot.data()[ADDRESS] != null ? snapshot.data()[ADDRESS][SENDERPHONE] : '';
    _landMark = snapshot.data()[ADDRESS] != null ? snapshot.data()[ADDRESS][SENDERLANDMARK] : '';
    _senderAddress = snapshot.data()[ADDRESS] != null ? snapshot.data()[ADDRESS][SENDERADDRESS] : '';
    _userAddress = snapshot.data()[ADDRESS];
    // _zipCode = snapshot.data()[ADDRESS] != null ? snapshot.data()[ADDRESS][ZIPCODE] : '';
  }
}
