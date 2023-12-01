import 'package:dellenhauer_admin/api_service.dart';
import 'package:dellenhauer_admin/model/requests/analytics_model.dart';
import 'package:dellenhauer_admin/pages/analytics/analytics_date_picker_widget.dart';
import 'package:dellenhauer_admin/pages/analytics/analytics_overview_widget.dart';
import 'package:dellenhauer_admin/utils/colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_date_range_picker/flutter_date_range_picker.dart';
import 'package:shimmer/shimmer.dart';

class AnalyticsScreen extends StatefulWidget {
  const AnalyticsScreen({super.key});

  @override
  State<AnalyticsScreen> createState() => _AnalyticsScreenState();
}

class _AnalyticsScreenState extends State<AnalyticsScreen>
    with AutomaticKeepAliveClientMixin {
  final ApiService _apiService = ApiService();
  late Future<List<AnalyticsModel>> mostLikedArticles;
  late Future<List<AnalyticsModel>> mostOpenedArticles;
  late Future<List<AnalyticsModel>> mostViewedArticles;
  late Future<List<AnalyticsModel>> mostSharedArticles;
  late Future<List<AnalyticsModel>> mostJoinedChannels;
  late Future<List<AnalyticsModel>> mostDownloadedArticles;
  Key mostLikedKey = UniqueKey();
  Key mostOpenedKey = UniqueKey();
  Key mostViewedKey = UniqueKey();
  Key mostSharedKey = UniqueKey();
  Key mostJoinedKey = UniqueKey();
  Key mostDownloadedKey = UniqueKey();
  DateRange selectedDateRange = DateRange(
    DateTime.now().subtract(const Duration(days: 7)),
    DateTime.now(),
  );

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _refreshData() async {
    setState(() {
      _loadData();
      mostLikedKey = UniqueKey();
      mostOpenedKey = UniqueKey();
      mostViewedKey = UniqueKey();
      mostSharedKey = UniqueKey();
      mostJoinedKey = UniqueKey();
      mostDownloadedKey = UniqueKey();
    });
  }

  Future _loadData() async {
    mostOpenedArticles = _apiService.getMostViewedArticles(
      eventName: 'article_opened',
      start: selectedDateRange.start,
      end: selectedDateRange.end,
    );

    mostLikedArticles = _apiService.getMostViewedArticles(
      eventName: 'article_view_duration',
      start: selectedDateRange.start,
      end: selectedDateRange.end,
    );
    mostViewedArticles = _apiService.getMostViewedArticles(
      eventName: 'article_share',
      start: selectedDateRange.start,
      end: selectedDateRange.end,
    );
    mostSharedArticles = _apiService.getMostViewedArticles(
      eventName: 'article_share',
      start: selectedDateRange.start,
      end: selectedDateRange.end,
    );
    mostJoinedChannels = _apiService.getMostViewedArticles(
      eventName: 'channel_join',
      start: selectedDateRange.start,
      end: selectedDateRange.end,
    );
    mostDownloadedArticles = _apiService.getMostViewedArticles(
      eventName: 'article_downloaded',
      start: selectedDateRange.start,
      end: selectedDateRange.end,
    );
  }

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
          Row(
            children: [
              const Text(
                'Analytics',
                style: TextStyle(
                  fontSize: 30,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const Spacer(),
              AnalyticsDatePickerWidget(
                selectedDateRange: (selectedDateRange) {
                  setState(() {
                    this.selectedDateRange = selectedDateRange;
                  });
                  _refreshData();
                },
              ),
            ],
          ),
          Container(
            margin: const EdgeInsets.only(top: 5, bottom: 10),
            height: 3,
            width: 50,
            decoration: BoxDecoration(
                color: kPrimaryColor, borderRadius: BorderRadius.circular(15)),
          ),
          Expanded(
            child: RefreshIndicator(
              color: kPrimaryColor,
              onRefresh: () async {
                await _refreshData();
              },
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: Column(
                  children: [
                    // most  article opened
                    FutureBuilder<List<AnalyticsModel>>(
                      future: mostOpenedArticles,
                      key: mostOpenedKey,
                      builder: (context, snapshot) {
                        if (snapshot.hasData && snapshot.data!.isNotEmpty) {
                          return AnalyticsOverviewWidget(
                            articles: snapshot.data!,
                            heading: 'Most opened Articles',
                            type: 'article_opened',
                          );
                        }
                        return shimmerLoading('Most opened Articles');
                      },
                    ),
                    // most liked
                    FutureBuilder<List<AnalyticsModel>>(
                      future: mostLikedArticles,
                      key: mostLikedKey,
                      builder: (context, snapshot) {
                        if (snapshot.hasData && snapshot.data!.isNotEmpty) {
                          return AnalyticsOverviewWidget(
                            articles: snapshot.data!,
                            heading: 'Most liked Articles',
                            type: 'article_liked',
                          );
                        }
                        return shimmerLoading('Most liked Articles');
                      },
                    ),
                    // most viewed
                    FutureBuilder<List<AnalyticsModel>>(
                      future: mostViewedArticles,
                      key: mostViewedKey,
                      builder: (context, snapshot) {
                        if (snapshot.hasData) {
                          return AnalyticsOverviewWidget(
                            articles: snapshot.data!,
                            heading: 'Most viewed Articles',
                            type: 'article_view_duration',
                          );
                        }
                        return shimmerLoading('Most viewed Articles');
                      },
                    ),
                    // most shared
                    FutureBuilder<List<AnalyticsModel>>(
                      future: mostSharedArticles,
                      key: mostSharedKey,
                      builder: (context, snapshot) {
                        if (snapshot.hasData) {
                          return AnalyticsOverviewWidget(
                            articles: snapshot.data!,
                            heading: 'Most shared Articles',
                            type: 'article_share',
                          );
                        }
                        return shimmerLoading('Most shared Articles');
                      },
                    ),
                    // most joined
                    FutureBuilder<List<AnalyticsModel>>(
                      future: mostJoinedChannels,
                      key: mostJoinedKey,
                      builder: (context, snapshot) {
                        if (snapshot.hasData) {
                          return AnalyticsOverviewWidget(
                            articles: snapshot.data!,
                            heading: 'Most joined channels',
                            type: 'channel_join',
                          );
                        }
                        return shimmerLoading('Most joined channels');
                      },
                    ),
                    // most downloaded
                    FutureBuilder<List<AnalyticsModel>>(
                      future: mostDownloadedArticles,
                      key: mostDownloadedKey,
                      builder: (context, snapshot) {
                        if (snapshot.hasData) {
                          return AnalyticsOverviewWidget(
                            articles: snapshot.data!,
                            heading: 'Most downloaded Articles',
                            type: 'article_downloaded',
                          );
                        }
                        return shimmerLoading('Most downloaded Articles');
                      },
                    ),
                  ],
                ),
              ),
            ),
          )
        ],
      ),
    );
  }

  Widget shimmerLoading(String title) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 15),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w800,
            ),
          ),
          Container(
            margin: const EdgeInsets.only(top: 5, bottom: 15),
            height: 3,
            width: 50,
            decoration: BoxDecoration(
              color: kPrimaryColor,
              borderRadius: BorderRadius.circular(15),
            ),
          ),
          Column(
            children: List.generate(5, (index) {
              return Shimmer.fromColors(
                baseColor: Colors.grey.withOpacity(0.7),
                highlightColor: Colors.grey.withOpacity(0.4),
                child: Container(
                  height: 50,
                  margin: const EdgeInsets.only(bottom: 10),
                  color: Colors.grey.withOpacity(0.7),
                  width: double.infinity,
                ),
              );
            }),
          ),
        ],
      ),
    );
  }
}
