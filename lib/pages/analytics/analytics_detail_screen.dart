import 'package:dellenhauer_admin/api_service.dart';
import 'package:dellenhauer_admin/model/requests/analytics_model.dart';
import 'package:dellenhauer_admin/pages/analytics/analytics_date_picker_widget.dart';
import 'package:dellenhauer_admin/pages/analytics/analytics_overview_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_date_range_picker/flutter_date_range_picker.dart';
import 'package:shimmer/shimmer.dart';

class AnalayticsDetailScreen extends StatefulWidget {
  final String eventName;
  final String title;
  final DateRange selectedDateRange;
  const AnalayticsDetailScreen({
    super.key,
    required this.title,
    required this.eventName,
    required this.selectedDateRange,
  });

  @override
  State<AnalayticsDetailScreen> createState() => _AnalayticsDetailScreenState();
}

class _AnalayticsDetailScreenState extends State<AnalayticsDetailScreen> {
  final ApiService apiService = ApiService();
  late DateRange selectedDateRange;
  late Future<List<AnalyticsModel>> future;
  Key futureKey = UniqueKey();

  @override
  void initState() {
    super.initState();
    selectedDateRange = widget.selectedDateRange;
    loadData();
  }

  Future loadData() async {
    future = apiService.getAnalyticsEntries(
      eventName: widget.eventName,
      start: selectedDateRange.start,
      end: selectedDateRange.end,
    );
  }

  Future<void> _reloadData() async {
    setState(() {
      loadData();
      futureKey = UniqueKey();
    });
  }

  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.of(context).size.width;

    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(50),
        child: Center(
          child: AppBar(
            elevation: 1,
            centerTitle: true,
            title: Text(widget.title),
          ),
        ),
      ),
      body: Container(
          margin: const EdgeInsets.all(20),
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
            children: [
              const SizedBox(height: 30),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  AnalyticsDatePickerWidget(
                      selectedDateRange: (selectedDateRange) {
                    setState(() {
                      this.selectedDateRange = selectedDateRange;
                    });
                    _reloadData();
                  }),
                ],
              ),
              const SizedBox(height: 30),
              Expanded(
                child: SingleChildScrollView(
                  child: FutureBuilder<List<AnalyticsModel>>(
                      future: future,
                      key: futureKey,
                      builder: (context, snapshot) {
                        if (snapshot.hasData) {
                          return AnalyticsOverviewWidget(
                            articles: snapshot.data!,
                            comingFromDetail: true,
                            heading: widget.title,
                            selectedDateRange: widget.selectedDateRange,
                            type: widget.eventName,
                          );
                        }
                        return Column(
                          children: List.generate(20, (index) {
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
                        );
                      }),
                ),
              ),
            ],
          )),
    );
  }
}
