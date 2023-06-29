import 'package:cached_network_image/cached_network_image.dart';
import 'package:dellenhauer_admin/model/channel/channel_model.dart';
import 'package:dellenhauer_admin/model/users/user_model.dart';
import 'package:dellenhauer_admin/pages/channels/channels_list_selection_screen.dart';
import 'package:dellenhauer_admin/pages/channels/new_channel/create_new_channel_user_dialog.dart';
import 'package:dellenhauer_admin/providers/channels_provider.dart';
import 'package:dellenhauer_admin/providers/users_provider.dart';
import 'package:dellenhauer_admin/utils/colors.dart';
import 'package:dellenhauer_admin/utils/utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:image_picker_web/image_picker_web.dart';
import 'package:provider/provider.dart';

class CreateNewChannel extends StatefulWidget {
  final VoidCallback onSaved;

  const CreateNewChannel({super.key, required this.onSaved});

  @override
  State<CreateNewChannel> createState() => _CreateNewChannelState();
}

class _CreateNewChannelState extends State<CreateNewChannel> {
  Uint8List? _image;
  final TextEditingController _channelNameController = TextEditingController();
  final TextEditingController _channelDescriptionController =
      TextEditingController();
  bool _channelAutoJoinWithRefCode = false;
  bool _channelAutoJoinWithoutRefCode = false;
  bool _isReadOnly = false;
  bool _joinAccessRequired = false;
  String visibility = 'public';
  late ChannelProvider channelProvider;
  late UsersProvider userProvider;
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  Future<void> _pickImage() async {
    final pickedImage = await ImagePickerWeb.getImageAsBytes();
    setState(() {
      _image = pickedImage;
    });
  }

