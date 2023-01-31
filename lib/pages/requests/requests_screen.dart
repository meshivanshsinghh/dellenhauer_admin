import 'package:cached_network_image/cached_network_image.dart';
import 'package:dellenhauer_admin/model/channel/channel_model.dart';
import 'package:dellenhauer_admin/pages/requests/request_list.dart';
import 'package:dellenhauer_admin/providers/requests_provider.dart';
import 'package:dellenhauer_admin/utils/nextscreen.dart';
import 'package:dellenhauer_admin/utils/widgets/empty.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';

class RequestsScreenList extends StatefulWidget {
  const RequestsScreenList({super.key});

  @override
  State<RequestsScreenList> createState() => _RequestsScreenListState();
}

class _RequestsScreenListState extends State<RequestsScreenList> {
  late RequestsProvider requestsProvider;
  ScrollController? scrollController;
  late String orderBy;
  late bool descending;
  String? sortByText;

  @override
  void initState() {
    super.initState();
    sortByText = 'Newest First';
    orderBy = 'created_timestamp';
    descending = true;
    Future.delayed(Duration.zero, () {
      scrollController = ScrollController()..addListener(_scrollListener);
      requestsProvider = Provider.of<RequestsProvider>(context, listen: false);
      requestsProvider.attachContext(context);
      requestsProvider.setChannelDataLoading(isLoading: true);
      requestsProvider.getChannelData(
        orderBy: orderBy,
        descending: descending,
      );
    });
  }

  void refreshData() {
    requestsProvider = Provider.of<RequestsProvider>(context, listen: false);
    requestsProvider.setLastVisibleChannelList(lastVisible: null);
    requestsProvider.setChannelDataLoading(isLoading: true);
    requestsProvider.channelData.clear();
    requestsProvider.getChannelData(orderBy: orderBy, descending: descending);
    requestsProvider.notifyListeners();
  }

  @override
  void dispose() {
    super.dispose();
    scrollController!.removeListener(_scrollListener);
  }

  void _scrollListener() async {
    requestsProvider = Provider.of<RequestsProvider>(context, listen: true);
    if (!requestsProvider.isLoadingChannelList) {
      if (scrollController!.position.pixels ==
          scrollController!.position.maxScrollExtent) {
        requestsProvider.setChannelDataLoading(isLoading: true);
        requestsProvider.getChannelData(
          orderBy: orderBy,
          descending: descending,
        );
      }
    }
  }

  navigateToRequestsScreen(BuildContext context, ChannelModel channelData) {
    nextScreen(context, RequestListScreen(channelModel: channelData));
  }

  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.of(context).size.width;
    requestsProvider = Provider.of<RequestsProvider>(context, listen: true);
    return Container(
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
        crossAxisAlignment: CrossAxisAlignment.start,
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
                    'Channel Join Requests',
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

          // displaying content here
          Expanded(
              child: requestsProvider.isLoadingChannelList == true
                  ? const Center(
                      child: CircularProgressIndicator(
                        color: Colors.redAccent,
                      ),
                    )
                  : requestsProvider.hasChannelData == false
                      ? emptyPage(
                          FontAwesomeIcons.peopleGroup, 'No Channel Found!')
                      : RefreshIndicator(
                          onRefresh: () async {
                            refreshData();
                          },
                          color: Colors.red,
                          child: ListView.builder(
                            itemCount: requestsProvider.channelData.length + 1,
                            itemBuilder: (context, index) {
                              if (index < requestsProvider.channelData.length) {
                                final ChannelModel d = ChannelModel.fromMap(
                                    requestsProvider.channelData[index].data()
                                        as dynamic);
                                return buildChannelList(d);
                              }
                              return Center(
                                child: Opacity(
                                  opacity: requestsProvider.isLoadingChannelList
                                      ? 1.0
                                      : 0.0,
                                  child: const SizedBox(
                                    width: 32,
                                    height: 32,
                                    child: CircularProgressIndicator(
                                        color: Colors.redAccent),
                                  ),
                                ),
                              );
                            },
                          ),
                        ))
        ],
      ),
    );
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

  //building channel list
  Widget buildChannelList(ChannelModel channelData) {
    return Container(
      padding: const EdgeInsets.all(15),
      height: 100,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey[200]!),
        borderRadius: BorderRadius.circular(10),
      ),
      margin: const EdgeInsets.only(top: 20),
      child: ListTile(
        leading: CachedNetworkImage(
          imageUrl: channelData.channelPhoto,
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
          channelData.channelName,
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        subtitle: SelectableText(
            'UID: ${channelData.groupId} \nMembers: ${channelData.membersId.length} Moderators: ${channelData.moderatorsId.length}'),
        isThreeLine: true,
        trailing: InkWell(
          child: CircleAvatar(
            backgroundColor: Colors.grey[200],
            radius: 18,
            child: const Icon(
              FontAwesomeIcons.arrowRight,
              size: 18,
              color: Colors.black54,
            ),
          ),
          onTap: () => navigateToRequestsScreen(context, channelData),
        ),
      ),
    );
  }
}
