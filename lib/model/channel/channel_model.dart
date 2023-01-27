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
  final String channelName;
  final String channelDescription;
  final bool channelNotification;
  final String channelPhoto;
  final bool channelAutoJoin;
  final bool channelReadOnly;
  final String createdAt;
  final bool joinAccessRequired;
  final List<String> membersId;
  final List<String> moderatorsId;
  final String groupId;
  final ChannelEnum visibility;

  // for last messages
  final DateTime timeSent;
  final String lastMessage;

  ChannelModel({
    required this.channelName,
    required this.channelDescription,
    required this.channelNotification,
    required this.channelPhoto,
    required this.channelAutoJoin,
    required this.channelReadOnly,
    required this.createdAt,
    required this.joinAccessRequired,
    required this.groupId,
    required this.lastMessage,
    required this.membersId,
    required this.moderatorsId,
    required this.timeSent,
    required this.visibility,
  });

  // to map
  Map<String, dynamic> toMap() {
    return {
      'channel_name': channelName,
      'channel_description': channelDescription,
      'channel_notification': channelNotification,
      'channel_photo': channelPhoto,
      'channel_autojoin': channelAutoJoin,
      'channel_readonly': channelReadOnly,
      'created_timestamp': createdAt,
      'join_access_required': joinAccessRequired,
      'members_id': membersId,
      'moderators_id': moderatorsId,
      'groupId': groupId,
      'visibility': visibility,
      'timeSent': timeSent.millisecondsSinceEpoch,
      'lastMessage': lastMessage,
    };
  }

  // from map
  factory ChannelModel.fromMap(Map<String, dynamic> map) {
    return ChannelModel(
        channelName: map['channel_name'] ?? '',
        channelDescription: map['channel_description'] ?? '',
        channelNotification: map['channel_notification'] ?? false,
        channelPhoto: map['channel_photo'] ?? '',
        channelAutoJoin: map['channel_autojoin'] ?? false,
        channelReadOnly: map['channel_readonly'] ?? false,
        createdAt: map['created_timestamp'] ?? '',
        joinAccessRequired: map['join_access_required'] ?? false,
        groupId: map['groupId'] ?? '',
        lastMessage: map['lastMessage'] ?? '',
        membersId: List<String>.from(map['members_id']),
        moderatorsId: List<String>.from(map['moderators_id']),
        timeSent: DateTime.fromMillisecondsSinceEpoch(map['timeSent']),
        visibility: (map['visibility'] as String).toEnum());
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
