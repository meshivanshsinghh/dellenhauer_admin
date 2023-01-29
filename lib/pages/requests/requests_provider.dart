import 'package:cloud_firestore/cloud_firestore.dart';
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
    _channelData = [];
    _requestData = [];
  }

  /* 

  1. showcasing the list of channels
  2. on clicking on single channel opening up the channel requests section
  
  */
  void setChannelDataLoading({bool isLoading = false}) {
    _isLoadingChannelList = isLoading;
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
        notifyListeners();
      } else {
        _isLoadingChannelList = false;
        _hasChannelData = true;
        showSnackbar(context!, 'No more channels available');
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
      _requestData.addAll(data.docs);
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
}
