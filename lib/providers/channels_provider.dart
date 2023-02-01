import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dellenhauer_admin/model/channel/channel_model.dart';
import 'package:dellenhauer_admin/model/users/user_model.dart';
import 'package:dellenhauer_admin/utils/utils.dart';
import 'package:flutter/material.dart';

class ChannelProvider extends ChangeNotifier {
  BuildContext? context;
  bool _isLoading = false;
  bool get isLoading => _isLoading;

  final FirebaseFirestore firebaseFirestore = FirebaseFirestore.instance;

  void attachContext(BuildContext context) {
    this.context = context;
  }

  // getting user model from list of users
  Future<List<UserModel>> getUserDataFromUserId({
    isReload = true,
    required String groupId,
    required bool isModerator,
  }) async {
    // getting the channel data first
    List<UserModel> userData = [];
    List<String> id = [];
    await firebaseFirestore
        .collection('channels')
        .doc(groupId)
        .get()
        .then((value) async {
      ChannelModel channelData = ChannelModel.fromMap(value.data() as dynamic);

      if (isModerator) {
        id.addAll(channelData.moderatorsId);
      } else {
        id.addAll(channelData.membersId);
      }
    });

    // getting data from user id
    for (var userId in id) {
      await firebaseFirestore
          .collection('users')
          .doc(userId)
          .get()
          .then((value) {
        if (value.exists) {
          userData.add(UserModel.fromJson(value.data() as dynamic));
        }
      });
    }
    return userData;
  }

  // removing id from collection
  Future<void> removeUserFromChannel(
      {required String userId,
      required bool isModerator,
      required String channelId}) async {
    await firebaseFirestore
        .collection('channels')
        .doc(channelId)
        .update(isModerator
            ? {
                'moderators_id': FieldValue.arrayRemove([userId])
              }
            : {
                'members_id': FieldValue.arrayRemove([userId])
              });
  }

  // updating channel data
  Future<void> updateChannelData({
    required String channelName,
    required String channelDescription,
    required bool autoJoin,
    required bool readOnly,
    required bool joinAccessRequired,
    required String visibility,
    required String channelId,
  }) async {
    _isLoading = true;
    notifyListeners();
    await firebaseFirestore.collection('channels').doc(channelId).update({
      'channel_name': channelName,
      'channel_description': channelDescription,
      'channel_autojoin': autoJoin,
      'channel_readonly': readOnly,
      'join_access_required': joinAccessRequired,
      'visibility': visibility,
    }).whenComplete(() {
      _isLoading = false;
      notifyListeners();
    });
  }

  // deleting a channel from databse
  Future<void> deleteChannelFromDatabase({
    required String channelId,
  }) async {
    await firebaseFirestore.collection('channels').doc(channelId).delete();
  }
}
