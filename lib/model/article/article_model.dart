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
      {id,
      headline,
      subheadline,
      content,
      nextArticle,
      previewImage,
      previousArticle,
      relatedArticles,
      createdDate,
      headerImage,
      video,
      badge,
      category,
      tags,
      visible,
      interactionSettings,
      permalink,
      audioPlaylist,
      authorId});

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
    final Map<String, dynamic> data = {};
    data['id'] = id;
    data['headline'] = headline;
    data['subheadline'] = subheadline;
    data['content'] = content;
    data['preview_image'] = previewImage;
    data['created_date'] = createdDate;
    if (headerImage != null) {
      data['header_image'] = headerImage!.toJson();
    }
    if (video != null) {
      data['video'] = video!.toJson();
    }
    data['badge'] = badge;
    if (category != null) {
      data['category'] = category!.map((v) => v.toJson()).toList();
    }
    if (tags != null) {
      data['tags'] = tags!.map((v) => v.toJson()).toList();
    }
    data['visible'] = visible;
    if (interactionSettings != null) {
      data['interaction_settings'] = interactionSettings!.toJson();
    }
    data['permalink'] = permalink;
    if (audioPlaylist != null) {
      data['audio_playlist'] = audioPlaylist!.toJson();
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
    data['author_id'] = authorId;
    return data;
  }
}

class HeaderImage {
  bool? show;
  String? url;

  HeaderImage({show, url});

  HeaderImage.fromJson(Map<String, dynamic> json) {
    show = json['show'];
    url = json['url'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {};
    data['show'] = show;
    data['url'] = url;
    return data;
  }
}

class Video {
  String? href;
  String? platform;

  Video({href, platform});

  Video.fromJson(Map<String, dynamic> json) {
    href = json['href'];
    platform = json['platform'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {};
    data['href'] = href;
    data['platform'] = platform;
    return data;
  }
}

class CategoryModel {
  int? id;
  String? name;

  CategoryModel({id, name});

  CategoryModel.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {};
    data['id'] = id;
    data['name'] = name;
    return data;
  }
}

class Tags {
  int? id;
  String? name;

  Tags({id, name});

  Tags.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {};
    data['id'] = id;
    data['name'] = name;
    return data;
  }
}

class InteractionSettings {
  bool? activateLike;
  bool? activateShare;
  bool? activateComment;

  InteractionSettings({activateLike, activateShare, activateComment});

  InteractionSettings.fromJson(Map<String, dynamic> json) {
    activateLike = json['activate_like'];
    activateShare = json['activate_share'];
    activateComment = json['activate_comment'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {};
    data['activate_like'] = activateLike;
    data['activate_share'] = activateShare;
    data['activate_comment'] = activateComment;
    return data;
  }
}

class AudioPlaylist {
  String? title;
  String? badge;
  List<AudioTracks>? tracks;

  AudioPlaylist({title, badge, tracks});

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
    final Map<String, dynamic> data = {};
    data['title'] = title;
    data['badge'] = badge;
    if (tracks != null) {
      data['tracks'] = tracks!.map((v) => v.toJson()).toList();
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

  AudioTracks({title, author, url, image, duration, trackId});

  AudioTracks.fromJson(Map<String, dynamic> json) {
    title = json['title'];
    author = json['author'];
    url = json['url'];
    image = json['image'];
    duration = json['duration'];
    trackId = json['track_id'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {};
    data['title'] = title;
    data['author'] = author;
    data['url'] = url;
    data['image'] = image;
    data['duration'] = duration;
    data['track_id'] = trackId;
    return data;
  }
}

class RelatedArticle {
  int? id;
  String? headline;
  String? subheadline;
  String? previewImage;

  RelatedArticle({id, headline, subheadline, previewImage});

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

  PreviousArticle({id, headline, subheadline});

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
