import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dellenhauer_admin/utils/utils.dart';
import 'package:flutter/material.dart';

class RequestsProvider extends ChangeNotifier {
  BuildContext? context;
  DocumentSnapshot? _lastVisible;
  DocumentSnapshot? get lastVisible => _lastVisible;
  final FirebaseFirestore firebaseFirestoree = FirebaseFirestore.instance;
  bool _isLoading = false;
  bool get isLoading => _isLoading;
  bool _hasData = false;
  bool get hasData => _hasData;
  String? _sortByText;
  String? get sortByText => _sortByText;

  List<DocumentSnapshot> _data = [];
  List<DocumentSnapshot> get data => _data;
  void attachContext(BuildContext context) {
    this.context = context;
  }

  /* 

  1. showcasing the list of channels
  2. on clicking on single channel opening up the channel requests section
  
  */
  void setLoading({bool isLoading = false}) {
    _isLoading = isLoading;
    notifyListeners();
  }

  void setLastVisible({DocumentSnapshot? lastVisible}) {
    _lastVisible = lastVisible;
    notifyListeners();
  }

  Future<void> getChannelData({
    required String orderBy,
    required bool descending,
    String? sortByText,
  }) async {
    QuerySnapshot data;
    if (_lastVisible == null) {
      data = await firebaseFirestoree
          .collection('channels')
          .orderBy(orderBy, descending: descending)
          .limit(10)
          .get();
    } else {
      data = await firebaseFirestoree
          .collection('channels')
          .orderBy(orderBy, descending: descending)
          .startAfter([_lastVisible![orderBy]])
          .limit(10)
          .get();
    }
    if (data.docs.isNotEmpty) {
      _lastVisible = data.docs[data.docs.length - 1];
      _isLoading = false;
      _hasData = true;
      _data.addAll(data.docs);
      notifyListeners();
    } else {
      if (_lastVisible == null) {
        _isLoading = false;
        _hasData = false;
        notifyListeners();
      } else {
        _isLoading = false;
        _hasData = true;
        showSnackbar(context!, 'No more channels available');
        notifyListeners();
      }
    }
  }
}
