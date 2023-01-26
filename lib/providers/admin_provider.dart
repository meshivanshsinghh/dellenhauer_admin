import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AdminDataProvider extends ChangeNotifier {
  final FirebaseFirestore firebaseFirestore = FirebaseFirestore.instance;
  bool _isSignedIn = false;
  bool get isSignedIn => _isSignedIn;
  String? _adminPassword;
  String? get adminPassword => _adminPassword;

  AdminDataProvider() {
    checkSignIn();
    getAdminPassword();
  }

  // getting password
  void getAdminPassword() async {
    await firebaseFirestore
        .collection('admin')
        .doc('settings')
        .get()
        .then((DocumentSnapshot snap) {
      String? aPassword = snap['admin_password'];
      _adminPassword = aPassword;
      notifyListeners();
    });
  }

  // check sign in
  void checkSignIn() async {
    final SharedPreferences sf = await SharedPreferences.getInstance();
    _isSignedIn = sf.getBool('signed_in') ?? false;
    notifyListeners();
  }

  // set sign in
  Future setSignIN() async {
    final SharedPreferences sf = await SharedPreferences.getInstance();
    sf.setBool('signed_in', true);
    _isSignedIn = true;
    notifyListeners();
  }
}
