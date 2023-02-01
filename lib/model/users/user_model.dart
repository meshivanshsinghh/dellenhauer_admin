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
  List<AwardsModel>? awardsModel;
  bool? isTyping;

  UserModel(
      {this.bio,
      this.awardsModel,
      this.coursesModel,
      this.countryModel,
      this.createdAt,
      this.isOnline,
      this.email,
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
      this.isTyping,
      this.servicesLooking,
      this.qrCodeUrl,
      this.servicesOffering,
      this.userId,
      this.nickname});

  // from json
  UserModel.fromJson(Map<String, dynamic> map) {
    if (map.isEmpty) {
      return;
    }
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
    if (map['awards'] != null) {
      awardsModel = [];
      map['awards'].forEach((value) {
        awardsModel!.add(AwardsModel.fromMap(value));
      });
    } else {
      awardsModel = [];
    }
    if (map['courses'] != null) {
      coursesModel = [];
      map['courses'].forEach((value) {
        coursesModel!.add(CoursesModel.fromMap(value));
      });
    } else {
      coursesModel = [];
    }
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

    if (map['servicesLooking'] != null) {
      servicesLooking = [];
      map['servicesLooking'].forEach((value) {
        servicesLooking!.add(value);
      });
    } else {
      servicesLooking = [];
    }
    if (map['servicesOffering'] != null) {
      servicesLooking = [];
      map['servicesOffering'].forEach((value) {
        servicesLooking!.add(value);
      });
    } else {
      servicesLooking = [];
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'websiteUrl': websiteUrl,
      'email': email,
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
      'awards': awardsModel != null
          ? awardsModel!.map((e) => e.toMap()).toList()
          : null,
      'courses': coursesModel != null
          ? coursesModel!.map((e) => e.toMap()).toList()
          : null,
      'postalCode': postalCode,
      'countryModel': countryModel,
      'isVerified': isVerified ?? false,
      'createdAt': createdAt,
      'profilePic': profilePic,
      'fcmToken': fcmToken,
      'servicesLooking': servicesLooking,
      'servicesOffering': servicesOffering,
    };
  }
}
