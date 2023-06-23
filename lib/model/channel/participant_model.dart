class ParticipantModel {
  final bool isNotificationEnabled;
  final String uid;
  final int joinedAt;

  ParticipantModel({
    required this.isNotificationEnabled,
    required this.uid,
    required this.joinedAt,
  });

  // Create a ParticipantModel from a map
  factory ParticipantModel.fromMap(Map<String, dynamic> map) {
    return ParticipantModel(
      isNotificationEnabled: map['isNotificationEnabled'] ?? false,
      uid: map['uid'] ?? '',
      joinedAt: map['joined_at'] ?? 0,
    );
  }

  // Convert a ParticipantModel to a map
  Map<String, dynamic> toMap() {
    return {
      'isNotificationEnabled': isNotificationEnabled,
      'uid': uid,
      'joined_at': joinedAt,
    };
  }
}
