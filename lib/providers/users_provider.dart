import 'dart:html';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dellenhauer_admin/model/awards/awards_model.dart';
import 'package:dellenhauer_admin/model/courses/courses_model.dart';
import 'package:dellenhauer_admin/model/users/user_model.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class UsersProvider extends ChangeNotifier {
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
  List<AwardsModel> _selectedUserAwards = [];
  List<AwardsModel> get selectedUserAwards => _selectedUserAwards;
  List<CoursesModel> _selectedCourses = [];
  List<CoursesModel> get selectedCourses => _selectedCourses;
  List<UserModel> _selectedNotificationUser = [];
  List<UserModel> get selectedNotificationUser => _selectedNotificationUser;
  UserModel? _selectedTestNotificationUser;
  UserModel? get selectedTestNotificationUser => _selectedTestNotificationUser;
  UserModel? _invitedByUser;
  UserModel? get invitedByUser => _invitedByUser;

  void setSelectedTestUser(UserModel userModel) {
    _selectedTestNotificationUser = userModel;
    notifyListeners();
  }

  void setInvitedByUser(UserModel userModel) {
    _invitedByUser = userModel;
    notifyListeners();
  }

  void removeInvitedByUser() {
    _invitedByUser = null;
    notifyListeners();
  }

  void removeSelectedTestUser() {
    _selectedTestNotificationUser = null;
    notifyListeners();
  }

  void setSelectedUserForNotification(UserModel userModel) {
    _selectedNotificationUser.add(userModel);
    notifyListeners();
  }

  void removeSelectedUserForNoticiation(String userId) {
    _selectedNotificationUser
        .removeWhere((element) => element.userId == userId);
    notifyListeners();
  }

  void attachContext(BuildContext context) {
    this.context = context;
  }

  void setselectedUserAwards(AwardsModel awardsModel) {
    _selectedUserAwards.add(awardsModel);
    notifyListeners();
  }

  void setSelectedCourses(CoursesModel coursesModel) {
    _selectedCourses.add(coursesModel);
    notifyListeners();
  }

  void setLoading({bool isLoading = false}) {
    _isLoading = isLoading;
    notifyListeners();
  }

  void loadingMoreContent({bool isLoading = false}) {
    _isLoadingMoreContent = isLoading;
    notifyListeners();
  }

  void removeSelectUserAwards(String awardId) {
    _selectedUserAwards.removeWhere((element) => element.id == awardId);
    notifyListeners();
  }

  void removeSelectCourses(String courseId) {
    _selectedCourses.removeWhere((element) => element.id == courseId);

    notifyListeners();
  }

  void setLastVisible({DocumentSnapshot? snapshot}) {
    _lastVisible = snapshot;
    notifyListeners();
  }

  // get users data
  Future<void> getUsersData({
    required String orderBy,
    required bool descending,
  }) async {
    QuerySnapshot querySnapshot;
    if (_lastVisible == null) {
      querySnapshot = await firebaseFirestore
          .collection('users')
          .orderBy(orderBy, descending: descending)
          .limit(15)
          .get();
    } else {
      querySnapshot = await firebaseFirestore
          .collection('users')
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

  // getting userdata form userId
  Future<UserModel?> getUserDataFromId(String userId) async {
    DocumentSnapshot documentSnapshot =
        await firebaseFirestore.collection('users').doc(userId).get();
    UserModel? userData =
        UserModel.fromJson(documentSnapshot.data() as dynamic);
    return userData;
  }

  // adding awards data to usermodel
  Future<void> addAwardsDataToUser(
      {required AwardsModel awardsModel, required String userId}) async {
    /*
        going to user collection and then
        adding a new array item under awards heading
        then adding the awardsmodel data
        */
    await firebaseFirestore.collection('users').doc(userId).update({
      'awards': FieldValue.arrayUnion([awardsModel.toMap()]),
    });
  }

  // deleting a user
  Future<void> deletingUser({required String userId}) async {
    await firebaseFirestore.collection('users').doc(userId).delete();
  }

  // updating existing data
  Future<void> updateUserData(
      {required UserModel userModel,
      required String userId,
      required bool activatePush}) async {
    try {
      await firebaseFirestore.collection('users').doc(userId).update({
        'firstName': userModel.firstName,
        'lastName': userModel.lastName,
        'nickname': userModel.nickname,
        'awards': userModel.awardsModel!.map((e) => e.toMap()).toList(),
        'courses': userModel.coursesModel!.map((e) => e.toMap()).toList(),
        'email': userModel.email,
        'bio': userModel.bio,
        'is_premium_user': userModel.isPremiumUser,
        'isVerified': userModel.isVerified,
        'invited_by': userModel.invitedBy,
        'phoneNumber': userModel.phoneNumber,
        'websiteUrl': userModel.websiteUrl,
      });

      DocumentSnapshot documentSnapshot =
          await firebaseFirestore.collection('users').doc(userId).get();
      if (documentSnapshot.exists) {
        String fcmToken = documentSnapshot['fcmToken'];
        if (fcmToken.trim().isNotEmpty) {
          QuerySnapshot query = await firebaseFirestore
              .collection('devices')
              .where('fcmToken', isEqualTo: userModel.fcmToken)
              .get();
          if (query.docs.isNotEmpty) {
            await firebaseFirestore
                .collection('devices')
                .doc(query.docs[0].id)
                .update({'activatePush': activatePush});
          }
        }
      }
    } catch (e) {
      print(e.toString());
    }
  }

  Future<bool> determineActivatePushForUser(String userId) async {
    try {
      DocumentSnapshot documentSnapshot =
          await firebaseFirestore.collection('users').doc(userId).get();
      if (documentSnapshot.exists) {
        UserModel userModel =
            UserModel.fromJson(documentSnapshot.data() as dynamic);
        String fcmToken = userModel.fcmToken!;
        if (fcmToken.trim().isNotEmpty) {
          QuerySnapshot query = await firebaseFirestore
              .collection('devices')
              .where('fcmToken', isEqualTo: fcmToken)
              .get();
          if (query.docs.isNotEmpty) {
            bool activatePush = query.docs[0]['activatePush'];
            return activatePush;
          } else {
            return false;
          }
        } else {
          return false;
        }
      } else {
        return false;
      }
    } catch (e) {
      if (kDebugMode) {
        print(e);
      }
      return false;
    }
  }
}
