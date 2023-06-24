import 'dart:convert';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dellenhauer_admin/constants.dart';
import 'package:dellenhauer_admin/model/channel/channel_model.dart';
import 'package:dellenhauer_admin/model/channel/participant_model.dart';
import 'package:dellenhauer_admin/model/notification/push_notification_model.dart';
import 'package:dellenhauer_admin/model/users/user_model.dart';
import 'package:firebase_storage/firebase_storage.dart';
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
  final FirebaseStorage storage = FirebaseStorage.instance;
  bool _isLoadingMoreContent = false;
  bool get isLoadingMoreContent => _isLoadingMoreContent;
  final List<String> _relatedChannels = [];
  List<String> get relatedChannels => _relatedChannels;
  final List<ChannelModel> _selectedNotificationChannels = [];
  List<ChannelModel> get selectedNotificationChannels =>
      _selectedNotificationChannels;
  ChannelModel? _selectedChannelPushNotification;
  ChannelModel? get selectedChannelPushNotification =>
      _selectedChannelPushNotification;

  void setSingleSelectedNotificationChannel(ChannelModel? channelModel) {
    _selectedChannelPushNotification = channelModel;
    notifyListeners();
  }

  void setSelectedNotificationChannels(ChannelModel channelModel) {
    _selectedNotificationChannels.add(channelModel);
    notifyListeners();
  }

  void removeSelectedNotificationChannels(String channelId) {
    _selectedNotificationChannels
        .removeWhere((element) => element.groupId == channelId);
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
    DocumentSnapshot dSnapshot =
        await firebaseFirestore.collection('channels').doc(channelId).get();

    if (dSnapshot.exists) {
      Map<String, dynamic> data = dSnapshot.data() as dynamic;
      DocumentSnapshot documentSnapshot = await firebaseFirestore
          .collection('channels')
          .doc(channelId)
          .collection(isModerator ? 'moderators' : 'members')
          .doc(userId)
          .get();
      if (!documentSnapshot.exists) {
        await firebaseFirestore
            .collection('channels')
            .doc(channelId)
            .collection(isModerator ? 'moderators' : 'members')
            .doc(userId)
            .set(
              ParticipantModel(
                      isNotificationEnabled: true,
                      uid: userId,
                      joinedAt: DateTime.now().millisecondsSinceEpoch)
                  .toMap(),
              SetOptions(merge: true),
            );
        if (data.containsKey(
                isModerator ? 'totalModerators' : 'totalMembers') &&
            data[isModerator ? 'totalModerators' : 'totalMembers'] >= 0) {
          await firebaseFirestore.collection('channels').doc(channelId).update({
            isModerator ? 'totalModerators' : 'totalMembers':
                FieldValue.increment(1),
          });
        }
        await firebaseFirestore.collection('users').doc(userId).update({
          'joinedChannels': FieldValue.arrayUnion([channelId])
        });
        if (isModerator) {
          sendModeratorPushNotification(
            userId: userId,
            message:
                'Du bist nun Moderator von $channelName und kannst den Channel verwalten',
            title: 'Als Moderator hinzugefügt',
            channelId: channelId,
            channelName: channelName,
          );
        }
      }
    }
  }

  // removing id from collection
  Future<void> removeUserFromChannel({
    required String userId,
    required bool isModerator,
    required String channelId,
    required String channelName,
  }) async {
    DocumentSnapshot dSnapshot =
        await firebaseFirestore.collection('channels').doc(channelId).get();

    if (dSnapshot.exists) {
      Map<String, dynamic> data = dSnapshot.data() as dynamic;
      DocumentSnapshot dReference = await firebaseFirestore
          .collection('channels')
          .doc(channelId)
          .collection(isModerator ? 'moderators' : 'members')
          .doc(userId)
          .get();
      if (dReference.exists) {
        await firebaseFirestore
            .collection('channels')
            .doc(channelId)
            .collection(isModerator ? 'moderators' : 'members')
            .doc(userId)
            .delete();

        if (data.containsKey(
                isModerator ? 'totalModerators' : 'totalMembers') &&
            data[isModerator ? 'totalModerators' : 'totalMembers'] > 0) {
          await firebaseFirestore.collection('channels').doc(channelId).update({
            isModerator ? 'totalModerators' : 'totalMembers':
                FieldValue.increment(-1),
          });
        }
        await firebaseFirestore.collection('users').doc(userId).update({
          'joinedChannels': FieldValue.arrayRemove([channelId])
        });
        if (isModerator) {
          sendModeratorPushNotification(
            userId: userId,
            message: 'Sie wurden als Moderator von $channelName entfernt',
            title: 'Als Moderator entfernt',
            channelId: channelId,
            channelName: channelName,
          );
        }
      }
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

  // deleting a channel from databse
  Future<void> deleteChannelFromDatabase({
    required String channelId,
  }) async {
    await firebaseFirestore.collection('channels').doc(channelId).delete();
  }

  Future<String> storeFileToFirebase(String ref, Uint8List data) async {
    UploadTask uploadTask = storage.ref().child(ref).putData(data);
    await uploadTask;
    String downloadUrl = await storage.ref(ref).getDownloadURL();
    return downloadUrl;
  }

  Future<void> sendModeratorPushNotification({
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
            Uri.parse(Contants.firebaseUrl),
            headers: {
              HttpHeaders.contentTypeHeader: 'application/json',
              HttpHeaders.authorizationHeader:
                  Contants.authorizationHeaderFCMDev,
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
      print(e);
    }
  }
}
