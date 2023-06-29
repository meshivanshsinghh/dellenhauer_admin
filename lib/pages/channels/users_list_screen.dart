import 'package:dellenhauer_admin/utils/colors.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:dellenhauer_admin/model/users/user_model.dart';
import 'package:dellenhauer_admin/pages/channels/user_list_add_dialog.dart';
import 'package:dellenhauer_admin/providers/channels_provider.dart';
import 'package:dellenhauer_admin/utils/utils.dart';
import 'package:dellenhauer_admin/utils/widgets/empty.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';

class UserListScreen extends StatefulWidget {
  final bool isModerator;
  final String channelId;
  final String channelName;
  final bool isNewChannel;
  const UserListScreen({
    super.key,
    required this.isModerator,
    required this.channelId,
    required this.channelName,
    this.isNewChannel = false,
  });

  @override
  State<UserListScreen> createState() => _UserListScreenState();
}

class _UserListScreenState extends State<UserListScreen> {
  late ChannelProvider channelProvider;
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.of(context).size.width;
    channelProvider = Provider.of<ChannelProvider>(context, listen: false);
    _searchController.selection = TextSelection.fromPosition(
      TextPosition(offset: _searchController.text.length),
    );
    return Scaffold(
      appBar: PreferredSize(
          preferredSize: const Size.fromHeight(60),
          child: Center(
            child: AppBar(
                elevation: 1,
                centerTitle: true,
                title: Text(
                  widget.isModerator ? 'Moderators' : 'Users',
                ),
                actions: [
                  TextButton(
                    child: Text(
                      widget.isModerator ? 'Add Moderators' : 'Add Users',
                      style: const TextStyle(color: kPrimaryColor),
                    ),
                    onPressed: () {
                      showDialog(
                        context: context,
                        barrierDismissible: true,
                        builder: (context) {
                          return UserListAddDialog(
                            isModerator: widget.isModerator,
                            channelId: widget.channelId,
                            channelName: widget.channelName,
                          );
                        },
                      );
                    },
                  ),
                ]),
          )),
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
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10.0),
                child: Container(
                  height: 50,
                  margin: const EdgeInsets.only(top: 10),
                  width: MediaQuery.of(context).size.width,
                  child: TextFormField(
                    focusNode: _focusNode,
                    controller: _searchController,
                    style: const TextStyle(color: Colors.black54),
                    onChanged: (value) {
                      if (value.trim().isNotEmpty) {
                        setState(() {
                          _searchController.text = value;
                        });
                      } else {
                        setState(() {
                          _searchController.clear();
                          _focusNode.unfocus();
                        });
                      }
                    },
                    decoration: InputDecoration(
                      suffixIcon: _searchController.text.isNotEmpty
                          ? IconButton(
                              onPressed: () {
                                setState(() {
                                  _searchController.clear();
                                  _focusNode.unfocus();
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
                )),
            // streambuilder for displaying user list
            StreamBuilder<List<UserModel>>(
              stream: channelProvider.getUserStream(
                groupId: widget.channelId,
                isModerator: widget.isModerator,
              ),
              builder: (context, snapshot) {
                if (snapshot.hasData && snapshot.data!.isEmpty) {
                  return emptyPage(
                    FontAwesomeIcons.solidUser,
                    'No ${widget.isModerator ? 'Moderators' : 'Users'} found!',
                  );
                } else if (snapshot.hasData && snapshot.data!.isNotEmpty) {
                  List<UserModel> users = snapshot.data!;
                  if (_searchController.text.isNotEmpty) {
                    users = snapshot.data!.where((element) {
                      return element.firstName
                          .toString()
                          .toLowerCase()
                          .contains(
                            _searchController.text.toLowerCase(),
                          );
                    }).toList();
                  }
                  return Expanded(
                    child: ListView.builder(
                      shrinkWrap: true,
                      itemCount: users.length,
                      padding: const EdgeInsets.only(top: 20, bottom: 30),
                      itemBuilder: (context, index) {
                        return buildUserData(users[index]);
                      },
                    ),
                  );
                } else if (snapshot.hasError) {
                  return emptyPage(
                    FontAwesomeIcons.circleXmark,
                    'Some unexpected error!',
                  );
                }
                return const Padding(
                  padding: EdgeInsets.only(top: 50.0),
                  child: Center(
                    child: CircularProgressIndicator(color: kPrimaryColor),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget buildUserData(UserModel userData) {
    return ListTile(
      contentPadding: const EdgeInsets.only(top: 10, bottom: 10),
      leading: CachedNetworkImage(
        imageUrl: userData.profilePic!,
        placeholder: (context, url) {
          return Container(
            height: 60,
            width: 60,
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
            height: 60,
            width: 60,
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
        '${userData.email} \nUID: ${userData.userId}',
        style: const TextStyle(fontSize: 12),
      ),
      title: SelectableText(
        '${userData.firstName} ${userData.lastName}',
        style: const TextStyle(fontWeight: FontWeight.w600),
      ),
      trailing: IconButton(
        icon: const Icon(FontAwesomeIcons.trash, color: kPrimaryColor),
        onPressed: () {
          deletingUser(
              context,
              'Delete?',
              'Want to remove this ${widget.isModerator ? 'moderator' : 'user'} from channel',
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: kPrimaryColor,
                ),
                onPressed: () {
                  channelProvider
                      .removeUserFromChannel(
                    userId: userData.userId!,
                    isModerator: widget.isModerator,
                    channelName: widget.channelName,
                    channelId: widget.channelId,
                  )
                      .whenComplete(() {
                    Navigator.of(context).pop();
                    showSnackbar(context, 'Removed successfully from database');
                  });
                },
                child: const Text(
                  'YES',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: kPrimaryColor,
                ),
                onPressed: () => Navigator.of(context).pop(),
                child: const Text(
                  'NO',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ));
        },
      ),
    );
  }
}
