import 'dart:convert';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dellenhauer_admin/constants.dart';
import 'package:dellenhauer_admin/model/channel/channel_model.dart';
import 'package:dellenhauer_admin/model/channel/participant_model.dart';
import 'package:dellenhauer_admin/model/notification/push_notification_model.dart';
import 'package:dellenhauer_admin/model/requests/requests_model.dart';
import 'package:dellenhauer_admin/model/users/user_model.dart';
import 'package:dellenhauer_admin/utils/utils.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class ChannelProvider extends ChangeNotifier {
  BuildContext? context;
  bool _isLoading = false;
  bool get isLoading => _isLoading;
  DocumentSnapshot? _lastVisible;
  DocumentSnapshot? get lastVisible => _lastVisible;
  bool _hasData = false;
  bool get hasData => _hasData;
  List<DocumentSnapshot> _channelData = [];
  List<DocumentSnapshot> get channelData => _channelData;
  final FirebaseFirestore firebaseFirestore = FirebaseFirestore.instance;
  bool _isLoadingMoreContent = false;
  bool get isLoadingMoreContent => _isLoadingMoreContent;
  final List<String> _relatedChannels = [];
  List<String> get relatedChannels => _relatedChannels;
  // select notification channels
  final List<String> _selectedNotificationChannels = [];
  List<String> get selectedNotificationChannels =>
      _selectedNotificationChannels;
  ChannelModel? _selectedChannelPushNotification;
  ChannelModel? get selectedChannelPushNotification =>
      _selectedChannelPushNotification;

  void setSingleSelectedNotificationChannel(ChannelModel? channelModel) {
    _selectedChannelPushNotification = channelModel;
    notifyListeners();
  }

  void setSelectedNotificationChannels(String channelId) {
    _selectedNotificationChannels.add(channelId);
    notifyListeners();
  }

  void removeSelectedNotificationChannels(String channelId) {
    _selectedNotificationChannels
        .removeWhere((element) => element == channelId);
    notifyListeners();
  }

  void attachContext(BuildContext context) {
    this.context = context;
  }

  void setRelatedChannel(String relatedChannelId) {
    _relatedChannels.add(relatedChannelId);
    notifyListeners();
  }

  void removeRelatedChannel(String relatedChannelId) {
    _relatedChannels.removeWhere((element) => element == relatedChannelId);
    notifyListeners();
  }

  void setLastVisible({DocumentSnapshot? documentSnapshot}) {
    _lastVisible = documentSnapshot;
    notifyListeners();
  }

  Future<void> getChannelData({
    required String orderBy,
    required bool descending,
  }) async {
    QuerySnapshot data;
    if (_lastVisible == null) {
      data = await firebaseFirestore
          .collection('channels')
          .orderBy(orderBy, descending: descending)
          .limit(10)
          .get();
    } else {
      data = await firebaseFirestore
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
      _channelData.addAll(data.docs);
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

  void setLoading({bool isLoading = false}) {
    _isLoading = isLoading;
    notifyListeners();
  }

  void loadingMoreContent({bool isLoading = false}) {
    _isLoadingMoreContent = isLoading;
    notifyListeners();
  }

  // getting user model form list of users
  Future<List<UserModel>> getSubCollectionUsers({
    bool isReload = true,
    required String groupId,
    required bool isModerator,
  }) async {
    List<UserModel> userData = [];
    DocumentSnapshot documentSnapshot =
        await firebaseFirestore.collection('channels').doc(groupId).get();
    if (documentSnapshot.exists) {
      QuerySnapshot query = await firebaseFirestore
          .collection('channels')
          .doc(groupId)
          .collection(isModerator ? 'moderators' : 'members')
          .get();
      for (var p in query.docs) {
        String userId = p.id;
        DocumentSnapshot documentSnapshot =
            await firebaseFirestore.collection('users').doc(userId).get();
        if (documentSnapshot.exists) {
          userData.add(UserModel.fromJson(documentSnapshot.data() as dynamic));
        }
      }
    }
    return userData;
  }

  Stream<List<UserModel>> getUserStream({
    required String groupId,
    required bool isModerator,
  }) {
    return firebaseFirestore
        .collection('channels')
        .doc(groupId)
        .collection(isModerator ? 'moderators' : 'members')
        .snapshots()
        .asyncMap((event) async {
      List<UserModel> finalUserList = [];
      for (var p in event.docs) {
        DocumentSnapshot snapshot =
            await firebaseFirestore.collection('users').doc(p.id).get();
        if (snapshot.exists) {
          finalUserList.add(UserModel.fromJson(snapshot.data() as dynamic));
        }
      }
      return finalUserList;
    });
  }

  Future<List<ChannelModel>> getChannelList() async {
    List<ChannelModel> channels = [];
    await firebaseFirestore.collection('channels').get().then((value) {
      for (var document in value.docs) {
        if (document.exists) {
          channels.add(ChannelModel.fromMap(document.data()));
        }
      }
    });
    return channels;
  }

  Stream<List<UserModel>> getUserList() {
    return firebaseFirestore.collection('users').snapshots().asyncMap((event) {
      List<UserModel> users = [];
      for (var document in event.docs) {
        users.add(UserModel.fromJson(document.data()));
      }
      return users;
    });
  }

  Future<void> addUserToChannel({
    required String userId,
    required bool isModerator,
    required String channelId,
    required String channelName,
  }) async {
    CollectionReference channelCollection =
        firebaseFirestore.collection('channels');
    DocumentSnapshot channelSnapshot =
        await channelCollection.doc(channelId).get();
    Map<String, dynamic> channelData = channelSnapshot.data() as dynamic;

    String roleToAdd = isModerator ? 'moderators' : 'members';
    String totalRoleToAdd = isModerator ? 'totalModerators' : 'totalMembers';

    DocumentSnapshot userRoleSnapshot = await channelCollection
        .doc(channelId)
        .collection(roleToAdd)
        .doc(userId)
        .get();

    if (!userRoleSnapshot.exists) {
      await channelCollection
          .doc(channelId)
          .collection(roleToAdd)
          .doc(userId)
          .set(
            ParticipantModel(
                    isNotificationEnabled: true,
                    uid: userId,
                    joinedAt: DateTime.now().millisecondsSinceEpoch)
                .toMap(),
            SetOptions(merge: true),
          );

      if (channelData.containsKey(totalRoleToAdd) &&
          channelData[totalRoleToAdd] >= 0) {
        await channelCollection.doc(channelId).update({
          totalRoleToAdd: FieldValue.increment(1),
        });
      }

      await firebaseFirestore.collection('users').doc(userId).update({
        'joinedChannels': FieldValue.arrayUnion([channelId])
      });

      await handleUserChannelRequests(channelId, userId, isApproved: true);

      if (isModerator) {
        sendSingleUserPushNotification(
          userId: userId,
          message:
              'Du bist nun Moderator von $channelName und kannst den Channel verwalten',
          title: 'Als Moderator hinzugefügt',
          channelId: channelId,
          channelName: channelName,
        );
      } else {
        sendSingleUserPushNotification(
          userId: userId,
          title: 'Einladung hinzugefügt',
          message: 'Du wurdest zum Channel $channelName eingeladen',
          channelId: channelId,
          channelName: channelName,
        );
      }
    }
  }

  Future<void> removeUserFromChannel({
    required String userId,
    required bool isModerator,
    required String channelId,
    required String channelName,
  }) async {
    CollectionReference channelCollection =
        firebaseFirestore.collection('channels');
    DocumentSnapshot channelSnapshot =
        await channelCollection.doc(channelId).get();
    if (!channelSnapshot.exists) {
      return;
    }

    String roleToRemove = isModerator ? 'moderators' : 'members';
    String totalRoleToRemove = isModerator ? 'totalModerators' : 'totalMembers';
    DocumentSnapshot userRoleSnapshot = await channelCollection
        .doc(channelId)
        .collection(roleToRemove)
        .doc(userId)
        .get();

    if (userRoleSnapshot.exists) {
      await channelCollection
          .doc(channelId)
          .collection(roleToRemove)
          .doc(userId)
          .delete();

      Map<String, dynamic> channelData = channelSnapshot.data() as dynamic;

      if (channelData.containsKey(totalRoleToRemove) &&
          channelData[totalRoleToRemove] > 0) {
        await channelCollection.doc(channelId).update({
          totalRoleToRemove: FieldValue.increment(-1),
        });
      }

      if (isModerator) {
        DocumentSnapshot memberRoleSnapshot = await channelCollection
            .doc(channelId)
            .collection('members')
            .doc(userId)
            .get();
        if (memberRoleSnapshot.exists) {
          await channelCollection
              .doc(channelId)
              .collection('members')
              .doc(userId)
              .delete();
          if (channelData.containsKey('totalMembers') &&
              channelData['totalMembers'] > 0) {
            await channelCollection.doc(channelId).update({
              'totalMembers': FieldValue.increment(-1),
            });
          }
        }
      }

      DocumentSnapshot remainingUserRoleSnapshot;
      if (isModerator) {
        remainingUserRoleSnapshot = await channelCollection
            .doc(channelId)
            .collection('members')
            .doc(userId)
            .get();
      } else {
        remainingUserRoleSnapshot = await channelCollection
            .doc(channelId)
            .collection('moderators')
            .doc(userId)
            .get();
      }

      if (!remainingUserRoleSnapshot.exists) {
        await firebaseFirestore.collection('users').doc(userId).update({
          'joinedChannels': FieldValue.arrayRemove([channelId])
        });
        await handleUserChannelRequests(channelId, userId, isApproved: false);
      }

      if (isModerator) {
        sendSingleUserPushNotification(
          userId: userId,
          message: 'Sie wurden als Moderator von $channelName entfernt',
          title: 'Als Moderator entfernt',
          channelId: channelId,
          channelName: channelName,
        );
      }
    }
  }

  Future<void> handleUserChannelRequests(
    String channelId,
    String userId, {
    required bool isApproved,
  }) async {
    DocumentSnapshot channelRequestUserSnapshot = await firebaseFirestore
        .collection('users')
        .doc(userId)
        .collection('channelRequests')
        .doc(channelId)
        .get();
    DocumentSnapshot channelRequestChannelSnapshot = await firebaseFirestore
        .collection('channels')
        .doc(channelId)
        .collection('requests')
        .doc(userId)
        .get();

    if (isApproved) {
      if (!channelRequestUserSnapshot.exists) {
        await firebaseFirestore
            .collection('users')
            .doc(userId)
            .collection('channelRequests')
            .doc(channelId)
            .set(
              UserRequetsCollection(channelId: channelId, accepted: true)
                  .toMap(),
              SetOptions(merge: true),
            );
      } else {
        await firebaseFirestore
            .collection('users')
            .doc(userId)
            .collection('channelRequests')
            .doc(channelId)
            .update(
          {'accepted': true},
        );
      }
      if (!channelRequestChannelSnapshot.exists) {
        await firebaseFirestore
            .collection('channels')
            .doc(channelId)
            .collection('requests')
            .doc(userId)
            .set(
              ChannelRequestModel(
                      userId: userId,
                      approvedBy: 'admin',
                      requestText: '',
                      createdAt:
                          DateTime.now().millisecondsSinceEpoch.toString(),
                      isApproved: true)
                  .toMap(),
              SetOptions(merge: true),
            );
      } else {
        await firebaseFirestore
            .collection('channels')
            .doc(channelId)
            .collection('requests')
            .doc(userId)
            .update({
          'approved_by': 'admin',
          'isApproved': true,
        });
      }
    } else {
      await firebaseFirestore
          .collection('users')
          .doc(userId)
          .collection('channelRequests')
          .doc(channelId)
          .delete();
      await firebaseFirestore
          .collection('channels')
          .doc(channelId)
          .collection('requests')
          .doc(userId)
          .delete();
    }
  }

  Future<bool> updateChannelData({
    required String channelName,
    required String channelDescription,
    required bool autoJoinWithRefCode,
    required bool autoJoinWithoutRefCode,
    required bool readOnly,
    required bool joinAccessRequired,
    Uint8List? imageFile,
    required String visibility,
    required String channelId,
    required List<String> relatedChannels,
    required bool allowUserConversation,
  }) async {
    _isLoading = true;
    notifyListeners();
    try {
      if (imageFile != null) {
        await storeFileToFirebase(
          'channels/profilePic/$channelId',
          imageFile,
        ).then((value) async {
          await firebaseFirestore.collection('channels').doc(channelId).update({
            'channel_name': channelName,
            'channel_description': channelDescription,
            'channel_autojoin_with_refcode': autoJoinWithRefCode,
            'allow_user_conversation': allowUserConversation,
            'channel_autojoin_without_refcode': autoJoinWithoutRefCode,
            'related_channels': FieldValue.arrayUnion(relatedChannels),
            'channel_readonly': readOnly,
            'channel_photo': value,
            'join_access_required': joinAccessRequired,
            'visibility': visibility,
          }).whenComplete(() {
            _isLoading = false;
            notifyListeners();
          });
        });
      } else {
        await firebaseFirestore.collection('channels').doc(channelId).update({
          'channel_name': channelName,
          'channel_description': channelDescription,
          'channel_autojoin_with_refcode': autoJoinWithRefCode,
          'channel_autojoin_without_refcode': autoJoinWithoutRefCode,
          'related_channels': FieldValue.arrayUnion(relatedChannels),
          'channel_readonly': readOnly,
          'allow_user_conversation': allowUserConversation,
          'join_access_required': joinAccessRequired,
          'visibility': visibility,
        }).whenComplete(() {
          _isLoading = false;
          notifyListeners();
        });
      }
      return true;
    } catch (e) {
      if (kDebugMode) {
        print(e);
      }
      return false;
    }
  }

  Future<void> deleteChannelFromDatabase(String channelId) async {
    final String url =
        '${AppConstants.cloudFunctionDevDeleteChannelFromDatabase}?channelId=$channelId';
    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      debugPrint('Successfully deleted channel and all references.');
    } else {
      debugPrint('Failed to delete channel: ${response.body}');
    }
  }

  Future<void> sendSingleUserPushNotification({
    required String userId,
    required String title,
    required String message,
    required String channelId,
    required String channelName,
  }) async {
    DocumentSnapshot documentSnapshot =
        await firebaseFirestore.collection('users').doc(userId).get();
    try {
      if (documentSnapshot.exists) {
        UserModel userData =
            UserModel.fromJson(documentSnapshot.data() as dynamic);
        if (userData.fcmToken != null && userData.fcmToken!.trim().isNotEmpty) {
          NotificationModel notificationModel = NotificationModel(
            badgeCount: true,
            receiverId: [userData.userId!],
            createdBy: 'admin',
            notificationImage: userData.profilePic,
            notificationTitle: title,
            notificationMessage: message,
            lowerVersionNotificationMessage: message.toString().toLowerCase(),
            notificationOpened: false,
            target: 'channel',
            href: channelId,
          );
          var notificationPayload = {
            'notification': {
              'title': title,
              'body': message,
              'sound': 'default',
            },
            'data': {
              'badgeCount': true,
              'target': 'channel',
              'href': channelId,
              'notificationImage': userData.profilePic,
              'click_action': 'FLUTTER_NOTIFICATION_CLICK',
              'senderId': 'admin',
              'name': channelName,
            },
            'registration_ids': [userData.fcmToken]
          };
          var res = await http.post(
            Uri.parse(AppConstants.firebaseUrl),
            headers: {
              HttpHeaders.contentTypeHeader: 'application/json',
              HttpHeaders.authorizationHeader:
                  AppConstants.authorizationHeaderFCMDev,
            },
            body: jsonEncode(notificationPayload),
          );
          if (res.statusCode == 200) {
            Map<String, dynamic> data = jsonDecode(res.body);
            if (data['results'][0]['message_id'] != null) {
              notificationModel.id = data['results'][0]['message_id'];
            } else {
              notificationModel.id = data['multicast_id'];
            }
            notificationModel.notificationSend = true;
            notificationModel.notificationSendTimestamp = DateTime.now();
            await firebaseFirestore.collection('notifications').add(
                  notificationModel.toMap(),
                );
          }
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print(e);
      }
    }
  }

  // create new channel
  Future<bool> createChannelData({
    required String channelName,
    required String channelDescription,
    required bool autoJoinWithRefCode,
    required bool autoJoinWithoutRefCode,
    required bool readOnly,
    required bool joinAccessRequired,
    Uint8List? imageFile,
    required String visibility,
    required List<String> relatedChannels,
    required List<UserModel> newUsers,
    required List<UserModel> newModerators,
  }) async {
    try {
      DocumentReference doc = firebaseFirestore.collection('channels').doc();
      String downloadUrl;
      if (imageFile != null) {
        downloadUrl = await storeFileToFirebase(
          'channels/profilePic/${doc.id}',
          imageFile,
        );
      } else {
        downloadUrl =
            'https://theperfectroundgolf.com/wp-content/uploads/2022/04/placeholder.png';
      }
      ChannelModel channelModel = ChannelModel(
        channelName: channelName,
        channelDescription: channelDescription,
        channelAutoJoinWithRefCode: autoJoinWithRefCode,
        channelAutoJoinWithoutRefCode: autoJoinWithoutRefCode,
        channelNotification: false,
        channelPhoto: downloadUrl,
        relatedChannel: relatedChannels,
        timeSent: DateTime.now(),
        onlineUsers: 0,
        totalMembers: 0,
        totalModerators: 0,
        visibility: visibility.toEnum(),
        lastMessage: '',
        groupId: doc.id,
        joinAccessRequired: joinAccessRequired,
        createdAt: DateTime.now().millisecondsSinceEpoch.toString(),
        channelReadOnly: readOnly,
      );
      // creating new entry is done
      await firebaseFirestore.collection('channels').doc(doc.id).set(
            channelModel.toMap(),
            SetOptions(merge: true),
          );

      for (UserModel user in newModerators) {
        await firebaseFirestore
            .collection('channels')
            .doc(channelModel.groupId)
            .collection('moderators')
            .doc(user.userId)
            .set(
                ParticipantModel(
                        isNotificationEnabled: true,
                        uid: user.userId!,
                        joinedAt: DateTime.now().millisecondsSinceEpoch)
                    .toMap(),
                SetOptions(merge: true));
        await firebaseFirestore.collection('users').doc(user.userId).update({
          'joinedChannels': FieldValue.arrayUnion([channelModel.groupId])
        });
        await firebaseFirestore
            .collection('channels')
            .doc(channelModel.groupId)
            .update({
          'totalModerators': FieldValue.increment(1),
        });
      }
      // adding users
      for (UserModel user in newUsers) {
        await firebaseFirestore
            .collection('channels')
            .doc(channelModel.groupId)
            .collection('members')
            .doc(user.userId)
            .set(
                ParticipantModel(
                        isNotificationEnabled: true,
                        uid: user.userId!,
                        joinedAt: DateTime.now().millisecondsSinceEpoch)
                    .toMap(),
                SetOptions(merge: true));
        await firebaseFirestore.collection('users').doc(user.userId).update({
          'joinedChannels': FieldValue.arrayUnion([channelModel.groupId])
        });
        await firebaseFirestore
            .collection('channels')
            .doc(channelModel.groupId)
            .update({
          'totalMembers': FieldValue.increment(1),
        });
      }

      return true;
    } catch (e) {
      if (kDebugMode) {
        print(e);
      }
      return false;
    }
  }

  // check channel name
  Future<bool> checkUniqueChannelName({required String channelName}) async {
    try {
      QuerySnapshot querySnapshot;
      querySnapshot = await firebaseFirestore
          .collection("channels")
          .where("channel_name", isEqualTo: channelName)
          .get();

      return querySnapshot.docs.isEmpty;
    } catch (e) {
      return false;
    }
  }
}
