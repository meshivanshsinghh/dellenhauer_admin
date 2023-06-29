import 'package:cached_network_image/cached_network_image.dart';
import 'package:dellenhauer_admin/pages/channels/channels_screen.dart';
import 'package:dellenhauer_admin/pages/new_channel_requests/new_channel_request_model.dart';
import 'package:dellenhauer_admin/pages/new_channel_requests/new_channel_requests_provider.dart';
import 'package:dellenhauer_admin/pages/push_notification/widgets/shimmer_image.dart';
import 'package:dellenhauer_admin/utils/colors.dart';
import 'package:dellenhauer_admin/utils/utils.dart';
import 'package:dellenhauer_admin/utils/widgets/empty.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/standalone.dart' as tz;

class NewChannelRequestsScreen extends StatefulWidget {
  const NewChannelRequestsScreen({super.key});

  @override
  State<NewChannelRequestsScreen> createState() =>
      _NewChannelRequestsScreenState();
}

class _NewChannelRequestsScreenState extends State<NewChannelRequestsScreen> {
  late NewChannelRequestsProvider requestProvider;
  final _debouncer = Debouncer(milliseconds: 100);
  late String orderBy;
  String? sortByText;
  late bool descending;

  @override
  void initState() {
    super.initState();
    sortByText = 'Newest First';
    orderBy = 'createdAt';
    descending = true;
    Future.delayed(Duration.zero, () {
      requestProvider =
          Provider.of<NewChannelRequestsProvider>(context, listen: false);
      requestProvider.attachContext(context);
      requestProvider.setLoading(isLoading: true);
      requestProvider.getChannelRequestsData(
        orderBy: orderBy,
        descending: descending,
      );
    });
  }

  @override
  void dispose() {
    _debouncer.dispose();
    super.dispose();
  }

