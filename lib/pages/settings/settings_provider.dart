import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class SettingsProvider extends ChangeNotifier {
  BuildContext? context;
  bool _isLoading = false;
  bool get isLoading => _isLoading;
  DocumentSnapshot? _lastVisible;
  DocumentSnapshot? get lastVisible => _lastVisible;
  bool _hasData = false;
  bool get hasData => _hasData;
  bool _isLoadingMoreContent = false;
  bool get isLoadingMoreContent => _isLoadingMoreContent;
  List<DocumentSnapshot> _data = [];
  List<DocumentSnapshot> get data => _data;
  final FirebaseFirestore firebaseFirestore = FirebaseFirestore.instance;

  void attachContext(BuildContext contextt) {
    context = contextt;
  }

  void setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void setLastVisible({DocumentSnapshot? snapshot}) {
    _lastVisible = snapshot;
    notifyListeners();
  }

  Future<void> getUsersData({
    required String orderBy,
    required bool descending,
  }) async {
    QuerySnapshot querySnapshot;
    if (_lastVisible == null) {
      querySnapshot = await firebaseFirestore
          .collection('admin')
          .doc('settings')
          .collection('blocked_numbers')
          .orderBy(orderBy, descending: descending)
          .limit(15)
          .get();
    } else {
      querySnapshot = await firebaseFirestore
          .collection('admin')
          .doc('settings')
          .collection('blocked_numbers')
          .orderBy(orderBy, descending: descending)
          .startAfter([_lastVisible![orderBy]])
          .limit(15)
          .get();
    }
    if (querySnapshot.docs.isNotEmpty) {
      _lastVisible = querySnapshot.docs[querySnapshot.docs.length - 1];
      _isLoading = false;
      _hasData = true;
      _data.addAll(querySnapshot.docs);
      notifyListeners();
    } else {
      if (_lastVisible == null) {
        _isLoading = false;
        _hasData = false;
        _isLoadingMoreContent = false;
        notifyListeners();
      } else {
        _isLoading = false;
        _hasData = true;
        _isLoadingMoreContent = false;
        notifyListeners();
      }
    }
  }

  Future<void> updateAdminPassword(String newPassword) async {
    await firebaseFirestore.collection('admin').doc('settings').update({
      'admin_password': newPassword,
    }).whenComplete(() => setLoading(false));
  }

  Future<bool> addPhoneNumber(String phoneNumber) async {
    QuerySnapshot query = await firebaseFirestore
        .collection('admin')
        .doc('settings')
        .collection('blocked_numbers')
        .where('phoneNumber', isEqualTo: phoneNumber)
        .get();
    if (query.docs.isEmpty) {
      await firebaseFirestore
          .collection('admin')
          .doc('settings')
          .collection('blocked_numbers')
          .add({
        'createdAt': DateTime.now().millisecondsSinceEpoch,
        'phoneNumber': phoneNumber,
      });
      QuerySnapshot userQuery = await firebaseFirestore
          .collection('users')
          .where('phoneNumber', isEqualTo: phoneNumber)
          .get();
      if (userQuery.docs.isNotEmpty) {
        await firebaseFirestore
            .collection('users')
            .doc(userQuery.docs[0].id)
            .update({
          'isVerified': false,
        });
      }
      return true;
    } else {
      return false;
    }
  }

  Future<void> removeNumberFromDatabase(String phoneNumber) async {
    QuerySnapshot query = await firebaseFirestore
        .collection('admin')
        .doc('settings')
        .collection('blocked_numbers')
        .where('phoneNumber', isEqualTo: phoneNumber)
        .get();
    if (query.docs.isNotEmpty) {
      await firebaseFirestore
          .collection('admin')
          .doc('settings')
          .collection('blocked_numbers')
          .doc(query.docs[0].id)
          .delete();
      QuerySnapshot userQuery = await firebaseFirestore
          .collection('users')
          .where('phoneNumber', isEqualTo: phoneNumber)
          .get();
      if (userQuery.docs.isNotEmpty) {
        await firebaseFirestore
            .collection('users')
            .doc(userQuery.docs[0].id)
            .update(
          {'isVerified': true},
        );
      }
    }
  }
}
