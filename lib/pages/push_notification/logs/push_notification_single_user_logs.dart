import 'package:dellenhauer_admin/model/notification/push_notification_model.dart';
import 'package:dellenhauer_admin/pages/push_notification/logs/push_notification_details_view.dart';
import 'package:dellenhauer_admin/pages/push_notification/push_notification_logs_provider.dart';
import 'package:dellenhauer_admin/utils/colors.dart';
import 'package:dellenhauer_admin/utils/nextscreen.dart';
import 'package:dellenhauer_admin/utils/utils.dart';
import 'package:dellenhauer_admin/utils/widgets/empty.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class PushNotificationSingleUserLogs extends StatefulWidget {
  final String userId;
  const PushNotificationSingleUserLogs({super.key, required this.userId});

  @override
  State<PushNotificationSingleUserLogs> createState() =>
      _PushNotificationSingleUserLogsState();
}

class _PushNotificationSingleUserLogsState
    extends State<PushNotificationSingleUserLogs> {
  late PushNotificationLogsProvider notificationProvider;
  late bool descending;
  late String orderBy;
  late String sortByText;

  @override
  void initState() {
    super.initState();
    sortByText = 'Newest First';
    orderBy = 'notificationSendTimestamp';
    descending = true;
    Future.delayed(Duration.zero, () {
      notificationProvider =
          Provider.of<PushNotificationLogsProvider>(context, listen: false);
      notificationProvider.attachContext(context);
      notificationProvider.setLoading(isLoading: true);
      notificationProvider.getSingleUserNotificationData(
          orderBy: orderBy, userId: widget.userId, descending: descending);
    });
  }

  void refreshData() {
    setState(() {
      notificationProvider =
          Provider.of<PushNotificationLogsProvider>(context, listen: false);
      notificationProvider.lastVisibleData = null;
      notificationProvider.setLoading(isLoading: true);
      notificationProvider.singleUserNotificationData.clear();
      notificationProvider.getSingleUserNotificationData(
        orderBy: orderBy,
        userId: widget.userId,
        descending: descending,
      );
    });
  }

  final colorsCustom = [
    kPrimaryColor,
    Colors.blueAccent,
    Colors.purpleAccent,
    Colors.black,
  ];

  getDate(int date) {
    DateTime dateTime = DateTime.fromMillisecondsSinceEpoch(date);
    String formattedDate = DateFormat('d MMMM').format(dateTime);
    return formattedDate;
  }

  getTime(int date) {
    DateTime dateTime = DateTime.fromMillisecondsSinceEpoch(date);
    String formattedDate = DateFormat('h:mm a').format(dateTime);
    return formattedDate;
  }

  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.of(context).size.width;
    notificationProvider =
        Provider.of<PushNotificationLogsProvider>(context, listen: true);
    return Scaffold(
      appBar: AppBar(),
      body: Container(
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
                    'User Notifications',
                    style: TextStyle(
                      fontSize: 25,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  sortingPopup(),
                ],
              ),
              // now dispalying conent
              Container(
                margin: const EdgeInsets.only(top: 5, bottom: 10),
                height: 3,
                width: 50,
                decoration: BoxDecoration(
                    color: kPrimaryColor,
                    borderRadius: BorderRadius.circular(15)),
              ),
              SizedBox(
                height: MediaQuery.of(context).size.height,
                child: NotificationListener<ScrollNotification>(
                    onNotification: (notification) {
                      if (!notificationProvider.isLoading &&
                          notification.metrics.pixels ==
                              notification.metrics.maxScrollExtent) {
                        notificationProvider.loadingMoreContent(
                            isLoading: true);
                        notificationProvider.getSingleUserNotificationData(
                          orderBy: orderBy,
                          descending: descending,
                          userId: widget.userId,
                        );
                      }
                      return false;
                    },
                    child: RefreshIndicator(
                      onRefresh: () async {
                        refreshData();
                      },
                      child: notificationProvider.isLoading
                          ? const Center(
                              child: CircularProgressIndicator(
                                  color: kPrimaryColor),
                            )
                          : notificationProvider.hasSingleUserData == false
                              ? emptyPage(FontAwesomeIcons.bell,
                                  'No notifications found!')
                              : SingleChildScrollView(
                                  physics:
                                      const AlwaysScrollableScrollPhysics(),
                                  scrollDirection: Axis.vertical,
                                  child: SizedBox(
                                    width: MediaQuery.of(context).size.width,
                                    child: SingleChildScrollView(
                                      scrollDirection: Axis.horizontal,
                                      child: DataTable(
                                        dataRowHeight: 60,
                                        columns: const [
                                          DataColumn(label: Text('Time')),
                                          DataColumn(label: Text('Target')),
                                          DataColumn(label: Text('Href')),
                                          DataColumn(label: Text('Created By')),
                                          DataColumn(label: Text('Date')),
                                          DataColumn(label: Text('Actions')),
                                        ],
                                        rows: notificationProvider
                                            .singleUserNotificationData
                                            .map((e) {
                                          final NotificationModel d =
                                              NotificationModel.fromMap(
                                            e.data() as dynamic,
                                          );

                                          return DataRow(cells: [
                                            DataCell(
                                              Text(
                                                getTime(
                                                  d.notificationSendTimestamp!
                                                      .millisecondsSinceEpoch,
                                                ).toString(),
                                                maxLines: 1,
                                              ),
                                            ),
                                            // target
                                            DataCell(Container(
                                              decoration: BoxDecoration(
                                                color: colorsCustom[d.target ==
                                                        'channel'
                                                    ? 1
                                                    : d.target == 'user'
                                                        ? 2
                                                        : d.target == 'article'
                                                            ? 0
                                                            : 3],
                                                borderRadius:
                                                    BorderRadius.circular(0),
                                              ),
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      vertical: 5,
                                                      horizontal: 10),
                                              child: Text(
                                                d.target!,
                                                style: const TextStyle(
                                                    color: Colors.white),
                                                maxLines: 1,
                                              ),
                                            )),
                                            // href
                                            DataCell(Text(
                                              d.href!,
                                              maxLines: 1,
                                            )),
                                            DataCell(Text(
                                              d.createdBy!,
                                              maxLines: 1,
                                            )),
                                            DataCell(
                                              Text(
                                                getDate(
                                                  d.notificationSendTimestamp!
                                                      .millisecondsSinceEpoch,
                                                ).toString(),
                                                maxLines: 1,
                                              ),
                                            ),
                                            DataCell(Row(
                                              children: [
                                                IconButton(
                                                    onPressed: () {
                                                      nextScreen(
                                                        context,
                                                        PushNotificationDetailsView(
                                                            notificationModel:
                                                                d),
                                                      );
                                                    },
                                                    icon: const Icon(
                                                      FontAwesomeIcons.solidEye,
                                                      size: 20,
                                                      color: Colors.black54,
                                                    )),
                                                const SizedBox(width: 5),
                                                IconButton(
                                                  onPressed: () {
                                                    deletingUser(
                                                      context,
                                                      'Delete Notification?',
                                                      'Are you sure you want to delete this notification from databse?',
                                                      ElevatedButton(
                                                        onPressed: () {
                                                          notificationProvider
                                                              .deletingPushNotification(
                                                                  d.id!)
                                                              .whenComplete(() {
                                                            Navigator.of(
                                                                    context)
                                                                .pop();
                                                            showSnackbar(
                                                                context,
                                                                'Notification deleted successfully form database');
                                                            refreshData();
                                                          });
                                                        },
                                                        style: ElevatedButton
                                                            .styleFrom(
                                                                backgroundColor:
                                                                    kPrimaryColor),
                                                        child:
                                                            const Text('YES'),
                                                      ),
                                                      ElevatedButton(
                                                        style: ElevatedButton
                                                            .styleFrom(
                                                                backgroundColor:
                                                                    Colors
                                                                        .grey),
                                                        onPressed: () =>
                                                            Navigator.of(
                                                                    context)
                                                                .pop(),
                                                        child: const Text("NO"),
                                                      ),
                                                    );
                                                  },
                                                  icon: const Icon(
                                                    FontAwesomeIcons.trash,
                                                    color: kPrimaryColor,
                                                    size: 20,
                                                  ),
                                                ),
                                              ],
                                            )),
                                          ]);
                                        }).toList(),
                                      ),
                                    ),
                                  ),
                                ),
                    )),
              ),
              // displaying the ciruclar progress indicator
              Center(
                child: Opacity(
                  opacity:
                      notificationProvider.isLoadingMoreContent ? 1.0 : 0.0,
                  child: const SizedBox(
                    width: 32,
                    height: 32,
                    child: CircularProgressIndicator(color: kPrimaryColor),
                  ),
                ),
              ),
            ],
          ),
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
        }
        // notificationProvider.sortData(orderBy, descending);
        refreshData();
      },
    );
  }
}
