import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dellenhauer_admin/model/channel/participant_model.dart';
import 'package:dellenhauer_admin/model/users/user_model.dart';
import 'package:dellenhauer_admin/model/requests/requests_model.dart';
import 'package:dellenhauer_admin/utils/utils.dart';
import 'package:flutter/material.dart';

class RequestsProvider extends ChangeNotifier {
  BuildContext? context;
  DocumentSnapshot? _lastVisibleChannelList;
  DocumentSnapshot? get lastVisibleChannelList => _lastVisibleChannelList;

  DocumentSnapshot? _lastVisibleRequestList;
  DocumentSnapshot? get lastVisibleRequestList => _lastVisibleRequestList;

  final FirebaseFirestore firebaseFirestoree = FirebaseFirestore.instance;
  bool _isLoadingChannelList = false;
  bool get isLoadingChannelList => _isLoadingChannelList;
  bool _isChannelLoadingMoreContent = false;
  bool get isChannelLoadingMoreContent => _isChannelLoadingMoreContent;
  bool _isLoadingRequestList = false;
  bool get isLoadingRequestList => _isLoadingRequestList;
  bool _hasChannelData = false;
  bool get hasChannelData => _hasChannelData;
  bool _hasRequestData = false;
  bool get hasRequestData => _hasRequestData;

  String? _sortByText;
  String? get sortByText => _sortByText;

  List<DocumentSnapshot> _channelData = [];
  List<DocumentSnapshot> get channelData => _channelData;

  List<DocumentSnapshot> _requestData = [];
  List<DocumentSnapshot> get requestData => _requestData;

  void attachContext(BuildContext context) {
    this.context = context;
  }

  void setChannelDataLoading({bool isLoading = false}) {
    _isLoadingChannelList = isLoading;
    notifyListeners();
  }

  void setChannelDataMoreContent({bool isLoading = false}) {
    _isChannelLoadingMoreContent = isLoading;
    notifyListeners();
  }

  void setRequestDataLoading({bool isLoading = false}) {
    _isLoadingRequestList = isLoading;
    notifyListeners();
  }

  void setLastVisibleChannelList({DocumentSnapshot? lastVisible}) {
    _lastVisibleChannelList = lastVisible;
    notifyListeners();
  }

  void setLastVisibleChannelRequestList({DocumentSnapshot? lastVisible}) {
    _lastVisibleRequestList = lastVisible;
    notifyListeners();
  }

  Future<void> getChannelData({
    required String orderBy,
    required bool descending,
  }) async {
    QuerySnapshot data;
    if (_lastVisibleChannelList == null) {
      data = await firebaseFirestoree
          .collection('channels')
          .orderBy(orderBy, descending: descending)
          .limit(10)
          .get();
    } else {
      data = await firebaseFirestoree
          .collection('channels')
          .orderBy(orderBy, descending: descending)
          .startAfter([_lastVisibleChannelList![orderBy]])
          .limit(10)
          .get();
    }
    if (data.docs.isNotEmpty) {
      _lastVisibleChannelList = data.docs[data.docs.length - 1];
      _isLoadingChannelList = false;
      _hasChannelData = true;
      _channelData.addAll(data.docs);
      notifyListeners();
    } else {
      if (_lastVisibleChannelList == null) {
        _isLoadingChannelList = false;
        _hasChannelData = false;
        _isChannelLoadingMoreContent = false;
        notifyListeners();
      } else {
        _isLoadingChannelList = false;
        _hasChannelData = true;
        _isChannelLoadingMoreContent = false;
        notifyListeners();
      }
    }
  }

