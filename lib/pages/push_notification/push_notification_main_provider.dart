import 'dart:convert';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dellenhauer_admin/constants.dart';
import 'package:dellenhauer_admin/model/channel/channel_model.dart';
import 'package:dellenhauer_admin/model/notification/push_notification_model.dart';
import 'package:dellenhauer_admin/model/users/user_model.dart';
import 'package:dellenhauer_admin/utils/utils.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class PushNotificationMainProvider extends ChangeNotifier {
  BuildContext? context;
  final FirebaseFirestore firebaseFirestore = FirebaseFirestore.instance;
  final FirebaseMessaging firebaseMessaging = FirebaseMessaging.instance;
  void attachContext(BuildContext context) {
    this.context = context;
  }

  // sending push notification
  Future<void> sendPushNotificationToUser({
    required String userId,
    required String preview,
    required String message,
    required bool badgeCount,
  }) async {
    try {
      var userDoc =
          await firebaseFirestore.collection('users').doc(userId).get();
      if (userDoc.exists) {
        UserModel userData = UserModel.fromJson(userDoc.data()!);
        if (userData.fcmToken == null) {
          return;
        }
        // creating a notificaiton model
        NotificationModel notificationModel = NotificationModel(
          badgeCount: true,
          receiverId: [userId],
          createdBy: 'admin',
          notificationImage: userData.profilePic,
          notificationTitle: 'New Message from Admin',
          notificationMessage: message,
          notificationOpened: false,
          target: 'user',
          lowerVersionNotificationMessage: message.toLowerCase(),
          href: '',
        );
        // notification payload
        var notificationPayload = {
          'notification': {
            'title': 'New Message from Admin',
            'body': preview,
            'sound': 'default',
          },
          'data': {
            'badgeCount': badgeCount,
            'target': 'users',
            'href': '',
            'notificationImage': userData.profilePic,
            'click_action': 'FLUTTER_NOTIFICATION_CLICK',
            'name': 'New Message from Admin',
          },
          'to': userData.fcmToken,
        };
        var res = await http.post(
          Uri.parse(Contants.firebaseUrl),
          headers: {
            HttpHeaders.contentTypeHeader: 'application/json',
            HttpHeaders.authorizationHeader: Contants.authorizationHeaderFCM,
          },
          body: jsonEncode(notificationPayload),
        );

        if (res.statusCode == 200) {
          // saving to firebase console
          Map<String, dynamic> data = jsonDecode(res.body);
          notificationModel.id = data['results'][0]['message_id'];
          notificationModel.notificationSend = true;
          notificationModel.notificationSendTimestamp = DateTime.now();
          await firebaseFirestore
              .collection('notifications')
              .add(notificationModel.toMap());
        }
      }
    } on FirebaseException catch (e) {
      showSnackbar(context!, e.message.toString());
    }
  }

  // sending push notification to channels
  Future<void> sendPushNotificationToChannel({
    required String channelId,
    required String preview,
    required String message,
    required bool badge,
  }) async {
    try {
      var channelDoc =
          await firebaseFirestore.collection('channels').doc(channelId).get();
      if (channelDoc.exists) {
        ChannelModel channelModel = ChannelModel.fromMap(channelDoc.data()!);
        if (channelModel.membersId == null &&
            channelModel.moderatorsId == null) {
          return;
        }
        var userIds = [
          ...{...channelModel.membersId!, ...channelModel.moderatorsId!}
        ];
        var userDocs = await firebaseFirestore
            .collection('users')
            .where(FieldPath.documentId, whereIn: userIds)
            .get();
        List<String> fcmTokens = [];
        for (var userDoc in userDocs.docs) {
          UserModel userModel = UserModel.fromJson(userDoc.data());
          if (userModel.fcmToken == null) {
            continue;
          }
          fcmTokens.add(userModel.fcmToken!);
        }
        NotificationModel notificationModel = NotificationModel(
          badgeCount: true,
          receiverId: userIds.take(10).toList(),
          createdBy: 'admin',
          notificationImage: channelModel.channelPhoto,
          notificationTitle: 'New Message from Admin',
          notificationMessage: message,
          notificationOpened: false,
          target: 'user',
          lowerVersionNotificationMessage: message.toLowerCase(),
          href: '',
        );
        // payload
        var notificationPayload = {
          'notification': {
            'title': 'New Message from Admin',
            'body': preview,
            'sound': 'default',
          },
          'data': {
            'badgeCount': badge,
            'target': 'channel',
            'href': '',
            'notificationImage': channelModel.channelPhoto,
            'click_action': 'FLUTTER_NOTIFICATION_CLICK',
            'name': 'New Message from Admin',
            'message': message,
          },
          'to': fcmTokens,
        };
        var res = await http.post(
          Uri.parse(Contants.firebaseUrl),
          headers: {
            HttpHeaders.contentTypeHeader: 'application/json',
            HttpHeaders.authorizationHeader: Contants.authorizationHeaderFCM,
          },
          body: jsonEncode(notificationPayload),
        );

        if (res.statusCode == 200) {
          // saving to firebase console
          Map<String, dynamic> data = jsonDecode(res.body);
          notificationModel.id = data['results'][0]['message_id'];
          notificationModel.notificationSend = true;
          notificationModel.notificationSendTimestamp = DateTime.now();
          await firebaseFirestore
              .collection('notifications')
              .add(notificationModel.toMap());
        }
      }
    } on FirebaseException catch (e) {
      showSnackbar(context!, e.message.toString());
    }
  }
}
