import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dellenhauer_admin/model/users/user_model.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class PushNotificationLogsProvider extends ChangeNotifier {
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
  final List<DocumentSnapshot> _singlUserNotificationData = [];
  List<DocumentSnapshot> get singleUserNotificationData =>
      _singlUserNotificationData;
  final List<String> _selectedIds = [];
  List<String> get selectedIds => _selectedIds;
  bool _selectAll = false;
  bool get selectAll => _selectAll;

  void toggleSelectAll(bool value) {
    _selectAll = value;
    if (_selectAll) {
      for (var notification in _notificationData) {
        if (notification['id'] != null &&
            !_selectedIds.contains(notification['id'])) {
          _selectedIds.add(notification['id']);
        }
      }
    } else {
      _selectedIds.clear();
    }
    notifyListeners();
  }

  // Method to deselect all notifications
  void clearSelection() {
    _selectedIds.clear();
    _selectAll = false;
    notifyListeners();
  }

  void resetSelectAll() {
    _selectAll = false;
    notifyListeners();
  }

  // Method to toggle selection of a single notification
  void toggleSelection(String id) {
    if (_selectedIds.contains(id)) {
      _selectedIds.remove(id);
    } else {
      _selectedIds.add(id);
    }
    notifyListeners();
  }

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

  Future<void> getNotificationData({
    String? searchQuery,
    required String orderBy,
    required bool descending,
    int pageNumber = 1,
  }) async {
    try {
      Query<Map<String, dynamic>> query;
      if (searchQuery != null && searchQuery.isNotEmpty) {
        query = firebaseFirestore
            .collection('notifications')
            .orderBy('lowerVersionNotificationMessage', descending: descending)
            .orderBy('notificationSendTimestamp', descending: descending)
            .limit(15);
      } else {
        switch (orderBy) {
          case 'user':
            query = firebaseFirestore
                .collection('notifications')
                .orderBy('notificationSendTimestamp', descending: descending)
                .where('target', isEqualTo: 'user')
                .limit(15);
            break;
          case 'channel':
            query = firebaseFirestore
                .collection('notifications')
                .orderBy('notificationSendTimestamp', descending: descending)
                .where('target', isEqualTo: 'channel')
                .limit(15);
            break;
          case 'website':
            query = firebaseFirestore
                .collection('notifications')
                .orderBy('notificationSendTimestamp', descending: descending)
                .where('target', isEqualTo: 'website')
                .limit(15);
            break;
          case 'article':
            query = firebaseFirestore
                .collection('notifications')
                .orderBy('notificationSendTimestamp', descending: descending)
                .where('target', isEqualTo: 'article')
                .limit(15);
            break;
          default:
            query = firebaseFirestore
                .collection('notifications')
                .orderBy(orderBy, descending: descending)
                .limit(15);
        }
      }

      if (searchQuery != null && searchQuery.isNotEmpty) {
        query = query.where('lowerVersionNotificationMessage',
            isGreaterThanOrEqualTo: searchQuery.toLowerCase());
        query = query.where('lowerVersionNotificationMessage',
            isLessThan: '${searchQuery.toLowerCase()}z');
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
    } catch (e) {
      if (kDebugMode) {
        print(e);
      }
    }
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

  Future<void> deleteMultipleNotifications() async {
    List<List<String>> batches = _selectedIds
        .map((e) => _selectedIds.sublist(
            _selectedIds.indexOf(e), _selectedIds.lastIndexOf(e) + 1))
        .toSet()
        .toList();

    for (final batch in batches) {
      final batchDelete = FirebaseFirestore.instance.batch();
      for (var id in batch) {
        QuerySnapshot query = await firebaseFirestore
            .collection('notifications')
            .where('id', isEqualTo: id)
            .get();
        if (query.docs.isNotEmpty) {
          batchDelete.delete(FirebaseFirestore.instance
              .collection('notifications')
              .doc(query.docs[0].id));
        }
      }
      try {
        await batchDelete.commit();
        _selectedIds.removeWhere((id) => batch.contains(id));
        notifyListeners();
      } catch (e) {
        if (kDebugMode) print(e);
      }
    }
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
