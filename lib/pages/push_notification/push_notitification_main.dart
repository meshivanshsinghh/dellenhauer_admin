import 'package:dellenhauer_admin/providers/channels_provider.dart';
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
  late ChannelProvider channelProvider;
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  bool _badgeCount = true;
  bool _sendNow = false;
  bool _sendLater = false;
  DateTime? _selectedDateTime;
  String? _formatedDateTime;
  final targets = ['Article', 'Channels', 'Users', 'URL'];
  final List<String> _selectedTargets = [];
  @override
  void initState() {
    super.initState();
    Future.delayed(Duration.zero, () {
      usersProvider = Provider.of<UsersProvider>(context, listen: false);
      usersProvider.attachContext(context);
      usersProvider.setLoading(isLoading: true);
      usersProvider.getUsersData(orderBy: 'createdAt', descending: true);
      channelProvider = Provider.of<ChannelProvider>(context, listen: false);
      channelProvider.attachContext(context);
      channelProvider.setLoading(isLoading: true);
      channelProvider.getChannelData(
        orderBy: 'created_timestamp',
        descending: true,
      );
    });
  }

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
                  if (!_sendNow)
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
                margin: const EdgeInsets.only(top: 20),
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
              )
              // DropdownButtonFormField<String>(
              //   value: _selectedTargets.isNotEmpty
              //       ? _selectedTargets.toString()
              //       : null,
              //   decoration: InputDecoration(
              //     labelText: 'Target',
              //     border: OutlineInputBorder(
              //       borderRadius: BorderRadius.circular(0),
              //     ),
              //   ),
              //   items: targets.map((target) {
              //     return DropdownMenuItem(
              //       value: target,
              //       child: Row(
              //         children: [
              //           Checkbox(
              //             value: _selectedTargets.contains(target),
              //             onChanged: (bool? value) {
              //               print(value);
              //               if (value == true) {
              //                 setState(() {
              //                   _selectedTargets.add(target);
              //                 });
              //               } else {
              //                 setState(() {
              //                   _selectedTargets.remove(target);
              //                 });
              //               }
              //             },
              //           ),
              //           Text(target),
              //         ],
              //       ),
              //     );
              //   }).toList(),
              // ),
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
