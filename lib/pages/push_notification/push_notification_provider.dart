import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dellenhauer_admin/model/users/user_model.dart';
import 'package:flutter/material.dart';

class PushNotificationProvider extends ChangeNotifier {
  BuildContext? context;

  bool _isLoading = false;
  bool get isLoading => _isLoading;
  bool _isLoadingMoreContent = false;
  bool _hasMoreContent = false;
  bool get isLoadingMoreContent => _isLoadingMoreContent;
  bool get hasMoreContent => _hasMoreContent;
  bool _hasData = false;
  bool get hasData => _hasData;
  bool _hasSingleUserData = false;
  bool get hasSingleUserData => _hasSingleUserData;
  DocumentSnapshot? _lastVisible;
  DocumentSnapshot? get lastVisible => _lastVisible;
  List<DocumentSnapshot> _notificationData = [];
  List<DocumentSnapshot> get notificationData => _notificationData;
  final FirebaseFirestore firebaseFirestore = FirebaseFirestore.instance;
  List<DocumentSnapshot> _singlUserNotificationData = [];
  List<DocumentSnapshot> get singleUserNotificationData =>
      _singlUserNotificationData;

  void setLoading({bool isLoading = false}) {
    _isLoading = isLoading;
    notifyListeners();
  }

  set lastVisibleData(DocumentSnapshot? document) {
    _lastVisible = document;
    notifyListeners();
  }

  void loadingMoreContent({bool isLoading = false}) {
    _isLoadingMoreContent = isLoading;
    notifyListeners();
  }

  void attachContext(BuildContext context) {
    this.context = context;
  }

  void clearNotification() {
    _notificationData.clear();
    notifyListeners();
  }

  // // get notifications
  // Future<void> getNotificationData({
  //   required String orderBy,
  //   required bool descending,
  //   String? searchQuery,
  //   int? pageNumber,
  // }) async {
  //   QuerySnapshot data;
  //   if (pageNumber == null || pageNumber == 1) {
  //     _lastVisible = null;
  //     _notificationData.clear();
  //   }
  //   // when lastVisible is set to null
  //   if (_lastVisible == null) {
  //     // when orderBy -> notifiationSendTimestamp
  //     if (orderBy == 'notificationSendTimestamp') {
  //       if (searchQuery == null) {
  //         data = await firebaseFirestore
  //             .collection('notifications')
  //             .orderBy(orderBy, descending: descending)
  //             .limit(10)
  //             .get();
  //       } else {
  //         data = await firebaseFirestore
  //             .collection('notifications')
  //             .where('lowerVersionNotificationMessage',
  //                 isGreaterThanOrEqualTo: searchQuery)
  //             .where('lowerVersionNotificationMessage',
  //                 isLessThan: '$searchQuery~')
  //             .orderBy(orderBy, descending: descending)
  //             .limit(10)
  //             .get();
  //       }
  //     } else {
  //       // when orderBy contains values of target.
  //       if (searchQuery == null) {
  //         data = await firebaseFirestore
  //             .collection('notifications')
  //             .where('target', isEqualTo: orderBy)
  //             .orderBy('notificationSendTimestamp', descending: true)
  //             .limitToLast(10)
  //             .get();
  //       } else {
  //         data = await firebaseFirestore
  //             .collection('notifications')
  //             .where('target', isEqualTo: orderBy)
  //             .where('lowerVersionNotificationMessage',
  //                 isGreaterThanOrEqualTo: searchQuery)
  //             .where('lowerVersionNotificationMessage',
  //                 isLessThan: '$searchQuery~')
  //             .orderBy('notificationSendTimestamp', descending: true)
  //             .limit(10)
  //             .get();
  //       }
  //     }
  //   } else {
  //     if (orderBy == 'notificationSendTimestamp') {
  //       if (searchQuery == null) {
  //         data = await firebaseFirestore
  //             .collection('notifications')
  //             .orderBy(orderBy, descending: descending)
  //             .limit(10)
  //             .get();
  //       } else {
  //         data = await firebaseFirestore
  //             .collection('notifications')
  //             .orderBy(orderBy, descending: descending)
  //             .where('lowerVersionNotificationMessage',
  //                 isGreaterThanOrEqualTo: searchQuery)
  //             .where('lowerVersionNotificationMessage',
  //                 isLessThan: '$searchQuery~')
  //             .startAfter([_lastVisible!['notificationSendTimestamp']])
  //             .limit(10)
  //             .get();
  //       }
  //     } else {
  //       if (searchQuery == null) {
  //         data = await firebaseFirestore
  //             .collection('notifications')
  //             .where('target', isEqualTo: orderBy)
  //             .orderBy('notificationSendTimestamp', descending: true)
  //             .startAfter([_lastVisible!['notificationSendTimestamp']])
  //             .limit(10)
  //             .get();
  //       } else {
  //         data = await firebaseFirestore
  //             .collection('notifications')
  //             .where('target', isEqualTo: orderBy)
  //             .orderBy(orderBy, descending: descending)
  //             .where('lowerVersionNotificationMessage',
  //                 isGreaterThanOrEqualTo: searchQuery)
  //             .where('lowerVersionNotificationMessage',
  //                 isLessThan: '$searchQuery~')
  //             .startAfter([_lastVisible!['notificationSendTimestamp']])
  //             .limit(10)
  //             .get();
  //       }
  //     }
  //   }
  //   if (data.docs.isNotEmpty) {
  //     _lastVisible = data.docs[data.docs.length - 1];
  //     if (pageNumber == null || pageNumber == 1) {
  //       _notificationData = data.docs;
  //     } else {
  //       int startIndex = (pageNumber - 1) * 10;
  //       int endIndex = pageNumber * 10;
  //       if (_notificationData.length >= endIndex) {
  //         _notificationData.replaceRange(startIndex, endIndex, data.docs);
  //       } else {
  //         _notificationData.addAll(data.docs);
  //       }
  //     }

