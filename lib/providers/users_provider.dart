import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dellenhauer_admin/constants.dart';
import 'package:dellenhauer_admin/model/awards/awards_model.dart';
import 'package:dellenhauer_admin/model/channel/channel_model.dart';
import 'package:dellenhauer_admin/model/courses/courses_model.dart';
import 'package:dellenhauer_admin/model/users/invitation_model.dart';
import 'package:dellenhauer_admin/model/users/user_model.dart';
import 'package:dellenhauer_admin/api_service.dart';
import 'package:dellenhauer_admin/pages/pending_users/pending_users_provider.dart';
import 'package:dellenhauer_admin/utils/utils.dart';
import 'package:dio/dio.dart';
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
  final List<DocumentSnapshot> _data = [];
  List<DocumentSnapshot> get data => _data;
  final FirebaseFirestore firebaseFirestore = FirebaseFirestore.instance;
  final List<AwardsModel> _selectedUserAwards = [];
  List<AwardsModel> get selectedUserAwards => _selectedUserAwards;
  final List<CoursesModel> _selectedCourses = [];
  List<CoursesModel> get selectedCourses => _selectedCourses;
  final List<String> _selectedNotificationUser = [];
  List<String> get selectedNotificationUser => _selectedNotificationUser;
  UserModel? _selectedTestNotificationUser;
  UserModel? get selectedTestNotificationUser => _selectedTestNotificationUser;
  UserModel? _invitedByUser;
  UserModel? get invitedByUser => _invitedByUser;
  String? _currentUserUniqueCode;
  String? get currentUserUniqueCode => _currentUserUniqueCode;
  final Dio dio = Dio(BaseOptions(headers: {
    'X-API-KEY': AppConstants.dellenhauereBestCMSKey,
  }));

  // create new channel's section
  final List<UserModel> _createNewChannelUsers = [];
  List<UserModel> get createNewChannelUsers => _createNewChannelUsers;
  final List<UserModel> _createNewModerators = [];
  List<UserModel> get createNewModerators => _createNewModerators;

  final ApiService _postDataHelper = ApiService();
  void addNewUser({
    required UserModel userModel,
    required bool isModerator,
  }) {
    if (isModerator) {
      _createNewModerators.add(userModel);
    } else {
      _createNewChannelUsers.add(userModel);
    }
    notifyListeners();
  }

  void removeNewUser({
    required String userId,
    required bool isModerator,
  }) {
    if (isModerator) {
      _createNewModerators.removeWhere((element) => element.userId == userId);
    } else {
      _createNewChannelUsers.removeWhere((element) => element.userId == userId);
    }
    notifyListeners();
  }

  // targets
  UserModel? _selectedUserForPushNotification;
  UserModel? get selectedUserForPushNotification =>
      _selectedUserForPushNotification;

  void setSelectedPushNotificationUser(UserModel? userModel) {
    _selectedUserForPushNotification = userModel;
    notifyListeners();
  }

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

  void setSelectedUserForNotification(String userId) {
    _selectedNotificationUser.add(userId);
    notifyListeners();
  }

  void removeSelectedUserForNoticiation(String userId) {
    _selectedNotificationUser.removeWhere((element) => element == userId);
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

  Future<bool> checkUniqueUsername({required String username}) async {
    try {
      QuerySnapshot querySnapshot;
      querySnapshot = await firebaseFirestore
          .collection("users")
          .where("nickname", isEqualTo: username)
          .get();

      return querySnapshot.docs.isEmpty;
    } catch (e) {
      return false;
    }
  }

  Future<bool> checkEmailAddress({required String email}) async {
    try {
      QuerySnapshot querySnapshot;
      querySnapshot = await firebaseFirestore
          .collection("users")
          .where("email", isEqualTo: email)
          .get();

      return querySnapshot.docs.isEmpty;
    } catch (e) {
      return false;
    }
  }

  // getting userdata form userId
  Future<UserModel?> getUserDataFromId({
    required String userId,
  }) async {
    DocumentSnapshot documentSnapshot =
        await firebaseFirestore.collection('users').doc(userId).get();
    UserModel? userData = UserModel.fromJson(
      documentSnapshot.data() as dynamic,
    );
    return userData;
  }

  // adding awards data to usermodel
  Future<void> addAwardsDataToUser({
    required AwardsModel awardsModel,
    required String userId,
  }) async {
    await firebaseFirestore.collection('users').doc(userId).update({
      'awards': FieldValue.arrayUnion([awardsModel.toMap()]),
    });
  }

  // updating existing data
  Future<void> updateUserData({
    required UserModel userModel,
    bool activatePush = false,
    Uint8List? imageFile,
    required PendingUsersProvider pendingUsersProvider,
  }) async {
    try {
      DocumentReference userRef =
          firebaseFirestore.collection('users').doc(userModel.userId);
      DocumentSnapshot lastestSnapshot = await userRef.get();
      UserModel latestUserModel =
          UserModel.fromJson(lastestSnapshot.data() as dynamic);

      // Extracting old and new states for comparison
      bool oldIsVerified = latestUserModel.isVerified ?? false;
      bool newIsVerified = userModel.isVerified ?? false;
      String? oldInvitedBy = latestUserModel.invitedBy;
      String? newInvitedBy = userModel.invitedBy;

      // Prepare user data update map
      Map<String, dynamic> userDataUpdate = {
        'firstName': userModel.firstName,
        'lastName': userModel.lastName,
        'nickname': userModel.nickname,
        'email': userModel.email,
        'bio': userModel.bio,
        'is_premium_user': userModel.isPremiumUser,
        'phoneNumber': userModel.phoneNumber,
        'websiteUrl': userModel.websiteUrl,
        'isOnline': userModel.isOnline,
      };

      // Handle profile picture upload if present
      if (imageFile != null) {
        String profilePicUrl = await storeFileToFirebase(
          'profilePic/${userModel.userId}',
          imageFile,
        );
        userDataUpdate['profilePic'] = profilePicUrl;
      }
      bool invitedByCleared = oldInvitedBy != null &&
          (newInvitedBy == null || newInvitedBy.trim().isEmpty);
      bool invitedByChanged = oldInvitedBy != newInvitedBy &&
          newInvitedBy != null &&
          newInvitedBy.trim().isNotEmpty;

      if (invitedByChanged || invitedByCleared) {
        userDataUpdate['invited_by'] = newInvitedBy ?? '';
        userDataUpdate['invited_timestamp'] = newInvitedBy != null
            ? userModel.invitedTimestamp ??
                DateTime.now().millisecondsSinceEpoch.toString()
            : '';

        if (invitedByChanged && newIsVerified) {
          await addInvitedByUserCurrentInvitation(
            currentUserId: userModel.userId!,
            referedUserId: newInvitedBy,
          );
        }
      }
      if (oldIsVerified != newIsVerified) {
        userDataUpdate['isVerified'] = newIsVerified;
        if (newIsVerified) {
          if (latestUserModel.wordpressCMSuserId == null ||
              latestUserModel.wordpressCMSuserId.toString().isNotEmpty) {
            int code = await addingUserToCMSWordpress(
              userModel: userModel,
            );
            if (code != 0) {
              userDataUpdate['wordpress_cms_userid'] = code;
            }
          }
        }
      }
      if (invitedByCleared && oldInvitedBy.trim().isNotEmpty) {
        await removeInvitedByUserCurrentInvitation(
          currentUserId: userModel.userId!,
          referedUserId: oldInvitedBy,
        );
      }

      await userRef.update(userDataUpdate);
      if (userModel.wordpressCMSuserId != null) {
        await _postDataHelper.updateUserData({
          'wordpress_cms_userid': userModel.wordpressCMSuserId,
          'firstName': userModel.firstName,
          'lastName': userModel.lastName,
          'websiteUrl': userModel.websiteUrl,
        });
      }
      await _updatePushActivation(userModel.userId!, activatePush);
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  Future<void> _updatePushActivation(String userId, bool activatePush) async {
    DocumentSnapshot userDoc =
        await firebaseFirestore.collection('users').doc(userId).get();
    String fcmToken = userDoc['fcmToken'] ?? '';
    if (fcmToken.isNotEmpty) {
      QuerySnapshot deviceQuery = await firebaseFirestore
          .collection('devices')
          .where('fcmToken', isEqualTo: fcmToken)
          .get();

      if (deviceQuery.docs.isNotEmpty) {
        await firebaseFirestore
            .collection('devices')
            .doc(deviceQuery.docs.first.id)
            .update({'activatePush': activatePush});
      }
    }
  }

  Future<void> removeInvitedByUserCurrentInvitation({
    required String currentUserId,
    required String referedUserId,
  }) async {
    if (referedUserId.trim().isNotEmpty) {
      try {
        QuerySnapshot qSnapshot = await firebaseFirestore
            .collection('invitations')
            .doc(referedUserId)
            .collection('user_invitations')
            .where('accepted_user_id', isEqualTo: currentUserId)
            .get();
        if (qSnapshot.docs.isEmpty) return;
        final batch = firebaseFirestore.batch();
        for (DocumentSnapshot doc in qSnapshot.docs) {
          batch.delete(doc.reference);
        }
        await batch.commit();
      } catch (e) {
        debugPrint('Error removing invited by user current invitation: $e');
      }
    }
  }

  Future<int> addingUserToCMSWordpress({
    required UserModel userModel,
  }) async {
    debugPrint('adding user to cms sytem');
    int code = 0;
    try {
      final Response response =
          await dio.post(AppConstants.cmsWordpressUserCreate, data: {
        'firstName': userModel.firstName,
        'lastName': userModel.lastName,
        'email': userModel.email,
        'nickname': userModel.nickname,
        'websiteUrl': userModel.websiteUrl,
        'phoneNumber': userModel.phoneNumber,
        'invited_by': userModel.invitedBy,
        'userId': userModel.userId,
      });
      if (response.statusCode == 200) {
        code = response.data['user_id'];
      }
    } catch (e) {
      debugPrint(e.toString());
    }
    return code;
  }

  Future<void> addInvitedByUserCurrentInvitation({
    required String currentUserId,
    required String referedUserId,
  }) async {
    if (referedUserId.trim().isNotEmpty) {
      await firebaseFirestore
          .collection('invitations')
          .doc(referedUserId)
          .collection('user_invitations')
          .add(InvitationModel(
            acceptedTimestamp: DateTime.now().millisecondsSinceEpoch.toString(),
            acceptedUserId: currentUserId,
            createdUserId: referedUserId,
          ).toJson());
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

  Future<void> getCurrentUserInviteCode(String userId) async {
    DocumentSnapshot doc =
        await firebaseFirestore.collection('invitations').doc(userId).get();
    setCurrentUserUniqueCode(doc['unique_code']);
  }

  void setCurrentUserUniqueCode(String? string) {
    _currentUserUniqueCode = string;
    notifyListeners();
  }

  Future<Map<String, dynamic>> getInvitedUsers(String userId) async {
    Map<String, dynamic> finalData = {};

    QuerySnapshot<Map<String, dynamic>> snapshot = await firebaseFirestore
        .collection('invitations')
        .doc(userId)
        .collection('user_invitations')
        .get();

    if (snapshot.docs.isNotEmpty) {
      List<Future> futures = [];

      // We now store both the Future and the associated InvitationModel in a tuple
      for (var data in snapshot.docs) {
        InvitationModel inviteduserData = InvitationModel.fromJson(data.data());
        futures.add(
          Future.value({
            'future': firebaseFirestore
                .collection('users')
                .doc(inviteduserData.acceptedUserId)
                .get(),
            'invitation': inviteduserData,
          }),
        );
      }

      // Wait for all the Futures to complete
      var results = await Future.wait(futures);
      int index = 1;

      for (var result in results) {
        DocumentSnapshot doc = await result['future'];
        InvitationModel invitation = result['invitation'];

        if (doc.exists) {
          UserModel userData = UserModel.fromJson(doc.data() as dynamic);
          finalData[index.toString()] = {
            'firstName': userData.firstName,
            'lastName': userData.lastName,
            'profilePic': userData.profilePic,
            'nickname': userData.nickname,
            'acceptedAt': invitation.acceptedTimestamp,
          };
          index += 1;
        }
      }
    }

    return finalData;
  }

  Future<ChannelModel?> getChannelData({required String channelId}) async {
    ChannelModel? channelData;
    try {
      DocumentSnapshot snapshot =
          await firebaseFirestore.collection('channels').doc(channelId).get();
      if (snapshot.exists) {
        channelData = ChannelModel.fromMap(snapshot.data() as dynamic);
      }
    } catch (e) {
      if (kDebugMode) {
        print(e);
      }
    }
    return channelData;
  }
}
