class ArticleModel {
  int? id;
  String? headline;
  String? subheadline;
  String? content;
  String? previewImage;
  int? createdDate;
  HeaderImage? headerImage;
  Video? video;
  String? badge;
  List<CategoryModel>? category;
  List<Tags>? tags;
  bool? visible;
  List<RelatedArticle>? relatedArticles;
  PreviousArticle? previousArticle;
  InteractionSettings? interactionSettings;
  String? permalink;
  AudioPlaylist? audioPlaylist;
  int? authorId;
  PreviousArticle? nextArticle;

  ArticleModel(
      {this.id,
      this.headline,
      this.subheadline,
      this.content,
      this.nextArticle,
      this.previewImage,
      this.previousArticle,
      this.relatedArticles,
      this.createdDate,
      this.headerImage,
      this.video,
      this.badge,
      this.category,
      this.tags,
      this.visible,
      this.interactionSettings,
      this.permalink,
      this.audioPlaylist,
      this.authorId});

  ArticleModel.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    headline = json['headline'];
    subheadline = json['subheadline'];
    content = json['content'];
    previewImage = json['preview_image'];
    createdDate = json['created_date'];
    headerImage = json['header_image'] != null
        ? HeaderImage.fromJson(json['header_image'])
        : null;
    video = json['video'] != null ? Video.fromJson(json['video']) : null;
    badge = json['badge'];
    if (json['related_articles'] != null) {
      relatedArticles = <RelatedArticle>[];
      json['related_articles'].forEach((v) {
        relatedArticles?.add(RelatedArticle.fromJson(v));
      });
    }

    if (json['category'] != null) {
      category = <CategoryModel>[];
      json['category'].forEach((v) {
        category!.add(CategoryModel.fromJson(v));
      });
    }
    if (json['tags'] != null) {
      tags = <Tags>[];
      json['tags'].forEach((v) {
        tags!.add(Tags.fromJson(v));
      });
    }
    visible = json['visible'];
    interactionSettings = json['interaction_settings'] != null
        ? InteractionSettings.fromJson(json['interaction_settings'])
        : null;
    permalink = json['permalink'];
    previousArticle = json['previous_article'] != null
        ? PreviousArticle.fromJson(json['previous_article'])
        : null;
    audioPlaylist = json['audio_playlist'] != null
        ? AudioPlaylist.fromJson(json['audio_playlist'])
        : null;
    nextArticle = json['next_article'] != null
        ? PreviousArticle.fromJson(json['next_article'])
        : null;
    authorId = json['author_id'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = Map<String, dynamic>();
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
    if (this.tags != null) {
      data['tags'] = this.tags!.map((v) => v.toJson()).toList();
    }
    data['visible'] = this.visible;
    if (this.interactionSettings != null) {
      data['interaction_settings'] = this.interactionSettings!.toJson();
    }
    data['permalink'] = this.permalink;
    if (this.audioPlaylist != null) {
      data['audio_playlist'] = this.audioPlaylist!.toJson();
    }
    if (previousArticle != null) {
      data['previous_article'] = previousArticle?.toJson();
    }
    if (relatedArticles != null) {
      data['related_articles'] =
          relatedArticles?.map((v) => v.toJson()).toList();
    }
    if (nextArticle != null) {
      data['next_article'] = nextArticle?.toJson();
    }
    data['author_id'] = this.authorId;
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
    final Map<String, dynamic> data = Map<String, dynamic>();
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
    final Map<String, dynamic> data = Map<String, dynamic>();
    data['href'] = this.href;
    data['platform'] = this.platform;
    return data;
  }
}

class CategoryModel {
  int? id;
  String? name;

  CategoryModel({this.id, this.name});

  CategoryModel.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = Map<String, dynamic>();
    data['id'] = this.id;
    data['name'] = this.name;
    return data;
  }
}

class Tags {
  int? id;
  String? name;

  Tags({this.id, this.name});

  Tags.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = Map<String, dynamic>();
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
    final Map<String, dynamic> data = Map<String, dynamic>();
    data['activate_like'] = this.activateLike;
    data['activate_share'] = this.activateShare;
    data['activate_comment'] = this.activateComment;
    return data;
  }
}

class AudioPlaylist {
  String? title;
  String? badge;
  List<AudioTracks>? tracks;

  AudioPlaylist({this.title, this.badge, this.tracks});

  AudioPlaylist.fromJson(Map<String, dynamic> json) {
    title = json['title'];
    badge = json['badge'];
    if (json['tracks'] != null) {
      tracks = <AudioTracks>[];
      json['tracks'].forEach((v) {
        tracks!.add(AudioTracks.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = Map<String, dynamic>();
    data['title'] = this.title;
    data['badge'] = this.badge;
    if (this.tracks != null) {
      data['tracks'] = this.tracks!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class AudioTracks {
  String? title;
  String? author;
  String? url;
  String? image;
  String? duration;
  String? trackId;

  AudioTracks(
      {this.title,
      this.author,
      this.url,
      this.image,
      this.duration,
      this.trackId});

  AudioTracks.fromJson(Map<String, dynamic> json) {
    title = json['title'];
    author = json['author'];
    url = json['url'];
    image = json['image'];
    duration = json['duration'];
    trackId = json['track_id'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = Map<String, dynamic>();
    data['title'] = this.title;
    data['author'] = this.author;
    data['url'] = this.url;
    data['image'] = this.image;
    data['duration'] = this.duration;
    data['track_id'] = this.trackId;
    return data;
  }
}

class RelatedArticle {
  int? id;
  String? headline;
  String? subheadline;
  String? previewImage;

  RelatedArticle({this.id, this.headline, this.subheadline, this.previewImage});

  RelatedArticle.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    headline = json['headline'];
    subheadline = json['subheadline'];
    previewImage = json['preview_image'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['headline'] = headline;
    data['subheadline'] = subheadline;
    data['preview_image'] = previewImage;
    return data;
  }
}

class PreviousArticle {
  int? id;
  String? headline;
  String? subheadline;

  PreviousArticle({this.id, this.headline, this.subheadline});

  PreviousArticle.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    headline = json['headline'];
    subheadline = json['subheadline'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['headline'] = headline;
    data['subheadline'] = subheadline;
    return data;
  }
}
