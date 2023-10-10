import 'package:dellenhauer_admin/providers/channels_provider.dart';
import 'package:dellenhauer_admin/utils/colors.dart';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:dellenhauer_admin/model/channel/channel_model.dart';
import 'package:dellenhauer_admin/model/requests/requests_model.dart';
import 'package:dellenhauer_admin/providers/requests_provider.dart';
import 'package:dellenhauer_admin/utils/utils.dart';
import 'package:dellenhauer_admin/utils/widgets/empty.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';

class RequestListScreen extends StatefulWidget {
  final ChannelModel channelModel;
  const RequestListScreen({super.key, required this.channelModel});

  @override
  State<RequestListScreen> createState() => _RequestListScreenState();
}

class _RequestListScreenState extends State<RequestListScreen> {
  late RequestsProvider requestsProvider;
  ScrollController? scrollController;
  late String orderBy;
  late bool descending;
  late ChannelProvider channelProvider;
  String? sortByText;

  @override
  void initState() {
    super.initState();
    sortByText = 'Newest First';
    orderBy = 'createdAt';
    descending = true;
    Future.delayed(Duration.zero, () {
      scrollController = ScrollController()..addListener(_scrollListener);
      requestsProvider = Provider.of<RequestsProvider>(context, listen: false);
      requestsProvider.attachContext(context);
      requestsProvider.requestData.clear();
      requestsProvider.setLastVisibleChannelRequestList(lastVisible: null);
      requestsProvider.setRequestDataLoading(isLoading: true);
      requestsProvider.getChannelRequestList(
        orderBy: orderBy,
        descending: descending,
        channelId: widget.channelModel.groupId!,
      );
    });
  }

  void _scrollListener() async {
    requestsProvider = Provider.of<RequestsProvider>(context, listen: true);
    if (!requestsProvider.isLoadingRequestList) {
      if (scrollController!.position.pixels ==
          scrollController!.position.maxScrollExtent) {
        requestsProvider.setRequestDataLoading(isLoading: true);
        requestsProvider.getChannelRequestList(
          orderBy: orderBy,
          descending: descending,
          channelId: widget.channelModel.groupId!,
        );
      }
    }
  }

  void refreshData() {
    requestsProvider = Provider.of<RequestsProvider>(context, listen: false);
    requestsProvider.setLastVisibleChannelRequestList(lastVisible: null);
    requestsProvider.setRequestDataLoading(isLoading: true);
    requestsProvider.requestData.clear();
    requestsProvider.getChannelRequestList(
      orderBy: orderBy,
      descending: descending,
      channelId: widget.channelModel.groupId!,
    );
  }

