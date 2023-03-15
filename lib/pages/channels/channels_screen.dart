import 'package:cached_network_image/cached_network_image.dart';
import 'package:dellenhauer_admin/model/channel/channel_model.dart';
import 'package:dellenhauer_admin/pages/channels/channels_edit_screen.dart';
import 'package:dellenhauer_admin/providers/channels_provider.dart';
import 'package:dellenhauer_admin/utils/nextscreen.dart';
import 'package:dellenhauer_admin/utils/utils.dart';
import 'package:dellenhauer_admin/utils/widgets/empty.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';

class ChannelsScreen extends StatefulWidget {
  const ChannelsScreen({super.key});

  @override
  State<ChannelsScreen> createState() => _ChannelsScreenState();
}

class _ChannelsScreenState extends State<ChannelsScreen> {
  String? sortByText;
  late ChannelProvider channelProvider;
  ScrollController? scrollController;
  late bool descending;
  late String orderBy;

  @override
  void initState() {
    super.initState();
    sortByText = 'Newest First';
    orderBy = 'created_timestamp';
    descending = true;
    Future.delayed(Duration.zero, () {
      scrollController = ScrollController()..addListener(_scrollListener);
      channelProvider = Provider.of<ChannelProvider>(context, listen: false);
      channelProvider.attachContext(context);
      channelProvider.setLoading(isLoading: true);
      channelProvider.getChannelData(orderBy: orderBy, descending: descending);
    });
  }

  void refreshData() {
    channelProvider = Provider.of<ChannelProvider>(context, listen: false);
    channelProvider.setLastVisible(documentSnapshot: null);
    channelProvider.setLoading(isLoading: true);
    channelProvider.channelData.clear();
    channelProvider.getChannelData(descending: descending, orderBy: orderBy);
    channelProvider.notifyListeners();
  }

  @override
  void dispose() {
    super.dispose();
    scrollController!.removeListener(_scrollListener);
  }

