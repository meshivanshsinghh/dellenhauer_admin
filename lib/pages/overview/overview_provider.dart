import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class OverviewProvider extends ChangeNotifier {
  BuildContext? context;
  final FirebaseFirestore firebaseFirestore = FirebaseFirestore.instance;
  int _userCount = 0;
  int get userCount => _userCount;
  int _channelCount = 0;
  int get channelCount => _channelCount;
  int _servicesCount = 0;
  int get servicesCount => _servicesCount;
  int _requestCount = 0;
  int get requestCount => _requestCount;

  void attachContext(BuildContext context) {
    this.context = context;
  }

  // getting initial data
  Future<void> loadData({bool reload = false}) async {
    await getData();
  }

  // getting user data
  Future getData() async {
    try {
      // user data
      QuerySnapshot queryUserData =
          await firebaseFirestore.collection('users').get();
      _userCount = queryUserData.docs.length;
      // channelcount
      QuerySnapshot queryChannel =
          await firebaseFirestore.collection('channels').get();
      _channelCount = queryChannel.docs.length;
      // services count
      DocumentSnapshot queryServices =
          await firebaseFirestore.collection('admin').doc('services').get();

      _servicesCount = queryServices['total_count'] as int;

      // requests count
      QuerySnapshot queryRequests = await firebaseFirestore
          .collection('admin')
          .doc('settings')
          .collection('channelRequests')
          .get();

      _requestCount = queryRequests.docs.length;
      notifyListeners();
    } catch (e) {
      return null;
    }
  }
}