  @override
  void initState() {
    super.initState();
    Future.delayed(Duration.zero, () async {
      channelProvider = Provider.of<ChannelProvider>(context, listen: false);
      channelProvider.attachContext(context);
      channelProvider.relatedChannels.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    channelProvider = Provider.of<ChannelProvider>(context, listen: true);
    userProvider = Provider.of<UsersProvider>(context, listen: true);

    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(60),
        child: Center(
          child: AppBar(
            elevation: 1,
            centerTitle: true,
            title: const Text('Create New Channel'),
          ),
        ),
      ),
      body: Container(
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height,
        margin: const EdgeInsets.all(20),
        padding: EdgeInsets.only(
          left: MediaQuery.of(context).size.width * 0.05,
          right: MediaQuery.of(context).size.width * 0.20,
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
          physics: const ClampingScrollPhysics(),
          padding: const EdgeInsets.symmetric(vertical: 10),
          child: Form(
            key: _formKey,
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
                          ? Container(
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
                            )
                          : ClipRRect(
                              borderRadius: BorderRadius.circular(100),
                              child: SizedBox(
                                height: 150,
                                width: 150,
                                child: FittedBox(
                                  fit: BoxFit.cover,
                                  child: Image.memory(_image!),
                                ),
                              ),
                            )
                    ],
                  ),
                ),
                const SizedBox(height: 10),
                textFieldEntry(
                  title: 'Channel Name',
                  controller: _channelNameController,
                  validator: (value) {
                    if (value != null && value.trim().isEmpty) {
                      return 'Channel name cannot be empty';
                    }
                    return null;
                  },
                ),
                textFieldEntry(
                  title: 'Channel Description',
                  controller: _channelDescriptionController,
                  validator: (value) {
                    if (value != null && value.trim().isEmpty) {
                      return 'Channel Description cannot be empty';
                    }
                    return null;
                  },
                ),
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
                buildModeratorWidget(),
                buildUserWidget(),
                relatedChannelWidget(channelProvider.relatedChannels),
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
                      {
                        if (_formKey.currentState!.validate()) {
                          if (userProvider.createNewChannelUsers.isEmpty &&
                              userProvider.createNewModerators.isEmpty) {
                            showSnackbar(context,
                                'Minimum 1 Moderator and Minimum 1 User is required');
                          } else if (userProvider.createNewModerators.isEmpty) {
                            showSnackbar(
                                context, 'Minimum 1 Moderator is required');
                          } else if (userProvider
                              .createNewChannelUsers.isEmpty) {
                            showSnackbar(context, 'Minimum 1 User is required');
                          } else {
                            channelProvider.setLoading(isLoading: true);
                            await channelProvider
                                .checkUniqueChannelName(
                              channelName: _channelNameController.text.trim(),
                            )
                                .then((value) {
                              if (value) {
                                channelProvider
                                    .createChannelData(
                                  channelName:
                                      _channelNameController.text.trim(),
                                  channelDescription:
                                      _channelDescriptionController.text.trim(),
                                  autoJoinWithRefCode:
                                      _channelAutoJoinWithRefCode,
                                  autoJoinWithoutRefCode:
                                      _channelAutoJoinWithoutRefCode,
                                  readOnly: _isReadOnly,
                                  joinAccessRequired: _joinAccessRequired,
                                  visibility: visibility,
                                  relatedChannels:
                                      channelProvider.relatedChannels,
                                  newUsers: userProvider.createNewChannelUsers,
                                  newModerators:
                                      userProvider.createNewModerators,
                                  imageFile: _image,
                                )
                                    .then((v) {
                                  if (v) {
                                    channelProvider.setLoading(
                                        isLoading: false);
                                    showSnackbar(
                                        context, 'Updated successfully');
                                    widget.onSaved();
                                    Navigator.of(context).pop();
                                  }
                                });
                              } else {
                                channelProvider.setLoading(isLoading: false);
                                showSnackbar(
                                    context, 'Channel name already exists');
                              }
                            });
                          }
                        }
                      }
                    },
                    child: channelProvider.isLoading == true
                        ? const Center(
                            child: CircularProgressIndicator(
                            color: Colors.white,
                          ))
                        : const Text('Create'),
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget buildModeratorWidget() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('Add Moderators'),
            IconButton(
              onPressed: () {
                showDialog(
                  context: context,
                  barrierDismissible: true,
                  builder: (context) {
                    return const CreateNewChannelUserDialog(isModerator: true);
                  },
                );
              },
              icon: const Icon(
                FontAwesomeIcons.circlePlus,
                color: kPrimaryColor,
                size: 20,
              ),
            )
          ],
        ),
        Container(
          width: double.infinity,
          height: 200,
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey, width: 1),
            borderRadius: BorderRadius.circular(8),
          ),
          margin: const EdgeInsets.symmetric(vertical: 10),
          child: SingleChildScrollView(
            padding: const EdgeInsets.only(top: 10, left: 10),
            child: userProvider.createNewModerators.isNotEmpty
                ? Wrap(
                    direction: Axis.horizontal,
                    children: [
                      ...userProvider.createNewModerators.map(
                        (e) => singleUserWidget(
                          userModel: e,
                          onDelete: () {
                            userProvider.removeNewUser(
                              userId: e.userId!,
                              isModerator: true,
                            );
                          },
                        ),
                      ),
                    ],
                  )
                : const Text(
                    'No moderators added yet.',
                    style: TextStyle(
                      color: Colors.grey,
                    ),
                  ),
          ),
        ),
      ],
    );
  }

  Widget buildUserWidget() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('Add Users'),
            IconButton(
              onPressed: () {
                showDialog(
                  context: context,
                  barrierDismissible: true,
                  builder: (context) {
                    return const CreateNewChannelUserDialog(isModerator: false);
                  },
                );
              },
              icon: const Icon(
                FontAwesomeIcons.circlePlus,
                color: kPrimaryColor,
                size: 20,
              ),
            )
          ],
        ),
        Container(
          width: double.infinity,
          height: 200,
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey, width: 1),
            borderRadius: BorderRadius.circular(8),
          ),
          margin: const EdgeInsets.symmetric(vertical: 10),
          child: SingleChildScrollView(
            padding: const EdgeInsets.only(top: 10, left: 10),
            child: userProvider.createNewChannelUsers.isNotEmpty
                ? Wrap(
                    direction: Axis.horizontal,
                    children: [
                      ...userProvider.createNewChannelUsers.map(
                        (e) => singleUserWidget(
                          userModel: e,
                          onDelete: () {
                            userProvider.removeNewUser(
                              userId: e.userId!,
                              isModerator: false,
                            );
                          },
                        ),
                      ),
                    ],
                  )
                : const Text(
                    'No users added yet.',
                    style: TextStyle(
                      color: Colors.grey,
                    ),
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
            value: visibility,
            onChanged: (dynamic value) {
              setState(() {
                visibility = value;
              });
            },
            onSaved: (dynamic newValue) {
              setState(() {
                visibility = newValue;
              });
            },
            hint: const Text('Select visibility'),
            decoration: const InputDecoration(border: InputBorder.none),
          ),
        ),
      ],
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
                      return const ChannelListSelectionScreen(
                        currentChannelId: '',
                        isCreateNewChannel: true,
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
                    direction: Axis.horizontal,
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
                : const Text(
                    'No related channels added yet.',
                    style: TextStyle(
                      color: Colors.grey,
                    ),
                  ),
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

  Widget singleUserWidget({
    required UserModel userModel,
    required VoidCallback onDelete,
  }) {
    return Container(
      margin: const EdgeInsets.all(5),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          CachedNetworkImage(
            imageUrl: userModel.profilePic!,
            placeholder: (context, url) {
              return Container(
                height: 40,
                width: 40,
                margin: const EdgeInsets.only(right: 10),
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
                height: 40,
                width: 40,
                margin: const EdgeInsets.only(right: 10),
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
                height: 40,
                width: 40,
                margin: const EdgeInsets.only(right: 10),
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
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SelectableText(
                '${userModel.firstName} ${userModel.lastName}',
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
              SelectableText(
                  '${userModel.email}\n@${userModel.nickname} • ${userModel.phoneNumber}'),
            ],
          ),
          IconButton(
            onPressed: onDelete,
            icon: const Icon(FontAwesomeIcons.circleXmark, size: 15),
          ),
        ],
      ),
    );
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

  Widget textFieldEntry({
    required String title,
    required TextEditingController controller,
    required String? Function(String?)? validator,
  }) {
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
          validator: validator,
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
}
