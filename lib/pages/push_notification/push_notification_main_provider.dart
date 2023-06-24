import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dellenhauer_admin/constants.dart';
import 'package:dellenhauer_admin/model/channel/channel_model.dart';
import 'package:dellenhauer_admin/model/notification/job_model.dart';
import 'package:dellenhauer_admin/model/notification/push_notification_model.dart';
import 'package:dellenhauer_admin/model/users/user_model.dart';
import 'package:dellenhauer_admin/pages/push_notification/model/push_notification_article_model.dart';
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
  List<PushNotificationArticleModel> _articleData = [];
  List<PushNotificationArticleModel> get articleData => _articleData;
  PushNotificationArticleModel? _selectedArticle;
  PushNotificationArticleModel? get selectedArticle => _selectedArticle;
  bool _loading = false;
  bool get loading => _loading;

  void setLoading(bool setLoading) {
    _loading = setLoading;
    notifyListeners();
  }

  void setNotificationSending(bool isLoading) {
    _isSendingNotification = isLoading;
    notifyListeners();
  }

  void attachContext(BuildContext context) {
    this.context = context;
  }

  void setSelectedArticle(PushNotificationArticleModel article) {
    _selectedArticle = article;
    notifyListeners();
  }

  Future<void> getArticleData() async {
    try {
      _articleData.clear();
      const String url = 'https://dellenhauer.com/wp-json/bestcms/v1/article';
      final http.Response response = await http.get(Uri.parse(url), headers: {
        'X-API-KEY': 'WPAObiq6mx57kW9kpZFhOERymRu3SHin',
        'Connection': 'keep-alive',
        'Accept': '*/*',
        'Accept-Encoding': 'gzip,defalte,br',
      });
      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        for (var a in data) {
          _articleData.add(PushNotificationArticleModel.fromJson(a));
        }
      }
      notifyListeners();
    } catch (error) {
      _articleData = [];
      notifyListeners();
    }
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
        QuerySnapshot moderatorsQuery = await firebaseFirestore
            .collection('channels')
            .doc(channelData.groupId)
            .collection('moderators')
            .limit(10)
            .get();
        QuerySnapshot membersQuery = await firebaseFirestore
            .collection('channels')
            .doc(channelData.groupId)
            .collection('members')
            .limit(10)
            .get();

        if (moderatorsQuery.docs.isEmpty && membersQuery.docs.isEmpty) {
          continue;
        }

        var userIds = [
          ...{
            ...moderatorsQuery.docs.map((doc) => doc.id),
            ...membersQuery.docs.map((doc) => doc.id)
          }
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
            HttpHeaders.authorizationHeader: Contants.authorizationHeaderFCMDev,
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
        QuerySnapshot moderatorsQuery = await firebaseFirestore
            .collection('channels')
            .doc(channelModel.groupId)
            .collection('moderators')
            .limit(10)
            .get();
        QuerySnapshot membersQuery = await firebaseFirestore
            .collection('channels')
            .doc(channelModel.groupId)
            .collection('members')
            .limit(10)
            .get();

        if (moderatorsQuery.docs.isEmpty && membersQuery.docs.isEmpty) {
          continue;
        }
        var userIds = [
          ...{
            ...moderatorsQuery.docs.map((doc) => doc.id),
            ...membersQuery.docs.map((doc) => doc.id)
          }
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
    Map<String, dynamic>? payload,
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
        href: payload == null ? '' : payload['data']['href'],
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
        Map<String, dynamic> notificationPayload;
        if (payload == null) {
          notificationPayload = {
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
        } else {
          notificationPayload = payload;
          notificationPayload['registration_ids'] = updatedFcmTokens;
        }
        var res = await http.post(
          Uri.parse(Contants.firebaseUrl),
          headers: {
            HttpHeaders.contentTypeHeader: 'application/json',
            HttpHeaders.authorizationHeader: Contants.authorizationHeaderFCMDev,
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
    required String articleUrl,
    required bool badgeCount,
  }) async {
    await sendPushNotificationToAllUsers(
      title: title,
      target: 'article',
      message: message,
      payload: {
        'notification': {
          'title': title,
          'body': message,
          'sound': 'default',
        },
        'data': {
          'badgeCount': badgeCount,
          'target': 'article',
          'click_action': 'FLUTTER_NOTIFICATION_CLICK',
          'notificationImage': '',
          'href': articleUrl,
          'name': title,
        },
      },
      badgeCount: badgeCount,
    );
  }

  // send notification to url
  Future<void> sendNotificationToUrl({
    required String title,
    required String message,
    required String url,
    DateTime? selectedTime,
    required bool badgeCount,
  }) async {
    await sendPushNotificationToAllUsers(
      title: title,
      target: 'website',
      message: message,
      payload: {
        'notification': {
          'title': title,
          'body': message,
          'sound': 'default',
        },
        'data': {
          'badgeCount': badgeCount,
          'target': 'website',
          'click_action': 'FLUTTER_NOTIFICATION_CLICK',
          'notificationImage': '',
          'href': url,
          'name': title,
        },
      },
      badgeCount: badgeCount,
    );
  }

  // send noticiation to test user
  Future<void> sendPushNotificationToTestUser({
    required UserModel user,
    required String title,
    required String message,
    required bool badgeCount,
  }) async {
    if (user.fcmToken == null || user.fcmToken!.trim().isEmpty) {
      return;
    }
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
        'href': user.userId,
        'notificationImage': user.profilePic,
        'click_action': 'FLUTTER_NOTIFICATION_CLICK',
        'senderId': 'admin',
        'name': '${user.firstName!} ${user.lastName!}',
      },
      'to': user.fcmToken,
    };
    var res = await http.post(
      Uri.parse(Contants.firebaseUrl),
      headers: {
        HttpHeaders.contentTypeHeader: 'application/json',
        HttpHeaders.authorizationHeader: Contants.authorizationHeaderFCMDev,
      },
      body: jsonEncode(notificationPayload),
    );

    if (res.statusCode == 200) {
      Map<String, dynamic> data = jsonDecode(res.body);
      if (kDebugMode) {
        print(data);
      }
    }
  }
}
