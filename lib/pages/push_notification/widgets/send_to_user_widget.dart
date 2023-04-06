import 'package:cached_network_image/cached_network_image.dart';
import 'package:dellenhauer_admin/pages/push_notification/widgets/user_and_channel_list_notification.dart';
import 'package:dellenhauer_admin/providers/users_provider.dart';
import 'package:dellenhauer_admin/utils/colors.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';

class SendToUserWidget extends StatefulWidget {
  const SendToUserWidget({super.key});

  @override
  State<SendToUserWidget> createState() => _SendToUserWidgetState();
}

class _SendToUserWidgetState extends State<SendToUserWidget> {
  bool _isSingleUser = false;
  bool _allUser = false;
  late UsersProvider usersProvider;
  @override
  Widget build(BuildContext context) {
    usersProvider = Provider.of<UsersProvider>(context, listen: true);
    return SizedBox(
      width: MediaQuery.of(context).size.width,
      child: Column(
        children: [
          // single users and all users
          Row(
            children: [
              Container(
                constraints: const BoxConstraints(minWidth: 200),
                child: Row(
                  children: [
                    Checkbox(
                      activeColor: kPrimaryColor,
                      value: _isSingleUser,
                      onChanged: (value) {
                        setState(() {
                          _isSingleUser = value!;
                          _allUser = false;
                        });
                      },
                    ),
                    const Text('Single Users'),
                  ],
                ),
              ),
              Container(
                constraints: const BoxConstraints(minWidth: 200),
                child: Row(
                  children: [
                    Checkbox(
                      activeColor: kPrimaryColor,
                      value: _allUser,
                      onChanged: (value) {
                        setState(() {
                          _allUser = value!;
                          _isSingleUser = false;
                        });
                      },
                    ),
                    const Text('All Users'),
                  ],
                ),
              ),
            ],
          ),

          // when single user is selected then i will be showcasing popup for adding users
          _isSingleUser
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
                              usersProvider.selectedNotificationUser.length,
                              (index) {
                                final e = usersProvider
                                    .selectedNotificationUser[index];
                                return SizedBox(
                                  width: 200,
                                  child: ListTile(
                                    contentPadding: EdgeInsets.zero,
                                    title: Text(
                                      '${e.firstName!} ${e.lastName!}',
                                      maxLines: 1,
                                    ),
                                    subtitle: Text(
                                      e.phoneNumber!,
                                      maxLines: 1,
                                    ),
                                    leading: CachedNetworkImage(
                                      imageUrl: e.profilePic!,
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
                                        usersProvider
                                            .removeSelectedUserForNoticiation(
                                          e.userId!,
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
                                  isUser: true,
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
