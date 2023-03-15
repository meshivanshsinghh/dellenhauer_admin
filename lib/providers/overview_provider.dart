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
    await getUserCount();
    await getChannelCount();
    await getServicesCount();
    await getRequestCount();
  }

  // getting user data
  Future getUserCount() async {
    try {
      QuerySnapshot query = await firebaseFirestore.collection('users').get();
      _userCount = query.docs.length;
      notifyListeners();
    } catch (e) {
      return null;
    }
  }

  // get channel data
  Future getChannelCount() async {
    QuerySnapshot query = await firebaseFirestore.collection('channels').get();
    _channelCount = query.docs.length;
    notifyListeners();
  }

  // getting services data
  Future getServicesCount() async {
    try {
      DocumentSnapshot query =
          await firebaseFirestore.collection('admin').doc('services').get();

      _servicesCount = query['total_count'] as int;
      notifyListeners();
    } catch (e) {
      return null;
    }
  }

  // getting request count
  Future getRequestCount() async {
    try {
      QuerySnapshot query = await firebaseFirestore
          .collection('admin')
          .doc('settings')
          .collection('channelRequests')
          .get();

      _requestCount = query.docs.length;
      notifyListeners();
    } catch (e) {
      return null;
    }
  }
}
