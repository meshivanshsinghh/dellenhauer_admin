import 'package:dellenhauer_admin/model/notification/push_notification_model.dart';
import 'package:dellenhauer_admin/pages/push_notification/push_notification_provider.dart';
import 'package:dellenhauer_admin/utils/widgets/empty.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';

class PushNotificationLogsScreen extends StatefulWidget {
  const PushNotificationLogsScreen({super.key});

  @override
  State<PushNotificationLogsScreen> createState() =>
      _PushNotificationLogsScreenState();
}

class _PushNotificationLogsScreenState
    extends State<PushNotificationLogsScreen> {
  String? sortByText;
  late PushNotificationProvider notificationProvider;
  late bool descending;
  late String orderBy;

  @override
  void initState() {
    super.initState();

    sortByText = 'Newest First';
    orderBy = 'notificationSendTimestamp';
    descending = true;

    Future.delayed(Duration.zero, () {
      notificationProvider =
          Provider.of<PushNotificationProvider>(context, listen: false);
      notificationProvider.attachContext(context);
      notificationProvider.setLoading(isLoading: true);
      notificationProvider.getNotificationData(
        orderBy: orderBy,
        descending: descending,
      );
    });
  }

  void refreshData() {
    setState(() {
      notificationProvider =
          Provider.of<PushNotificationProvider>(context, listen: false);
      notificationProvider.setLastVisible(documentSnapshot: null);
      notificationProvider.setLoading(isLoading: true);
      notificationProvider.notificationData.clear();
      notificationProvider.getNotificationData(
        orderBy: orderBy,
        descending: descending,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.of(context).size.width;
    notificationProvider =
        Provider.of<PushNotificationProvider>(context, listen: true);
    return Container(
      padding: EdgeInsets.only(
        left: w * 0.05,
        right: w * 0.20,
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
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              height: MediaQuery.of(context).size.height * 0.05,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'All Notifications',
                  style: TextStyle(
                    fontSize: 25,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                sortingPopup(),
              ],
            ),
            Container(
              margin: const EdgeInsets.only(top: 5, bottom: 10),
              height: 3,
              width: 50,
              decoration: BoxDecoration(
                  color: Colors.redAccent,
                  borderRadius: BorderRadius.circular(15)),
            ),
            // displaying content
            NotificationListener<ScrollNotification>(
              onNotification: (scrollNotification) {
                if (!notificationProvider.isLoading &&
                    scrollNotification.metrics.pixels ==
                        scrollNotification.metrics.maxScrollExtent) {
                  notificationProvider.loadingMoreContent(isLoading: true);
                  notificationProvider.getNotificationData(
                    orderBy: orderBy,
                    descending: descending,
                  );
                }
                return true;
              },
              child: RefreshIndicator(
                onRefresh: () async {
                  refreshData();
                },
                child: notificationProvider.isLoading
                    ? const Center(
                        child: CircularProgressIndicator(color: Colors.red),
                      )
                    : notificationProvider.hasData == false
                        ? emptyPage(
                            FontAwesomeIcons.bell, 'No notifications found!')
                        : SingleChildScrollView(
                            physics: const AlwaysScrollableScrollPhysics(),
                            scrollDirection: Axis.vertical,
                            child: SingleChildScrollView(
                                scrollDirection: Axis.horizontal,
                                child: DataTable(
                                  columns: const [
                                    DataColumn(label: Text('Created At')),
                                    DataColumn(label: Text('Type')),
                                    DataColumn(label: Text('Href')),
                                    DataColumn(label: Text('Done By')),
                                    DataColumn(label: Text('Actions')),
                                  ],
                                  rows: notificationProvider.notificationData
                                      .map((e) {
                                    final NotificationModel d =
                                        NotificationModel.fromMap(
                                      e.data() as dynamic,
                                    );
                                    return DataRow(cells: [
                                      DataCell(Text(d.notificationSendTimestamp
                                          .toString())),
                                      DataCell(Text(d.target!)),
                                      DataCell(Text(d.href!)),
                                      DataCell(Text(d.createdBy!)),
                                      const DataCell(Text('actions')),
                                    ]);
                                  }).toList(),
                                )),
                          ),
              ),
            )
          ],
        ),
      ),
    );
  }

  // sorting popup
  Widget sortingPopup() {
    return PopupMenuButton(
      child: Container(
        height: 40,
        alignment: Alignment.center,
        padding: const EdgeInsets.only(left: 20, right: 20),
        decoration: BoxDecoration(
          color: Colors.grey[100],
          border: Border.all(color: Colors.grey[300]!),
          borderRadius: BorderRadius.circular(30),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              FontAwesomeIcons.arrowDown,
              size: 20,
              color: Colors.grey[800],
            ),
            const SizedBox(width: 10),
            Text(
              'Sort By - $sortByText',
              style: TextStyle(
                color: Colors.grey[900],
                fontWeight: FontWeight.w500,
              ),
              maxLines: 1,
            )
          ],
        ),
      ),
      itemBuilder: (context) {
        return const [
          PopupMenuItem(value: 'new', child: Text('Newest First')),
          PopupMenuItem(value: 'old', child: Text('Oldest First')),
          PopupMenuItem(value: 'channel', child: Text('Channel Notifications')),
          PopupMenuItem(value: 'user', child: Text('User Notifications')),
          PopupMenuItem(value: 'website', child: Text('Website Notifications')),
          PopupMenuItem(value: 'article', child: Text('Article Notifications')),
        ];
      },
      onSelected: (dynamic value) {
        if (value == 'new') {
          setState(() {
            sortByText = 'Newest First';
            orderBy = 'notificationSendTimestamp';
            descending = true;
          });
        } else if (value == 'old') {
          setState(() {
            sortByText = 'Oldest First';
            orderBy = 'notificationSendTimestamp';
            descending = false;
          });
        } else if (value == 'website') {
          setState(() {
            sortByText = 'Website';
            orderBy = 'website';
            descending = true;
          });
        } else if (value == 'article') {
          setState(() {
            sortByText = 'Article';
            orderBy = 'article';
            descending = true;
          });
        } else if (value == 'user') {
          setState(() {
            sortByText = 'User';
            orderBy = 'user';
            descending = true;
          });
        } else if (value == 'channel') {
          setState(() {
            sortByText = 'Channel';
            orderBy = 'channel';
            descending = true;
          });
        }

        refreshData();
      },
    );
  }

  // notification content list
  buildContentList(NotificationModel notificationModel) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(notificationModel.createdBy.toString()),
        Text(notificationModel.createdBy.toString()),
        Text(notificationModel.createdBy.toString()),
        Text(notificationModel.createdBy.toString()),
        Text(notificationModel.createdBy.toString()),
      ],
    );
  }
}
