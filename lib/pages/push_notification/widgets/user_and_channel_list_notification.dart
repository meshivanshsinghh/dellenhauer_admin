import 'package:cached_network_image/cached_network_image.dart';
import 'package:dellenhauer_admin/model/channel/channel_model.dart';
import 'package:dellenhauer_admin/model/users/user_model.dart';
import 'package:dellenhauer_admin/providers/channels_provider.dart';
import 'package:dellenhauer_admin/providers/users_provider.dart';
import 'package:dellenhauer_admin/utils/colors.dart';
import 'package:dellenhauer_admin/utils/widgets/empty.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';

class UserListNotificationSelection extends StatefulWidget {
  final bool isUser;
  final bool isTestUser;
  const UserListNotificationSelection(
      {super.key, required this.isUser, this.isTestUser = false});

  @override
  State<UserListNotificationSelection> createState() =>
      _UserListNotificationSelectionState();
}

class _UserListNotificationSelectionState
    extends State<UserListNotificationSelection> {
  late UsersProvider usersProvider;
  late ChannelProvider channelProvider;

  @override
  void initState() {
    super.initState();
    Future.delayed(Duration.zero, () {
      if (widget.isUser) {
        usersProvider = Provider.of<UsersProvider>(context, listen: false);
        usersProvider.attachContext(context);
        usersProvider.setLoading(isLoading: true);
        usersProvider.getUsersData(orderBy: 'createdAt', descending: true);
      } else {
        channelProvider = Provider.of<ChannelProvider>(context, listen: false);
        channelProvider.attachContext(context);
        channelProvider.setLoading(isLoading: true);
        channelProvider.getChannelData(
          orderBy: 'created_timestamp',
          descending: true,
        );
      }
    });
  }

  refreshData() {
    if (widget.isUser) {
      usersProvider = Provider.of<UsersProvider>(context, listen: false);
      usersProvider.setLastVisible(snapshot: null);
      usersProvider.setLoading(isLoading: true);
      usersProvider.data.clear();
      usersProvider.getUsersData(orderBy: 'createdAt', descending: true);
      usersProvider.notifyListeners();
    } else {
      channelProvider = Provider.of<ChannelProvider>(context, listen: false);
      channelProvider.setLastVisible(documentSnapshot: null);
      channelProvider.setLoading(isLoading: true);
      channelProvider.channelData.clear();
      channelProvider.getChannelData(
          orderBy: 'created_timestamp', descending: true);
      channelProvider.notifyListeners();
    }
  }

  @override
  Widget build(BuildContext context) {
    usersProvider = Provider.of<UsersProvider>(context, listen: true);
    channelProvider = Provider.of<ChannelProvider>(context, listen: true);
    return FractionallySizedBox(
      heightFactor: 0.8,
      widthFactor: 0.8,
      child: Scaffold(
        body: Container(
          margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    widget.isUser ? 'All Users' : 'All Channels',
                    style: const TextStyle(
                      fontSize: 25,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  IconButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    icon: const Icon(
                      FontAwesomeIcons.circleXmark,
                      color: kPrimaryColor,
                    ),
                  )
                ],
              ),
              widget.isUser
                  ? Expanded(
                      child: usersProvider.isLoading == true
                          ? const Center(
                              child: CircularProgressIndicator(
                                  color: kPrimaryColor),
                            )
                          : usersProvider.hasData == false
                              ? emptyPage(
                                  FontAwesomeIcons.solidUser, 'No user found')
                              : NotificationListener<ScrollNotification>(
                                  onNotification: (notification) {
                                    if (!usersProvider.isLoading) {
                                      if (notification.metrics.pixels ==
                                          notification
                                              .metrics.maxScrollExtent) {
                                        usersProvider.loadingMoreContent(
                                            isLoading: true);
                                        usersProvider.getUsersData(
                                            orderBy: 'createdAt',
                                            descending: true);
                                      }
                                    }
                                    return false;
                                  },
                                  child: RefreshIndicator(
                                    color: kPrimaryColor,
                                    onRefresh: () async {
                                      refreshData();
                                    },
                                    child: ListView.builder(
                                      itemCount: usersProvider.data.length + 1,
                                      itemBuilder: (context, index) {
                                        if (index < usersProvider.data.length) {
                                          final UserModel u =
                                              UserModel.fromJson(
                                            usersProvider.data[index].data()
                                                as dynamic,
                                          );
                                          return buildUserData(u);
                                        }
                                        return Center(
                                          child: Opacity(
                                            opacity: usersProvider
                                                    .isLoadingMoreContent
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
                                      },
                                    ),
                                  ),
                                ),
                    )
                  : Expanded(
                      child: channelProvider.isLoading == true
                          ? const Center(
                              child: CircularProgressIndicator(
                                  color: kPrimaryColor),
                            )
                          : channelProvider.hasData == false
                              ? emptyPage(FontAwesomeIcons.solidUser,
                                  'No channels found')
                              : NotificationListener<ScrollNotification>(
                                  onNotification: (notification) {
                                    if (!channelProvider.isLoading) {
                                      if (notification.metrics.pixels ==
                                          notification
                                              .metrics.maxScrollExtent) {
                                        channelProvider.loadingMoreContent(
                                            isLoading: true);
                                        channelProvider.getChannelData(
                                            orderBy: 'created_timestamp',
                                            descending: true);
                                      }
                                    }
                                    return false;
                                  },
                                  child: RefreshIndicator(
                                    color: kPrimaryColor,
                                    onRefresh: () async {
                                      refreshData();
                                    },
                                    child: ListView.builder(
                                      itemCount:
                                          channelProvider.channelData.length +
                                              1,
                                      itemBuilder: (context, index) {
                                        if (index <
                                            channelProvider
                                                .channelData.length) {
                                          final ChannelModel u =
                                              ChannelModel.fromMap(
                                            channelProvider.channelData[index]
                                                .data() as dynamic,
                                          );
                                          return buildChannelData(u);
                                        }
                                        return Center(
                                          child: Opacity(
                                            opacity: usersProvider
                                                    .isLoadingMoreContent
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
                                      },
                                    ),
                                  ),
                                ),
                    )
            ],
          ),
        ),
      ),
    );
  }

  Widget buildUserData(UserModel userData) {
    return ListTile(
      contentPadding: const EdgeInsets.only(top: 10, bottom: 10),
      leading: CachedNetworkImage(
        imageUrl: userData.profilePic!,
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
      subtitle:
          SelectableText('${userData.email} \nUID: ${userData.phoneNumber}'),
      title: SelectableText(
        '${userData.firstName} ${userData.lastName}',
        style: const TextStyle(fontWeight: FontWeight.w600),
      ),
      isThreeLine: true,
      trailing: widget.isTestUser
          ? IgnorePointer(
              ignoring: usersProvider.selectedTestNotificationUser != null,
              child: IconButton(
                color: usersProvider.selectedTestNotificationUser != null
                    ? Colors.grey
                    : kPrimaryColor,
                icon: const Icon(FontAwesomeIcons.circlePlus),
                onPressed: () {
                  usersProvider.setSelectedTestUser(userData);
                },
              ),
            )
          : IgnorePointer(
              ignoring: usersProvider.selectedNotificationUser
                  .any((element) => element.userId == userData.userId),
              child: IconButton(
                color: usersProvider.selectedNotificationUser
                        .any((element) => element.userId == userData.userId)
                    ? Colors.grey
                    : kPrimaryColor,
                icon: const Icon(FontAwesomeIcons.circlePlus),
                onPressed: () {
                  usersProvider.setSelectedUserForNotification(userData);
                },
              ),
            ),
    );
  }

  Widget buildChannelData(ChannelModel channelModel) {
    return ListTile(
      contentPadding: const EdgeInsets.only(top: 10, bottom: 10),
      leading: CachedNetworkImage(
        imageUrl: channelModel.channelPhoto!,
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
      subtitle: SelectableText(channelModel.channelDescription!),
      title: SelectableText(
        channelModel.channelName!,
        style: const TextStyle(fontWeight: FontWeight.w600),
      ),
      isThreeLine: true,
      trailing: IgnorePointer(
        ignoring: channelProvider.selectedNotificationChannels
            .any((element) => element.groupId == channelModel.groupId),
        child: IconButton(
          color: channelProvider.selectedNotificationChannels
                  .any((element) => element.groupId == channelModel.groupId)
              ? Colors.grey
              : kPrimaryColor,
          icon: const Icon(FontAwesomeIcons.circlePlus),
          onPressed: () {
            channelProvider.setSelectedNotificationChannels(channelModel);
          },
        ),
      ),
    );
  }
}
