import 'package:cached_network_image/cached_network_image.dart';
import 'package:dellenhauer_admin/pages/push_notification/widgets/user_and_channel_list_notification.dart';
import 'package:dellenhauer_admin/providers/channels_provider.dart';
import 'package:dellenhauer_admin/utils/colors.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';

class SendToChannelWidget extends StatefulWidget {
  const SendToChannelWidget({super.key});

  @override
  State<SendToChannelWidget> createState() => _SendToChannelWidgetState();
}

class _SendToChannelWidgetState extends State<SendToChannelWidget> {
  bool _isSingleChannel = false;

  bool _allChannels = false;
  late ChannelProvider channelProvider;

  @override
  Widget build(BuildContext context) {
    channelProvider = Provider.of<ChannelProvider>(context, listen: true);
    return SizedBox(
      width: MediaQuery.of(context).size.width,
      child: Column(
        children: [
          Row(
            children: [
              Container(
                constraints: const BoxConstraints(minWidth: 200),
                child: Row(
                  children: [
                    Checkbox(
                      activeColor: kPrimaryColor,
                      value: _isSingleChannel,
                      onChanged: (value) {
                        setState(() {
                          _isSingleChannel = value!;
                          _allChannels = false;
                        });
                      },
                    ),
                    const Text('Single Channel'),
                  ],
                ),
              ),
              Container(
                constraints: const BoxConstraints(minWidth: 200),
                child: Row(
                  children: [
                    Checkbox(
                      activeColor: kPrimaryColor,
                      value: _allChannels,
                      onChanged: (value) {
                        setState(() {
                          _allChannels = value!;
                          _isSingleChannel = false;
                        });
                      },
                    ),
                    const Text('All Channels'),
                  ],
                ),
              ),
            ],
          ),
          _isSingleChannel
              ? Stack(
                  children: [
                    Container(
                        width: MediaQuery.of(context).size.width,
                        height: 200,
                        margin: const EdgeInsets.symmetric(vertical: 10),
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: Colors.grey.shade300,
                          ),
                        ),
                        child: SingleChildScrollView(
                          scrollDirection: Axis.vertical,
                          child: Wrap(
                            direction: Axis.horizontal,
                            alignment: WrapAlignment.start,
                            crossAxisAlignment: WrapCrossAlignment.start,
                            children: List.generate(
                              channelProvider
                                  .selectedNotificationChannels.length,
                              (index) {
                                final e = channelProvider
                                    .selectedNotificationChannels[index];
                                return SizedBox(
                                  width: 200,
                                  child: ListTile(
                                    contentPadding: EdgeInsets.zero,
                                    title: Text(
                                      e.channelName!,
                                      maxLines: 1,
                                    ),
                                    subtitle: Text(
                                      e.channelDescription!,
                                      maxLines: 1,
                                    ),
                                    leading: CachedNetworkImage(
                                      imageUrl: e.channelPhoto!,
                                      placeholder: (context, url) {
                                        return Container(
                                          height: 30,
                                          width: 30,
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
                                          height: 30,
                                          width: 30,
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
                                          height: 30,
                                          width: 30,
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
                                    trailing: IconButton(
                                      icon: const Icon(
                                        FontAwesomeIcons.circleXmark,
                                        color: kPrimaryColor,
                                        size: 13,
                                      ),
                                      onPressed: () {
                                        channelProvider
                                            .removeSelectedNotificationChannels(
                                          e.groupId!,
                                        );
                                      },
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                        )),
                    Positioned(
                      right: 0,
                      top: 10,
                      child: IconButton(
                        icon: const Icon(
                          FontAwesomeIcons.circlePlus,
                          color: kPrimaryColor,
                        ),
                        onPressed: () {
                          showDialog(
                              context: context,
                              builder: (context) {
                                return const UserListNotificationSelection(
                                  isUser: false,
                                );
                              });
                        },
                      ),
                    )
                  ],
                )
              : const SizedBox.shrink(),
        ],
      ),
    );
  }
}
