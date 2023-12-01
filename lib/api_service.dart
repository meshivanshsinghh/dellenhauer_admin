import 'package:intl/intl.dart';
import 'package:dellenhauer_admin/constants.dart';
import 'package:dellenhauer_admin/model/article/article_model.dart';
import 'package:dellenhauer_admin/model/requests/analytics_model.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';

class ApiService {
  final Dio _dio = Dio(BaseOptions(headers: {
    'X-API-KEY': AppConstants.X_API_KEY,
  }));

  final BASE_URL_ANALYTICS_API =
      'https://dellenhauerapi-e48eb97aae38.herokuapp.com/analytics/';
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

  String formatDate(DateTime date) {
    final DateFormat formatter = DateFormat('yyyy-MM-dd');
    return formatter.format(date);
  }

  // get analytics entries
  Future<List<AnalyticsModel>> getMostViewedArticles({
    required String eventName,
    required DateTime start,
    required DateTime end,
  }) async {
    List<AnalyticsModel> articles = [];
    try {
      String startDate = formatDate(start);
      String endDate = formatDate(end);
      Response response = await _dio.get(
        '$BASE_URL_ANALYTICS_API$eventName?start_date=$startDate&end_date=$endDate',
      );
      if (response.statusCode == 200) {
        for (var data in response.data) {
          articles.add(AnalyticsModel.fromJson(data));
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print(e);
      }
    }
    return articles;
  }

  Future<ArticleModel?> getSingleData({
    required String articleId,
  }) async {
    ArticleModel? articleData;
    try {
      final Response response = await _dio.get(
        'https://dellenhauer.com/wp-json/bestcms/v1/article?id=$articleId',
        options: Options(
          headers: {
            'X-API-KEY': 'WPAObiq6mx57kW9kpZFhOERymRu3SHin',
          },
        ),
      );
      if (response.statusCode == 200) {
        articleData = ArticleModel.fromJson(response.data[0]);
      }
    } catch (e) {
      if (kDebugMode) {
        print(e);
      }
    }
    return articleData;
  }
}
