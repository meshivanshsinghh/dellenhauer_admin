import 'package:cached_network_image/cached_network_image.dart';
import 'package:dellenhauer_admin/model/users/user_model.dart';
import 'package:dellenhauer_admin/pages/pending_users/pending_users_provider.dart';
import 'package:dellenhauer_admin/utils/colors.dart';
import 'package:dellenhauer_admin/utils/utils.dart';
import 'package:dellenhauer_admin/utils/widgets/empty.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';

class PendingUsers extends StatefulWidget {
  const PendingUsers({super.key});

  @override
  State<PendingUsers> createState() => _PendingUsersState();
}

class _PendingUsersState extends State<PendingUsers> {
  String? sortByText;
  late bool descending;
  late String orderBy;
  late PendingUsersProvider pendingUsersProvider;
  @override
  void initState() {
    super.initState();
    sortByText = 'Newest First';
    orderBy = 'createdAt';
    descending = true;
    Future.delayed(Duration.zero, () {
      pendingUsersProvider =
          Provider.of<PendingUsersProvider>(context, listen: false);
      pendingUsersProvider.attachContext(context);
      pendingUsersProvider.setLoading(true);
      pendingUsersProvider.getUserData(
          orderBy: orderBy, descending: descending);
    });
  }

  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.of(context).size.width;
    pendingUsersProvider =
        Provider.of<PendingUsersProvider>(context, listen: true);

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
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: MediaQuery.of(context).size.height * 0.05),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Pending Users',
                style: TextStyle(
                  fontSize: 25,
                  fontWeight: FontWeight.w800,
                ),
              ),
              sortingPopup(),
            ],
          ),
          Container(
            margin: const EdgeInsets.only(top: 5, bottom: 10),
            height: 3,
            width: 50,
            decoration: BoxDecoration(
                color: kPrimaryColor, borderRadius: BorderRadius.circular(15)),
          ),
          Expanded(
            child: pendingUsersProvider.isLoading
                ? const Center(
                    child: CircularProgressIndicator(
                    color: kPrimaryColor,
                  ))
                : !pendingUsersProvider.hasData
                    ? emptyPage(FontAwesomeIcons.userPlus, 'No Pending Users')
                    : NotificationListener<ScrollNotification>(
                        onNotification: (notification) {
                          if (!pendingUsersProvider.isLoading) {
                            if (notification.metrics.pixels ==
                                notification.metrics.maxScrollExtent) {
                              pendingUsersProvider.loadingMoreContent(true);
                              pendingUsersProvider.getUserData(
                                  orderBy: orderBy, descending: descending);
                            }
                          }
                          return false;
                        },
                        child: RefreshIndicator(
                          color: kPrimaryColor,
                          onRefresh: () async {
                            refreshData();
                          },
                          child: ListView.builder(
                            itemCount: pendingUsersProvider.data.length,
                            padding: const EdgeInsets.only(top: 20),
                            shrinkWrap: true,
                            itemBuilder: (context, index) {
                              if (index < pendingUsersProvider.data.length) {
                                final UserModel u = UserModel.fromJson(
                                    pendingUsersProvider.data[index].data()
                                        as dynamic);
                                return buildUserData(u);
                              }
                              return Center(
                                child: Opacity(
                                  opacity:
                                      pendingUsersProvider.isLoadingMoreContent
                                          ? 1.0
                                          : 0.0,
                                  child: const SizedBox(
                                    height: 30,
                                    width: 30,
                                    child: CircularProgressIndicator(
                                      color: kPrimaryColor,
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      ),
          )
        ],
      ),
    );
  }

  Widget buildUserData(UserModel data) {
    return ListTile(
      contentPadding: const EdgeInsets.only(top: 10, bottom: 10),
      leading: CachedNetworkImage(
        imageUrl: data.profilePic!,
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
      subtitle: SelectableText('${data.email} \nUID: ${data.phoneNumber}'),
      title: SelectableText(
        '${data.firstName} ${data.lastName}',
        style: const TextStyle(fontWeight: FontWeight.w600),
      ),
      isThreeLine: true,
      trailing: Wrap(
        children: [
          IconButton(
            onPressed: () {
              showSnackbar(context, 'Verifiying....');
              pendingUsersProvider
                  .acceptPendingUser(userId: data.userId!)
                  .then((v) {
                Future.delayed(const Duration(seconds: 1), () {
                  showSnackbar(context, 'User verified successfully');
                  refreshData();
                });
              });
            },
            icon: Icon(
              FontAwesomeIcons.check,
              color: Colors.green.shade400,
            ),
          ),
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
              'Sort By -$sortByText',
              style: TextStyle(
                color: Colors.grey[900],
                fontWeight: FontWeight.w500,
              ),
            ),
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

  void refreshData() {
    pendingUsersProvider =
        Provider.of<PendingUsersProvider>(context, listen: false);
    pendingUsersProvider.setLastVisible(null);
    pendingUsersProvider.setLoading(true);
    pendingUsersProvider.data.clear();
    pendingUsersProvider.getUserData(orderBy: orderBy, descending: descending);
    pendingUsersProvider.notifyListeners();
  }
}
