import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dellenhauer_admin/constants.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class PendingUsersProvider extends ChangeNotifier {
  BuildContext? context;
  bool _isLoading = false;
  bool get isLoading => _isLoading;
  DocumentSnapshot? _lastVisible;
  DocumentSnapshot? get lastVisible => _lastVisible;
  final FirebaseFirestore _firebaseFirestore = FirebaseFirestore.instance;
  bool _hasData = false;
  bool get hasData => _hasData;
  List<DocumentSnapshot> _data = [];
  List<DocumentSnapshot> get data => _data;
  bool _isLoadingMoreContent = false;
  bool get isLoadingMoreContent => _isLoadingMoreContent;

  void attachContext(BuildContext contextt) {
    context = contextt;
  }

  void setLoading(bool isLoading) {
    _isLoading = isLoading;
    notifyListeners();
  }

  // get user data
  Future<void> getUserData({
    required String orderBy,
    required bool descending,
  }) async {
    QuerySnapshot snapshot;
    if (_lastVisible == null) {
      snapshot = await _firebaseFirestore
          .collection('users')
          .where('isVerified', isEqualTo: false)
          .orderBy(orderBy, descending: descending)
          .limit(15)
          .get();
    } else {
      snapshot = await _firebaseFirestore
          .collection('users')
          .where('isVerified', isEqualTo: false)
          .orderBy(orderBy, descending: descending)
          .startAfter([_lastVisible![orderBy]])
          .limit(15)
          .get();
    }

    if (snapshot.docs.isNotEmpty) {
      _lastVisible = snapshot.docs[snapshot.docs.length - 1];
      _isLoading = false;
      _hasData = true;
      _data.addAll(snapshot.docs);
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

  void setLastVisible(DocumentSnapshot? snapshott) {
    _lastVisible = snapshott;
    notifyListeners();
  }

  void loadingMoreContent(bool isLoading) {
    _isLoadingMoreContent = isLoading;
    notifyListeners();
  }

  // approve pending user
  Future<void> acceptPendingUser({
    required String userId,
    bool comingFromUserUpdate = false,
  }) async {
    if (!comingFromUserUpdate) {
      await _firebaseFirestore.collection('users').doc(userId).update(
        {'isVerified': true},
      );
    }
    final response = await http.post(
      Uri.parse(
        '${AppConstants.acceptPendingUser}?userId=$userId',
      ),
    );
    if (response.statusCode == 200) {
      debugPrint('Cloud function executed successfully');
    } else {
      debugPrint('Cloud function execution failed., ${response.body}');
    }
  }

  // deleting user
  Future<void> deleteUser({required String userId}) async {
    final String url = '${AppConstants.deleteUser}?userId=$userId';
    final response = await http.get(Uri.parse(url));
    if (response.statusCode == 200) {
      debugPrint('Successfully deleted user');
    } else {
      debugPrint(response.body);
    }
  }
}
