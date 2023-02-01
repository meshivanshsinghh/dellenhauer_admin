import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dellenhauer_admin/model/channel/channel_model.dart';
import 'package:dellenhauer_admin/pages/channels/channels_edit_screen.dart';
import 'package:dellenhauer_admin/utils/nextscreen.dart';
import 'package:dellenhauer_admin/utils/utils.dart';
import 'package:dellenhauer_admin/utils/widgets/empty.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class ChannelsScreen extends StatefulWidget {
  const ChannelsScreen({super.key});

  @override
  State<ChannelsScreen> createState() => _ChannelsScreenState();
}

class _ChannelsScreenState extends State<ChannelsScreen> {
  String? _sortByText;

  ScrollController? scrollController;
  late bool _descending;
  late String _orderBy;
  bool? hasData;
  late bool _isLoading;
  DocumentSnapshot? _lastVisible;
  final List<DocumentSnapshot> _data = [];
  final FirebaseFirestore firebaseFirestore = FirebaseFirestore.instance;
  @override
  void initState() {
    super.initState();

    scrollController = ScrollController()..addListener(_scrollListener);
    _isLoading = true;
    _sortByText = 'Newest First';
    _orderBy = 'created_timestamp';
    _descending = true;
    getData();
  }

  void refreshData() {
    setState(() {
      _isLoading = true;
      _lastVisible = null;
      _data.clear();
    });
    getData();
  }

  Future<void> getData() async {
    QuerySnapshot data;
    if (_lastVisible == null) {
      data = await firebaseFirestore
          .collection('channels')
          .orderBy(_orderBy, descending: _descending)
          .limit(10)
          .get();
    } else {
      data = await firebaseFirestore
          .collection('channels')
          .orderBy(_orderBy, descending: _descending)
          .startAfter([_lastVisible![_orderBy]])
          .limit(10)
          .get();
    }
    // is data is not empty
    if (data.docs.isNotEmpty) {
      _lastVisible = data.docs[data.docs.length - 1];
      if (mounted) {
        setState(() {
          _isLoading = false;
          hasData = true;
          _data.addAll(data.docs);
        });
      }
    } else {
      if (_lastVisible == null) {
        setState(() {
          _isLoading = false;
          hasData = false;
        });
      } else {
        setState(() {
          _isLoading = false;
          hasData = true;
        });
        // ignore: use_build_context_synchronously
        showSnackbar(context, 'No more channels available');
      }
    }
  }

  @override
  void dispose() {
    super.dispose();
    scrollController!.removeListener(_scrollListener);
  }

  // scroll listener
  void _scrollListener() {
    if (!_isLoading) {
      if (scrollController!.position.pixels ==
          scrollController!.position.maxScrollExtent) {
        setState(() {
          _isLoading = true;
          getData();
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.of(context).size.width;
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
              child: hasData == false
                  ? emptyPage(FontAwesomeIcons.peopleGroup, 'No Channel Found!')
                  : RefreshIndicator(
                      color: Colors.redAccent,
                      child: ListView.builder(
                        itemCount: _data.length + 1,
                        itemBuilder: (context, index) {
                          if (index < _data.length) {
                            final ChannelModel d = ChannelModel.fromMap(
                                _data[index].data() as dynamic);
                            return buildContentList(d);
                          }
                          return Center(
                            child: Opacity(
                              opacity: _isLoading ? 1.0 : 0.0,
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
              'Sort By - $_sortByText',
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
            _sortByText = 'Newest First';
            _orderBy = 'created_timestamp';
            _descending = true;
          });
        } else if (value == 'old') {
          setState(() {
            _sortByText = 'Oldest First';
            _orderBy = 'created_timestamp';
            _descending = false;
          });
        }
        // else if (value == 'users') {
        //   setState(() {
        //     _sortByText = 'Most Users';
        //     _orderBy = 'members_id';
        //   });
        // }
        // refreshing data
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
              imageUrl: channelModel.channelPhoto,
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
          Padding(
            padding: const EdgeInsets.only(top: 15, left: 15),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  channelModel.channelName,
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
                            channelModel.membersId.length.toString(),
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
                            channelModel.moderatorsId.length.toString(),
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
                          handlePreview(context, channelModel.channelPhoto),
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
                                        onPressed: () {},
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: Colors.redAccent,
                                        ),
                                        child: const Text('YES')),
                                    ElevatedButton(
                                        onPressed: () =>
                                            Navigator.of(context).pop(),
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: Colors.redAccent,
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
          )
        ],
      ),
    );
  }

  void handlePreview(BuildContext context, String imageUrl) async {
    await showImageContentDialog(context, imageUrl);
  }
}
