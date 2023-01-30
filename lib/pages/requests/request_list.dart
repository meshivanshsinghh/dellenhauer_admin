import 'package:dellenhauer_admin/model/channel/channel_model.dart';
import 'package:dellenhauer_admin/pages/requests/requests_model.dart';
import 'package:dellenhauer_admin/pages/requests/requests_provider.dart';
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
      requestsProvider.setRequestDataLoading(isLoading: true);
      requestsProvider.getChannelRequestList(
        orderBy: orderBy,
        descending: descending,
        channelId: widget.channelModel.groupId,
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
          channelId: widget.channelModel.groupId,
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
      channelId: widget.channelModel.groupId,
    );
    requestsProvider.notifyListeners();
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
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(60),
        child: Center(
            child: AppBar(
          title: Text(widget.channelModel.channelName),
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
                          color: Colors.redAccent,
                          borderRadius: BorderRadius.circular(15)),
                    ),
                    const SizedBox(height: 10),
                    const Text(
                      'Click on any channel to view list of channel requests',
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
              child: requestsProvider.isLoadingRequestList == true
                  ? const Center(
                      child: CircularProgressIndicator(color: Colors.redAccent),
                    )
                  : requestsProvider.requestData.isEmpty
                      ? emptyPage(FontAwesomeIcons.userPlus,
                          'No channel join request found!')
                      : RefreshIndicator(
                          child: ListView.builder(
                              itemCount:
                                  requestsProvider.requestData.length + 1,
                              itemBuilder: (context, index) {
                                if (index <
                                    requestsProvider.requestData.length) {
                                  final ChannelRequestModel
                                      channelRequestModel =
                                      ChannelRequestModel.fromMap(
                                          requestsProvider.requestData[index]
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
                                        color: Colors.redAccent),
                                  ),
                                ));
                              }),
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
            orderBy = 'created_timestamp';
            descending = true;
          });
        } else if (value == 'old') {
          setState(() {
            sortByText = 'Oldest First';
            orderBy = 'created_timestamp';
            descending = false;
          });
        }
        refreshData();
      },
    );
  }

  // request list
  Widget buildRequestList(ChannelRequestModel requestData) {
    return Container();
  }
}
