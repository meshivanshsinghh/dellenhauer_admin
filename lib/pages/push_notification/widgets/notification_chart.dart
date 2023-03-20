import 'package:dellenhauer_admin/pages/push_notification/push_notification_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_echarts/flutter_echarts.dart';
import 'package:provider/provider.dart';

class NotificationPieChart extends StatefulWidget {
  const NotificationPieChart({super.key});

  @override
  State<NotificationPieChart> createState() => _NotificationPieChartState();
}

class _NotificationPieChartState extends State<NotificationPieChart> {
  late PushNotificationProvider notificationProvider;
  late Map<int, int> notificationCounts;

  @override
  Widget build(BuildContext context) {
    notificationProvider =
        Provider.of<PushNotificationProvider>(context, listen: false);
    return Container();
  }
}