  // scroll listener
  void _scrollListener() {
    channelProvider = Provider.of<ChannelProvider>(context, listen: true);
    if (!channelProvider.isLoading) {
      if (scrollController!.position.pixels ==
          scrollController!.position.maxScrollExtent) {
        channelProvider.setLoading(isLoading: true);
        channelProvider.getChannelData(
            orderBy: orderBy, descending: descending);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.of(context).size.width;
    channelProvider = Provider.of<ChannelProvider>(context, listen: true);
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
          ]),
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
                'All Channels',
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
          // displaying content here
          Expanded(
              child: channelProvider.isLoading == true
                  ? const Center(
                      child: CircularProgressIndicator(
                      color: Colors.redAccent,
                    ))
                  : channelProvider.hasData == false
                      ? emptyPage(
                          FontAwesomeIcons.peopleGroup, 'No Channel Found!')
                      : RefreshIndicator(
                          color: Colors.redAccent,
                          child: ListView.builder(
                            itemCount: channelProvider.channelData.length + 1,
                            itemBuilder: (context, index) {
                              if (index < channelProvider.channelData.length) {
                                final ChannelModel d = ChannelModel.fromMap(
                                    channelProvider.channelData[index].data()
                                        as dynamic);

                                return buildContentList(d);
                              }
                              return Center(
                                child: Opacity(
                                  opacity:
                                      channelProvider.isLoading ? 1.0 : 0.0,
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
                          onRefresh: () async {
                            refreshData();
                          }))
        ],
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
            )
          ],
        ),
      ),
      itemBuilder: (context) {
        return const [
          PopupMenuItem(value: 'new', child: Text('Newest First')),
          PopupMenuItem(value: 'old', child: Text('Oldest First')),
          // PopupMenuItem(value: 'users', child: Text('Most Users')),
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

  // building the content list
  Widget buildContentList(ChannelModel channelModel) {
    return Container(
      margin: const EdgeInsets.only(top: 10, bottom: 10),
      padding: const EdgeInsets.all(15),
      height: 150,
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey[200]!),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () =>
                showImageContentDialog(context, channelModel.channelPhoto),
            child: CachedNetworkImage(
              imageUrl: channelModel.channelPhoto!,
              placeholder: (context, url) {
                return Container(
                  height: 130,
                  width: 150,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(10),
                    image: const DecorationImage(
                      image: AssetImage('assets/images/placeholder.jpeg'),
                      fit: BoxFit.cover,
                    ),
                  ),
                );
              },
              errorWidget: (context, url, error) {
                return Container(
                  height: 130,
                  width: 150,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(10),
                    image: const DecorationImage(
                      image: AssetImage('assets/images/placeholder.jpeg'),
                      fit: BoxFit.cover,
                    ),
                  ),
                );
              },
              imageBuilder: (context, imageProvider) {
                return Container(
                  height: 130,
                  width: 150,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(10),
                    image: DecorationImage(
                      image: imageProvider,
                      fit: BoxFit.cover,
                    ),
                  ),
                );
              },
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(top: 15, left: 15),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    channelModel.channelName!,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      // members
                      Container(
                        padding: const EdgeInsets.all(10),
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: Colors.grey[200],
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(
                              FontAwesomeIcons.solidUser,
                              size: 12,
                              color: Colors.grey,
                            ),
                            const SizedBox(width: 10),
                            Text(
                              channelModel.membersId!.length.toString(),
                              style: const TextStyle(
                                color: Colors.grey,
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                              ),
                            )
                          ],
                        ),
                      ),
                      const SizedBox(width: 10),
                      // moderators
                      Container(
                        padding: const EdgeInsets.all(10),
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: Colors.grey[200],
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(
                              FontAwesomeIcons.userSecret,
                              size: 12,
                              color: Colors.grey,
                            ),
                            const SizedBox(width: 10),
                            Text(
                              channelModel.moderatorsId!.length.toString(),
                              style: const TextStyle(
                                color: Colors.grey,
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 10),
                      InkWell(
                        child: Container(
                          padding: const EdgeInsets.all(10),
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: Colors.grey[200],
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Icon(
                            Icons.remove_red_eye,
                            size: 15,
                            color: Colors.grey,
                          ),
                        ),
                        onTap: () =>
                            handlePreview(context, channelModel.channelPhoto!),
                      ),
                      const SizedBox(width: 10),
                      InkWell(
                        child: Container(
                          padding: const EdgeInsets.all(10),
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: Colors.grey[200],
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Icon(
                            Icons.edit,
                            size: 15,
                            color: Colors.grey,
                          ),
                        ),
                        onTap: () => nextScreen(context,
                            ChannelEditScreen(channelModel: channelModel)),
                      ),
                      const SizedBox(width: 10),
                      InkWell(
                        child: Container(
                          padding: const EdgeInsets.all(10),
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: Colors.redAccent,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Icon(
                            Icons.delete,
                            size: 15,
                            color: Colors.white,
                          ),
                        ),
                        onTap: () {
                          showDialog(
                              context: context,
                              builder: (context) {
                                return AlertDialog(
                                    title: const Text('Delete?'),
                                    content: const Text(
                                      'Are you sure you want to delete this channel from database?',
                                    ),
                                    actions: [
                                      ElevatedButton(
                                          onPressed: () {
                                            channelProvider
                                                .deleteChannelFromDatabase(
                                                    channelId:
                                                        channelModel.groupId!)
                                                .whenComplete(() {
                                              Navigator.of(context).pop();
                                              showSnackbar(context,
                                                  'Channel delete successfully from database');
                                              setState(() {});
                                            });
                                          },
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: Colors.redAccent,
                                          ),
                                          child: const Text('YES')),
                                      ElevatedButton(
                                          onPressed: () =>
                                              Navigator.of(context).pop(),
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: Colors.grey,
                                          ),
                                          child: const Text('NO')),
                                    ]);
                              });
                        },
                      ),
                    ],
                  )
                ],
              ),
            ),
          )
        ],
      ),
    );
  }

  void handlePreview(BuildContext context, String imageUrl) async {
    await showImageContentDialog(context, imageUrl);
  }
}