  //     _hasData = true;
  //   } else {
  //     _hasData = false;
  //   }
  //   _isLoading = false;
  //   if (_notificationData.length % 10 == 0 && data.docs.isNotEmpty) {
  //     _hasMoreContent = true;
  //   } else {
  //     _hasMoreContent = false;
  //   }
  //   notifyListeners();
  // }
  // in the NotificationProvider class

  Future<void> getNotificationData({
    String? searchQuery,
    String orderBy = 'notificationSendTimestamp',
    bool descending = true,
    int pageNumber = 1,
  }) async {
    _isLoading = true;
    notifyListeners();
    Query<Map<String, dynamic>> query = firebaseFirestore
        .collection('notifications')
        .orderBy(orderBy, descending: descending)
        .limit(10);

    if (searchQuery != null && searchQuery.isNotEmpty) {
      query = query
          .where('lowerVersionNotificationMessage',
              isGreaterThanOrEqualTo: searchQuery)
          .where('lowerVersionNotificationMessage',
              isLessThan: '$searchQuery~');
    }
    if (pageNumber > 1) {
      if (_lastVisible == null) {
        await getNotificationData(
          searchQuery: searchQuery,
          orderBy: orderBy,
          descending: descending,
          pageNumber: 1,
        );
        _notificationData.clear();
      }
      query = query.startAfterDocument(_lastVisible!);
    }

    final QuerySnapshot<Map<String, dynamic>> data = await query.get();

    if (data.docs.isNotEmpty) {
      if (_lastVisible != null && data.docs.first.id == _lastVisible!.id) {
        _hasMoreContent = false;
      } else {
        _lastVisible = data.docs.last;
        _hasMoreContent = true;
      }

      if (pageNumber == 1) {
        _notificationData = data.docs;
      } else {
        final int startIndex = (pageNumber - 1) * 10;
        final int endIndex = pageNumber * 10;
        if (_notificationData.length >= endIndex) {
          _notificationData.replaceRange(startIndex, endIndex, data.docs);
        } else {
          if (startIndex == 0) {
            _notificationData.clear();
          }
          _notificationData.addAll(data.docs);
        }
      }

      _hasData = true;
    } else {
      _hasData = false;
      _hasMoreContent = false;
    }
    _isLoading = false;
    notifyListeners();
  }

  // void sortData(String sortColumn, bool isAscending) {
  //   if (sortColumn == "notificationSendTimestamp") {
  //     notificationData.sort((a, b) {
  //       NotificationModel aData =
  //           NotificationModel.fromMap(a.data() as dynamic);
  //       NotificationModel bData =
  //           NotificationModel.fromMap(b.data() as dynamic);
  //       int comparison = aData.notificationSendTimestamp!
  //           .compareTo(bData.notificationSendTimestamp!);
  //       return isAscending ? comparison : -comparison;
  //     });
  //   } else if (sortColumn == "target") {
  //     notificationData.sort((a, b) {
  //       NotificationModel aData =
  //           NotificationModel.fromMap(a.data() as dynamic);
  //       NotificationModel bData =
  //           NotificationModel.fromMap(b.data() as dynamic);
  //       int comparison = aData.target!.compareTo(bData.target!);
  //       return isAscending ? comparison : -comparison;
  //     });
  //   }
  //   notifyListeners();
  // }

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

  // loading notification for single user.
  Future<void> getSingleUserNotificationData({
    required String orderBy,
    required String userId,
    required bool descending,
  }) async {
    QuerySnapshot data;
    if (_lastVisible == null) {
      if (orderBy == 'notificationSendTimestamp') {
        data = await firebaseFirestore
            .collection('notifications')
            .where('receiverId', arrayContains: userId)
            .orderBy(orderBy, descending: descending)
            .limit(15)
            .get();
      } else {
        data = await firebaseFirestore
            .collection('notifications')
            .where('receiverId', arrayContains: userId)
            .where('target', isEqualTo: orderBy)
            .orderBy('notificationSendTimestamp', descending: true)
            .limit(15)
            .get();
      }
    } else {
      // last instance is present
      if (orderBy == 'notificationSendTimestamp') {
        data = await firebaseFirestore
            .collection('notifications')
            .where('receiverId', arrayContains: userId)
            .orderBy(orderBy, descending: descending)
            .startAfter([_lastVisible![orderBy]])
            .limit(15)
            .get();
      } else {
        data = await firebaseFirestore
            .collection('notifications')
            .where('receiverId', arrayContains: userId)
            .where('target', isEqualTo: orderBy)
            .orderBy('notificationSendTimestamp', descending: true)
            .startAfter([_lastVisible![orderBy]])
            .limit(15)
            .get();
      }
    }
    // not quering different tasks
    if (data.docs.isNotEmpty) {
      _lastVisible = data.docs[data.docs.length - 1];
      _isLoading = false;
      _hasSingleUserData = true;
      _singlUserNotificationData.addAll(data.docs);
      notifyListeners();
    } else {
      if (_lastVisible == null) {
        _isLoading = false;
        _isLoadingMoreContent = false;
        _hasSingleUserData = false;
        notifyListeners();
      } else {
        _isLoading = false;
        _hasSingleUserData = true;
        _isLoadingMoreContent = false;
        notifyListeners();
      }
    }
  }
}
