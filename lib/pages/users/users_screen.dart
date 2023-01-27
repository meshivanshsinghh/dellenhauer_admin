import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dellenhauer_admin/pages/users/model/user_model.dart';
import 'package:dellenhauer_admin/utils/utils.dart';
import 'package:dellenhauer_admin/utils/widgets/empty.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class UserScreen extends StatefulWidget {
  const UserScreen({super.key});

  @override
  State<UserScreen> createState() => _UserScreenState();
}

class _UserScreenState extends State<UserScreen> {
  final FirebaseFirestore firebaseFirestore = FirebaseFirestore.instance;
  ScrollController? scrollController;
  DocumentSnapshot? _lastVisible;
  List<DocumentSnapshot> dataSnapshot = [];
  bool? _hasData;
  late bool? _isLoading;
  @override
  void initState() {
    super.initState();
    scrollController = ScrollController()..addListener(_scrollListener);
    _isLoading = true;
    getData();
  }

  void _scrollListener() async {
    if (_isLoading!) {
      if (scrollController!.position.pixels ==
          scrollController!.position.maxScrollExtent) {
        setState(() {
          _isLoading = true;
          getData();
        });
      }
    }
  }

  Future<void> getData() async {
    QuerySnapshot data;
    if (_lastVisible == null) {
      data = await firebaseFirestore
          .collection('users')
          .orderBy('createdAt', descending: true)
          .limit(15)
          .get();
    } else {
      data = await firebaseFirestore
          .collection('users')
          .orderBy('createdAt', descending: true)
          .startAfter([_lastVisible!['createdAt']])
          .limit(15)
          .get();
    }
    if (data.docs.isNotEmpty) {
      _lastVisible = data.docs[data.docs.length - 1];
      if (mounted) {
        setState(() {
          _isLoading = false;
          _hasData = true;
          dataSnapshot.addAll(data.docs);
        });
      }
    } else {
      setState(() {
        _isLoading = false;
        _hasData = false;
      });
      // ignore: use_build_context_synchronously
      showSnackbar(context, 'No more data available');
    }
  }

  @override
  void dispose() {
    super.dispose();
    scrollController!.removeListener(_scrollListener);
  }

  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.of(context).size.width;

    return Container(
      margin: const EdgeInsets.all(30),
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
          Expanded(
              child: _hasData == false
                  ? emptyPage(FontAwesomeIcons.solidUser, 'No User Found!')
                  : RefreshIndicator(
                      color: Colors.redAccent,
                      child: ListView.builder(
                        itemCount: dataSnapshot.length + 1,
                        padding: const EdgeInsets.only(top: 20, bottom: 30),
                        itemBuilder: ((context, index) {
                          if (index < dataSnapshot.length) {
                            final UserModel u = UserModel.fromJson(
                                dataSnapshot[index].data() as dynamic);
                            return buildUserData(u);
                          }
                          return Center(
                            child: Opacity(
                              opacity: _isLoading! ? 1.0 : 0.0,
                              child: const SizedBox(
                                width: 32,
                                height: 32,
                                child: CircularProgressIndicator(),
                              ),
                            ),
                          );
                        }),
                      ),
                      onRefresh: () async {
                        setState(() {
                          dataSnapshot.clear();
                          _lastVisible = null;
                        });
                        await getData();
                      }))
        ],
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
      subtitle: SelectableText('${userData.email} \nUID: ${userData.userId}'),
      title: SelectableText(
        '${userData.firstName} ${userData.lastName}',
        style: const TextStyle(fontWeight: FontWeight.w600),
      ),
      isThreeLine: true,
      trailing: InkWell(
        child: CircleAvatar(
          backgroundColor: Colors.grey[200],
          radius: 18,
          child: const Icon(
            Icons.copy,
            size: 18,
            color: Colors.black54,
          ),
        ),
        onTap: () {
          Clipboard.setData(ClipboardData(text: userData.userId));
          showSnackbar(context, 'Copied UID to Clipboard');
        },
      ),
    );
  }
}
