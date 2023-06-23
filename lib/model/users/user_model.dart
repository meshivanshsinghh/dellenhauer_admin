import 'package:dellenhauer_admin/model/awards/awards_model.dart';
import 'package:dellenhauer_admin/model/courses/courses_model.dart';

class CountryModel {
  String? country;
  String? city;
  String? state;
  CountryModel({
    this.country,
    this.city,
    this.state,
  });
  CountryModel.fromJson(Map<String, dynamic> json) {
    country = json['coutry'];
    city = json['city'];
    state = json['state'];
  }
  Map<String, dynamic> toJson() {
    return {
      'coutry': country,
      'city': city,
      'state': state,
    };
  }
}

class UserModel {
  String? email;
  String? userId;
  String? firstName;
  String? lastName;
  String? nickname;
  String? phoneNumber;
  bool? isOnline;
  String? bio;
  String? postalCode;
  CountryModel? countryModel;
  bool? isVerified;
  String? qrCodeUrl;
  bool? isPremiumUser;
  String? createdAt;
  String? profilePic;
  List<String>? servicesLooking;
  List<String>? servicesOffering;
  String? fcmToken;
  String? websiteUrl;
  List<CoursesModel>? coursesModel;
  String? invitedBy;
  String? invitedTimestamp;
  bool? isTyping;
  List<String>? likedArticles;
  List<AwardsModel>? awardsModel;
  int? lastSeen;
  int? firstLoginTimeStamp;
  List<String>? joinedChannels;

  UserModel({
    this.bio,
    this.countryModel,
    this.createdAt,
    this.isOnline,
    this.awardsModel,
    this.email,
    this.likedArticles,
    this.coursesModel,
    this.fcmToken,
    this.firstName,
    this.isVerified,
    this.isPremiumUser,
    this.websiteUrl,
    this.lastName,
    this.phoneNumber,
    this.invitedBy,
    this.invitedTimestamp,
    this.postalCode,
    this.profilePic,
    this.joinedChannels,
    this.isTyping,
    this.servicesLooking,
    this.qrCodeUrl,
    this.servicesOffering,
    this.userId,
    this.lastSeen,
    this.nickname,
    this.firstLoginTimeStamp,
  });

  // from json
  UserModel.fromJson(Map<String, dynamic>? map) {
    if (map == null) {
      return;
    }
    lastSeen = map['lastSeen'];
    firstLoginTimeStamp = map['firstLoginTimestamp'];
    email = map['email'];
    userId = map['userId'];
    qrCodeUrl = map['qr_code_url'];
    firstName = map['firstName'];
    lastName = map['lastName'];
    nickname = map['nickname'];
    invitedBy = map['invited_by'];
    invitedTimestamp = map['invited_timestamp'];
    isTyping = map['isTyping'] ?? false;
    phoneNumber = map['phoneNumber'];
    isOnline = map['isOnline'] ?? false;
    bio = map['bio'];
    websiteUrl = map['websiteUrl'];
    postalCode = map['postalCode'];
    countryModel = map['countryModel'] != null
        ? CountryModel.fromJson(map['countryModel'])
        : null;
    isVerified = map['isVerified'] ?? false;
    createdAt = map['createdAt'];
    profilePic = map['profilePic'];
    isPremiumUser = map['is_premium_user'];
    fcmToken = map['fcmToken'];

    joinedChannels = [];
    if (map.containsKey('joinedChannels') && map['joinedChannels'] != null) {
      map['joinedChannels'].forEach((value) {
        joinedChannels!.add(value);
      });
    }

    likedArticles = [];
    if (map.containsKey('likedArticles') && map['likedArticles'] != null) {
      map['likedArticles'].forEach((value) {
        likedArticles!.add(value);
      });
    }
    awardsModel = [];
    if (map.containsKey('awards') && map['awards'] != null) {
      map['awards'].forEach((value) {
        awardsModel!.add(AwardsModel.fromMap(value));
      });
    }
    coursesModel = [];
    if (map.containsKey('courses') && map['courses'] != null) {
      map['courses'].forEach((value) {
        coursesModel!.add(CoursesModel.fromMap(value));
      });
    }
    servicesLooking = [];
    if (map.containsKey('servicesLooking') && map['servicesLooking'] != null) {
      map['servicesLooking'].forEach((value) {
        servicesLooking!.add(value);
      });
    }
    servicesOffering = [];
    if (map.containsKey('servicesOffering') &&
        map['servicesOffering'] != null) {
      map['servicesOffering'].forEach((value) {
        servicesOffering!.add(value);
      });
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'websiteUrl': websiteUrl,
      'email': email,
      'lastSeen': lastSeen,
      'firstLoginTimestamp': firstLoginTimeStamp,
      'userId': userId,
      'firstName': firstName,
      'isOnline': isOnline ?? false,
      'lastName': lastName,
      'invited_by': invitedBy,
      'qr_code_url': qrCodeUrl,
      'invited_timestamp': invitedTimestamp,
      'isTyping': isTyping ?? false,
      'nickname': nickname,
      'is_premium_user': isPremiumUser ?? false,
      'phoneNumber': phoneNumber,
      'bio': bio,
      'postalCode': postalCode,
      'countryModel': countryModel!.toJson(),
      'isVerified': isVerified ?? false,
      'createdAt': createdAt,
      'profilePic': profilePic,
      'fcmToken': fcmToken,
      'likedArticles': likedArticles != null && likedArticles!.isNotEmpty
          ? likedArticles!.map((e) => e).toList()
          : [],
      'joinedChannels': joinedChannels != null && joinedChannels!.isNotEmpty
          ? joinedChannels!.map((e) => e).toList()
          : [],
      'awards': awardsModel != null && awardsModel!.isNotEmpty
          ? awardsModel!.map((e) => e.toMap()).toList()
          : [],
      'courses': coursesModel != null && coursesModel!.isNotEmpty
          ? coursesModel!.map((e) => e.toMap()).toList()
          : [],
      'servicesLooking': servicesLooking != null && servicesLooking!.isNotEmpty
          ? servicesLooking!.map((e) => e).toList()
          : [],
      'servicesOffering':
          servicesOffering != null && servicesOffering!.isNotEmpty
              ? servicesOffering!.map((e) => e).toList()
              : [],
    };
  }
}
