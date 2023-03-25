import 'package:dellenhauer_admin/utils/colors.dart';

import 'package:dellenhauer_admin/model/notification/push_notification_model.dart';
import 'package:dellenhauer_admin/pages/push_notification/logs/push_notification_details_view.dart';
import 'package:dellenhauer_admin/pages/push_notification/push_notification_provider.dart';
import 'package:dellenhauer_admin/utils/nextscreen.dart';
import 'package:dellenhauer_admin/utils/utils.dart';
import 'package:dellenhauer_admin/utils/widgets/empty.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';
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
  int currentPage = 1;
  final TextEditingController _searchController = TextEditingController();

  final colorsCustom = [
    kPrimaryColor,
    Colors.blueAccent,
    Colors.purpleAccent,
    Colors.black,
  ];

  getTime(int date) {
    DateTime dateTime = DateTime.fromMillisecondsSinceEpoch(date);
    String formattedDate = DateFormat('h:mm a').format(dateTime);
    return formattedDate;
  }

  @override
  void initState() {
    super.initState();
    setState(() {
      sortByText = 'Newest First';
      orderBy = 'notificationSendTimestamp';
      descending = true;
    });

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
      notificationProvider.lastVisibleData = null;
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
                  color: kPrimaryColor,
                  borderRadius: BorderRadius.circular(15)),
            ),
            // text form field for searching notifications
            Container(
              margin: const EdgeInsets.symmetric(vertical: 10),
              width: MediaQuery.of(context).size.width,
              child: TextFormField(
                controller: _searchController,
                cursorColor: kPrimaryColor,
                onChanged: onItemChanged,
                decoration: InputDecoration(
                  suffixIcon: _searchController.text.trim().isNotEmpty
                      ? IconButton(
                          icon: const Icon(
                            FontAwesomeIcons.solidCircleXmark,
                            size: 20,
                            color: kPrimaryColor,
                          ),
                          onPressed: () {
                            HapticFeedback.lightImpact();
                            setState(() {
                              _searchController.clear();
                            });
                            refreshData();
                          })
                      : null,
                  hintText: 'Search notification messages here',
                  hintStyle: const TextStyle(
                    color: Colors.black54,
                    fontSize: 13,
                  ),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 20),
                  fillColor: const Color.fromRGBO(232, 232, 232, 1),
                  filled: true,
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(color: Colors.transparent),
                  ),
                  prefixIcon: const Icon(
                    FontAwesomeIcons.magnifyingGlass,
                    size: 16,
                    color: kPrimaryColor,
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(color: Colors.transparent),
                  ),
                  border: InputBorder.none,
                ),
              ),
            ),

            // displaying content
            notificationProvider.isLoading &&
                    notificationProvider.notificationData.isEmpty
                ? const Center(
                    child: CircularProgressIndicator(color: kPrimaryColor),
                  )
                : Column(
                    children: [
                      RefreshIndicator(
                        onRefresh: () async {
                          refreshData();
                        },
                        child: notificationProvider.hasData == false
                            ? emptyPage(FontAwesomeIcons.bell,
                                'No notifications found!')
                            : SingleChildScrollView(
                                scrollDirection: Axis.horizontal,
                                child: DataTable(
                                  dataRowHeight: 60,
                                  columns: const [
                                    DataColumn(label: Text('Created At')),
                                    DataColumn(label: Text('Target')),
                                    DataColumn(label: Text('Message')),
                                    DataColumn(label: Text('Href')),
                                    DataColumn(label: Text('Created By')),
                                    DataColumn(label: Text('Date')),
                                    DataColumn(label: Text('Actions')),
                                  ],
                                  rows: notificationProvider.notificationData
                                      .map((e) {
                                    final NotificationModel d =
                                        NotificationModel.fromMap(
                                      e.data() as dynamic,
                                    );
                                    return DataRow(cells: [
                                      DataCell(
                                        Text(
                                          getDate(
                                            d.notificationSendTimestamp!
                                                .millisecondsSinceEpoch,
                                          ),
                                          maxLines: 1,
                                        ),
                                      ),
                                      // target
                                      DataCell(Container(
                                        decoration: BoxDecoration(
                                          color:
                                              colorsCustom[d.target == 'channel'
                                                  ? 1
                                                  : d.target == 'user'
                                                      ? 2
                                                      : d.target == 'article'
                                                          ? 0
                                                          : 3],
                                          borderRadius:
                                              BorderRadius.circular(0),
                                        ),
                                        padding: const EdgeInsets.symmetric(
                                            vertical: 5, horizontal: 10),
                                        child: Text(
                                          d.target!,
                                          style: const TextStyle(
                                              color: Colors.white),
                                          maxLines: 1,
                                        ),
                                      )),

                                      // href
                                      DataCell(SizedBox(
                                        width: 200,
                                        child: Text(
                                          d.notificationMessage!,
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
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
                                                      notificationModel: d),
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
                                                      Navigator.of(context)
                                                          .pop();
                                                      showSnackbar(context,
                                                          'Notification deleted successfully form database');
                                                      refreshData();
                                                    });
                                                  },
                                                  style:
                                                      ElevatedButton.styleFrom(
                                                          backgroundColor:
                                                              kPrimaryColor),
                                                  child: const Text('YES'),
                                                ),
                                                ElevatedButton(
                                                  style:
                                                      ElevatedButton.styleFrom(
                                                          backgroundColor:
                                                              Colors.grey),
                                                  onPressed: () =>
                                                      Navigator.of(context)
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
                      const SizedBox(height: 10),
                      buildPaginationRow(),
                    ],
                  ),
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

  void onItemChanged(String value) {
    setState(() {
      notificationProvider.setLoading(isLoading: true);
    });

    if (value.isEmpty) {
      refreshData();
    } else {
      final String searchQuery = value.toLowerCase();
      notificationProvider.getNotificationData(
        orderBy: orderBy,
        descending: descending,
        searchQuery: searchQuery,
      );
    }
  }

  Widget buildPaginationButton(
      String text, bool condition, Function() onPressed) {
    return Container(
      alignment: Alignment.center,
      width: 30,
      child: ElevatedButton(
        onPressed: condition ? onPressed : null,
        child: Text(text),
      ),
    );
  }

  Future<void> getNextPage() async {
    if (notificationProvider.hasMoreContent) {
      setState(() {
        currentPage++;
        notificationProvider.setLoading(isLoading: true);
      });
      notificationProvider.clearNotification();
      await notificationProvider.getNotificationData(
        orderBy: orderBy,
        descending: descending,
        searchQuery: _searchController.text.trim(),
        pageNumber: currentPage,
      );
    }
  }

  Future<void> getPreviousPage() async {
    if (currentPage > 1) {
      setState(() {
        currentPage--;
        notificationProvider.setLoading(isLoading: true);
        notificationProvider.lastVisibleData = null;
      });
      notificationProvider.clearNotification();
      await notificationProvider.getNotificationData(
        orderBy: orderBy,
        descending: descending,
        searchQuery: _searchController.text,
        pageNumber: currentPage,
      );
    }
  }

  Widget buildPaginationRow() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        buildPaginationButton(
          '<',
          currentPage > 1,
          getPreviousPage,
        ),
        const SizedBox(width: 10),
        Text('Page $currentPage'),
        const SizedBox(width: 10),
        buildPaginationButton(
          '>',
          notificationProvider.hasMoreContent,
          getNextPage,
        ),
      ],
    );
  }
}
