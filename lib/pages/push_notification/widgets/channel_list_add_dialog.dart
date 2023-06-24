import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dellenhauer_admin/model/channel/channel_model.dart';
import 'package:dellenhauer_admin/pages/channels/channels_screen.dart';
import 'package:dellenhauer_admin/providers/channels_provider.dart';
import 'package:dellenhauer_admin/utils/colors.dart';
import 'package:dellenhauer_admin/utils/widgets/empty.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';

class ChannelListAddDialog extends StatefulWidget {
  final bool selectMultipleChannels;
  const ChannelListAddDialog({super.key, this.selectMultipleChannels = false});

  @override
  State<ChannelListAddDialog> createState() => _ChannelListAddDialogState();
}

class _ChannelListAddDialogState extends State<ChannelListAddDialog> {
  late ChannelProvider channelProvider;
  List<DocumentSnapshot<Object?>>? _searchedChannel;
  String _searchQuery = '';
  final TextEditingController _textEditingController = TextEditingController();
  final _debouncer = Debouncer(milliseconds: 100);

  @override
  void initState() {
    super.initState();
    Future.delayed(Duration.zero, () {
      channelProvider = Provider.of<ChannelProvider>(context, listen: false);
      channelProvider.channelData.clear();
      channelProvider.setLastVisible(documentSnapshot: null);
      channelProvider.attachContext(context);
      channelProvider.setLoading(isLoading: true);
      channelProvider.getChannelData(
        orderBy: 'created_timestamp',
        descending: true,
      );
    });
  }

