import 'package:dellenhauer_admin/model/notification/push_notification_model.dart';

class JobModel {
  final String id;
  final String title;
  final String message;
  final bool badgeCount;
  final DateTime selectedDateTime;
  final List<String> fcmTokens;
  final NotificationModel notificationModel;

  JobModel({
    required this.id,
    required this.title,
    required this.message,
    required this.badgeCount,
    required this.selectedDateTime,
    required this.fcmTokens,
    required this.notificationModel,
  });

  factory JobModel.fromMap(Map<String, dynamic> map) {
    return JobModel(
      id: map['id'] as String,
      title: map['title'] as String,
      message: map['message'] as String,
      badgeCount: map['badgeCount'] as bool,
      selectedDateTime: DateTime.parse(map['selectedDateTime'] as String),
      fcmTokens: List<String>.from(map['fcmTokens']),
      notificationModel: NotificationModel.fromMap(
          map['notificationModel'] as Map<String, dynamic>),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'message': message,
      'badgeCount': badgeCount,
      'selectedDateTime': selectedDateTime.toIso8601String(),
      'fcmTokens': fcmTokens,
      'notificationModel': notificationModel.toMap(),
    };
  }
}
