import 'dart:convert';

import 'package:dellenhauer_admin/pages/push_notification/model/push_notification_article_model.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class PushNotificationArticleProvider extends ChangeNotifier {
  BuildContext? buildContext;
  bool _loading = false;
  bool get loading => _loading;
  List<PushNotificationArticleModel> _articleData = [];
  List<PushNotificationArticleModel> get articleData => _articleData;
  PushNotificationArticleModel? _selectedArticle;
  PushNotificationArticleModel? get selectedArticle => _selectedArticle;

  void attachContext(BuildContext context) {
    buildContext = context;
  }

  void setLoading(bool isLoading) {
    _loading = isLoading;
    notifyListeners();
  }

  void setSelectedArticle(PushNotificationArticleModel article) {
    _selectedArticle = article;
    notifyListeners();
  }

  Future<void> getArticleData() async {
    try {
      _articleData.clear();
      const String url = 'https://dellenhauer.com/wp-json/bestcms/v1/article';
      final http.Response response = await http.get(Uri.parse(url), headers: {
        'X-API-KEY': 'WPAObiq6mx57kW9kpZFhOERymRu3SHin',
        'Connection': 'keep-alive',
        'Accept': '*/*',
        'Accept-Encoding': 'gzip,defalte,br',
      });
      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        for (var a in data) {
          _articleData.add(PushNotificationArticleModel.fromJson(a));
        }
      }
      notifyListeners();
    } catch (error) {
      _articleData = [];
      notifyListeners();
    }
  }
}