  // get channel request
  Future<void> getChannelRequestList({
    required String orderBy,
    required bool descending,
    required String channelId,
  }) async {
    QuerySnapshot data;
    if (_lastVisibleRequestList == null) {
      data = await firebaseFirestoree
          .collection('channels')
          .doc(channelId)
          .collection('requests')
          .orderBy(orderBy, descending: descending)
          .limit(10)
          .get();
    } else {
      data = await firebaseFirestoree
          .collection('channels')
          .doc(channelId)
          .collection('requests')
          .orderBy(orderBy, descending: descending)
          .startAfter([lastVisibleRequestList![orderBy]])
          .limit(10)
          .get();
    }
    if (data.docs.isNotEmpty) {
      _lastVisibleRequestList = data.docs[data.docs.length - 1];
      _isLoadingRequestList = false;
      _hasRequestData = true;
      for (var data in data.docs) {
        ChannelRequestModel model =
            ChannelRequestModel.fromMap(data.data() as dynamic);
        if (model.isApproved == false) {
          _requestData.add(data);
        }
      }
      notifyListeners();
    } else {
      if (_lastVisibleRequestList == null) {
        _isLoadingRequestList = false;
        _hasRequestData = false;
        notifyListeners();
      } else {
        _isLoadingRequestList = false;
        _hasRequestData = true;
        showSnackbar(context!, 'No more channel requests found');
        notifyListeners();
      }
    }
  }

  Future<UserModel> returnUserModelFromId(String userId) async {
    return firebaseFirestoree
        .collection('users')
        .doc(userId)
        .get()
        .then((value) {
      return UserModel.fromJson(value.data() as dynamic);
    });
  }

  // approve request
  Future<void> acceptChannelRequest({
    required ChannelRequestModel channelRequestData,
    required String channelId,
  }) async {
    DocumentSnapshot channelDocSnapshot =
        await firebaseFirestoree.collection('channels').doc(channelId).get();
    if (channelDocSnapshot.exists) {
      Map<String, dynamic> data = channelDocSnapshot.data() as dynamic;
      await firebaseFirestoree
          .collection('channels')
          .doc(channelId)
          .collection('requests')
          .doc(channelRequestData.requestId)
          .update({
        'approved_by': 'admin',
        'isApproved': true,
      });
      DocumentSnapshot dSnapshot = await firebaseFirestoree
          .collection('channels')
          .doc(channelId)
          .collection('members')
          .doc(channelRequestData.userId)
          .get();
      if (!dSnapshot.exists) {
        // adding to members collection
        await firebaseFirestoree
            .collection('channels')
            .doc(channelId)
            .collection('members')
            .doc(channelRequestData.userId)
            .set(
              ParticipantModel(
                      isNotificationEnabled: true,
                      uid: channelRequestData.userId,
                      joinedAt: DateTime.now().millisecondsSinceEpoch)
                  .toMap(),
              SetOptions(merge: true),
            );
        if (data.containsKey('totalMembers') && data['totalMembers'] >= 0) {
          await firebaseFirestoree
              .collection('channels')
              .doc(channelId)
              .update({
            'totalMembers': FieldValue.increment(1),
          });
        }
        // adding to user's joined channel array
        await firebaseFirestoree
            .collection('users')
            .doc(channelRequestData.userId)
            .update({
          'joinedChannels': FieldValue.arrayUnion([channelId])
        });
      }
      // updating user personal request
      QuerySnapshot snap = await firebaseFirestoree
          .collection('users')
          .doc(channelRequestData.userId)
          .collection('channelRequests')
          .where('channelId', isEqualTo: channelId)
          .get();
      if (snap.docs.isNotEmpty) {
        await firebaseFirestoree
            .collection('users')
            .doc(channelRequestData.userId)
            .collection('channelRequests')
            .doc(snap.docs[0].id)
            .update({
          'accepted': true,
        });
      }
    }
  }

  Future<void> declineChannelRequest({
    required ChannelRequestModel channelRequestdata,
    required String channelId,
  }) async {
    await firebaseFirestoree
        .collection('channels')
        .doc(channelId)
        .collection('requests')
        .doc(channelRequestdata.requestId)
        .delete();
    QuerySnapshot snap = await firebaseFirestoree
        .collection('users')
        .doc(channelRequestdata.userId)
        .collection('channelRequests')
        .where('channelId', isEqualTo: channelId)
        .get();
    if (snap.docs.isNotEmpty) {
      await firebaseFirestoree
          .collection('users')
          .doc(channelRequestdata.userId)
          .collection('channelRequests')
          .doc(snap.docs[0].id)
          .delete();
    }
  }
}
