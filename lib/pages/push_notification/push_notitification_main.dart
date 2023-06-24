import 'package:cached_network_image/cached_network_image.dart';
import 'package:dellenhauer_admin/pages/channels/user_list_add_dialog.dart';
import 'package:dellenhauer_admin/pages/push_notification/widgets/article_list_add_dialog.dart';
import 'package:dellenhauer_admin/pages/push_notification/push_notification_main_provider.dart';
import 'package:dellenhauer_admin/pages/push_notification/widgets/channel_list_add_dialog.dart';
import 'package:dellenhauer_admin/pages/push_notification/widgets/user_and_channel_list_notification.dart';
import 'package:dellenhauer_admin/pages/push_notification/widgets/user_list_dialog.dart';
import 'package:dellenhauer_admin/providers/channels_provider.dart';
import 'package:dellenhauer_admin/providers/overview_provider.dart';
import 'package:dellenhauer_admin/providers/users_provider.dart';
import 'package:dellenhauer_admin/utils/colors.dart';
import 'package:dellenhauer_admin/utils/styles.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class PushNotificationMain extends StatefulWidget {
  const PushNotificationMain({super.key});

  @override
  State<PushNotificationMain> createState() => _PushNotificationMainState();
}

class _PushNotificationMainState extends State<PushNotificationMain> {
  TextEditingController titleController = TextEditingController();
  TextEditingController messageController = TextEditingController();
  TextEditingController articleController = TextEditingController();
  TextEditingController urlController = TextEditingController();
  late UsersProvider usersProvider;
  late ChannelProvider channelProvider;
  late PushNotificationMainProvider pushNotificationMainProvider;
  late OverviewProvider overviewProvider;

  bool _isSent = false;
  bool _allUsers = false;
  bool _selectedUsers = false;
  bool _selectedChannels = false;

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  bool _badgeCount = true;
  bool _sendNow = false;
  DateTime? _selectedDateTime;
  String? _formatedDateTime;
  final targets = ['Article', 'Channel', 'User', 'URL'];
  String _selectedTargets = '';

  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.of(context).size.width;
    pushNotificationMainProvider =
        Provider.of<PushNotificationMainProvider>(context, listen: true);
    usersProvider = Provider.of<UsersProvider>(context, listen: true);
    channelProvider = Provider.of<ChannelProvider>(context, listen: true);
    overviewProvider = Provider.of<OverviewProvider>(context, listen: true);

