import 'package:cached_network_image/cached_network_image.dart';
import 'package:dellenhauer_admin/pages/push_notification/widgets/send_to_channel_widget.dart';
import 'package:dellenhauer_admin/pages/push_notification/widgets/send_to_user_widget.dart';
import 'package:dellenhauer_admin/pages/push_notification/widgets/user_and_channel_list_notification.dart';
import 'package:dellenhauer_admin/providers/users_provider.dart';
import 'package:dellenhauer_admin/utils/colors.dart';
import 'package:dellenhauer_admin/utils/styles.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/standalone.dart' as tz;

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
  bool _isSent = false;

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
    titleController.selection = TextSelection.fromPosition(
        TextPosition(offset: titleController.text.length));
    messageController.selection = TextSelection.fromPosition(
        TextPosition(offset: messageController.text.length));
    articleController.selection = TextSelection.fromPosition(
        TextPosition(offset: messageController.text.length));
    urlController.selection = TextSelection.fromPosition(
        TextPosition(offset: messageController.text.length));
    usersProvider = Provider.of<UsersProvider>(context, listen: true);
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
          child: Column(
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
                decoration:
                    inputDecoration('Enter Title', 'Title', titleController),
                onChanged: (value) {
                  setState(() {
                    titleController.text = value;
                  });
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return "Preview cannot be empty";
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: messageController,
                cursorColor: kPrimaryColor,
                decoration: inputDecoration(
                    'Enter Message', 'Message', titleController),
                onChanged: (value) {
                  setState(() {
                    messageController.text = value;
                  });
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return "Message cannot be empty";
                  }
                  return null;
                },
              ),
              _selectedTargets.contains('Article')
                  ? Container(
                      margin: const EdgeInsets.only(top: 20),
                      child: TextFormField(
                        controller: articleController,
                        cursorColor: kPrimaryColor,
                        decoration: inputDecoration('Enter Article Url',
                            'https://articleurl.com', articleController),
                        onChanged: (value) {
                          setState(() {
                            articleController.text = value;
                          });
                        },
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return "Article Url cannot be empty";
                          }
                          return null;
                        },
                      ),
                    )
                  : const SizedBox.shrink(),
              _selectedTargets.contains('URL')
                  ? Container(
                      margin: const EdgeInsets.only(top: 20),
                      child: TextFormField(
                        controller: urlController,
                        cursorColor: kPrimaryColor,
                        decoration: inputDecoration(
                            'Enter Url', 'https://url.com', urlController),
                        onChanged: (value) {
                          setState(() {
                            urlController.text = value;
                          });
                        },
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return "Url cannot be empty";
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
                  if (!_sendNow && _selectedDateTime != null)
                    Expanded(
                      child: Text(
                        '$_formatedDateTime Timezone: Europe/Belin',
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
                            (e) => e == 'URL' ? Text(e) : Text('$e/'),
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
              const SendToUserWidget(),
              const SizedBox(height: 20),
              const SendToChannelWidget(),
              // sending test notification section
              Container(
                width: MediaQuery.of(context).size.width,
                padding: const EdgeInsets.all(10),
                margin: const EdgeInsets.symmetric(vertical: 20, horizontal: 2),
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
                            usersProvider.selectedTestNotificationUser == null
                                ? SizedBox(
                                    child: TextButton(
                                        style: TextButton.styleFrom(
                                          foregroundColor: kPrimaryColor,
                                          shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(30)),
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
                            usersProvider.selectedTestNotificationUser != null
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
                                      contentPadding: EdgeInsets.zero,
                                      title: Text(
                                        '${usersProvider.selectedTestNotificationUser!.firstName!} ${usersProvider.selectedTestNotificationUser!.lastName!}',
                                        maxLines: 1,
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
                            onPressed: () {},
                            style: ElevatedButton.styleFrom(
                              backgroundColor: kPrimaryColor,
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(30)),
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
                onPressed: () {},
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
    tz.initializeTimeZones();
    var berlin = tz.getLocation('Europe/Berlin');
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
        final berlinDateTime = tz.TZDateTime.from(localDateTime, berlin);
        final formattedDateTime = DateFormat('dd\'th\' MMMM yyyy \'at\' HH:mm')
            .format(berlinDateTime);

        setState(() {
          _selectedDateTime = berlinDateTime;
          _formatedDateTime = formattedDateTime;
        });
      }
    }
  }
}
