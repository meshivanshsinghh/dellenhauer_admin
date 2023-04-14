import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dellenhauer_admin/constants.dart';
import 'package:dellenhauer_admin/model/channel/channel_model.dart';
import 'package:dellenhauer_admin/model/notification/job_model.dart';
import 'package:dellenhauer_admin/model/notification/push_notification_model.dart';
import 'package:dellenhauer_admin/model/users/user_model.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class PushNotificationMainProvider extends ChangeNotifier {
  BuildContext? context;
  final FirebaseFirestore firebaseFirestore = FirebaseFirestore.instance;
  final FirebaseMessaging firebaseMessaging = FirebaseMessaging.instance;
  bool _isSendingNotification = false;
  bool get isSendingNotification => _isSendingNotification;

  void setNotificationSending(bool isLoading) {
    _isSendingNotification = isLoading;
    notifyListeners();
  }

  void attachContext(BuildContext context) {
    this.context = context;
  }

  // send push notification to selected channels
  Future<void> sendPushNotificationToSelectedChannels({
    required String title,
    required String message,
    required bool badgeCount,
    DateTime? selectedDateTime,
    required List<ChannelModel> selectedChannels,
  }) async {
    List<String> fcmToken = [];
    try {
      for (var channelData in selectedChannels) {
        if (channelData.membersId == null && channelData.moderatorsId == null) {
          continue;
        }
        var userIds = [
          ...{...channelData.membersId!, ...channelData.moderatorsId!}
        ];
        if (userIds.isNotEmpty) {
          var userDocs = await firebaseFirestore
              .collection('users')
              .where(FieldPath.documentId, whereIn: userIds)
              .get();
          for (var userDoc in userDocs.docs) {
            UserModel userModel = UserModel.fromJson(userDoc.data());
            if (userModel.fcmToken == null ||
                userModel.fcmToken!.trim().isEmpty) {
              continue;
            }
            fcmToken.add(userModel.fcmToken!);
          }

          // notification model
          NotificationModel notificationModel = NotificationModel(
            badgeCount: badgeCount,
            receiverId: userIds.take(15).toList(),
            createdBy: 'admin',
            notificationImage: channelData.channelPhoto,
            notificationTitle: title,
            notificationMessage: message,
            lowerVersionNotificationMessage: message.toString().toLowerCase(),
            notificationOpened: false,
            target: 'channel',
            href: channelData.groupId,
          );
          List<String> updatedFcmTokens = fcmToken
              .where(
                  (element) => element.trim().isNotEmpty && element.isNotEmpty)
              .toList();
          if (selectedDateTime != null) {
            DocumentReference documentReference =
                firebaseFirestore.collection('jobs').doc();
            JobModel jobModel = JobModel(
              id: documentReference.id,
              title: title,
              message: message,
              badgeCount: badgeCount,
              selectedDateTime: selectedDateTime,
              fcmTokens: updatedFcmTokens,
              notificationModel: notificationModel,
            );
            await firebaseFirestore
                .collection('jobs')
                .doc(jobModel.id)
                .set(jobModel.toMap());
          } else {
            // payload
            var notificationPayload = {
              'notification': {
                'title': title,
                'body': message,
                'sound': 'default',
              },
              'data': {
                'badgeCount': badgeCount,
                'target': 'channel',
                'href': channelData.groupId,
                'notificationImage': channelData.channelPhoto,
                'click_action': 'FLUTTER_NOTIFICATION_CLICK',
                'senderId': 'admin',
                'name': channelData.channelName,
              },
              'registration_ids': updatedFcmTokens
            };
            var res = await http.post(
              Uri.parse(Contants.firebaseUrl),
              headers: {
                HttpHeaders.contentTypeHeader: 'application/json',
                HttpHeaders.authorizationHeader:
                    Contants.authorizationHeaderFCM,
              },
              body: jsonEncode(notificationPayload),
            );
            if (res.statusCode == 200) {
              Map<String, dynamic> data = jsonDecode(res.body);
              notificationModel.id = data['results'][0]['message_id'];
              notificationModel.notificationSend = true;
              notificationModel.notificationSendTimestamp = DateTime.now();
              await firebaseFirestore.collection('notifications').add(
                    notificationModel.toMap(),
                  );
            }
          }
        }
      }
    } on FirebaseException catch (e) {
      if (kDebugMode) {
        print(e);
      }
    }
  }

  // send push notification to selected users
  Future<void> sendPushNotificationToSelectedUsers({
    required String title,
    required String message,
    required bool badgeCount,
    DateTime? selectedDateTime,
    required List<UserModel> selectedUsers,
  }) async {
    try {
      List<String> fcmTokens = [];
      List<String> receiverId = [];
      for (var userData in selectedUsers) {
        if (userData.fcmToken == null || userData.fcmToken!.trim().isEmpty) {
          continue;
        }
        fcmTokens.add(userData.fcmToken!);
        receiverId.add(userData.userId!);
      }

      List<String> updatedFcmTokens = fcmTokens
          .where((element) => element.trim().isNotEmpty && element.isNotEmpty)
          .toList();

      NotificationModel notificationModel = NotificationModel(
        badgeCount: badgeCount,
        receiverId: receiverId,
        createdBy: 'admin',
        notificationTitle: title,
        notificationMessage: message,
        lowerVersionNotificationMessage: message.toLowerCase(),
        notificationOpened: false,
        target: 'user',
        notificationImage: '',
        href: '',
      );
      if (selectedDateTime != null) {
        DocumentReference documentReference =
            firebaseFirestore.collection('jobs').doc();
        JobModel jobModel = JobModel(
          id: documentReference.id,
          title: title,
          message: message,
          fcmTokens: updatedFcmTokens,
          selectedDateTime: selectedDateTime,
          notificationModel: notificationModel,
          badgeCount: badgeCount,
        );
        await firebaseFirestore
            .collection('jobs')
            .doc(jobModel.id)
            .set(jobModel.toMap());
      } else {
        // payload
        var notificationPayload = {
          'notification': {
            'title': title,
            'body': message,
            'sound': 'default',
          },
          'data': {
            'badgeCount': badgeCount,
            'target': 'user',
            'click_action': 'FLUTTER_NOTIFICATION_CLICK',
            'notificationImage': '',
            'href': '',
            'name': title,
          },
          'registration_ids': updatedFcmTokens,
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
          Map<String, dynamic> data = jsonDecode(res.body);
          notificationModel.id = data['results'][0]['message_id'];
          notificationModel.notificationSend = true;
          notificationModel.notificationSendTimestamp = DateTime.now();
          await firebaseFirestore.collection('notifications').add(
                notificationModel.toMap(),
              );
        }
      }
    } on FirebaseException catch (e) {
      if (kDebugMode) {
        print(e);
      }
    }
  }

  // send push notiication to all channels
  Future<void> sendPushNotificationToAllChannels({
    required String title,
    required String message,
    required bool badgeCount,
    DateTime? selectedDateTime,
    required String target,
  }) async {
    try {
      var channelDocs = await firebaseFirestore.collection('channels').get();
      List<String> fcmTokens = [];

      for (var channelDoc in channelDocs.docs) {
        ChannelModel channelModel = ChannelModel.fromMap(channelDoc.data());
        if (channelModel.membersId == null &&
            channelModel.moderatorsId == null) {
          continue;
        }
        var userIds = [
          ...{...channelModel.membersId!, ...channelModel.moderatorsId!}
        ];

        if (userIds.isNotEmpty) {
          fcmTokens.clear();
          var userDocs = await firebaseFirestore
              .collection('users')
              .where(FieldPath.documentId, whereIn: userIds)
              .get();

          for (var userDoc in userDocs.docs) {
            UserModel userModel = UserModel.fromJson(userDoc.data());
            if (userModel.fcmToken == null ||
                userModel.fcmToken!.trim().isEmpty) {
              continue;
            }
            fcmTokens.add(userModel.fcmToken!);
          }
          // notification model
          NotificationModel notificationModel = NotificationModel(
            badgeCount: badgeCount,
            receiverId: userIds.take(15).toList(),
            createdBy: 'admin',
            notificationImage: channelModel.channelPhoto,
            notificationTitle: title,
            notificationMessage: message,
            lowerVersionNotificationMessage: message.toLowerCase(),
            notificationOpened: false,
            target: target,
            href: channelModel.groupId,
          );
          List<String> updatedFcmTokens = fcmTokens
              .where((token) => token.trim().isNotEmpty && token.isNotEmpty)
              .toList();
          if (selectedDateTime != null) {
            DocumentReference documentReference =
                firebaseFirestore.collection('jobs').doc();
            JobModel jobModel = JobModel(
              id: documentReference.id,
              title: title,
              message: message,
              fcmTokens: updatedFcmTokens,
              selectedDateTime: selectedDateTime,
              notificationModel: notificationModel,
              badgeCount: badgeCount,
            );
            await firebaseFirestore
                .collection('jobs')
                .doc(jobModel.id)
                .set(jobModel.toMap());
          } else {
            // payload
            var notificationPayload = {
              'notification': {
                'title': title,
                'body': message,
                'sound': 'default',
              },
              'data': {
                'badgeCount': badgeCount,
                'target': target,
                'href': channelModel.groupId,
                'notificationImage': channelModel.channelPhoto,
                'click_action': 'FLUTTER_NOTIFICATION_CLICK',
                'senderId': 'admin',
                'name': channelModel.channelName,
              },
              'registration_ids': updatedFcmTokens,
            };
            var res = await http.post(
              Uri.parse(Contants.firebaseUrl),
              headers: {
                HttpHeaders.contentTypeHeader: 'application/json',
                HttpHeaders.authorizationHeader:
                    Contants.authorizationHeaderFCM,
              },
              body: jsonEncode(notificationPayload),
            );

            if (res.statusCode == 200) {
              Map<String, dynamic> data = jsonDecode(res.body);
              notificationModel.id = data['results'][0]['message_id'];
              notificationModel.notificationSend = true;
              notificationModel.notificationSendTimestamp = DateTime.now();
              await firebaseFirestore.collection('notifications').add(
                    notificationModel.toMap(),
                  );
            }
          }
        }
      }
    } on FirebaseException catch (e) {
      if (kDebugMode) {
        print(e);
      }
    }
  }

  Future<void> sendPushNotificationToAllUsers({
    required String title,
    required String message,
    required bool badgeCount,
    DateTime? selectedDateTime,
    required String target,
  }) async {
    try {
      List<String> fcmTokens = [];
      List<String> receiverId = [];
      var userDocs = await firebaseFirestore.collection('users').get();
      for (var userDoc in userDocs.docs) {
        UserModel userModel = UserModel.fromJson(userDoc.data());
        if (userModel.fcmToken == null || userModel.fcmToken!.trim().isEmpty) {
          continue;
        }
        fcmTokens.add(userModel.fcmToken!);
        receiverId.add(userModel.userId!);
      }
      List<String> updatedFcmTokens = fcmTokens
          .where((element) => element.trim().isNotEmpty && element.isNotEmpty)
          .toList();

      NotificationModel notificationModel = NotificationModel(
        badgeCount: badgeCount,
        receiverId: receiverId,
        createdBy: 'admin',
        notificationTitle: title,
        notificationMessage: message,
        lowerVersionNotificationMessage: message.toLowerCase(),
        notificationOpened: false,
        target: target,
        notificationImage: '',
        href: '',
      );
      if (selectedDateTime != null) {
        DocumentReference documentReference =
            firebaseFirestore.collection('jobs').doc();
        JobModel jobModel = JobModel(
          id: documentReference.id,
          title: title,
          message: message,
          fcmTokens: updatedFcmTokens,
          selectedDateTime: selectedDateTime,
          notificationModel: notificationModel,
          badgeCount: badgeCount,
        );
        await firebaseFirestore
            .collection('jobs')
            .doc(jobModel.id)
            .set(jobModel.toMap());
      } else {
        // payload
        var notificationPayload = {
          'notification': {
            'title': title,
            'body': message,
            'sound': 'default',
          },
          'data': {
            'badgeCount': badgeCount,
            'target': target,
            'click_action': 'FLUTTER_NOTIFICATION_CLICK',
            'notificationImage': '',
            'href': '',
            'name': title,
          },
          'registration_ids': updatedFcmTokens,
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
          Map<String, dynamic> data = jsonDecode(res.body);
          notificationModel.id = data['results'][0]['message_id'];
          notificationModel.notificationSend = true;
          notificationModel.notificationSendTimestamp = DateTime.now();
          await firebaseFirestore.collection('notifications').add(
                notificationModel.toMap(),
              );
        }
      }
    } on FirebaseException catch (e) {
      if (kDebugMode) {
        print(e);
      }
    }
  }

  // send notification to article
  Future<void> sendNotificationToArticle({
    required String title,
    required String message,
    DateTime? selectedTime,
    required bool badgeCount,
  }) async {
    // only limiting to all users
    // await sendPushNotificationToAllChannels(
    //   title: title,
    //   message: message,
    //   target: 'article',
    //   badgeCount: badgeCount,
    // );
    await sendPushNotificationToAllUsers(
      title: title,
      target: 'article',
      message: message,
      badgeCount: badgeCount,
    );
  }

  // send notification to url
  Future<void> sendNotificationToUrl({
    required String title,
    required String message,
    DateTime? selectedTime,
    required bool badgeCount,
  }) async {
    // only limiting to all users
    // await sendPushNotificationToAllChannels(
    //   title: title,
    //   message: message,
    //   target: 'website',
    //   badgeCount: badgeCount,
    // );
    await sendPushNotificationToAllUsers(
      title: title,
      target: 'website',
      message: message,
      badgeCount: badgeCount,
    );
  }
}
