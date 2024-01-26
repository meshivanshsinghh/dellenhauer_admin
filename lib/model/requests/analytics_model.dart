class AnalyticsModel {
  String? articleId;
  String? count;

  AnalyticsModel({this.articleId, this.count});

  AnalyticsModel.fromJson(Map<String, dynamic> json) {
    articleId = json['article_id'];
    count = json['count'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['article_id'] = this.articleId;
    data['count'] = this.count;
    return data;
  }
}
