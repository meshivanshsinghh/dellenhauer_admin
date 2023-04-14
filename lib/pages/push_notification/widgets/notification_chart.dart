import 'package:dellenhauer_admin/pages/push_notification/push_notification_logs_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_echarts/flutter_echarts.dart';
import 'package:provider/provider.dart';

class NotificationPieChart extends StatefulWidget {
  const NotificationPieChart({super.key});

  @override
  State<NotificationPieChart> createState() => _NotificationPieChartState();
}

class _NotificationPieChartState extends State<NotificationPieChart> {
  late PushNotificationLogsProvider notificationProvider;
  late Map<int, int> notificationCounts;

  @override
  Widget build(BuildContext context) {
    notificationProvider =
        Provider.of<PushNotificationLogsProvider>(context, listen: false);
    return Container();
  }
}
