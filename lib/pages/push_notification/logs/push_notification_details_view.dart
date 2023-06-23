import 'package:dellenhauer_admin/pages/push_notification/push_notification_logs_provider.dart';
import 'package:dellenhauer_admin/utils/colors.dart';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:dellenhauer_admin/model/notification/push_notification_model.dart';
import 'package:dellenhauer_admin/model/users/user_model.dart';
import 'package:dellenhauer_admin/utils/utils.dart';
import 'package:dellenhauer_admin/utils/widgets/empty.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import 'package:provider/provider.dart';

class PushNotificationDetailsView extends StatefulWidget {
  final NotificationModel notificationModel;
  const PushNotificationDetailsView(
      {super.key, required this.notificationModel});

  @override
  State<PushNotificationDetailsView> createState() =>
      _PushNotificationDetailsViewState();
}

class _PushNotificationDetailsViewState
    extends State<PushNotificationDetailsView> {
  late PushNotificationLogsProvider pushNotificationProvider;

  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.of(context).size.width;
    pushNotificationProvider =
        Provider.of<PushNotificationLogsProvider>(context, listen: false);
    return Scaffold(
        appBar: PreferredSize(
          preferredSize: const Size.fromHeight(60),
          child: Center(
            child: AppBar(
              elevation: 1,
              centerTitle: true,
              title: Text('Notification Id: ${widget.notificationModel.id}'),
            ),
          ),
        ),
        body: Container(
          height: double.infinity,
          width: double.infinity,
          margin: const EdgeInsets.all(20),
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
            padding: const EdgeInsets.symmetric(vertical: 50),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                buildItem('ID', widget.notificationModel.id.toString(), true),
                buildItem(
                  'Title',
                  widget.notificationModel.notificationTitle!,
                  false,
                ),

                buildItem(
                  'Message',
                  widget.notificationModel.notificationMessage!,
                  false,
                ),

                buildItem(
                  'Send At',
                  getDate(
                    widget.notificationModel.notificationSendTimestamp!
                        .millisecondsSinceEpoch,
                  ),
                  false,
                ),
                buildItem(
                  'Created By',
                  widget.notificationModel.createdBy!,
                  false,
                ),
                buildItem(
                  'Target',
                  widget.notificationModel.target!,
                  false,
                ),
                buildItem(
                  'Href',
                  widget.notificationModel.href != null &&
                          widget.notificationModel.href!.trim().isEmpty
                      ? 'N/A'
                      : widget.notificationModel.href ?? 'N/A',
                  false,
                ),
                const SizedBox(height: 10),
                // receiver id
                Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Receiver',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                      FutureBuilder<List<UserModel>>(
                        future: pushNotificationProvider.getUserDetails(
                            widget.notificationModel.receiverId!),
                        builder: (context, snapshot) {
                          if (snapshot.hasData && snapshot.data!.isNotEmpty) {
                            return Container(
                              height: 300,
                              margin: const EdgeInsets.only(top: 20),
                              padding: const EdgeInsets.all(10),
                              decoration:
                                  BoxDecoration(color: Colors.grey.shade50),
                              child: ListView.builder(
                                shrinkWrap: true,
                                itemCount: snapshot.data!.length,
                                itemBuilder: (context, index) {
                                  return ListTile(
                                    contentPadding: EdgeInsets.zero,
                                    leading: CachedNetworkImage(
                                      imageUrl:
                                          snapshot.data![index].profilePic!,
                                      placeholder: (context, url) {
                                        return Container(
                                          height: 40,
                                          width: 40,
                                          decoration: BoxDecoration(
                                            color: Colors.grey[300],
                                            shape: BoxShape.circle,
                                            image: const DecorationImage(
                                              image: AssetImage(
                                                  'assets/images/placeholder.jpeg'),
                                              fit: BoxFit.cover,
                                            ),
                                          ),
                                        );
                                      },
                                      errorWidget: (context, url, error) {
                                        return Container(
                                          height: 40,
                                          width: 40,
                                          decoration: BoxDecoration(
                                            color: Colors.grey[300],
                                            shape: BoxShape.circle,
                                            image: const DecorationImage(
                                              image: AssetImage(
                                                  'assets/images/placeholder.jpeg'),
                                              fit: BoxFit.cover,
                                            ),
                                          ),
                                        );
                                      },
                                      imageBuilder: (context, imageProvider) {
                                        return Container(
                                          height: 40,
                                          width: 40,
                                          decoration: BoxDecoration(
                                            color: Colors.grey[300],
                                            shape: BoxShape.circle,
                                            image: DecorationImage(
                                              image: imageProvider,
                                              fit: BoxFit.cover,
                                            ),
                                          ),
                                        );
                                      },
                                    ),
                                    title: Text(
                                      '${snapshot.data![index].firstName} ${snapshot.data![index].lastName}',
                                    ),
                                    subtitle: Text(
                                      snapshot.data![index].phoneNumber!,
                                    ),
                                  );
                                },
                              ),
                            );
                          } else if (snapshot.hasData &&
                              snapshot.data!.isEmpty) {
                            return Container(
                              height: 300,
                              width: MediaQuery.of(context).size.width,
                              margin: const EdgeInsets.only(top: 20),
                              padding: const EdgeInsets.all(10),
                              alignment: Alignment.center,
                              decoration:
                                  BoxDecoration(color: Colors.grey.shade50),
                              child: emptyPage(
                                  FontAwesomeIcons.user, 'No receiver found!'),
                            );
                          }
                          return Container(
                            height: 300,
                            width: MediaQuery.of(context).size.width,
                            margin: const EdgeInsets.only(top: 20),
                            padding: const EdgeInsets.all(10),
                            alignment: Alignment.center,
                            decoration:
                                BoxDecoration(color: Colors.grey.shade50),
                            child: const SizedBox(
                              height: 30,
                              width: 30,
                              child: CircularProgressIndicator(
                                color: kPrimaryColor,
                              ),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ));
  }

  Widget buildItem(String title, String value, bool firstItem) {
    return Container(
      padding: const EdgeInsets.all(10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
            maxLines: 1,
          ),
          Text(
            value,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w400,
              color: Colors.black54,
            ),
            maxLines: 1,
          ),
        ],
      ),
    );
  }
}
