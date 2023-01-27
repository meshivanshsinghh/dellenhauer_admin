class ChannelRequestModel {
  final String requestId;
  final String userId;
  final String approvedBy;
  final String requestText;
  final String createdAt;
  final bool isApproved;

  ChannelRequestModel({
    required this.requestId,
    required this.userId,
    required this.approvedBy,
    required this.requestText,
    required this.createdAt,
    required this.isApproved,
  });

  Map<String, dynamic> toMap() {
    return {
      'requestId': requestId,
      'userId': userId,
      'approved_by': approvedBy,
      'requestText': requestText,
      'createdAt': createdAt,
      'isApproved': isApproved,
    };
  }

  factory ChannelRequestModel.fromMap(Map<String, dynamic> map) {
    return ChannelRequestModel(
      requestId: map['requestId'],
      userId: map['userId'],
      approvedBy: map['approved_by'],
      requestText: map['requestText'],
      createdAt: map['createdAt'],
      isApproved: map['isApproved'],
    );
  }
}