  @override
  void dispose() {
    _debouncer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    channelProvider = Provider.of<ChannelProvider>(context, listen: true);
    return FractionallySizedBox(
      heightFactor: 0.85,
      widthFactor: 0.85,
      child: Scaffold(
        body: Padding(
          padding: const EdgeInsets.only(top: 10, left: 10, right: 10),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10.0),
                child: Container(
                  height: 50,
                  margin: const EdgeInsets.only(top: 10),
                  width: MediaQuery.of(context).size.width,
                  child: TextFormField(
                    cursorColor: kPrimaryColor,
                    controller: _textEditingController,
                    style: const TextStyle(color: Colors.black54),
                    onChanged: _updateSearchQuery,
                    decoration: InputDecoration(
                      suffixIcon: _textEditingController.text.isNotEmpty
                          ? IconButton(
                              onPressed: () {
                                setState(() {
                                  _textEditingController.clear();
                                });
                              },
                              icon: const Icon(
                                FontAwesomeIcons.solidCircleXmark,
                                size: 20,
                                color: kPrimaryColor,
                              ),
                            )
                          : null,
                      hintText: 'Search channels here...',
                      hintStyle: const TextStyle(
                        color: Colors.black54,
                        fontSize: 13,
                      ),
                      contentPadding:
                          const EdgeInsets.symmetric(horizontal: 20),
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
                      errorBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: const BorderSide(color: Colors.redAccent),
                      ),
                      border: InputBorder.none,
                    ),
                  ),
                ),
              ),
              Expanded(
                child: channelProvider.isLoading
                    ? const Center(
                        child: CircularProgressIndicator(
                          color: kPrimaryColor,
                        ),
                      )
                    : !channelProvider.hasData
                        ? emptyPage(
                            FontAwesomeIcons.peopleGroup,
                            'No Channel Found!',
                          )
                        : NotificationListener<ScrollUpdateNotification>(
                            onNotification: (notification) {
                              if (_searchedChannel == null &&
                                  !channelProvider.isLoading) {
                                if (notification.metrics.pixels ==
                                        notification.metrics.maxScrollExtent &&
                                    notification.scrollDelta! > 0) {
                                  _debouncer.run(() {
                                    channelProvider.loadingMoreContent(
                                        isLoading: true);
                                    channelProvider.getChannelData(
                                      orderBy: 'created_timestamp',
                                      descending: true,
                                    );
                                  });
                                }
                              }
                              return false;
                            },
                            child: ListView.builder(
                              itemCount: _searchedChannel?.length ??
                                  channelProvider.channelData.length +
                                      (channelProvider.isLoadingMoreContent
                                          ? 1
                                          : 0),
                              shrinkWrap: true,
                              padding: EdgeInsets.zero,
                              itemBuilder: (context, index) {
                                if (_searchedChannel == null &&
                                    index >=
                                        channelProvider.channelData.length) {
                                  return Center(
                                    child: Opacity(
                                      opacity:
                                          channelProvider.isLoadingMoreContent
                                              ? 1.0
                                              : 0.0,
                                      child: const SizedBox(
                                        width: 32,
                                        height: 32,
                                        child: CircularProgressIndicator(
                                            color: kPrimaryColor),
                                      ),
                                    ),
                                  );
                                }
                                ChannelModel currentChannel =
                                    ChannelModel.fromMap(
                                  (_searchedChannel ??
                                          channelProvider.channelData)[index]
                                      .data() as dynamic,
                                );
                                return Container(
                                  margin: const EdgeInsets.only(
                                      top: 10, bottom: 10),
                                  padding: const EdgeInsets.all(15),
                                  height: 150,
                                  decoration: BoxDecoration(
                                    border:
                                        Border.all(color: Colors.grey[200]!),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Row(
                                    children: [
                                      CachedNetworkImage(
                                        imageUrl: currentChannel.channelPhoto!,
                                        placeholder: (context, url) {
                                          return Container(
                                            height: 130,
                                            width: 150,
                                            decoration: BoxDecoration(
                                              color: Colors.grey[300],
                                              borderRadius:
                                                  BorderRadius.circular(10),
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
                                            height: 130,
                                            width: 150,
                                            decoration: BoxDecoration(
                                              color: Colors.grey[300],
                                              borderRadius:
                                                  BorderRadius.circular(10),
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
                                            height: 130,
                                            width: 150,
                                            decoration: BoxDecoration(
                                              color: Colors.grey[300],
                                              borderRadius:
                                                  BorderRadius.circular(10),
                                              image: DecorationImage(
                                                image: imageProvider,
                                                fit: BoxFit.cover,
                                              ),
                                            ),
                                          );
                                        },
                                      ),
                                      Expanded(
                                        child: Padding(
                                          padding: const EdgeInsets.only(
                                              top: 15, left: 15),
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                currentChannel.channelName!,
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
                                                    padding:
                                                        const EdgeInsets.all(
                                                            10),
                                                    alignment: Alignment.center,
                                                    decoration: BoxDecoration(
                                                      color: Colors.grey[200],
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              10),
                                                    ),
                                                    child: Row(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .center,
                                                      children: [
                                                        const Icon(
                                                          FontAwesomeIcons
                                                              .solidUser,
                                                          size: 12,
                                                          color: Colors.grey,
                                                        ),
                                                        const SizedBox(
                                                            width: 10),
                                                        Text(
                                                          currentChannel
                                                              .totalMembers
                                                              .toString(),
                                                          style:
                                                              const TextStyle(
                                                            color: Colors.grey,
                                                            fontSize: 12,
                                                            fontWeight:
                                                                FontWeight.w600,
                                                          ),
                                                        )
                                                      ],
                                                    ),
                                                  ),
                                                  const SizedBox(width: 10),
                                                  // moderators
                                                  Container(
                                                    padding:
                                                        const EdgeInsets.all(
                                                            10),
                                                    alignment: Alignment.center,
                                                    decoration: BoxDecoration(
                                                      color: Colors.grey[200],
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              10),
                                                    ),
                                                    child: Row(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .center,
                                                      children: [
                                                        const Icon(
                                                          FontAwesomeIcons
                                                              .userSecret,
                                                          size: 12,
                                                          color: Colors.grey,
                                                        ),
                                                        const SizedBox(
                                                            width: 10),
                                                        Text(
                                                          currentChannel
                                                              .totalModerators
                                                              .toString(),
                                                          style:
                                                              const TextStyle(
                                                            color: Colors.grey,
                                                            fontSize: 12,
                                                            fontWeight:
                                                                FontWeight.w600,
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                  const SizedBox(width: 10),
                                                  const Spacer(),
                                                  widget.selectMultipleChannels
                                                      ? Checkbox(
                                                          activeColor:
                                                              kPrimaryColor,
                                                          shape:
                                                              RoundedRectangleBorder(
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        20),
                                                          ),
                                                          value: channelProvider
                                                              .selectedNotificationChannels
                                                              .contains(
                                                            currentChannel
                                                                .groupId,
                                                          ),
                                                          onChanged: (value) {
                                                            if (value != null &&
                                                                value == true) {
                                                              channelProvider
                                                                  .setSelectedNotificationChannels(
                                                                currentChannel
                                                                    .groupId!,
                                                              );
                                                            } else {
                                                              channelProvider
                                                                  .removeSelectedNotificationChannels(
                                                                currentChannel
                                                                    .groupId!,
                                                              );
                                                            }
                                                          })
                                                      : Checkbox(
                                                          activeColor:
                                                              kPrimaryColor,
                                                          shape:
                                                              RoundedRectangleBorder(
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        20),
                                                          ),
                                                          value: channelProvider
                                                                      .selectedChannelPushNotification !=
                                                                  null &&
                                                              channelProvider
                                                                      .selectedChannelPushNotification!
                                                                      .groupId ==
                                                                  currentChannel
                                                                      .groupId,
                                                          onChanged: (value) {
                                                            if (value != null &&
                                                                value == true) {
                                                              channelProvider
                                                                  .setSingleSelectedNotificationChannel(
                                                                currentChannel,
                                                              );
                                                            } else {
                                                              channelProvider
                                                                  .setSingleSelectedNotificationChannel(
                                                                null,
                                                              );
                                                            }
                                                          })
                                                ],
                                              )
                                            ],
                                          ),
                                        ),
                                      )
                                    ],
                                  ),
                                );
                              },
                            ),
                          ),
              )
            ],
          ),
        ),
      ),
    );
  }

  void _updateSearchQuery(String newQuery) {
    _searchQuery = newQuery;

    if (_searchQuery.isEmpty) {
      _searchedChannel = null;
    } else {
      _searchedChannel = channelProvider.channelData
          .where((element) => element['channel_name']
              .toString()
              .toLowerCase()
              .contains(_searchQuery.toLowerCase()))
          .toList();
    }

    setState(() {});
  }
}
