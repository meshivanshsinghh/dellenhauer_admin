import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dellenhauer_admin/model/awards/awards_model.dart';
import 'package:dellenhauer_admin/model/courses/courses_model.dart';
import 'package:dellenhauer_admin/model/users/user_model.dart';
import 'package:dellenhauer_admin/utils/utils.dart';
import 'package:flutter/material.dart';

class UsersProvider extends ChangeNotifier {
  BuildContext? context;
  DocumentSnapshot? _lastVisible;
  DocumentSnapshot? get lastVisible => _lastVisible;
  bool _isLoading = false;
  bool get isLoading => _isLoading;
  bool _hasData = false;
  bool get hasData => _hasData;
  List<DocumentSnapshot> _data = [];
  List<DocumentSnapshot> get data => _data;
  final FirebaseFirestore firebaseFirestore = FirebaseFirestore.instance;
  List<AwardsModel> _selectedUserAwards = [];
  List<AwardsModel> get selectedUserAwards => _selectedUserAwards;
  List<CoursesModel> _selectedCourses = [];
  List<CoursesModel> get selectedCourses => _selectedCourses;

  void attachContext(BuildContext context) {
    this.context = context;
  }

  void setselectedUserAwards(AwardsModel awardsModel) {
    if (_selectedCourses.any((element) => element.id == awardsModel.id)) {
      showSnackbar(context!, 'Award already present in user list');
    } else {
      _selectedUserAwards.add(awardsModel);
      notifyListeners();
    }
  }

  void setSelectedCourses(CoursesModel coursesModel) {
    _selectedCourses.add(coursesModel);
    notifyListeners();
  }

  void setLoading({bool isLoading = false}) {
    _isLoading = isLoading;
    notifyListeners();
  }

  void removeSelectUserAwards(String awardId) {
    for (var d in _selectedUserAwards) {
      if (d.id == awardId) {
        _selectedUserAwards.remove(d);
      }
    }
    notifyListeners();
  }

  void removeSelectCourses(String courseId) {
    for (var d in _selectedCourses) {
      if (d.id == courseId) {
        _selectedCourses.remove(d);
      }
    }
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
        notifyListeners();
      } else {
        _isLoading = false;
        _hasData = true;
        showSnackbar(context!, 'No more users available!');
        notifyListeners();
      }
    }
  }

  // getting userdata form userId
  Future<UserModel> getUserDataFromId(String userId) async {
    UserModel? userData;
    await firebaseFirestore.collection('users').doc(userId).get().then((value) {
      if (value.exists) {
        userData = UserModel.fromJson(value.data() as dynamic);
      }
    });
    return userData!;
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
      {required UserModel userModel, required String userId}) async {
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
    } catch (e) {
      print(e.toString());
    }
  }
}
