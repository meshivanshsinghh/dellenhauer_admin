import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dellenhauer_admin/model/notification/push_notification_model.dart';
import 'package:dellenhauer_admin/model/users/user_model.dart';
import 'package:flutter/material.dart';

class PushNotificationProvider extends ChangeNotifier {
  BuildContext? context;

  bool _isLoading = false;
  bool get isLoading => _isLoading;
  bool _isLoadingMoreContent = false;
  bool get isLoadingMoreContent => _isLoadingMoreContent;
  bool _hasData = false;
  bool get hasData => _hasData;
  DocumentSnapshot? _lastVisible;
  DocumentSnapshot? get lastVisible => _lastVisible;
  List<DocumentSnapshot> _notificationData = [];
  List<DocumentSnapshot> get notificationData => _notificationData;
  final FirebaseFirestore firebaseFirestore = FirebaseFirestore.instance;

  void setLoading({bool isLoading = false}) {
    _isLoading = isLoading;
    notifyListeners();
  }

  void loadingMoreContent({bool isLoading = false}) {
    _isLoadingMoreContent = isLoading;
    notifyListeners();
  }

  void attachContext(BuildContext context) {
    this.context = context;
  }

  // get notifications
  Future<void> getNotificationData({
    required String orderBy,
    required bool descending,
  }) async {
    QuerySnapshot data;
    if (_lastVisible == null) {
      if (orderBy == 'notificationSendTimestamp') {
        data = await firebaseFirestore
            .collection('notifications')
            .orderBy(orderBy, descending: descending)
            .limit(20)
            .get();
      } else {
        data = await firebaseFirestore
            .collection('notifications')
            .where('target', isEqualTo: orderBy)
            .orderBy('notificationSendTimestamp', descending: descending)
            .limit(20)
            .get();
      }
    } else {
      if (orderBy == 'notificationSendTimestamp') {
        data = await firebaseFirestore
            .collection('notifications')
            .orderBy(orderBy, descending: descending)
            .startAfter([_lastVisible![orderBy]])
            .limit(20)
            .get();
      } else {
        final Map<String, dynamic>? dataMap = _lastVisible!.data() as dynamic;
        final String orderByField = dataMap?.containsKey(orderBy) == true
            ? orderBy
            : 'notificationSendTimestamp';
        data = await firebaseFirestore
            .collection('notifications')
            .orderBy('notificationSendTimestamp', descending: descending)
            .where('target', isEqualTo: orderByField)
            .startAfter([_lastVisible![orderByField]])
            .limit(20)
            .get();
      }
    }
    if (data.docs.isNotEmpty) {
      _lastVisible = data.docs[data.docs.length - 1];
      _isLoading = false;
      _hasData = true;
      _notificationData.addAll(data.docs);
      notifyListeners();
    } else {
      if (_lastVisible == null) {
        _isLoading = false;
        _isLoadingMoreContent = false;
        _hasData = false;
        notifyListeners();
      } else {
        _isLoading = false;
        _hasData = true;
        _isLoadingMoreContent = false;
        notifyListeners();
      }
    }
  }

  void setLastVisible({DocumentSnapshot? documentSnapshot}) {
    _lastVisible = documentSnapshot;
    notifyListeners();
  }

  void sortData(String sortColumn, bool isAscending) {
    if (sortColumn == "notificationSendTimestamp") {
      notificationData.sort((a, b) {
        NotificationModel aData =
            NotificationModel.fromMap(a.data() as dynamic);
        NotificationModel bData =
            NotificationModel.fromMap(b.data() as dynamic);
        int comparison = aData.notificationSendTimestamp!
            .compareTo(bData.notificationSendTimestamp!);
        return isAscending ? comparison : -comparison;
      });
    } else if (sortColumn == "target") {
      notificationData.sort((a, b) {
        NotificationModel aData =
            NotificationModel.fromMap(a.data() as dynamic);
        NotificationModel bData =
            NotificationModel.fromMap(b.data() as dynamic);
        int comparison = aData.target!.compareTo(bData.target!);
        return isAscending ? comparison : -comparison;
      });
    }
    notifyListeners();
  }

  // deleting push notification
  Future<void> deletingPushNotification(String pushNotificationId) async {
    await firebaseFirestore
        .collection('notifications')
        .doc(pushNotificationId)
        .delete();
  }

  Future<List<UserModel>> getUserDetails(List<String> id) async {
    List<UserModel> userData = [];
    for (var documentID in id) {
      DocumentSnapshot snap =
          await firebaseFirestore.collection('users').doc(documentID).get();
      if (snap.exists) {
        userData.add(UserModel.fromJson(snap.data() as dynamic));
      }
    }
    return userData;
  }
}
