import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class OverviewProvider extends ChangeNotifier {
  BuildContext? context;
  final FirebaseFirestore firebaseFirestore = FirebaseFirestore.instance;
  bool _isLoading = false;
  bool get isLoading => _isLoading;
  int _userCount = 0;
  int get userCount => _userCount;
  int _channelCount = 0;
  int get channelCount => _channelCount;
  int _servicesCount = 0;
  int get servicesCount => _servicesCount;
  int _requestCount = 0;
  int get requestCount => _requestCount;
  int _notificationCount = 0;
  int get notificationCount => _notificationCount;

  void attachContext(BuildContext context) {
    this.context = context;
  }

  void setLoading(bool isLoading) {
    _isLoading = isLoading;
    notifyListeners();
  }

  // getting initial data
  Future<void> loadData({bool reload = false}) async {
    try {
      setLoading(true);
      await Future.wait([
        getUserCount(),
        getChannelCount(),
        getServicesCount(),
        getRequestCount(),
        getNotificationCount()
      ]);
    } finally {
      setLoading(false);
    }
  }

  // getting user data
  Future<void> getUserCount() async {
    QuerySnapshot<Map<String, dynamic>> query =
        await firebaseFirestore.collection('users').get();
    _userCount = query.size;
    notifyListeners();
  }

  // get channel data
  Future<void> getChannelCount() async {
    QuerySnapshot<Map<String, dynamic>> query =
        await firebaseFirestore.collection('channels').get();
    _channelCount = query.size;
    notifyListeners();
  }

  Future<void> getNotificationCount() async {
    QuerySnapshot<Map<String, dynamic>> query =
        await firebaseFirestore.collection('notifications').get();
    _notificationCount = query.size;
    notifyListeners();
  }

  // getting services data
  Future<void> getServicesCount() async {
    QuerySnapshot<Map<String, dynamic>> query = await firebaseFirestore
        .collection('admin')
        .doc('services')
        .collection('serviceCollection')
        .get();
    _servicesCount = query.size;
    notifyListeners();
  }

  // getting request count
  Future<void> getRequestCount() async {
    QuerySnapshot<Map<String, dynamic>> query = await firebaseFirestore
        .collection('admin')
        .doc('settings')
        .collection('channelRequests')
        .get();
    _requestCount = query.size;
    notifyListeners();
  }
}
