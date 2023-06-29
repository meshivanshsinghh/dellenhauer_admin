import 'package:dellenhauer_admin/utils/colors.dart';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:dellenhauer_admin/model/channel/channel_model.dart';
import 'package:dellenhauer_admin/pages/channels/channels_list_selection_screen.dart';
import 'package:dellenhauer_admin/providers/channels_provider.dart';
import 'package:dellenhauer_admin/pages/channels/users_list_screen.dart';
import 'package:dellenhauer_admin/utils/nextscreen.dart';
import 'package:dellenhauer_admin/utils/utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:image_picker_web/image_picker_web.dart';
import 'package:provider/provider.dart';

class ChannelEditScreen extends StatefulWidget {
  final ChannelModel channelModel;
  final VoidCallback onSaved;
  const ChannelEditScreen({
    super.key,
    required this.channelModel,
    required this.onSaved,
  });

  @override
  State<ChannelEditScreen> createState() => _ChannelEditScreenState();
}

class _ChannelEditScreenState extends State<ChannelEditScreen> {
  late ChannelProvider channelProvider;
  final TextEditingController _channelNameController = TextEditingController();
  final TextEditingController _channelDescriptionController =
      TextEditingController();
  late bool _channelAutoJoinWithRefCode;
  late bool _channelAutoJoinWithoutRefCode;
  late bool _isReadOnly;
  late bool _joinAccessRequired;
  String? _visibility;
  Uint8List? _image;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    Future.delayed(Duration.zero, () async {
      channelProvider = Provider.of<ChannelProvider>(context, listen: false);
      channelProvider.attachContext(context);
      channelProvider.relatedChannels.clear();
      getData().whenComplete(() {
        setState(() {
          _isLoading = false;
        });
      });
    });
  }

  Future<void> getData() async {
    channelProvider = Provider.of<ChannelProvider>(context, listen: false);
    if (mounted) {
      setState(() {
        _channelNameController.text = widget.channelModel.channelName!;
        _channelDescriptionController.text =
            widget.channelModel.channelDescription!;
        _channelAutoJoinWithRefCode =
            widget.channelModel.channelAutoJoinWithRefCode!;
        _channelAutoJoinWithoutRefCode =
            widget.channelModel.channelAutoJoinWithoutRefCode!;
        _isReadOnly = widget.channelModel.channelReadOnly!;
        _joinAccessRequired = widget.channelModel.joinAccessRequired!;
        _visibility = widget.channelModel.visibility!.name;
        if (widget.channelModel.relatedChannel != null &&
            widget.channelModel.relatedChannel!.isNotEmpty) {
          channelProvider.relatedChannels.addAll(
            widget.channelModel.relatedChannel!,
          );
        }
      });
    }
  }

  Future<void> _pickImage() async {
    final pickedImage = await ImagePickerWeb.getImageAsBytes();
    setState(() {
      _image = pickedImage;
    });
  }

  @override
  void dispose() {
    super.dispose();
    _channelNameController.dispose();
    _channelDescriptionController.dispose();
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
        child: _isLoading
            ? const Center(
                child: SizedBox(
                  height: 50,
                  width: 50,
                  child: CircularProgressIndicator(color: kPrimaryColor),
                ),
              )
            : SingleChildScrollView(
                physics: const ClampingScrollPhysics(),
                padding: const EdgeInsets.symmetric(vertical: 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    InkWell(
                      onTap: () {
                        _pickImage();
                      },
                      child: Stack(
                        children: [
                          _image == null
                              ? CachedNetworkImage(
                                  imageUrl: widget.channelModel.channelPhoto!,
                                  placeholder: (context, url) {
                                    return Container(
                                      height: 150,
                                      width: 150,
                                      decoration: BoxDecoration(
                                        color: Colors.grey[300],
                                        shape: BoxShape.circle,
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
                                      height: 150,
                                      width: 150,
                                      decoration: BoxDecoration(
                                        color: Colors.grey[300],
                                        shape: BoxShape.circle,
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
                                )
                              : ClipRRect(
                                  borderRadius: BorderRadius.circular(100),
                                  child: SizedBox(
                                    height: 150,
                                    width: 150,
                                    child: _image != null
                                        ? FittedBox(
                                            fit: BoxFit.cover,
                                            child: Image.memory(_image!),
                                          )
                                        : const SizedBox.shrink(),
                                  ),
                                ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 20),
                    textFieldEntry(
                      'Channel Name',
                      _channelNameController,
                    ),
                    textFieldEntry(
                      'Channel Description',
                      _channelDescriptionController,
                    ),
                    // switch section
                    switchWidget('AutoJoin Channel (with Ref-Code)',
                        _channelAutoJoinWithRefCode, (value) {
                      toggleSwitch(value, 'autoJoinWithRefCode');
                    }),
                    switchWidget('AutoJoin Channel (without Ref-Code)',
                        _channelAutoJoinWithoutRefCode, (value) {
                      toggleSwitch(value, 'autoJoinWithoutRefCode');
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
                            channelId: widget.channelModel.groupId!,
                            channelName: widget.channelModel.channelName!,
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
                            channelId: widget.channelModel.groupId!,
                            channelName: widget.channelModel.channelName!,
                          ),
                        );
                      },
                      true,
                    ),
                    relatedChannelWidget(channelProvider.relatedChannels),
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
                          backgroundColor: kPrimaryColor,
                        ),
                        onPressed: () async {
                          await channelProvider
                              .updateChannelData(
                            relatedChannels: channelProvider.relatedChannels,
                            channelName: _channelNameController.text,
                            channelDescription:
                                _channelDescriptionController.text,
                            autoJoinWithRefCode: _channelAutoJoinWithRefCode,
                            autoJoinWithoutRefCode:
                                _channelAutoJoinWithoutRefCode,
                            imageFile: _image,
                            readOnly: _isReadOnly,
                            joinAccessRequired: _joinAccessRequired,
                            visibility: _visibility!,
                            channelId: widget.channelModel.groupId!,
                          )
                              .then((value) {
                            if (value) {
                              showSnackbar(context, 'Updated successfully');
                              widget.onSaved();
                              Navigator.of(context).pop();
                            }
                          });
                        },
                        child: channelProvider.isLoading == true
                            ? const Center(
                                child: CircularProgressIndicator(
                                color: Colors.white,
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
            '$title: ${isUser ? widget.channelModel.totalMembers : widget.channelModel.totalModerators}'),
        trailing: IconButton(
          icon: const Icon(FontAwesomeIcons.arrowRight),
          onPressed: () {
            if (isUser) {
              nextScreen(
                context,
                UserListScreen(
                  isModerator: false,
                  channelId: widget.channelModel.groupId!,
                  channelName: widget.channelModel.channelName!,
                ),
              );
            } else {
              nextScreen(
                context,
                UserListScreen(
                  isModerator: true,
                  channelId: widget.channelModel.groupId!,
                  channelName: widget.channelModel.channelName!,
                ),
              );
            }
          },
        ));
  }

  void toggleSwitch(bool value, String type) {
    if (type == 'autoJoinWithRefCode') {
      setState(() {
        _channelAutoJoinWithRefCode = value;
      });
    } else if (type == 'readOnly') {
      setState(() {
        _isReadOnly = value;
      });
    } else if (type == 'autoJoinWithoutRefCode') {
      setState(() {
        _channelAutoJoinWithoutRefCode = value;
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
            activeColor: kPrimaryColor,
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }

  Widget textFieldEntry(
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
          cursorColor: kPrimaryColor,
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

  Widget singleCardWidget(
      {required String title, required VoidCallback onDelete}) {
    return Container(
      constraints: const BoxConstraints(maxHeight: 50, maxWidth: 200),
      margin: const EdgeInsets.only(right: 10, bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 5),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(5),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Expanded(
            child: Text(
              title,
              overflow: TextOverflow.clip,
              maxLines: 1,
            ),
          ),
          IconButton(
            onPressed: onDelete,
            icon: const Icon(FontAwesomeIcons.circleXmark, size: 15),
          )
        ],
      ),
    );
  }

  Widget relatedChannelWidget(List<String> initialData) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('Related Channels'),
            IconButton(
                icon: const Icon(
                  FontAwesomeIcons.circlePlus,
                  color: kPrimaryColor,
                  size: 20,
                ),
                onPressed: () {
                  showDialog(
                    barrierDismissible: true,
                    context: context,
                    builder: (context) {
                      return ChannelListSelectionScreen(
                        currentChannelId: widget.channelModel.groupId!,
                      );
                    },
                  );
                })
          ],
        ),
        Container(
          width: double.infinity,
          height: 150,
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey, width: 1),
            borderRadius: BorderRadius.circular(8),
          ),
          margin: const EdgeInsets.symmetric(vertical: 10),
          child: SingleChildScrollView(
            padding: const EdgeInsets.only(top: 10, left: 10),
            child: channelProvider.relatedChannels.isNotEmpty
                ? Wrap(
                    children: [
                      ...channelProvider.relatedChannels.map(
                        (e) => singleCardWidget(
                          title: e,
                          onDelete: () {
                            channelProvider.removeRelatedChannel(e);
                          },
                        ),
                      ),
                    ],
                  )
                : const Text('No related channels..'),
          ),
        ),
      ],
    );
  }
}
