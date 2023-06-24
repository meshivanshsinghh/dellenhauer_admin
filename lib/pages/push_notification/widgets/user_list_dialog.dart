import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dellenhauer_admin/model/users/user_model.dart';
import 'package:dellenhauer_admin/pages/channels/channels_screen.dart';
import 'package:dellenhauer_admin/providers/users_provider.dart';
import 'package:dellenhauer_admin/utils/colors.dart';
import 'package:dellenhauer_admin/utils/widgets/empty.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';

class UserListDialog extends StatefulWidget {
  final bool selectMultipleUsers;
  final bool isTestUser;
  const UserListDialog(
      {super.key, this.selectMultipleUsers = false, this.isTestUser = false});

  @override
  State<UserListDialog> createState() => _UserListDialogState();
}

class _UserListDialogState extends State<UserListDialog> {
  late UsersProvider userProvider;
  final TextEditingController _textEditingController = TextEditingController();
  List<DocumentSnapshot<Object?>>? _searchUsers;
  String _searchQuery = '';
  final _debouncer = Debouncer(milliseconds: 100);

  @override
  void initState() {
    super.initState();
    Future.delayed(Duration.zero, () {
      userProvider = Provider.of<UsersProvider>(context, listen: false);
      userProvider.data.clear();
      userProvider.setLastVisible(snapshot: null);
      userProvider.attachContext(context);
      userProvider.setLoading(isLoading: true);
      userProvider.getUsersData(orderBy: 'createdAt', descending: true);
    });
  }

  // update search query
  void _updateSearchQuery(String query) {
    _searchQuery = query;
    if (_searchQuery.isEmpty) {
      _searchUsers = null;
    } else {
      _searchUsers = userProvider.data
          .where((element) => element['firstName']
              .toString()
              .toLowerCase()
              .contains(_searchQuery.toLowerCase()))
          .toList();
    }
    setState(() {});
  }

  @override
  void dispose() {
    _debouncer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    userProvider = Provider.of<UsersProvider>(context, listen: true);
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
                      hintText: 'Search users here...',
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
                  child: userProvider.isLoading
                      ? const Center(
                          child: CircularProgressIndicator(
                            color: kPrimaryColor,
                          ),
                        )
                      : !userProvider.hasData
                          ? emptyPage(
                              FontAwesomeIcons.peopleGroup,
                              'No Users Found!',
                            )
                          : NotificationListener<ScrollUpdateNotification>(
                              onNotification: (notification) {
                                if (_searchUsers == null &&
                                    !userProvider.isLoading) {
                                  if (notification.metrics.pixels ==
                                          notification
                                              .metrics.maxScrollExtent &&
                                      notification.scrollDelta! > 0) {
                                    _debouncer.run(() {
                                      userProvider.loadingMoreContent(
                                          isLoading: true);
                                      userProvider.getUsersData(
                                        orderBy: 'createdAt',
                                        descending: true,
                                      );
                                    });
                                  }
                                }
                                return false;
                              },
                              child: ListView.builder(
                                itemCount: _searchUsers?.length ??
                                    userProvider.data.length,
                                shrinkWrap: true,
                                padding: EdgeInsets.zero,
                                itemBuilder: (context, index) {
                                  UserModel currentUser = UserModel.fromJson(
                                    (_searchUsers ?? userProvider.data)[index]
                                        .data() as dynamic,
                                  );
                                  return ListTile(
                                      contentPadding: const EdgeInsets.only(
                                          top: 10, bottom: 10),
                                      leading: CachedNetworkImage(
                                        imageUrl: currentUser.profilePic!,
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
                                          '${currentUser.email} \nUID: ${currentUser.phoneNumber}'),
                                      title: SelectableText(
                                        '${currentUser.firstName} ${currentUser.lastName}',
                                        style: const TextStyle(
                                            fontWeight: FontWeight.w600),
                                      ),
                                      isThreeLine: true,
                                      trailing: widget.isTestUser
                                          ? Checkbox(
                                              activeColor: kPrimaryColor,
                                              shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(20),
                                              ),
                                              value: userProvider
                                                          .selectedTestNotificationUser !=
                                                      null &&
                                                  userProvider
                                                          .selectedTestNotificationUser!
                                                          .userId ==
                                                      currentUser.userId,
                                              onChanged: (value) {
                                                if (value != null &&
                                                    value == true) {
                                                  userProvider
                                                      .setSelectedTestUser(
                                                          currentUser);
                                                } else {
                                                  userProvider
                                                      .removeSelectedTestUser();
                                                }
                                              })
                                          : widget.selectMultipleUsers
                                              ? Checkbox(
                                                  activeColor: kPrimaryColor,
                                                  shape: RoundedRectangleBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            20),
                                                  ),
                                                  value: userProvider
                                                      .selectedNotificationUser
                                                      .contains(
                                                          currentUser.userId),
                                                  onChanged: (value) {
                                                    if (value != null &&
                                                        value == true) {
                                                      userProvider
                                                          .setSelectedUserForNotification(
                                                        currentUser.userId!,
                                                      );
                                                    } else {
                                                      userProvider
                                                          .removeSelectedUserForNoticiation(
                                                        currentUser.userId!,
                                                      );
                                                    }
                                                  })
                                              : Checkbox(
                                                  activeColor: kPrimaryColor,
                                                  shape: RoundedRectangleBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            20),
                                                  ),
                                                  value: userProvider
                                                              .selectedUserForPushNotification !=
                                                          null &&
                                                      userProvider
                                                              .selectedUserForPushNotification!
                                                              .userId ==
                                                          currentUser.userId,
                                                  onChanged: (value) {
                                                    if (value != null &&
                                                        value == true) {
                                                      userProvider
                                                          .setSelectedPushNotificationUser(
                                                        currentUser,
                                                      );
                                                    } else {
                                                      userProvider
                                                          .setSelectedPushNotificationUser(
                                                        null,
                                                      );
                                                    }
                                                  },
                                                ));
                                },
                              ),
                            ))
            ],
          ),
        ),
      ),
    );
  }
}
