import 'package:cached_network_image/cached_network_image.dart';
import 'package:dellenhauer_admin/pages/push_notification/article/article_list_add_dialog.dart';
import 'package:dellenhauer_admin/pages/push_notification/push_notification_main_provider.dart';
import 'package:dellenhauer_admin/pages/push_notification/widgets/send_to_channel_widget.dart';
import 'package:dellenhauer_admin/pages/push_notification/widgets/send_to_user_widget.dart';
import 'package:dellenhauer_admin/pages/push_notification/widgets/user_and_channel_list_notification.dart';
import 'package:dellenhauer_admin/providers/channels_provider.dart';
import 'package:dellenhauer_admin/providers/users_provider.dart';
import 'package:dellenhauer_admin/utils/colors.dart';
import 'package:dellenhauer_admin/utils/styles.dart';
import 'package:dellenhauer_admin/utils/utils.dart';
import 'package:flutter/foundation.dart';
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

  bool _isSent = false;
  bool? _allUsers;
  bool? _singleUser;
  bool? _allChannels;
  bool? _singleChannel;

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  bool _badgeCount = true;
  bool _sendNow = true;
  bool _sendLater = false;
  DateTime? _selectedDateTime;
  String? _formatedDateTime;
  final targets = ['Article', 'Channels', 'Users', 'URL'];
  final List<String> _selectedTargets = [];
  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.of(context).size.width;
    pushNotificationMainProvider =
        Provider.of<PushNotificationMainProvider>(context, listen: true);
    usersProvider = Provider.of<UsersProvider>(context, listen: true);
    channelProvider = Provider.of<ChannelProvider>(context, listen: true);
    return Container(
      width: MediaQuery.of(context).size.width,
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
                      'Send Push Notification',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: MediaQuery.of(context).size.height * 0.03),
                    TextFormField(
                      controller: titleController,
                      cursorColor: kPrimaryColor,
                      decoration: inputDecoration(
                          'Enter Title', 'Title', titleController),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return "Title text cannot be empty";
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 20),
                    TextFormField(
                      controller: messageController,
                      cursorColor: kPrimaryColor,
                      decoration: inputDecoration(
                          'Enter Message', 'Message', messageController),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return "Message text cannot be empty";
                        }
                        return null;
                      },
                    ),
                    // todo
                    _selectedTargets.contains('Article')
                        ? Container(
                            width: MediaQuery.of(context).size.width,
                            margin: const EdgeInsets.only(top: 20),
                            child: Row(
                              children: [
                                Expanded(
                                  child: TextFormField(
                                    controller: articleController,
                                    cursorColor: kPrimaryColor,
                                    decoration: inputDecoration(
                                        'Enter Article Url',
                                        'https://articleurl.com',
                                        articleController),
                                    validator: (value) {
                                      if (value == null || value.isEmpty) {
                                        return "Article url cannot be empty";
                                      }
                                      return null;
                                    },
                                  ),
                                ),
                                GestureDetector(
                                  behavior: HitTestBehavior.opaque,
                                  onTap: () {
                                    showDialog(
                                      context: context,
                                      barrierDismissible: true,
                                      builder: (context) {
                                        return const ArticleListAddDialog();
                                      },
                                    );
                                  },
                                  child: Container(
                                    margin: const EdgeInsets.only(left: 20),
                                    child: const Icon(
                                      FontAwesomeIcons.circlePlus,
                                      color: kPrimaryColor,
                                    ),
                                  ),
                                )
                              ],
                            ),
                          )
                        : const SizedBox.shrink(),
                    _selectedTargets.contains('URL')
                        ? Container(
                            margin: const EdgeInsets.only(top: 20),
                            child: TextFormField(
                              controller: urlController,
                              cursorColor: kPrimaryColor,
                              decoration: inputDecoration('Enter Url',
                                  'https://url.com', urlController),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return "Url address cannot be empty";
                                }
                                return null;
                              },
                            ),
                          )
                        : const SizedBox.shrink(),

                    const SizedBox(height: 20),
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
                        const Text('Badge Count')
                      ],
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Checkbox(
                          activeColor: kPrimaryColor,
                          value: _sendNow,
                          onChanged: (value) {
                            setState(() {
                              _sendNow = value!;
                              if (_sendNow) {
                                _sendLater = false;
                                _selectedDateTime = null;
                              }
                            });
                          },
                        ),
                        const SizedBox(width: 10),
                        const Text('Send Now!')
                      ],
                    ),
                    const SizedBox(height: 10),
                    // checkbox
                    Row(
                      children: [
                        Checkbox(
                          activeColor: kPrimaryColor,
                          value: _sendLater,
                          onChanged: (value) {
                            setState(() {
                              _sendLater = value!;
                              if (_sendLater) {
                                _sendNow = false;
                              }
                            });
                          },
                        ),
                        const SizedBox(width: 10),
                        const Text('Send Later:'),
                        const SizedBox(width: 10),
                        // date time picker
                        if (!_sendNow && _sendLater)
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: kPrimaryColor,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20),
                              ),
                            ),
                            onPressed: () {
                              setState(() {
                                _sendLater = true;
                              });
                              selectDateTime(context);
                            },
                            child: const Text('Select Date & Time'),
                          ),
                        const SizedBox(width: 10),
                        if (!_sendNow &&
                            _selectedDateTime != null &&
                            _sendLater)
                          Expanded(
                            child: Text(
                              '$_formatedDateTime',
                            ),
                          ),
                      ],
                    ),
                    // target
                    const SizedBox(height: 20),
                    Row(
                      children: [
                        const Text(
                          'Target:',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(width: 20),
                        Expanded(
                          child: Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(0),
                              border: Border.all(color: Colors.grey.shade400),
                            ),
                            height: 50,
                            padding: const EdgeInsets.all(10),
                            child: Row(
                              children: [
                                ..._selectedTargets.map(
                                  (e) => Text('$e '),
                                )
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                    // list of target items
                    Container(
                      width: MediaQuery.of(context).size.width,
                      margin: const EdgeInsets.symmetric(vertical: 30),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          ...targets.map((e) {
                            return Row(
                              children: [
                                Checkbox(
                                  activeColor: kPrimaryColor,
                                  value: _selectedTargets.contains(e),
                                  onChanged: (value) {
                                    setState(() {
                                      if (value == true) {
                                        _selectedTargets.add(e);
                                      } else {
                                        _selectedTargets.remove(e);
                                      }
                                    });
                                  },
                                ),
                                Text(e)
                              ],
                            );
                          })
                        ],
                      ),
                    ),

                    // showcasing sent to option
                    const Text(
                      'Send To:',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 20),
                    _selectedTargets.contains('Users')
                        ? SendToUserWidget(
                            isActive: true,
                            onCheckboxAllUsers: (value) {
                              setState(() {
                                _allUsers = value;
                              });
                            },
                            onCheckboxSingleUser: (value) {
                              setState(() {
                                _singleUser = value;
                              });
                            },
                          )
                        : SendToUserWidget(
                            isActive: false,
                            onCheckboxAllUsers: (value) {},
                            onCheckboxSingleUser: (value) {},
                          ),
                    const SizedBox(height: 20),
                    _selectedTargets.contains('Channels')
                        ? SendToChannelWidget(
                            isActive: true,
                            onCheckboxAllChannels: (value) {
                              setState(() {
                                _allChannels = value;
                              });
                            },
                            onCheckboxSingleChannel: (value) {
                              setState(() {
                                _singleChannel = value;
                              });
                            },
                          )
                        : SendToChannelWidget(
                            isActive: false,
                            onCheckboxAllChannels: (value) {},
                            onCheckboxSingleChannel: (value) {},
                          ),
                    // sending test notification section
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
                                      ? SizedBox(
                                          child: TextButton(
                                              style: TextButton.styleFrom(
                                                foregroundColor: kPrimaryColor,
                                                shape: RoundedRectangleBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            30)),
                                              ),
                                              onPressed: () {
                                                if (usersProvider
                                                        .selectedTestNotificationUser ==
                                                    null) {
                                                  showDialog(
                                                    context: context,
                                                    builder: (context) {
                                                      return const UserListNotificationSelection(
                                                        isUser: true,
                                                        isTestUser: true,
                                                      );
                                                    },
                                                  );
                                                } else {
                                                  usersProvider
                                                      .removeSelectedTestUser();
                                                }
                                              },
                                              child: const Text('Select User')),
                                        )
                                      : const SizedBox.shrink(),
                                  // list tile
                                  usersProvider.selectedTestNotificationUser !=
                                          null
                                      ? Container(
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
                                        )
                                      : const SizedBox.shrink(),
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
                                        borderRadius:
                                            BorderRadius.circular(30)),
                                  ),
                                  child: const Text('Send to Test-Device'),
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
                    // publish button
                    ElevatedButton(
                      onPressed: () => sendPublishClicked(isTest: false),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: kPrimaryColor,
                      ),
                      child: const Text('Publish'),
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
    if (isTest) {
      await pushNotificationMainProvider
          .sendPushNotificationToTestUser(
        user: usersProvider.selectedTestNotificationUser!,
        title: titleController.text.trim(),
        message: messageController.text.trim(),
        badgeCount: _badgeCount,
      )
          .whenComplete(() {
        setState(() {
          _isSent = true;
        });
      });
    } else {
      pushNotificationMainProvider.setNotificationSending(true);
      try {
        for (var a in _selectedTargets) {
          if (a == 'Article') {
            await pushNotificationMainProvider.sendNotificationToArticle(
              title: titleController.text.trim(),
              message: messageController.text.trim(),
              articleUrl: articleController.text.trim(),
              selectedTime: _selectedDateTime,
              badgeCount: _badgeCount,
            );
          } else if (a == 'URL') {
            await pushNotificationMainProvider.sendNotificationToUrl(
              title: titleController.text.trim(),
              message: messageController.text.trim(),
              url: urlController.text.trim(),
              badgeCount: _badgeCount,
              selectedTime: _selectedDateTime,
            );
          } else if (a == 'Channels') {
            if (_allChannels == true) {
              await pushNotificationMainProvider
                  .sendPushNotificationToAllChannels(
                title: titleController.text.trim(),
                target: 'channel',
                message: messageController.text.trim(),
                badgeCount: _badgeCount,
                selectedDateTime: _selectedDateTime,
              );
            } else if (_singleChannel == true) {
              await pushNotificationMainProvider
                  .sendPushNotificationToSelectedChannels(
                title: titleController.text.trim(),
                message: messageController.text.trim(),
                badgeCount: _badgeCount,
                selectedChannels: channelProvider.selectedNotificationChannels,
                selectedDateTime: _selectedDateTime,
              );
            }
          } else if (a == 'Users') {
            if (_allUsers == true) {
              await pushNotificationMainProvider.sendPushNotificationToAllUsers(
                title: titleController.text.trim(),
                target: 'user',
                message: messageController.text.trim(),
                badgeCount: _badgeCount,
                selectedDateTime: _selectedDateTime,
              );
            } else if (_singleUser == true) {
              await pushNotificationMainProvider
                  .sendPushNotificationToSelectedUsers(
                title: titleController.text.trim(),
                message: messageController.text.trim(),
                badgeCount: _badgeCount,
                selectedDateTime: _selectedDateTime,
                selectedUsers: usersProvider.selectedNotificationUser,
              );
            }
          }
        }
      } catch (e) {
        if (kDebugMode) {
          print(e);
        }
      } finally {
        pushNotificationMainProvider.setNotificationSending(false);
      }
    }
  }

  void checkValidation({required bool isTest}) {
    if (_formKey.currentState!.validate()) {
      if (_selectedTargets.isEmpty) {
        showSnackbar(context, 'Please select at least one target');
      } else if (_selectedTargets.length == 4) {
        // all four items are selected
        bool allFieldsFilled = true;
        if (articleController.text.isEmpty) {
          allFieldsFilled = false;
          showSnackbar(context, 'Please enter article details');
        }
        if (urlController.text.isEmpty) {
          allFieldsFilled = false;
          showSnackbar(context, 'Please enter URL details');
        }

        if (_selectedTargets.contains('Channels')) {
          if (_allChannels == false && _singleChannel == true) {
            if (channelProvider.selectedNotificationChannels.isEmpty) {
              allFieldsFilled = false;
              showSnackbar(context, 'Please select atleast one single channel');
            }
          } else if (_allChannels == null && _singleChannel == null) {
            allFieldsFilled = false;
            showSnackbar(context, 'Please select channel type');
          } else if (_allChannels == false && _singleChannel == false) {
            allFieldsFilled = false;
            showSnackbar(context, 'Please select channel type');
          }
        }
        if (_selectedTargets.contains('Users')) {
          if (_allUsers == false && _singleUser == true) {
            if (usersProvider.selectedNotificationUser.isEmpty) {
              allFieldsFilled = false;
              showSnackbar(context, 'Please select atleast one single user');
            }
          } else if (_allUsers == null && _singleUser == null) {
            allFieldsFilled = false;
            showSnackbar(context, 'Please select user type');
          } else if (_allUsers == false && _singleUser == false) {
            allFieldsFilled = false;
            showSnackbar(context, 'Please select user type');
          }
        }
        if (allFieldsFilled) {
          sendNotification(isTest: isTest);
        }
      } else if (_selectedTargets.length == 1) {
        // only one target is selected
        String target = _selectedTargets.first;
        switch (target) {
          case 'Article':
            if (articleController.text.isNotEmpty) {
              // required fields are filled
              sendNotification(isTest: isTest);
            } else {
              showSnackbar(context, 'Please enter article details');
            }
            break;
          case 'URL':
            if (urlController.text.isNotEmpty) {
              // required fields are filled
              sendNotification(isTest: isTest);
            } else {
              showSnackbar(context, 'Please enter URL details');
            }
            break;
          case 'Channels':
            if (_allChannels! ||
                channelProvider.selectedNotificationChannels.isNotEmpty) {
              // required fields are filled
              sendNotification(isTest: isTest);
            } else {
              showSnackbar(
                context,
                'Please select at least one channel by clicking on plus icon on right side',
              );
            }
            break;
          case 'Users':
            if (_allUsers! ||
                usersProvider.selectedNotificationUser.isNotEmpty) {
              // required fields are filled
              sendNotification(isTest: isTest);
            } else {
              showSnackbar(
                context,
                'Please select at least one user by clicking on plus icon on right side',
              );
            }
            break;
        }
      } else {
        // multiple targets are selected
        bool allFieldsFilled = true;
        if (_selectedTargets.contains('Article') &&
            articleController.text.isEmpty) {
          allFieldsFilled = false;
          showSnackbar(context, 'Please enter article details');
        }
        if (_selectedTargets.contains('URL') && urlController.text.isEmpty) {
          allFieldsFilled = false;
          showSnackbar(context, 'Please enter URL details');
        }
        if (_selectedTargets.contains('Channels')) {
          if (_allChannels == false && _singleChannel == true) {
            if (channelProvider.selectedNotificationChannels.isEmpty) {
              allFieldsFilled = false;
              showSnackbar(context, 'Please select atleast one single channel');
            }
          } else if (_allChannels == null && _singleChannel == null) {
            allFieldsFilled = false;
            showSnackbar(context, 'Please select channel type');
          } else if (_allChannels == false && _singleChannel == false) {
            allFieldsFilled = false;
            showSnackbar(context, 'Please select channel type');
          }
        }
        if (_selectedTargets.contains('Users')) {
          if (_allUsers == false && _singleUser == true) {
            if (usersProvider.selectedNotificationUser.isEmpty) {
              allFieldsFilled = false;
              showSnackbar(context, 'Please select atleast one single user');
            }
          } else if (_allUsers == null && _singleUser == null) {
            allFieldsFilled = false;
            showSnackbar(context, 'Please select user type');
          } else if (_allUsers == false && _singleUser == false) {
            allFieldsFilled = false;
            showSnackbar(context, 'Please select user type');
          }
        }
        if (allFieldsFilled) {
          sendNotification(isTest: isTest);
        }
      }
    }
  }

  void sendPublishClicked({required bool isTest}) {
    if (isTest) {
      sendNotification(isTest: isTest);
    } else {
      if (_sendNow) {
        checkValidation(isTest: isTest);
      } else if (_sendLater) {
        if (_selectedDateTime != null) {
          checkValidation(isTest: isTest);
        } else {
          showSnackbar(
            context,
            'Please select date and time when opting for send-later notifications',
          );
        }
      }
    }
  }
}
