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
  const UserListScreen(
      {super.key, required this.isModerator, required this.channelId});

  @override
  State<UserListScreen> createState() => _UserListScreenState();
}

class _UserListScreenState extends State<UserListScreen> {
  late ChannelProvider channelProvider;

  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.of(context).size.width;
    channelProvider = Provider.of<ChannelProvider>(context, listen: false);

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
                            );
                          });
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
        child: StreamBuilder<List<UserModel>>(
          stream: channelProvider.getUserStream(
              groupId: widget.channelId, isModerator: widget.isModerator),
          builder: (context, snapshot) {
            if (snapshot.hasData && snapshot.data!.isEmpty) {
              return emptyPage(FontAwesomeIcons.solidUser,
                  'No ${widget.isModerator ? 'Moderators' : 'Users'} found!');
            } else if (snapshot.hasData && snapshot.data!.isNotEmpty) {
              return ListView.builder(
                itemCount: snapshot.data!.length,
                padding: const EdgeInsets.only(top: 20, bottom: 30),
                itemBuilder: (context, index) {
                  return buildUserData(snapshot.data![index]);
                },
              );
            } else if (snapshot.hasError) {
              return emptyPage(
                FontAwesomeIcons.circleXmark,
                'Some unexpected error!',
              );
            }
            return const Center(
                child: CircularProgressIndicator(color: kPrimaryColor));
          },
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
                    channelId: widget.channelId,
                  )
                      .whenComplete(() {
                    Navigator.of(context).pop();
                    showSnackbar(context, 'Removed successfully from database');
                  });
                  setState(() {});
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
