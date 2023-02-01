import 'package:cached_network_image/cached_network_image.dart';
import 'package:dellenhauer_admin/model/users/user_model.dart';
import 'package:dellenhauer_admin/pages/users/users_edit_screen.dart';
import 'package:dellenhauer_admin/providers/users_provider.dart';
import 'package:dellenhauer_admin/utils/nextscreen.dart';
import 'package:dellenhauer_admin/utils/utils.dart';
import 'package:dellenhauer_admin/utils/widgets/empty.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';

class UserScreen extends StatefulWidget {
  const UserScreen({super.key});

  @override
  State<UserScreen> createState() => _UserScreenState();
}

class _UserScreenState extends State<UserScreen> {
  late UsersProvider usersProvider;
  ScrollController? scrollController;
  late String orderBy;
  String? sortByText;
  late bool descending;

  @override
  void initState() {
    super.initState();
    sortByText = 'Newest First';
    orderBy = 'createdAt';
    descending = true;
    Future.delayed(Duration.zero, () {
      scrollController = ScrollController()..addListener(_scrollListener);
      usersProvider = Provider.of<UsersProvider>(context, listen: false);
      usersProvider.attachContext(context);
      usersProvider.setLoading(isLoading: true);
      usersProvider.getUsersData(orderBy: orderBy, descending: descending);
    });
  }

  void _scrollListener() async {
    usersProvider = Provider.of<UsersProvider>(context, listen: true);
    if (!usersProvider.isLoading) {
      if (scrollController!.position.pixels ==
          scrollController!.position.maxScrollExtent) {
        usersProvider.setLoading(isLoading: true);
        usersProvider.getUsersData(orderBy: orderBy, descending: descending);
      }
    }
  }

  refreshData() {
    usersProvider = Provider.of<UsersProvider>(context, listen: false);
    usersProvider.setLastVisible(snapshot: null);
    usersProvider.setLoading(isLoading: true);
    usersProvider.data.clear();
    usersProvider.getUsersData(orderBy: orderBy, descending: descending);
    usersProvider.notifyListeners();
  }

  @override
  void dispose() {
    super.dispose();
    scrollController!.removeListener(_scrollListener);
  }

  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.of(context).size.width;
    usersProvider = Provider.of<UsersProvider>(context, listen: true);
    return Container(
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
          ]),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: MediaQuery.of(context).size.height * 0.05),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Users',
                    style: TextStyle(
                      fontSize: 25,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  Container(
                    margin: const EdgeInsets.only(top: 5, bottom: 10),
                    height: 3,
                    width: 50,
                    decoration: BoxDecoration(
                        color: Colors.redAccent,
                        borderRadius: BorderRadius.circular(15)),
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    'Click on any user to edit their details',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.black54,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ],
              ),
              sortingPopup(),
            ],
          ),
          Expanded(
              child: usersProvider.isLoading == true
                  ? const Center(
                      child: CircularProgressIndicator(
                        color: Colors.redAccent,
                      ),
                    )
                  : usersProvider.hasData == false
                      ? emptyPage(FontAwesomeIcons.solidUser, 'No User Found!')
                      : RefreshIndicator(
                          color: Colors.redAccent,
                          child: ListView.builder(
                            shrinkWrap: true,
                            padding: const EdgeInsets.only(top: 20),
                            itemCount: usersProvider.data.length + 1,
                            itemBuilder: ((context, index) {
                              if (index < usersProvider.data.length) {
                                final UserModel u = UserModel.fromJson(
                                    usersProvider.data[index].data()
                                        as dynamic);

                                return buildUserData(u);
                              }
                              return Center(
                                child: Opacity(
                                  opacity: usersProvider.isLoading ? 1.0 : 0.0,
                                  child: const SizedBox(
                                    width: 32,
                                    height: 32,
                                    child: CircularProgressIndicator(
                                      color: Colors.redAccent,
                                    ),
                                  ),
                                ),
                              );
                            }),
                          ),
                          onRefresh: () async {
                            refreshData();
                          }))
        ],
      ),
    );
  }

  Widget sortingPopup() {
    return PopupMenuButton(
      child: Container(
        height: 40,
        alignment: Alignment.center,
        padding: const EdgeInsets.only(left: 20, right: 20),
        decoration: BoxDecoration(
          color: Colors.grey[100],
          border: Border.all(color: Colors.grey[300]!),
          borderRadius: BorderRadius.circular(30),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              FontAwesomeIcons.arrowDown,
              size: 20,
              color: Colors.grey[800],
            ),
            const SizedBox(width: 10),
            Text(
              'Sort By - $sortByText',
              style: TextStyle(
                color: Colors.grey[900],
                fontWeight: FontWeight.w500,
              ),
            )
          ],
        ),
      ),
      itemBuilder: (context) {
        return const [
          PopupMenuItem(value: 'new', child: Text('Newest First')),
          PopupMenuItem(value: 'old', child: Text('Oldest First')),
        ];
      },
      onSelected: (dynamic value) {
        if (value == 'new') {
          setState(() {
            sortByText = 'Newest First';
            orderBy = 'createdAt';
            descending = true;
          });
        } else if (value == 'old') {
          setState(() {
            sortByText = 'Oldest First';
            orderBy = 'createdAt';
            descending = false;
          });
        }
        refreshData();
      },
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
      subtitle: SelectableText('${userData.email} \nUID: ${userData.userId}'),
      title: SelectableText(
        '${userData.firstName} ${userData.lastName}',
        style: const TextStyle(fontWeight: FontWeight.w600),
      ),
      isThreeLine: true,
      trailing: Wrap(
        children: [
          IconButton(
              icon: const Icon(
                FontAwesomeIcons.trash,
                color: Colors.redAccent,
                size: 18,
              ),
              onPressed: () {
                deletingUser(
                  context,
                  'Delete User?',
                  'Are you sure you want to delete this user from databse?',
                  ElevatedButton(
                    onPressed: () {
                      usersProvider
                          .deletingUser(userId: userData.userId!)
                          .whenComplete(() {
                        Navigator.of(context).pop();
                        showSnackbar(context,
                            'User deleted successfully form #Dellenhauer');
                        setState(() {});
                      });
                    },
                    style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.redAccent),
                    child: const Text('YES'),
                  ),
                  ElevatedButton(
                    style:
                        ElevatedButton.styleFrom(backgroundColor: Colors.grey),
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text("NO"),
                  ),
                );
              }),
          const SizedBox(width: 5),
          IconButton(
              icon: const Icon(
                FontAwesomeIcons.pencil,
                color: Colors.grey,
                size: 18,
              ),
              onPressed: () {
                nextScreen(context, UsersEditScreen(userId: userData.userId!));
              }),
        ],
      ),
    );
  }
}
