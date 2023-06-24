class PushNotificationArticleModel {
  int? id;
  String? headline;
  String? subheadline;
  String? content;
  String? previewImage;
  int? createdDate;
  HeaderImage? headerImage;
  Video? video;
  String? badge;
  List<Category>? category;

  bool? visible;
  InteractionSettings? interactionSettings;
  String? permalink;

  PushNotificationArticleModel(
      {this.id,
      this.headline,
      this.subheadline,
      this.content,
      this.previewImage,
      this.createdDate,
      this.headerImage,
      this.video,
      this.badge,
      this.category,
      this.visible,
      this.interactionSettings,
      this.permalink});

  PushNotificationArticleModel.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    headline = json['headline'];
    subheadline = json['subheadline'];
    content = json['content'];
    previewImage = json['preview_image'];
    createdDate = json['created_date'];
    headerImage = json['header_image'] != null
        ? new HeaderImage.fromJson(json['header_image'])
        : null;
    video = json['video'] != null ? new Video.fromJson(json['video']) : null;
    badge = json['badge'];
    if (json['category'] != null) {
      category = <Category>[];
      json['category'].forEach((v) {
        category!.add(new Category.fromJson(v));
      });
    }

    visible = json['visible'];
    interactionSettings = json['interaction_settings'] != null
        ? new InteractionSettings.fromJson(json['interaction_settings'])
        : null;
    permalink = json['permalink'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['headline'] = this.headline;
    data['subheadline'] = this.subheadline;
    data['content'] = this.content;
    data['preview_image'] = this.previewImage;
    data['created_date'] = this.createdDate;
    if (this.headerImage != null) {
      data['header_image'] = this.headerImage!.toJson();
    }
    if (this.video != null) {
      data['video'] = this.video!.toJson();
    }
    data['badge'] = this.badge;
    if (this.category != null) {
      data['category'] = this.category!.map((v) => v.toJson()).toList();
    }

    data['visible'] = this.visible;
    if (this.interactionSettings != null) {
      data['interaction_settings'] = this.interactionSettings!.toJson();
    }
    data['permalink'] = this.permalink;
    return data;
  }
}

class HeaderImage {
  bool? show;
  String? url;

  HeaderImage({this.show, this.url});

  HeaderImage.fromJson(Map<String, dynamic> json) {
    show = json['show'];
    url = json['url'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['show'] = this.show;
    data['url'] = this.url;
    return data;
  }
}

class Video {
  String? href;
  String? platform;

  Video({this.href, this.platform});

  Video.fromJson(Map<String, dynamic> json) {
    href = json['href'];
    platform = json['platform'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['href'] = this.href;
    data['platform'] = this.platform;
    return data;
  }
}

class Category {
  int? id;
  String? name;

  Category({this.id, this.name});

  Category.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['name'] = this.name;
    return data;
  }
}

class InteractionSettings {
  bool? activateLike;
  bool? activateShare;
  bool? activateComment;

  InteractionSettings(
      {this.activateLike, this.activateShare, this.activateComment});

  InteractionSettings.fromJson(Map<String, dynamic> json) {
    activateLike = json['activate_like'];
    activateShare = json['activate_share'];
    activateComment = json['activate_comment'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['activate_like'] = this.activateLike;
    data['activate_share'] = this.activateShare;
    data['activate_comment'] = this.activateComment;
    return data;
  }
}
