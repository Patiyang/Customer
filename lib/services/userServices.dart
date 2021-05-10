import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:my_cab/helpers&widgets/helpers/routing.dart';
import 'package:my_cab/models/userModel.dart';
import 'package:my_cab/services/emailService.dart';
import 'package:my_cab/views/home/homeNavigation.dart';

class UserServices {
  FirebaseAuth auth = FirebaseAuth.instance;
  FirebaseFirestore _firestore = FirebaseFirestore.instance;
  EmailService _emailService = new EmailService();

  Future<bool> createUser(String userName, String phoneNumber, String emailAddress, String password, BuildContext context) async {
    try {
      await auth.createUserWithEmailAndPassword(email: emailAddress, password: password).then((value) {
        _firestore.collection(UserModel.USERS).doc(auth.currentUser.uid).set(
          {
            UserModel.NAMES: userName,
            UserModel.PHONENUMBER: phoneNumber,
            UserModel.EMAIL: emailAddress,
            UserModel.UID: auth.currentUser.uid,
          },
        );
      });
      _emailService.sendWelcomeEmail(userName, emailAddress);
      changeScreenReplacement(context, HomeNavigation());
      return true;
    } catch (e) {
      print(e.toString());
      Fluttertoast.showToast(msg: e.toString());
      return false;
    }
  }

  Future<bool> loginUser(String emailAddress, String password, BuildContext context) async {
    // bool success = false;
    try {
      await auth.signInWithEmailAndPassword(email: emailAddress, password: password);
      changeScreenReplacement(context, HomeNavigation());
      return true;
    } catch (e) {
      Fluttertoast.showToast(msg: 'Invalid email or password');
      print(e.toString());
      return false;
    }
  }

  Future updateUser(String uid, String email, String gender, String phoneNumber, String userName, String profilePicture) async {
    try {
      await _firestore.collection(UserModel.USERS).doc(uid).update(
        {
          UserModel.EMAIL: email,
          UserModel.GENDER: gender,
          UserModel.PHONENUMBER: phoneNumber,
          UserModel.NAMES: userName,
          UserModel.PROFILEPICTURE: profilePicture
        },
      );
    } catch (e) {
      print(e.toString());
    }
  }

  Future<bool> updateUserAddress(Map<String, dynamic> addressMap) async {
    try {
      await _firestore.collection(UserModel.USERS).doc(auth.currentUser.uid).update({UserModel.ADDRESS: addressMap});
      return true;
    } catch (e) {
      print(e.toString());
      return false;
    }
  }

  Future<UserModel> getUserById(String id) => _firestore.collection(UserModel.USERS).doc(id).get().then((doc) {
        return UserModel.fromSnapshot(doc);
      });

  Future<List<UserModel>> getAllCustomers() async {
    List<UserModel> users = [];
    try {
      await _firestore.collection(UserModel.USERS).get().then((doc) {
        for (DocumentSnapshot user in doc.docs) {
          users.add(UserModel.fromSnapshot(user));
        }
      });
    } catch (e) {
      print(e.toString());
    }
    return users;
  }

  Future resetPassword(String email, BuildContext context) async {
    try {
      Navigator.of(context).pop(true);
      return  auth.sendPasswordResetEmail(email: email);
    } catch (e) {
      Navigator.of(context).pop(true);
      print(e.toString());
    }
  }
}
