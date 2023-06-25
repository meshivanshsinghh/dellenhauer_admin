class InvitationModel {
  String? acceptedTimestamp;
  String? createdUserId;
  String? acceptedUserId;

  InvitationModel({
    this.acceptedTimestamp,
    this.acceptedUserId,
    this.createdUserId,
  });

  // from json
  InvitationModel.fromJson(Map<String, dynamic>? json) {
    if (json == null) {
      return;
    }

    acceptedTimestamp = json['accepted_timestamp'];
    createdUserId = json['created_user_id'];
    acceptedUserId = json['accepted_user_id'];
  }
  Map<String, dynamic> toJson() {
    return {
      "accepted_timestamp": acceptedTimestamp,
      "created_user_id": createdUserId,
      "accepted_user_id": acceptedUserId,
    };
  }
}
