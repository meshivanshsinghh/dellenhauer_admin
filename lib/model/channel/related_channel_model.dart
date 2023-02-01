class RelatedChannel {
  String? relatedChannelName;
  String? relatedChannelId;
  RelatedChannel({this.relatedChannelId, this.relatedChannelName});

  RelatedChannel.fromJson(Map<String, dynamic> map) {
    relatedChannelId = map['relatedChannelId'];
    relatedChannelName = map['relatedChannelName'];
  }
  Map<String, dynamic> toMap() {
    return {
      'relatedChannelId': relatedChannelId,
      'relatedChannelName': relatedChannelName,
    };
  }
}