    return Container(
      width: MediaQuery.of(context).size.width,
      margin: const EdgeInsets.only(left: 30, top: 30, bottom: 30),
      padding: EdgeInsets.only(
        left: w * 0.05,
        right: w * 0.15,
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
      child: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: pushNotificationMainProvider.isSendingNotification
              ? SizedBox(
                  height: 500,
                  width: MediaQuery.of(context).size.width,
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: const [
                        CircularProgressIndicator(color: kPrimaryColor),
                        SizedBox(height: 50),
                        Text(
                          'Sending push notification... This might take a while!',
                        )
                      ],
                    ),
                  ),
                )
              : Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: MediaQuery.of(context).size.height * 0.05),
                    const Text(
                      'Create a new Push Notification',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: MediaQuery.of(context).size.height * 0.03),
                    TextFormField(
                      controller: titleController,
                      cursorColor: kPrimaryColor,
                      maxLength: 40,
                      decoration: inputDecorationPushNotification(
                          'Enter Title', 'Title', titleController),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return "Title text cannot be empty";
                        }
                        return null;
                      },
                    ),
                    TextFormField(
                      controller: messageController,
                      maxLength: 60,
                      cursorColor: kPrimaryColor,
                      decoration: inputDecorationPushNotification(
                        'Enter Message',
                        'Message (Max 60 characters)',
                        messageController,
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return "Message text cannot be empty";
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Checkbox(
                          activeColor: kPrimaryColor,
                          value: _badgeCount,
                          onChanged: (value) {
                            setState(() {
                              _badgeCount = value!;
                            });
                          },
                        ),
                        const SizedBox(width: 10),
                        const Text('Count Badge?')
                      ],
                    ),
                    const SizedBox(height: 10),
                    // send now or send late row
                    Row(
                      children: [
                        Checkbox(
                          activeColor: kPrimaryColor,
                          value: _sendNow,
                          onChanged: (value) {
                            setState(() {
                              _sendNow = value!;
                              if (_sendNow) {
                                _selectedDateTime = null;
                              }
                            });
                          },
                        ),
                        const SizedBox(width: 10),
                        const Text('Send Now!'),
                        const SizedBox(width: 50),
                        // date time picker
                        if (!_sendNow)
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: kPrimaryColor,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20),
                              ),
                            ),
                            onPressed: () {
                              selectDateTime(context);
                            },
                            child: const Text('Select Date & Time'),
                          ),
                        const SizedBox(width: 10),
                        if (!_sendNow && _selectedDateTime != null)
                          Expanded(
                            child: Text(
                              'Geplant um: $_formatedDateTime',
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    const Divider(color: Color(0xffCDCDCD)),
                    const SizedBox(height: 20),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        Text(
                          'Target / Action',
                          style: TextStyle(
                            fontSize: 15,
                            color: Color(0xff6B6B6B),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 10),
                        Text(
                          'Which view will be open, when the user opens the push notification?',
                          style: TextStyle(
                            fontSize: 15,
                            color: Color(0xff6B6B6B),
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ],
                    ),
                    // list of target items
                    Container(
                      width: MediaQuery.of(context).size.width,
                      margin: const EdgeInsets.symmetric(vertical: 20),
                      child: Wrap(
                        direction: Axis.horizontal,
                        alignment: WrapAlignment.spaceBetween,
                        children: [
                          ...targets.map((e) {
                            return Column(
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Checkbox(
                                      activeColor: kPrimaryColor,
                                      value: _selectedTargets == e,
                                      onChanged: (value) {
                                        setState(() {
                                          if (value == true) {
                                            _selectedTargets = e;
                                          } else {
                                            _selectedTargets = '';
                                          }
                                        });
                                      },
                                    ),
                                    Text(e)
                                  ],
                                ),
                                if (_selectedTargets == e)
                                  GestureDetector(
                                    behavior: HitTestBehavior.opaque,
                                    onTap: handleCurrentTarget,
                                    child: Container(
                                      width: 140,
                                      decoration: BoxDecoration(
                                        border: Border.all(
                                            color: const Color(0xffD9D9D9)),
                                      ),
                                      alignment: Alignment.center,
                                      height: 40,
                                      margin: const EdgeInsets.only(
                                        left: 5,
                                        top: 5,
                                      ),
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 5,
                                      ),
                                      child: Text(
                                        'Select $_selectedTargets',
                                        style: const TextStyle(
                                          color: Color(0xff6B6B6B),
                                          fontWeight: FontWeight.w400,
                                        ),
                                      ),
                                    ),
                                  )
                              ],
                            );
                          })
                        ],
                      ),
                    ),
                    if (_selectedTargets.trim().isNotEmpty)
                      buildSelectedWidget(),
                    const SizedBox(height: 20),
                    const Divider(color: Color(0xffCDCDCD)),
                    const SizedBox(height: 20),
                    // showcasing sent to option
                    const Text(
                      'Select the recipients',
                      style: TextStyle(
                        fontSize: 15,
                        color: Color(0xff6B6B6B),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 20),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Checkbox(
                          activeColor: kPrimaryColor,
                          value: _allUsers,
                          onChanged: (value) {
                            if (value != null && value == true) {
                              setState(() {
                                _allUsers = true;
                                _selectedUsers = false;
                                _selectedChannels = false;
                              });
                            } else {
                              setState(() {
                                _allUsers = false;
                              });
                            }
                          },
                        ),
                        Text('All Users (${overviewProvider.userCount} Users)'),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Checkbox(
                          activeColor: kPrimaryColor,
                          value: _selectedUsers,
                          onChanged: (value) {
                            if (value != null && value == true) {
                              setState(() {
                                _selectedUsers = true;
                                _selectedChannels = false;
                                _allUsers = false;
                              });
                            } else {
                              setState(() {
                                _selectedUsers = false;
                              });
                            }
                          },
                        ),
                        _selectedUsers
                            ? Text(
                                'Select Users (${usersProvider.selectedNotificationUser.length})',
                              )
                            : const Text('Select Users'),
                        if (_selectedUsers)
                          Expanded(
                            child: GestureDetector(
                              behavior: HitTestBehavior.opaque,
                              onTap: () {
                                showDialog(
                                  barrierDismissible: true,
                                  context: context,
                                  builder: (context) {
                                    return const UserListDialog(
                                      selectMultipleUsers: true,
                                    );
                                  },
                                );
                              },
                              child: Container(
                                margin: EdgeInsets.only(
                                  left: 20,
                                  right:
                                      MediaQuery.of(context).size.width * 0.3,
                                ),
                                width: 100,
                                decoration: BoxDecoration(
                                  border: Border.all(
                                      color: const Color(0xffD9D9D9)),
                                  borderRadius: BorderRadius.circular(0),
                                  color: const Color(0xffFCFCFC),
                                ),
                                padding: const EdgeInsets.only(
                                  left: 10,
                                  right: 5,
                                  top: 7,
                                  bottom: 7,
                                ),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: const [
                                    Text(
                                      'Select Users',
                                      style:
                                          TextStyle(color: Color(0xff6B6B6B)),
                                    ),
                                    Icon(
                                      Icons.arrow_drop_down_sharp,
                                      color: kPrimaryColor,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Checkbox(
                          activeColor: kPrimaryColor,
                          value: _selectedChannels,
                          onChanged: (value) {
                            if (value != null && value == true) {
                              setState(() {
                                _selectedUsers = false;
                                _selectedChannels = true;
                                _allUsers = false;
                              });
                            } else {
                              setState(() {
                                _selectedChannels = false;
                              });
                            }
                          },
                        ),
                        _selectedChannels
                            ? Text(
                                'Select Channels (${channelProvider.selectedNotificationChannels.length})',
                              )
                            : const Text('Select Channels'),
                        if (_selectedChannels)
                          Expanded(
                            child: GestureDetector(
                              behavior: HitTestBehavior.opaque,
                              onTap: () {
                                showDialog(
                                  barrierDismissible: true,
                                  context: context,
                                  builder: (context) {
                                    return const ChannelListAddDialog(
                                      selectMultipleChannels: true,
                                    );
                                  },
                                );
                              },
                              child: Container(
                                margin: EdgeInsets.only(
                                  right:
                                      MediaQuery.of(context).size.width * 0.3,
                                  left: 20,
                                ),
                                decoration: BoxDecoration(
                                  border: Border.all(
                                      color: const Color(0xffD9D9D9)),
                                  borderRadius: BorderRadius.circular(0),
                                  color: const Color(0xffFCFCFC),
                                ),
                                padding: const EdgeInsets.only(
                                  left: 10,
                                  right: 5,
                                  top: 7,
                                  bottom: 7,
                                ),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: const [
                                    Text(
                                      'Select Channels',
                                      style:
                                          TextStyle(color: Color(0xff6B6B6B)),
                                    ),
                                    Icon(
                                      Icons.arrow_drop_down_sharp,
                                      color: kPrimaryColor,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          )
                      ],
                    ),
                    const SizedBox(height: 20),
                    Container(
                      width: MediaQuery.of(context).size.width,
                      padding: const EdgeInsets.all(10),
                      margin: const EdgeInsets.symmetric(
                          vertical: 20, horizontal: 2),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey.shade300),
                        borderRadius: BorderRadius.circular(0),
                      ),
                      child: SingleChildScrollView(
                        scrollDirection: Axis.vertical,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Send Test Notification',
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 5),
                            const Text(
                              'Send Test Notification to a selected user',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w400,
                                color: Colors.black45,
                              ),
                            ),
                            Container(
                              margin: const EdgeInsets.symmetric(vertical: 20),
                              child: Row(
                                children: [
                                  // button
                                  usersProvider.selectedTestNotificationUser ==
                                          null
                                      ? Expanded(
                                          child: GestureDetector(
                                            behavior: HitTestBehavior.opaque,
                                            onTap: () {
                                              showDialog(
                                                barrierDismissible: true,
                                                context: context,
                                                builder: (context) {
                                                  return const UserListDialog(
                                                    isTestUser: true,
                                                  );
                                                },
                                              );
                                            },
                                            child: Container(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                horizontal: 10,
                                                vertical: 5,
                                              ),
                                              margin: EdgeInsets.only(
                                                right: MediaQuery.of(context)
                                                        .size
                                                        .width *
                                                    0.30,
                                              ),
                                              decoration: BoxDecoration(
                                                border: Border.all(
                                                  color:
                                                      const Color(0xffD9D9D9),
                                                ),
                                                borderRadius:
                                                    BorderRadius.circular(0),
                                              ),
                                              child: Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceBetween,
                                                children: const [
                                                  Text('Select User'),
                                                  Icon(
                                                    Icons.arrow_drop_down_sharp,
                                                    color: kPrimaryColor,
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                        )
                                      : Container(
                                          margin: const EdgeInsets.symmetric(
                                            horizontal: 10,
                                          ),
                                          width: 200,
                                          child: ListTile(
                                            leading: CachedNetworkImage(
                                              imageUrl: usersProvider
                                                  .selectedTestNotificationUser!
                                                  .profilePic!,
                                              placeholder: (context, url) {
                                                return Container(
                                                  height: 30,
                                                  width: 30,
                                                  decoration: BoxDecoration(
                                                    shape: BoxShape.circle,
                                                    color: Colors.grey[300],
                                                    image:
                                                        const DecorationImage(
                                                      image: AssetImage(
                                                          'assets/images/placeholder.jpeg'),
                                                      fit: BoxFit.cover,
                                                    ),
                                                  ),
                                                );
                                              },
                                              errorWidget:
                                                  (context, url, error) {
                                                return Container(
                                                  height: 30,
                                                  width: 30,
                                                  decoration: BoxDecoration(
                                                    shape: BoxShape.circle,
                                                    color: Colors.grey[300],
                                                    image:
                                                        const DecorationImage(
                                                      image: AssetImage(
                                                          'assets/images/placeholder.jpeg'),
                                                      fit: BoxFit.cover,
                                                    ),
                                                  ),
                                                );
                                              },
                                              imageBuilder:
                                                  (context, imageProvider) {
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
                                            contentPadding: EdgeInsets.zero,
                                            title: Text(
                                              '${usersProvider.selectedTestNotificationUser!.firstName!} ${usersProvider.selectedTestNotificationUser!.lastName!}',
                                              maxLines: 1,
                                            ),
                                            trailing: IconButton(
                                              icon: const Icon(
                                                  FontAwesomeIcons.circleXmark,
                                                  size: 20,
                                                  color: kPrimaryColor),
                                              onPressed: () {
                                                usersProvider
                                                    .removeSelectedTestUser();
                                              },
                                            ),
                                            subtitle: Text(
                                              usersProvider
                                                  .selectedTestNotificationUser!
                                                  .phoneNumber!,
                                              maxLines: 1,
                                            ),
                                          ),
                                        ),
                                ],
                              ),
                            ),
                            Row(
                              children: [
                                ElevatedButton(
                                  onPressed: () =>
                                      sendPublishClicked(isTest: true),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: kPrimaryColor,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(30),
                                    ),
                                  ),
                                  child: const Text('Send'),
                                ),
                                const SizedBox(width: 10),
                                _isSent
                                    ? Text(
                                        'Sent!',
                                        style: TextStyle(
                                          color: Colors.green.shade600,
                                        ),
                                      )
                                    : const SizedBox.shrink(),
                              ],
                            )
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    // publish button
                    SizedBox(
                      width: 100,
                      child: ElevatedButton(
                        onPressed: () => sendPublishClicked(isTest: false),
                        style: ElevatedButton.styleFrom(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                          backgroundColor: kPrimaryColor,
                        ),
                        child: const Text('Publish'),
                      ),
                    ),
                    SizedBox(
                      height: MediaQuery.of(context).size.height * 0.10,
                    )
                  ],
                ),
        ),
      ),
    );
  }

  Future<void> selectDateTime(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null) {
      // ignore: use_build_context_synchronously
      final TimeOfDay? timePicked = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.now(),
      );

      if (timePicked != null) {
        final DateTime localDateTime = DateTime(
          picked.year,
          picked.month,
          picked.day,
          timePicked.hour,
          timePicked.minute,
        );

        final formattedDateTime = DateFormat('dd\'th\' MMMM yyyy \'at\' h:mm a')
            .format(localDateTime);

        setState(() {
          _selectedDateTime = localDateTime;
          _formatedDateTime = formattedDateTime;
        });
      }
    }
  }

  Future<void> sendNotification({required bool isTest}) async {
    // if (isTest) {
    //   await pushNotificationMainProvider
    //       .sendPushNotificationToTestUser(
    //     user: usersProvider.selectedTestNotificationUser!,
    //     title: titleController.text.trim(),
    //     message: messageController.text.trim(),
    //     badgeCount: _badgeCount,
    //   )
    //       .whenComplete(() {
    //     setState(() {
    //       _isSent = true;
    //     });
    //   });
    // } else {
    //   pushNotificationMainProvider.setNotificationSending(true);
    //   try {
    //     for (var a in _selectedTargets) {
    //       if (a == 'Article') {
    //         await pushNotificationMainProvider.sendNotificationToArticle(
    //           title: titleController.text.trim(),
    //           message: messageController.text.trim(),
    //           articleUrl: articleController.text.trim(),
    //           selectedTime: _selectedDateTime,
    //           badgeCount: _badgeCount,
    //         );
    //       } else if (a == 'URL') {
    //         await pushNotificationMainProvider.sendNotificationToUrl(
    //           title: titleController.text.trim(),
    //           message: messageController.text.trim(),
    //           url: urlController.text.trim(),
    //           badgeCount: _badgeCount,
    //           selectedTime: _selectedDateTime,
    //         );
    //       } else if (a == 'Channels') {
    //         if (_allChannels == true) {
    //           await pushNotificationMainProvider
    //               .sendPushNotificationToAllChannels(
    //             title: titleController.text.trim(),
    //             target: 'channel',
    //             message: messageController.text.trim(),
    //             badgeCount: _badgeCount,
    //             selectedDateTime: _selectedDateTime,
    //           );
    //         } else if (_singleChannel == true) {
    //           await pushNotificationMainProvider
    //               .sendPushNotificationToSelectedChannels(
    //             title: titleController.text.trim(),
    //             message: messageController.text.trim(),
    //             badgeCount: _badgeCount,
    //             selectedChannels: channelProvider.selectedNotificationChannels,
    //             selectedDateTime: _selectedDateTime,
    //           );
    //         }
    //       } else if (a == 'Users') {
    //         if (_allUsers == true) {
    //           await pushNotificationMainProvider.sendPushNotificationToAllUsers(
    //             title: titleController.text.trim(),
    //             target: 'user',
    //             message: messageController.text.trim(),
    //             badgeCount: _badgeCount,
    //             selectedDateTime: _selectedDateTime,
    //           );
    //         } else if (_singleUser == true) {
    //           await pushNotificationMainProvider
    //               .sendPushNotificationToSelectedUsers(
    //             title: titleController.text.trim(),
    //             message: messageController.text.trim(),
    //             badgeCount: _badgeCount,
    //             selectedDateTime: _selectedDateTime,
    //             selectedUsers: usersProvider.selectedNotificationUser,
    //           );
    //         }
    //       }
    //     }
    //   } catch (e) {
    //     if (kDebugMode) {
    //       print(e);
    //     }
    //   } finally {
    //     pushNotificationMainProvider.setNotificationSending(false);
    //   }
    // }
  }

  void checkValidation({required bool isTest}) {
    // if (_formKey.currentState!.validate()) {
    //   if (_selectedTargets.isEmpty) {
    //     showSnackbar(context, 'Please select at least one target');
    //   } else if (_selectedTargets.length == 4) {
    //     // all four items are selected
    //     bool allFieldsFilled = true;
    //     if (articleController.text.isEmpty) {
    //       allFieldsFilled = false;
    //       showSnackbar(context, 'Please enter article details');
    //     }
    //     if (urlController.text.isEmpty) {
    //       allFieldsFilled = false;
    //       showSnackbar(context, 'Please enter URL details');
    //     }

    //     if (_selectedTargets.contains('Channels')) {
    //       if (_allChannels == false && _singleChannel == true) {
    //         if (channelProvider.selectedNotificationChannels.isEmpty) {
    //           allFieldsFilled = false;
    //           showSnackbar(context, 'Please select atleast one single channel');
    //         }
    //       } else if (_allChannels == null && _singleChannel == null) {
    //         allFieldsFilled = false;
    //         showSnackbar(context, 'Please select channel type');
    //       } else if (_allChannels == false && _singleChannel == false) {
    //         allFieldsFilled = false;
    //         showSnackbar(context, 'Please select channel type');
    //       }
    //     }
    //     if (_selectedTargets.contains('Users')) {
    //       if (_allUsers == false && _singleUser == true) {
    //         if (usersProvider.selectedNotificationUser.isEmpty) {
    //           allFieldsFilled = false;
    //           showSnackbar(context, 'Please select atleast one single user');
    //         }
    //       } else if (_allUsers == null && _singleUser == null) {
    //         allFieldsFilled = false;
    //         showSnackbar(context, 'Please select user type');
    //       } else if (_allUsers == false && _singleUser == false) {
    //         allFieldsFilled = false;
    //         showSnackbar(context, 'Please select user type');
    //       }
    //     }
    //     if (allFieldsFilled) {
    //       sendNotification(isTest: isTest);
    //     }
    //   } else if (_selectedTargets.length == 1) {
    //     // only one target is selected
    //     String target = _selectedTargets.first;
    //     switch (target) {
    //       case 'Article':
    //         if (articleController.text.isNotEmpty) {
    //           // required fields are filled
    //           sendNotification(isTest: isTest);
    //         } else {
    //           showSnackbar(context, 'Please enter article details');
    //         }
    //         break;
    //       case 'URL':
    //         if (urlController.text.isNotEmpty) {
    //           // required fields are filled
    //           sendNotification(isTest: isTest);
    //         } else {
    //           showSnackbar(context, 'Please enter URL details');
    //         }
    //         break;
    //       case 'Channels':
    //         if (_allChannels! ||
    //             channelProvider.selectedNotificationChannels.isNotEmpty) {
    //           // required fields are filled
    //           sendNotification(isTest: isTest);
    //         } else {
    //           showSnackbar(
    //             context,
    //             'Please select at least one channel by clicking on plus icon on right side',
    //           );
    //         }
    //         break;
    //       case 'Users':
    //         if (_allUsers! ||
    //             usersProvider.selectedNotificationUser.isNotEmpty) {
    //           // required fields are filled
    //           sendNotification(isTest: isTest);
    //         } else {
    //           showSnackbar(
    //             context,
    //             'Please select at least one user by clicking on plus icon on right side',
    //           );
    //         }
    //         break;
    //     }
    //   } else {
    //     // multiple targets are selected
    //     bool allFieldsFilled = true;
    //     if (_selectedTargets.contains('Article') &&
    //         articleController.text.isEmpty) {
    //       allFieldsFilled = false;
    //       showSnackbar(context, 'Please enter article details');
    //     }
    //     if (_selectedTargets.contains('URL') && urlController.text.isEmpty) {
    //       allFieldsFilled = false;
    //       showSnackbar(context, 'Please enter URL details');
    //     }
    //     if (_selectedTargets.contains('Channels')) {
    //       if (_allChannels == false && _singleChannel == true) {
    //         if (channelProvider.selectedNotificationChannels.isEmpty) {
    //           allFieldsFilled = false;
    //           showSnackbar(context, 'Please select atleast one single channel');
    //         }
    //       } else if (_allChannels == null && _singleChannel == null) {
    //         allFieldsFilled = false;
    //         showSnackbar(context, 'Please select channel type');
    //       } else if (_allChannels == false && _singleChannel == false) {
    //         allFieldsFilled = false;
    //         showSnackbar(context, 'Please select channel type');
    //       }
    //     }
    //     if (_selectedTargets.contains('Users')) {
    //       if (_allUsers == false && _singleUser == true) {
    //         if (usersProvider.selectedNotificationUser.isEmpty) {
    //           allFieldsFilled = false;
    //           showSnackbar(context, 'Please select atleast one single user');
    //         }
    //       } else if (_allUsers == null && _singleUser == null) {
    //         allFieldsFilled = false;
    //         showSnackbar(context, 'Please select user type');
    //       } else if (_allUsers == false && _singleUser == false) {
    //         allFieldsFilled = false;
    //         showSnackbar(context, 'Please select user type');
    //       }
    //     }
    //     if (allFieldsFilled) {
    //       sendNotification(isTest: isTest);
    //     }
    //   }
    // }
  }

  void sendPublishClicked({required bool isTest}) {
    // if (isTest) {
    //   sendNotification(isTest: isTest);
    // } else {
    //   if (_sendNow) {
    //     checkValidation(isTest: isTest);
    //   } else if (_sendLater) {
    //     if (_selectedDateTime != null) {
    //       checkValidation(isTest: isTest);
    //     } else {
    //       showSnackbar(
    //         context,
    //         'Please select date and time when opting for send-later notifications',
    //       );
    //     }
    //   }
    // }
  }

  void handleCurrentTarget() {
    if (_selectedTargets.trim() == 'Article') {
      showDialog(
        context: context,
        barrierDismissible: true,
        builder: (context) {
          return const ArticleListAddDialog();
        },
      );
    } else if (_selectedTargets.trim() == 'Channel') {
      showDialog(
        barrierDismissible: true,
        context: context,
        builder: (context) {
          return const ChannelListAddDialog();
        },
      );
    } else if (_selectedTargets.trim() == 'User') {
      showDialog(
        context: context,
        builder: (context) {
          return const UserListDialog();
        },
      );
    } else if (_selectedTargets.trim() == 'URL') {
      return showURLDialog();
    }
  }

  Widget buildSelectedWidget() {
    return Row(
      children: [
        Text('Selected $_selectedTargets: '),
        Text(
          currentSelected(),
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
      ],
    );
  }

  String currentSelected() {
    switch (_selectedTargets.trim()) {
      case 'Article':
        if (pushNotificationMainProvider.selectedArticle != null) {
          return pushNotificationMainProvider.selectedArticle!.headline!;
        } else {
          return '';
        }
      case 'Channel':
        if (channelProvider.selectedChannelPushNotification != null) {
          return channelProvider.selectedChannelPushNotification!.channelName!;
        } else {
          return '';
        }
      case 'User':
        if (usersProvider.selectedUserForPushNotification != null) {
          return '${usersProvider.selectedUserForPushNotification!.firstName!} ${usersProvider.selectedUserForPushNotification!.lastName!}';
        } else {
          return '';
        }
      case 'URL':
        if (urlController.text.trim().isNotEmpty) {
          return urlController.text;
        } else {
          return '';
        }
      default:
        return '';
    }
  }

  void showURLDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Enter URL here'),
          content: SizedBox(
            width: 400,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  cursorColor: kPrimaryColor,
                  style: const TextStyle(color: Colors.black54),
                  decoration: InputDecoration(
                    suffix: urlController.text.isNotEmpty
                        ? IconButton(
                            onPressed: () {
                              setState(() {
                                urlController.clear();
                              });
                            },
                            icon: const Icon(
                              FontAwesomeIcons.solidCircleXmark,
                              size: 20,
                              color: kPrimaryColor,
                            ),
                          )
                        : null,
                    hintText: 'https://',
                    hintStyle: const TextStyle(
                      color: Colors.black54,
                      fontSize: 13,
                    ),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 20),
                    fillColor: const Color.fromRGBO(232, 232, 232, 1),
                    filled: true,
                    prefixIcon: const Icon(
                      FontAwesomeIcons.earthAmericas,
                      size: 16,
                      color: kPrimaryColor,
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: const BorderSide(color: Colors.transparent),
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
                  controller: urlController,
                ),
                const SizedBox(height: 10),
                SizedBox(
                  width: MediaQuery.of(context).size.width,
                  child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: kPrimaryColor,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(50),
                        ),
                      ),
                      onPressed: () {
                        Navigator.of(context).pop();
                        setState(() {});
                      },
                      child: const Text('Save')),
                )
              ],
            ),
          ),
        );
      },
      barrierDismissible: true,
    );
  }
}
