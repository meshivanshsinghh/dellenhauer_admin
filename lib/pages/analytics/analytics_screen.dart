import 'package:dellenhauer_admin/api_service.dart';
import 'package:dellenhauer_admin/model/requests/analytics_model.dart';
import 'package:dellenhauer_admin/pages/analytics/analytics_overview_widget.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class AnalyticsScreen extends StatefulWidget {
  const AnalyticsScreen({super.key});

  @override
  State<AnalyticsScreen> createState() => _AnalyticsScreenState();
}

class _AnalyticsScreenState extends State<AnalyticsScreen>
    with AutomaticKeepAliveClientMixin {
  final ApiService _apiService = ApiService();

  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final w = MediaQuery.of(context).size.width;

    return Container(
      margin: const EdgeInsets.only(left: 30, top: 30, bottom: 30),
      padding: EdgeInsets.only(
        left: w * 0.05,
        right: w * 0.05,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.grey[300]!,
            blurRadius: 10,
            offset: const Offset(3, 3),
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            height: MediaQuery.of(context).size.height * 0.05,
          ),
          const Text(
            'Analytics',
            style: TextStyle(
              fontSize: 30,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 20),
          Expanded(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Column(
                children: [
                  // most opened and most liked
                  IntrinsicHeight(
                    child: Row(
                      children: [
                        Expanded(
                          child: FutureBuilder<List<AnalyticsModel>>(
                            future: _apiService.getMostViewedArticles(
                              eventName: 'article_opened',
                            ),
                            builder: (context, snapshot) {
                              if (snapshot.hasData &&
                                  snapshot.data!.isNotEmpty) {
                                return AnalyticsOverviewWidget(
                                  articles: snapshot.data!,
                                  heading: 'Most opened Articles',
                                  type: 'article_opened',
                                );
                              }
                              return const SizedBox(
                                height: 300,
                                child: CupertinoActivityIndicator(),
                              );
                            },
                          ),
                        ),
                        const VerticalDivider(width: 20, color: Colors.grey),
                        Expanded(
                          child: FutureBuilder<List<AnalyticsModel>>(
                            future: _apiService.getMostViewedArticles(
                              eventName: 'article_view_duration',
                            ),
                            builder: (context, snapshot) {
                              if (snapshot.hasData) {
                                return AnalyticsOverviewWidget(
                                  articles: snapshot.data!,
                                  heading: 'Most viewed Articles',
                                  type: 'article_view_duration',
                                );
                              }
                              return const SizedBox(
                                height: 300,
                                child: CupertinoActivityIndicator(),
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 30),
                  // most shared and most downloaded
                  IntrinsicHeight(
                    child: Row(
                      children: [
                        Expanded(
                          child: FutureBuilder<List<AnalyticsModel>>(
                            future: _apiService.getMostViewedArticles(
                              eventName: 'article_liked',
                            ),
                            builder: (context, snapshot) {
                              if (snapshot.hasData &&
                                  snapshot.data!.isNotEmpty) {
                                return AnalyticsOverviewWidget(
                                  articles: snapshot.data!,
                                  heading: 'Most liked Articles',
                                  type: 'article_liked',
                                );
                              }
                              return const SizedBox(
                                height: 300,
                                child: CupertinoActivityIndicator(),
                              );
                            },
                          ),
                        ),
                        const VerticalDivider(width: 20, color: Colors.grey),
                        Expanded(
                          child: FutureBuilder<List<AnalyticsModel>>(
                            future: _apiService.getMostViewedArticles(
                              eventName: 'article_share',
                            ),
                            builder: (context, snapshot) {
                              if (snapshot.hasData) {
                                return AnalyticsOverviewWidget(
                                  articles: snapshot.data!,
                                  heading: 'Most shared Articles',
                                  type: 'article_share',
                                );
                              }
                              return const SizedBox(
                                height: 300,
                                child: CupertinoActivityIndicator(),
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 30),
                  // channel join and view duration
                  IntrinsicHeight(
                    child: Row(
                      children: [
                        Expanded(
                          child: FutureBuilder<List<AnalyticsModel>>(
                            future: _apiService.getMostViewedArticles(
                              eventName: 'channel_join',
                            ),
                            builder: (context, snapshot) {
                              if (snapshot.hasData) {
                                return AnalyticsOverviewWidget(
                                  articles: snapshot.data!,
                                  heading: 'Most joined channels',
                                  type: 'channel_join',
                                );
                              }
                              return const SizedBox(
                                height: 300,
                                child: CupertinoActivityIndicator(),
                              );
                            },
                          ),
                        ),
                        const VerticalDivider(width: 20, color: Colors.grey),
                        Expanded(
                          child: FutureBuilder<List<AnalyticsModel>>(
                            future: _apiService.getMostViewedArticles(
                              eventName: 'article_downloaded',
                            ),
                            builder: (context, snapshot) {
                              if (snapshot.hasData) {
                                return AnalyticsOverviewWidget(
                                  articles: snapshot.data!,
                                  heading: 'Most downloaded Articles',
                                  type: 'article_downloaded',
                                );
                              }
                              return const SizedBox(
                                height: 300,
                                child: CupertinoActivityIndicator(),
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          )
        ],
      ),
    );
  }
}
