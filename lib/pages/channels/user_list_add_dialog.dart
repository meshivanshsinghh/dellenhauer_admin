import 'package:cached_network_image/cached_network_image.dart';
import 'package:dellenhauer_admin/model/users/user_model.dart';
import 'package:dellenhauer_admin/providers/channels_provider.dart';
import 'package:dellenhauer_admin/utils/styles.dart';
import 'package:dellenhauer_admin/utils/colors.dart';
import 'package:dellenhauer_admin/utils/widgets/empty.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';

class UserListAddDialog extends StatefulWidget {
  final bool isModerator;
  final String channelId;
  const UserListAddDialog(
      {super.key, required this.isModerator, required this.channelId});

  @override
  State<UserListAddDialog> createState() => _UserListAddDialogState();
}

class _UserListAddDialogState extends State<UserListAddDialog> {
  final TextEditingController _textEditingController = TextEditingController();
  late ChannelProvider channelProvider;

  @override
  Widget build(BuildContext context) {
    channelProvider = Provider.of<ChannelProvider>(context, listen: false);
    return FractionallySizedBox(
      heightFactor: 0.8,
      widthFactor: 0.8,
      child: Scaffold(
        body: Padding(
          padding: const EdgeInsets.only(top: 10, left: 10, right: 10),
          child: Column(
            children: [
              TextFormField(
                controller: _textEditingController,
                decoration: inputDecoration(
                  widget.isModerator ? 'Search Moderators' : 'Search Users',
                  widget.isModerator
                      ? 'Add new moderator...'
                      : 'Add new user...',
                  _textEditingController,
                ),
              ),

              // list view of all the users in our channel
              FutureBuilder(
                  future: channelProvider.getUserList(),
                  builder: (context, snapshot) {
                    if (snapshot.hasData && snapshot.data!.isNotEmpty) {
                      List<UserModel> userList = snapshot.data!;
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
                                    onPressed: () {
                                      // adding user to moderators collection
                                      channelProvider
                                          .addUserToChannel(
                                        userId: userList[index].userId!,
                                        isModerator: widget.isModerator,
                                        channelId: widget.channelId,
                                      )
                                          .whenComplete(() {
                                        Navigator.of(context).pop();
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
