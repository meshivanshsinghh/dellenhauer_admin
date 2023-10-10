import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dellenhauer_admin/constants.dart';
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
        'X-API-KEY': AppConstants.dellenhauereBestCMSKey,
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

  // final push notification code
  Future<void> sendPushNotification({
    required bool allUsers,
    required bool selectedUsers,
    required bool selectedChannels,
    required List<String> selectedChannelID,
    required List<String> selectedUserID,
    required String target,
    required String href,
    required String title,
    required bool badge,
    required String message,
    required DateTime? selectedDateTime,
    required String name,
  }) async {
    const int maxTokensPerRequest = 500;
    List<String> fcmToken = [];
    List<String> receiverId = [];

    if (allUsers) {
      QuerySnapshot<Map<String, dynamic>> snapshpot =
          await firebaseFirestore.collection('users').get();
      for (var a in snapshpot.docs) {
        UserModel userModel = UserModel.fromJson(a.data());
        if (userModel.fcmToken != null &&
            userModel.fcmToken!.trim().isNotEmpty) {
          fcmToken.add(userModel.fcmToken!);
        }
        receiverId.add(a.id);
      }
    } else if (selectedUsers) {
      for (var id in selectedUserID) {
        DocumentSnapshot snapshot =
            await firebaseFirestore.collection('users').doc(id).get();
        if (snapshot.exists) {
          UserModel userModel = UserModel.fromJson(snapshot.data() as dynamic);
          if (userModel.fcmToken != null &&
              userModel.fcmToken!.trim().isNotEmpty) {
            fcmToken.add(userModel.fcmToken!);
          }
          receiverId.add(id);
        }
      }
    } else if (selectedChannels) {
      for (var id in selectedChannelID) {
        DocumentSnapshot snapshot =
            await firebaseFirestore.collection('channels').doc(id).get();
        if (snapshot.exists) {
          QuerySnapshot<Map<String, dynamic>> membersCollection =
              await firebaseFirestore
                  .collection('channels')
                  .doc(id)
                  .collection('members')
                  .get();
          for (var docId in membersCollection.docs) {
            DocumentSnapshot userSnapshot =
                await firebaseFirestore.collection('users').doc(docId.id).get();
            if (userSnapshot.exists) {
              UserModel userModel =
                  UserModel.fromJson(userSnapshot.data() as dynamic);
              if (userModel.fcmToken != null &&
                  userModel.fcmToken!.trim().isNotEmpty) {
                fcmToken.add(userModel.fcmToken!);
              }
              receiverId.add(id);
            }
          }
        }
      }
    }

    try {
      NotificationModel notificationModel = NotificationModel(
        badgeCount: badge,
        receiverId: [...receiverId.take(15)],
        createdBy: 'admin',
        notificationImage: '',
        notificationTitle: title,
        notificationMessage: message,
        lowerVersionNotificationMessage: message.toString().toLowerCase(),
        notificationOpened: false,
        target: getTarget(target),
        href: href,
      );
      if (selectedDateTime != null) {
        DocumentReference docRefrence =
            firebaseFirestore.collection('jobs').doc();
        JobModel jobModel = JobModel(
          id: docRefrence.id,
          title: title,
          message: message,
          badgeCount: badge,
          selectedDateTime: selectedDateTime,
          fcmTokens: fcmToken,
          notificationModel: notificationModel,
        );
        await firebaseFirestore
            .collection('jobs')
            .doc(jobModel.id)
            .set(jobModel.toMap());
      } else {
        for (var i = 0; i < fcmToken.length; i += maxTokensPerRequest) {
          var end = (i + maxTokensPerRequest < fcmToken.length)
              ? i + maxTokensPerRequest
              : fcmToken.length;
          var tokensChunk = fcmToken.sublist(i, end);
          var notificationPayload = {
            'notification': {
              'title': title,
              'body': message,
              'sound': 'default',
            },
            'data': {
              'badgeCount': badge,
              'target': getTarget(target),
              'href': href,
              'notificationImage': '',
              'click_action': 'FLUTTER_NOTIFICATION_CLICK',
              'senderId': 'admin',
              'name': name,
            },
            'registration_ids': tokensChunk,
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

  Future<bool> sendPushNotificationToTestUser({
    required UserModel userModel,
    required String title,
    required String message,
    required String target,
    required bool badgeCount,
    required String href,
    required String name,
  }) async {
    if (userModel.fcmToken == null || userModel.fcmToken!.trim().isEmpty) {
      return false;
    }
    try {
      // payload for notification
      var notificationPayload = {
        'notification': {
          'title': title,
          'body': message,
          'sound': 'default',
        },
        'data': {
          'badgeCount': badgeCount,
          'target': getTarget(target),
          'href': href,
          'notificationImage': userModel.profilePic,
          'click_action': 'FLUTTER_NOTIFICATION_CLICK',
          'senderId': 'admin',
          'name': name,
        },
        'to': userModel.fcmToken,
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
        return true;
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

  String getTarget(String target) {
    switch (target) {
      case 'Article':
        return 'article';
      case 'URL':
        return 'website';
      case 'User':
        return 'user';
      case 'Channel':
        return 'channel';
      default:
        return 'home';
    }
  }
}
