import 'package:dellenhauer_admin/constants.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

class PostDataHelper {
  final Dio _dio = Dio(BaseOptions(headers: {
    'X-API-KEY': AppConstants.X_API_KEY,
  }));

  // update user data
  Future<void> updateUserData(Map<String, dynamic> data) async {
    try {
      await _dio.post(
        'https://dellenhauer.com/wp-json/bestcms/v1/user/update',
        data: {
          'wordpress_cms_userid': data['wordpress_cms_userid'],
          'firstName': data['firstName'],
          'lastName': data['lastName'],
          'websiteUrl': data['websiteUrl'],
        },
      );
    } catch (e) {
      debugPrint('Error sending request: $e');
    }
  }
}