  refreshData() {
    requestProvider =
        Provider.of<NewChannelRequestsProvider>(context, listen: false);
    requestProvider.setLastVisible(snapshot: null);
    requestProvider.setLoading(isLoading: true);
    requestProvider.data.clear();
    requestProvider.getChannelRequestsData(
      orderBy: orderBy,
      descending: descending,
    );
    requestProvider.notifyListeners();
  }

  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.of(context).size.width;
    requestProvider =
        Provider.of<NewChannelRequestsProvider>(context, listen: true);
    return Container(
      margin: const EdgeInsets.only(left: 30, top: 30, bottom: 30),
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: MediaQuery.of(context).size.height * 0.05),
          Row(
            children: [
              const Text(
                'New Channel Requests',
                style: TextStyle(
                  fontSize: 25,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const Spacer(),
              sortingPopup(),
              GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () {
                  refreshData();
                },
                child: Container(
                  margin: const EdgeInsets.only(left: 20),
                  child: const Icon(
                    FontAwesomeIcons.arrowsRotate,
                    color: kPrimaryColor,
                  ),
                ),
              )
            ],
          ),
          const SizedBox(height: 10),
          const Text(
            'Here you can see all user requests, which channels the user is still missing. \nPlease check the list, create a group if necessary and/or get in touch with the user.',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w400,
              color: Colors.grey,
            ),
          ),
          Container(
            margin: const EdgeInsets.only(top: 10, bottom: 10),
            height: 3,
            width: 50,
            decoration: BoxDecoration(
                color: kPrimaryColor, borderRadius: BorderRadius.circular(15)),
          ),
          Expanded(
              child: requestProvider.isLoading == true
                  ? const Center(
                      child: CircularProgressIndicator(
                        color: kPrimaryColor,
                      ),
                    )
                  : requestProvider.hasData == false
                      ? emptyPage(FontAwesomeIcons.solidUser,
                          'No Channel Requests Found!')
                      : NotificationListener<ScrollUpdateNotification>(
                          onNotification: (notification) {
                            if (!requestProvider.isLoading) {
                              if (notification.metrics.pixels ==
                                      notification.metrics.maxScrollExtent &&
                                  notification.scrollDelta! > 0) {
                                _debouncer.run(
                                  () {
                                    requestProvider.loadingMoreContent(
                                        isLoading: true);
                                    requestProvider.getChannelRequestsData(
                                      orderBy: orderBy,
                                      descending: descending,
                                    );
                                  },
                                );
                              }
                            }
                            return false;
                          },
                          child: ListView.builder(
                            shrinkWrap: true,
                            padding: const EdgeInsets.only(top: 20),
                            itemCount: requestProvider.data.length + 1,
                            itemBuilder: ((context, index) {
                              if (index < requestProvider.data.length) {
                                final ChannelRequest u =
                                    ChannelRequest.fromJson(
                                  requestProvider.data[index].data() as dynamic,
                                );
                                return buildRequestData(u);
                              }
                              return Center(
                                child: Opacity(
                                  opacity: requestProvider.isLoadingMoreContent
                                      ? 1.0
                                      : 0.0,
                                  child: const SizedBox(
                                    width: 32,
                                    height: 32,
                                    child: CircularProgressIndicator(
                                      color: kPrimaryColor,
                                    ),
                                  ),
                                ),
                              );
                            }),
                          ),
                        ))
        ],
      ),
    );
  }

  String getCreatedDate({
    required int timestamp,
  }) {
    tz.initializeTimeZones();
    final berlin = tz.getLocation('Europe/Berlin');

    final berlinTime =
        tz.TZDateTime.fromMillisecondsSinceEpoch(berlin, timestamp);
    final formatter = DateFormat('d.M.y H:m:s');
    final berlinFormatted = formatter.format(berlinTime);

    return 'Request created at: $berlinFormatted (Berlin)';
  }

  Widget buildRequestData(ChannelRequest request) {
    return ListTile(
        contentPadding: const EdgeInsets.only(top: 10, bottom: 10),
        title: SelectableText(
          request.text!,
          style: const TextStyle(
            fontWeight: FontWeight.w600,
          ),
          maxLines: 2,
          scrollPhysics: const NeverScrollableScrollPhysics(),
        ),
        subtitle: SelectableText(
          '${getCreatedDate(
            timestamp: int.parse(request.createdAt!),
          )} \nBy:${request.createdBy}',
        ),
        isThreeLine: true,
        trailing: Wrap(
          children: [
            ElevatedButton(
              onPressed: () {
                deletingUser(
                  context,
                  'Mark as done?',
                  'Once click yes, it will delete the entry from new channel requests and mark this as completed.',
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: kPrimaryColor,
                    ),
                    onPressed: () {
                      requestProvider.markTaskAsDone(request).whenComplete(() {
                        Navigator.of(context).pop();
                        showSnackbar(
                          context,
                          'Successfully completed new channel request',
                        );
                        refreshData();
                      });
                    },
                    child: const Text(
                      'YES',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: kPrimaryColor,
                    ),
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text(
                      'NO',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: kPrimaryColor,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
              child: const Text(
                'Mark as Done',
                style: TextStyle(color: Colors.white),
              ),
            ),
            const SizedBox(width: 10),
            ElevatedButton(
              onPressed: () {
                showViewDetailsModel(request);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: kPrimaryColor,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
              child: const Text(
                'View Details',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        ));
  }

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
            orderBy = 'createdAt';
            descending = true;
          });
        } else if (value == 'old') {
          setState(() {
            sortByText = 'Oldest First';
            orderBy = 'createdAt';
            descending = false;
          });
        }
        refreshData();
      },
    );
  }

  // show dialog for view details
  void showViewDetailsModel(ChannelRequest channelRequest) {
    showDialog(
        builder: (context) {
          return FractionallySizedBox(
            heightFactor: 0.5,
            widthFactor: 0.5,
            child: Scaffold(
              body: Container(
                color: Colors.white,
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 30),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // create by
                    const Text(
                      'Created By',
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    FutureBuilder(
                      future: requestProvider
                          .getUserDataFromID(channelRequest.createdBy!),
                      builder: (context, snapshot) {
                        if (snapshot.hasData && snapshot.data != null) {
                          return ListTile(
                            leading: CachedNetworkImage(
                              imageUrl: snapshot.data!.profilePic!,
                              placeholder: (context, url) {
                                return Container(
                                  height: 60,
                                  width: 60,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: Colors.grey[300],
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
                                  height: 60,
                                  width: 60,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: Colors.grey[300],
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
                                  height: 60,
                                  width: 60,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: Colors.grey[300],
                                    image: DecorationImage(
                                      image: imageProvider,
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                );
                              },
                            ),
                            subtitle: SelectableText(
                                '${snapshot.data!.email}\n@${snapshot.data!.nickname} • ${snapshot.data!.phoneNumber}'),
                            title: SelectableText(
                              '${snapshot.data!.firstName} ${snapshot.data!.lastName}',
                              style:
                                  const TextStyle(fontWeight: FontWeight.w600),
                            ),
                            isThreeLine: true,
                          );
                        } else if (snapshot.hasData && snapshot.data == null) {
                          return Text(channelRequest.createdBy!);
                        }
                        return const SizedBox(
                          height: 50,
                          width: double.infinity,
                          child: Center(
                            child: CircularProgressIndicator(
                              color: kPrimaryColor,
                            ),
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 30),
                    RichText(
                      maxLines: 5,
                      text: TextSpan(
                        children: [
                          const TextSpan(
                            text: 'Request: ',
                            style: TextStyle(
                              fontFamily: 'Poppins',
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                          ),
                          TextSpan(
                            text: '${channelRequest.text}',
                            style: const TextStyle(
                              fontFamily: 'Poppins',
                              fontWeight: FontWeight.w400,
                              color: Colors.black38,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
        context: context);
  }
}
