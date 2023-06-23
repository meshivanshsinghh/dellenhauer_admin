class NotificationModel {
  String? id;
  bool? badgeCount;
  List<String>? receiverId;
  String? createdBy;
  String? notificationImage;
  String? notificationTitle;
  String? notificationMessage;
  bool? notificationOpened;
  DateTime? notificationOpenedTimestamp;
  bool? notificationSend;
  DateTime? notificationSendTimestamp;
  String? href;
  String? lowerVersionNotificationMessage;
  String? target;
  bool selected = false;

  NotificationModel({
    this.badgeCount,
    this.createdBy,
    this.id,
    this.notificationImage,
    this.notificationMessage,
    this.notificationOpened,
    this.lowerVersionNotificationMessage,
    this.notificationOpenedTimestamp,
    this.notificationSend,
    this.notificationSendTimestamp,
    this.href,
    this.target,
    this.notificationTitle,
    this.receiverId,
  });

  // form json
  NotificationModel.fromMap(Map<String, dynamic> map) {
    id = map['id'].toString();
    badgeCount = map['badgeCount'] ?? true;
    if (map['receiverId'] != null) {
      receiverId = [];
      if (map['receiverId'] is List) {
        map['receiverId'].forEach((value) {
          receiverId!.add(value);
        });
      } else {
        receiverId!.add(map['receiverId']);
      }
    } else {
      receiverId = [];
    }
    lowerVersionNotificationMessage = map['lowerVersionNotificationMessage'];
    href = map['href'];
    target = map['target'];
    createdBy = map['createdBy'];
    notificationImage = map['notificationImage'];
    notificationTitle = map['notificationTitle'];
    notificationMessage = map['notificationMessage'];
    notificationOpened = map['notificationOpened'] ?? false;
    if (map['notificationOpenedTimestamp'] != null) {
      DateTime.fromMillisecondsSinceEpoch(map['notificationOpenedTimestamp']);
    } else {
      notificationOpenedTimestamp = null;
    }

    notificationSend = map['notificationSend'] ?? false;
    notificationSendTimestamp =
        DateTime.fromMillisecondsSinceEpoch(map['notificationSendTimestamp']);
  }
  // to json
  Map<String, dynamic> toMap() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id.toString();
    data['badgeCount'] = badgeCount;
    data['receiverId'] = receiverId;
    data['createdBy'] = createdBy;
    data['notificationImage'] = notificationImage;
    data['href'] = href;
    data['target'] = target;
    data['notificationTitle'] = notificationTitle;
    data['notificationMessage'] = notificationMessage;
    data['notificationOpened'] = notificationOpened;
    data['notificationOpenedTimestamp'] = notificationOpenedTimestamp;
    data['notificationSend'] = notificationSend;
    data['lowerVersionNotificationMessage'] = lowerVersionNotificationMessage;
    if (notificationSendTimestamp != null) {
      data['notificationSendTimestamp'] =
          notificationSendTimestamp!.millisecondsSinceEpoch;
    } else {
      data['notificationSendTimestamp'] = null;
    }
    return data;
  }
}
