import 'package:cached_network_image/cached_network_image.dart';
import 'package:dellenhauer_admin/model/users/user_model.dart';
import 'package:dellenhauer_admin/providers/channels_provider.dart';
import 'package:dellenhauer_admin/utils/colors.dart';
import 'package:dellenhauer_admin/utils/utils.dart';
import 'package:dellenhauer_admin/utils/widgets/empty.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';

class UserListAddDialog extends StatefulWidget {
  final bool isModerator;
  final String channelId;
  final String channelName;

  const UserListAddDialog({
    super.key,
    required this.isModerator,
    required this.channelId,
    required this.channelName,
  });

  @override
  State<UserListAddDialog> createState() => _UserListAddDialogState();
}

class _UserListAddDialogState extends State<UserListAddDialog> {
  final TextEditingController _textEditingController = TextEditingController();
  late ChannelProvider channelProvider;

  @override
  Widget build(BuildContext context) {
    channelProvider = Provider.of<ChannelProvider>(context, listen: false);
    _textEditingController.selection = TextSelection.fromPosition(
      TextPosition(offset: _textEditingController.text.length),
    );
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
                    controller: _textEditingController,
                    style: const TextStyle(color: Colors.black54),
                    onChanged: (value) {
                      if (value.trim().isNotEmpty) {
                        setState(() {
                          _textEditingController.text = value;
                        });
                      } else {
                        setState(() {
                          _textEditingController.clear();
                        });
                      }
                    },
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
                      hintText:
                          'Search ${widget.isModerator ? 'Moderators' : 'Users'} here...',
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

              // list view of all the users in our channel
              StreamBuilder(
                  stream: channelProvider.getUserList(),
                  builder: (context, snapshot) {
                    if (snapshot.hasData && snapshot.data!.isNotEmpty) {
                      List<UserModel> userList = snapshot.data!;
                      if (_textEditingController.text.isNotEmpty) {
                        userList = snapshot.data!.where((element) {
                          return element.firstName
                              .toString()
                              .toLowerCase()
                              .contains(
                                _textEditingController.text.toLowerCase(),
                              );
                        }).toList();
                      }
                      return Expanded(
                        child: ListView.builder(
                          shrinkWrap: true,
                          padding: EdgeInsets.zero,
                          itemCount: userList.length,
                          itemBuilder: (context, index) {
                            return Container(
                              margin: const EdgeInsets.symmetric(vertical: 10),
                              child: ListTile(
                                contentPadding: EdgeInsets.zero,
                                leading: CachedNetworkImage(
                                  imageUrl: userList[index].profilePic!,
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
                                ),
                                title: SelectableText(
                                  '${userList[index].firstName}${userList[index].lastName}',
                                  maxLines: 1,
                                ),
                                subtitle: SelectableText(
                                  userList[index].userId!,
                                  maxLines: 1,
                                ),
                                // building the trailing widget
                                trailing: IconButton(
                                    icon: const Icon(
                                      FontAwesomeIcons.circlePlus,
                                      color: kPrimaryColor,
                                    ),
                                    onPressed: () async {
                                      // adding user to moderators collection
                                      await channelProvider
                                          .addUserToChannel(
                                        userId: userList[index].userId!,
                                        isModerator: widget.isModerator,
                                        channelId: widget.channelId,
                                        channelName: widget.channelName,
                                      )
                                          .whenComplete(() {
                                        Navigator.of(context).pop();
                                        showSnackbar(
                                          context,
                                          '${widget.isModerator ? 'Moderator' : 'User'} added to channel',
                                        );
                                      });
                                    }),
                              ),
                            );
                          },
                        ),
                      );
                    } else if (snapshot.hasError) {
                      return emptyPage(FontAwesomeIcons.circleXmark, "Error!");
                    }
                    return const Center(
                      child: CircularProgressIndicator(color: kPrimaryColor),
                    );
                  })
            ],
          ),
        ),
      ),
    );
  }
}
