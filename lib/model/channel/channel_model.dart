enum ChannelEnum {
  public,
  private,
}

extension ConvertMessage on String {
  ChannelEnum toEnum() {
    switch (this) {
      case 'public':
        return ChannelEnum.public;
      case 'private':
        return ChannelEnum.private;

      default:
        return ChannelEnum.public;
    }
  }
}

class ChannelModel {
  String? channelName;
  String? channelDescription;
  bool? channelNotification;
  String? channelPhoto;
  // bool? channelAutoJoin;
  bool? channelAutoJoinWithRefCode;
  bool? channelAutoJoinWithoutRefCode;
  bool? channelReadOnly;
  String? createdAt;
  bool? joinAccessRequired;
  // List<String>? membersId;
  // List<String>? moderatorsId;
  String? groupId;
  ChannelEnum? visibility;
  List<String>? relatedChannel;

  // for last messages
  DateTime? timeSent;
  String? lastMessage;

  int? totalMembers;
  int? totalModerators;
  int? onlineUsers;

  ChannelModel({
    this.channelName,
    this.channelDescription,
    this.channelNotification,
    this.channelPhoto,
    this.relatedChannel,
    this.channelAutoJoinWithRefCode,
    this.channelAutoJoinWithoutRefCode,
    this.channelReadOnly,
    this.createdAt,
    this.joinAccessRequired,
    this.groupId,
    this.lastMessage,
    // this.membersId,
    // this.moderatorsId,
    this.timeSent,
    this.visibility,
    this.onlineUsers,
    this.totalMembers,
    this.totalModerators,
  });

  // to map
  Map<String, dynamic> toMap() {
    return {
      'channel_name': channelName,
      'channel_description': channelDescription,
      'channel_notification': channelNotification,
      'channel_photo': channelPhoto,
      'channel_autojoin_with_refcode': channelAutoJoinWithRefCode,
      'channel_autojoin_without_refcode': channelAutoJoinWithoutRefCode,
      'channel_readonly': channelReadOnly,
      'created_timestamp': createdAt,
      'related_channels': relatedChannel,
      'join_access_required': joinAccessRequired,
      // 'members_id': membersId,
      // 'moderators_id': moderatorsId,
      'groupId': groupId,
      'visibility': visibility,
      'onlineUsers': onlineUsers,
      'totalMembers': totalMembers,
      'totalModerators': totalModerators,
      'timeSent': timeSent!.millisecondsSinceEpoch,
      'lastMessage': lastMessage,
    };
  }

  // from map
  ChannelModel.fromMap(Map<String, dynamic> map) {
    if (map.isEmpty) {
      return;
    }

    channelName = map['channel_name'];
    channelDescription = map['channel_description'];
    if (map['channel_notification'] != null) {
      channelNotification = map['channel_notification'];
    } else {
      channelNotification = false;
    }
    channelPhoto = map['channel_photo'];

    if (map['channel_autojoin_with_refcode'] != null) {
      channelAutoJoinWithRefCode = map['channel_autojoin_with_refcode'];
    } else {
      channelAutoJoinWithRefCode = false;
    }
    if (map['channel_autojoin_without_refcode'] != null) {
      channelAutoJoinWithoutRefCode = map['channel_autojoin_without_refcode'];
    } else {
      channelAutoJoinWithoutRefCode = false;
    }

    if (map['channel_readonly'] != null) {
      channelReadOnly = map['channel_readonly'];
    } else {
      channelReadOnly = false;
    }

    createdAt = map['created_timestamp'];

    if (map['join_access_required'] != null) {
      joinAccessRequired = map['join_access_required'];
    } else {
      joinAccessRequired = false;
    }

    groupId = map['groupId'];
    lastMessage = map['lastMessage'];
    // if (map['members_id'] != null) {
    //   membersId = [];
    //   map['members_id'].forEach((value) {
    //     membersId!.add(value);
    //   });
    // } else {
    //   membersId = [];
    // }
    // if (map['moderators_id'] != null) {
    //   moderatorsId = [];
    //   map['moderators_id'].forEach((value) {
    //     moderatorsId!.add(value);
    //   });
    // } else {
    //   moderatorsId = [];
    // }
    if (map['related_channels'] != null) {
      relatedChannel = [];
      map['related_channels'].forEach((value) {
        relatedChannel!.add(value);
      });
    } else {
      relatedChannel = [];
    }
    if (map['onlineUsers'] != null) {
      onlineUsers = map['onlineUsers'];
    } else {
      onlineUsers = 0;
    }
    if (map['totalMembers'] != null) {
      totalMembers = map['totalMembers'];
    } else {
      totalMembers = 0;
    }
    if (map['totalModerators'] != null) {
      totalModerators = map['totalModerators'];
    } else {
      totalModerators = 0;
    }

    timeSent = DateTime.fromMillisecondsSinceEpoch(map['timeSent']);
    visibility = (map['visibility'] as String).toEnum();
  }
}

class UserRequetsCollection {
  final String channelId;
  final bool accepted;

  UserRequetsCollection({
    required this.channelId,
    required this.accepted,
  });

  // from json
  factory UserRequetsCollection.fromJson(Map<String, dynamic> json) {
    return UserRequetsCollection(
      channelId: json['channelId'],
      accepted: json['accepted'],
    );
  }

  // to map
  Map<String, dynamic> toMap() {
    return {
      'channelId': channelId,
      'accepted': accepted,
    };
  }
}
