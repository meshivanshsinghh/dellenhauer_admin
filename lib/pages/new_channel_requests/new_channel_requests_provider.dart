import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dellenhauer_admin/model/users/user_model.dart';
import 'package:dellenhauer_admin/pages/new_channel_requests/new_channel_request_model.dart';
import 'package:flutter/material.dart';

class NewChannelRequestsProvider extends ChangeNotifier {
  BuildContext? context;
  DocumentSnapshot? _lastVisible;
  DocumentSnapshot? get lastVisible => _lastVisible;
  bool _isLoading = false;
  bool get isLoading => _isLoading;
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

  Future<void> getChannelRequestsData({
    required String orderBy,
    required bool descending,
  }) async {
    QuerySnapshot querySnapshot;
    if (_lastVisible == null) {
      querySnapshot = await firebaseFirestore
          .collection('admin')
          .doc('settings')
          .collection('channelRequests')
          .orderBy(orderBy, descending: descending)
          .limit(15)
          .get();
    } else {
      querySnapshot = await firebaseFirestore
          .collection('admin')
          .doc('settings')
          .collection('channelRequests')
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

  void setLoading({bool isLoading = false}) {
    _isLoading = isLoading;
    notifyListeners();
  }

  void setLastVisible({DocumentSnapshot? snapshot}) {
    _lastVisible = snapshot;
    notifyListeners();
  }

  void loadingMoreContent({bool isLoading = false}) {
    _isLoadingMoreContent = isLoading;
    notifyListeners();
  }

  Future<UserModel?> getUserDataFromID(String userId) async {
    DocumentSnapshot documentSnapshot =
        await firebaseFirestore.collection('users').doc(userId).get();
    if (documentSnapshot.exists) {
      return UserModel.fromJson(documentSnapshot.data() as dynamic);
    } else {
      return null;
    }
  }

  // mark task as done
  Future<void> markTaskAsDone(ChannelRequest request) async {
    QuerySnapshot query = await firebaseFirestore
        .collection('admin')
        .doc('settings')
        .collection('channelRequests')
        .where('text', isEqualTo: request.text)
        .where('createdAt', isEqualTo: request.createdAt)
        .get();
    if (query.docs.isNotEmpty) {
      await firebaseFirestore
          .collection('admin')
          .doc('settings')
          .collection('channelRequests')
          .doc(query.docs[0].id)
          .delete();
    }
  }
}
