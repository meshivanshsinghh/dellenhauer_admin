import 'package:cached_network_image/cached_network_image.dart';
import 'package:dellenhauer_admin/model/channel/channel_model.dart';
import 'package:dellenhauer_admin/pages/channels/channels_provider.dart';
import 'package:dellenhauer_admin/pages/channels/users_list_screen.dart';
import 'package:dellenhauer_admin/utils/nextscreen.dart';
import 'package:dellenhauer_admin/utils/utils.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';

class ChannelEditScreen extends StatefulWidget {
  final ChannelModel channelModel;
  const ChannelEditScreen({super.key, required this.channelModel});

  @override
  State<ChannelEditScreen> createState() => _ChannelEditScreenState();
}

class _ChannelEditScreenState extends State<ChannelEditScreen> {
  late TextEditingController _channelNameController;
  late TextEditingController _channelDescriptionController;
  late bool _isAutoJoinSwitched;
  late bool _isReadOnly;
  late bool _joinAccessRequired;
  late ChannelProvider channelProvider;
  String? _visibility;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    getData();
  }

  getData() {
    if (mounted) {
      setState(() {
        _channelNameController =
            TextEditingController(text: widget.channelModel.channelName);
        _channelDescriptionController =
            TextEditingController(text: widget.channelModel.channelDescription);
        _isAutoJoinSwitched = widget.channelModel.channelAutoJoin;
        _isReadOnly = widget.channelModel.channelReadOnly;
        _joinAccessRequired = widget.channelModel.joinAccessRequired;
        _visibility = widget.channelModel.visibility.name;
      });
      channelProvider = Provider.of<ChannelProvider>(context, listen: false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.of(context).size.width;
    channelProvider = Provider.of<ChannelProvider>(context, listen: true);
    return Scaffold(
      key: _scaffoldKey,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(60),
        child: Center(
          child: AppBar(
            elevation: 1,
            centerTitle: true,
            title: const Text('Edit Channel'),
          ),
        ),
      ),
      body: Container(
        height: double.infinity,
        width: double.infinity,
        margin: const EdgeInsets.all(20),
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
          padding: const EdgeInsets.symmetric(vertical: 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              CachedNetworkImage(
                imageUrl: widget.channelModel.channelPhoto,
                placeholder: (context, url) {
                  return Container(
                    height: 150,
                    width: 150,
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      shape: BoxShape.circle,
                      image: const DecorationImage(
                        image: AssetImage('assets/images/placeholder.jpeg'),
                        fit: BoxFit.cover,
                      ),
                    ),
                  );
                },
                errorWidget: (context, url, error) {
                  return Container(
                    height: 150,
                    width: 150,
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      shape: BoxShape.circle,
                      image: const DecorationImage(
                        image: AssetImage('assets/images/placeholder.jpeg'),
                        fit: BoxFit.cover,
                      ),
                    ),
                  );
                },
                imageBuilder: (context, imageProvider) {
                  return Container(
                    height: 150,
                    width: 150,
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      shape: BoxShape.circle,
                      image: DecorationImage(
                        image: imageProvider,
                        fit: BoxFit.cover,
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(height: 20),
              textFieldEntry(
                'Real Estate',
                'Channel Name',
                _channelNameController,
              ),
              textFieldEntry(
                'Hello this is channelDescription Text',
                'Channel Description',
                _channelDescriptionController,
              ),
              // switch section
              switchWidget('AutoJoin Channel', _isAutoJoinSwitched, (value) {
                toggleSwitch(value, 'autoJoin');
              }),
              switchWidget('Read-Only Channel', _isReadOnly, (value) {
                toggleSwitch(value, 'readOnly');
              }),
              switchWidget(
                'Join Access Required',
                _joinAccessRequired,
                (value) {
                  toggleSwitch(value, 'joinAccess');
                },
              ),

              // displaying moderator list
              listWidget(
                'Moderators',
                () {
                  nextScreen(
                    context,
                    UserListScreen(
                      isModerator: true,
                      channelId: widget.channelModel.groupId,
                    ),
                  );
                },
                false,
              ),
              // displaying member list
              listWidget(
                'Users',
                () {
                  nextScreen(
                    context,
                    UserListScreen(
                      isModerator: false,
                      channelId: widget.channelModel.groupId,
                    ),
                  );
                },
                true,
              ),
              const SizedBox(height: 20),

              // visibility dropdown
              visibilityDropDown(),
              Container(
                margin: const EdgeInsets.symmetric(vertical: 50),
                width: MediaQuery.of(context).size.width * 0.50,
                height: 50,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                ),
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30)),
                    backgroundColor: Colors.redAccent,
                  ),
                  onPressed: () {
                    channelProvider
                        .updateChannelData(
                      channelName: _channelNameController.text,
                      channelDescription: _channelDescriptionController.text,
                      autoJoin: _isAutoJoinSwitched,
                      readOnly: _isReadOnly,
                      joinAccessRequired: _joinAccessRequired,
                      visibility: _visibility!,
                      channelId: widget.channelModel.groupId,
                    )
                        .whenComplete(() {
                      showSnackbar(context, 'Updated successfully');
                      Navigator.of(context).pop();
                    });
                  },
                  child: channelProvider.isLoading == true
                      ? const Center(
                          child: CircularProgressIndicator(
                          color: Colors.redAccent,
                        ))
                      : const Text('Save'),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget listWidget(
    String title,
    Function onTap,
    bool isUser,
  ) {
    return ListTile(
        contentPadding: const EdgeInsets.symmetric(vertical: 10),
        leading: CircleAvatar(
          backgroundColor: Colors.grey[200],
          child: Icon(
            isUser ? FontAwesomeIcons.solidUser : FontAwesomeIcons.userSecret,
            size: 15,
            color: Colors.grey,
          ),
        ),
        title: Text(
            '$title: ${isUser ? widget.channelModel.membersId.length : widget.channelModel.moderatorsId.length}'),
        trailing: IconButton(
          icon: const Icon(FontAwesomeIcons.arrowRight),
          onPressed: () {
            if (isUser) {
              nextScreen(
                context,
                UserListScreen(
                  isModerator: false,
                  channelId: widget.channelModel.groupId,
                ),
              );
            } else {
              nextScreen(
                context,
                UserListScreen(
                  isModerator: true,
                  channelId: widget.channelModel.groupId,
                ),
              );
            }
          },
        ));
  }

  void toggleSwitch(bool value, String type) {
    if (type == 'autoJoin') {
      setState(() {
        _isAutoJoinSwitched = value;
      });
    } else if (type == 'readOnly') {
      setState(() {
        _isReadOnly = value;
      });
    } else {
      setState(() {
        _joinAccessRequired = value;
      });
    }
  }

  Widget switchWidget(String title, bool value, ValueChanged<bool> onChanged) {
    return Container(
      width: double.infinity,
      alignment: Alignment.center,
      margin: const EdgeInsets.only(top: 10, bottom: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: const TextStyle(fontWeight: FontWeight.w500),
          ),
          Switch(
            value: value,
            activeColor: Colors.blue,
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }

  Widget textFieldEntry(
    String placeHolder,
    String title,
    TextEditingController controller,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 10.0, top: 10.0),
          child: Text(
            title,
            style: const TextStyle(color: Colors.grey),
          ),
        ),
        TextFormField(
          maxLines: controller == _channelDescriptionController ? 4 : 1,
          controller: controller,
          cursorColor: Colors.redAccent,
          decoration: InputDecoration(
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: Colors.grey, width: 1),
            ),
            hintText: '',
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: Colors.grey, width: 1),
            ),
          ),
        ),
      ],
    );
  }

  Widget visibilityDropDown() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.only(bottom: 10.0),
          child: Text(
            'Visibility',
            style: TextStyle(color: Colors.grey),
          ),
        ),
        Container(
          height: 50,
          padding: const EdgeInsets.only(left: 15, right: 15),
          decoration: BoxDecoration(
            color: Colors.grey[200],
            border: Border.all(
              color: Colors.grey[300]!,
            ),
            borderRadius: BorderRadius.circular(30),
          ),
          child: DropdownButtonFormField(
            isExpanded: true,
            items: const [
              DropdownMenuItem(
                value: 'public',
                child: Text('Public'),
              ),
              DropdownMenuItem(
                value: 'private',
                child: Text('Private'),
              ),
            ],
            value: _visibility,
            onChanged: (dynamic value) {
              setState(() {
                _visibility = value;
              });
            },
            onSaved: (dynamic newValue) {
              setState(() {
                _visibility = newValue;
              });
            },
            hint: const Text('Select visibility'),
            decoration: const InputDecoration(border: InputBorder.none),
          ),
        ),
      ],
    );
  }
}