  @override
  void dispose() {
    super.dispose();
    scrollController!.removeListener(_scrollListener);
  }

  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.of(context).size.width;
    requestsProvider = Provider.of<RequestsProvider>(context, listen: true);
    channelProvider = Provider.of<ChannelProvider>(context, listen: false);
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(60),
        child: Center(
            child: AppBar(
          title: Text(widget.channelModel.channelName!),
        )),
      ),
      body: Container(
        margin: const EdgeInsets.all(30),
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
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            SizedBox(
              height: MediaQuery.of(context).size.height * 0.05,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Requests',
                      style: TextStyle(
                        fontSize: 25,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    Container(
                      margin: const EdgeInsets.only(top: 5, bottom: 10),
                      height: 3,
                      width: 50,
                      decoration: BoxDecoration(
                          color: kPrimaryColor,
                          borderRadius: BorderRadius.circular(15)),
                    ),
                    const SizedBox(height: 10),
                    const Text(
                      'Approve/Decline the requests in this channel',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.black54,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ],
                ),
                // sorting
                sortingPopup(),
              ],
            ),
            // displaying list of items
            Expanded(
              child: requestsProvider.isLoadingRequestList
                  ? const Center(
                      child: CircularProgressIndicator(color: kPrimaryColor),
                    )
                  : requestsProvider.requestData.isEmpty
                      ? emptyPage(
                          FontAwesomeIcons.userPlus,
                          'No channel join request found!',
                        )
                      : RefreshIndicator(
                          child: ListView.builder(
                            itemCount: requestsProvider.requestData.length + 1,
                            itemBuilder: (context, index) {
                              if (index < requestsProvider.requestData.length) {
                                final ChannelRequestModel channelRequestModel =
                                    ChannelRequestModel.fromMap(requestsProvider
                                        .requestData[index]
                                        .data() as dynamic);
                                return buildRequestList(channelRequestModel);
                              }
                              return Center(
                                  child: Opacity(
                                opacity: requestsProvider.isLoadingRequestList
                                    ? 1.0
                                    : 0.0,
                                child: const SizedBox(
                                  width: 32,
                                  height: 32,
                                  child: CircularProgressIndicator(
                                      color: kPrimaryColor),
                                ),
                              ));
                            },
                          ),
                          onRefresh: () async {
                            refreshData();
                          }),
            )
          ],
        ),
      ),
    );
  }

  /// sorting
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

  // request list
  Widget buildRequestList(ChannelRequestModel requestData) {
    return Column(
      children: [
        FutureBuilder(
          future: requestsProvider.returnUserModelFromId(requestData.userId),
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              return const Text('Error');
            } else if (snapshot.hasData) {
              return Container(
                height: 120,
                padding: const EdgeInsets.all(15),
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey[200]!),
                  borderRadius: BorderRadius.circular(10),
                ),
                margin: const EdgeInsets.only(top: 20),
                child: ListTile(
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
                            image: AssetImage('assets/images/placeholder.jpeg'),
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
                            image: AssetImage('assets/images/placeholder.jpeg'),
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
                  title: SelectableText(
                    '${snapshot.data!.firstName} ${snapshot.data!.lastName}',
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                  subtitle: SelectableText(
                    'Query: ${requestData.requestText}',
                    maxLines: 3,
                  ),
                  isThreeLine: true,
                  trailing: IconButton(
                      icon: const Icon(FontAwesomeIcons.eye),
                      onPressed: () {
                        showTextContentDialog(
                          context,
                          requestData.requestText,
                          snapshot.data!,
                        );
                      }),
                ),
              );
            }
            return Container(
              height: 120,
              padding: const EdgeInsets.all(15),
              alignment: Alignment.center,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey[200]!),
                borderRadius: BorderRadius.circular(10),
              ),
              margin: const EdgeInsets.only(top: 20),
            );
          },
        ),
        const SizedBox(height: 20),
        Row(
          children: [
            actionButton(
              buttonBackgroundColor: kPrimaryColor,
              textColor: Colors.white,
              onPressed: () {
                requestsProvider
                    .acceptChannelRequest(
                  channelRequestData: requestData,
                  channelId: widget.channelModel.groupId!,
                  channelprovider: channelProvider,
                )
                    .whenComplete(() {
                  showSnackbar(context, 'User successfully added to channel');
                  refreshData();
                });
              },
              title: 'Approve',
            ),
            const SizedBox(width: 20),
            actionButton(
              buttonBackgroundColor: Colors.grey,
              textColor: Colors.black,
              onPressed: () {
                requestsProvider
                    .declineChannelRequest(
                        channelRequestdata: requestData,
                        channelId: widget.channelModel.groupId!)
                    .whenComplete(() {
                  showSnackbar(context, 'User successfully removed from list');
                  refreshData();
                });
              },
              title: 'Decline',
            ),
          ],
        ),
      ],
    );
  }

  // building the action buttons
  Widget actionButton({
    required Color buttonBackgroundColor,
    required Color textColor,
    required VoidCallback onPressed,
    required String title,
  }) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: buttonBackgroundColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
      ),
      child: Text(
        title,
        style: TextStyle(color: textColor),
      ),
    );
  }
}
