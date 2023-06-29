class ChannelRequest {
  String? createdAt;
  String? createdBy;
  bool? isDone;
  String? text;

  ChannelRequest({
    this.createdAt,
    this.createdBy,
    this.isDone,
    this.text,
  });

  ChannelRequest.fromJson(Map<String, dynamic>? json) {
    if (json == null) {
      return;
    }
    createdAt = json['createdAt'];
    createdBy = json['createdBy'];
    isDone = json['isDone'];
    text = json['text'];
  }
  Map<String, dynamic> toJson() => {
        'createdAt': createdAt,
        'createdBy': createdBy,
        'isDone': isDone,
        'text': text,
      };
}
