import 'package:cached_network_image/cached_network_image.dart';
import 'package:dellenhauer_admin/model/awards/awards_model.dart';
import 'package:dellenhauer_admin/model/courses/courses_model.dart';
import 'package:dellenhauer_admin/model/users/user_model.dart';
import 'package:dellenhauer_admin/pages/push_notification/widgets/user_and_channel_list_notification.dart';
import 'package:dellenhauer_admin/pages/users/users_awards_list.dart';
import 'package:dellenhauer_admin/pages/users/users_courses_list.dart';
import 'package:dellenhauer_admin/providers/users_provider.dart';
import 'package:dellenhauer_admin/utils/colors.dart';
import 'package:dellenhauer_admin/utils/utils.dart';
import 'package:dellenhauer_admin/utils/widgets/empty.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/standalone.dart' as tz;

class UsersEditScreen extends StatefulWidget {
  final String userId;
  const UsersEditScreen({super.key, required this.userId});

  @override
  State<UsersEditScreen> createState() => _UsersEditScreenState();
}

class _UsersEditScreenState extends State<UsersEditScreen> {
  late UsersProvider userProvider;
  bool isLoading = false;
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _nickNameController = TextEditingController();
  late CountryModel countryModel;
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _bioController = TextEditingController();
  late bool _isPremiumUser;
  late bool _isVerified;
  UserModel? userModelLatest;
  final TextEditingController _phoneNumber = TextEditingController();
  List<AwardsModel> awardsModel = [];
  List<CoursesModel> coursesModel = [];
  bool _activatePush = false;
  late UserModel currentUser;
  final TextEditingController _websiteUrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    Future.delayed(Duration.zero, () async {
      userProvider = Provider.of<UsersProvider>(context, listen: false);
      userProvider.attachContext(context);
      userProvider.removeInvitedByUser();
      userProvider.selectedCourses.clear();
      userProvider.selectedUserAwards.clear();
      await userProvider.getUserDataFromId(widget.userId).then((value) {
        setState(() {
          currentUser = value!;
        });
      }).whenComplete(() => setData());
      await fetchPushPermission(currentUser.userId!);
    });
  }

  setData() async {
    if (mounted) {
      setState(() {
        _isPremiumUser = currentUser.isPremiumUser!;
        _isVerified = currentUser.isVerified!;
        _isVerified = currentUser.isVerified!;
      });
      userProvider.selectedCourses.addAll(currentUser.coursesModel!);
      userProvider.selectedUserAwards.addAll(currentUser.awardsModel!);
    }
    if (currentUser.invitedBy!.trim().isNotEmpty) {
      setState(() {
        isLoading = true;
      });
      await userProvider
          .getUserDataFromId(currentUser.invitedBy!)
          .then((value) {
        userProvider.setInvitedByUser(value!);
      }).whenComplete(() {
        setState(() {
          isLoading = false;
        });
      });
    }
  }

  void toggleSwitch(bool value, String type) {
    if (type == 'premium') {
      setState(() {
        _isPremiumUser = value;
      });
    } else if (type == 'verified') {
      setState(() {
        _isVerified = value;
      });
    } else if (type == 'activatePush') {
      setState(() {
        _activatePush = value;
      });
    }
  }

  Future<void> fetchPushPermission(String userId) async {
    await userProvider.determineActivatePushForUser(userId).then((value) {
      if (mounted) {
        setState(() {
          _activatePush = value;
        });
      }
    });
  }

  @override
  void dispose() {
    super.dispose();
    _firstNameController.dispose();
    _lastNameController.dispose();
    _nickNameController.dispose();
    _emailController.dispose();
    _bioController.dispose();
    _websiteUrl.dispose();
    _phoneNumber.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.of(context).size.width;
    userProvider = Provider.of<UsersProvider>(context, listen: true);
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(60),
        child: Center(
          child: AppBar(
            elevation: 1,
            centerTitle: true,
            title: const Text('Edit User'),
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
          child:
              // getting the userdata in futurebuilder
              FutureBuilder<UserModel?>(
            future: userProvider.getUserDataFromId(widget.userId),
            builder: (context, snapshot) {
              if (snapshot.hasData && snapshot.data != null) {
                // setting up dataa
                return SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      // profile pic of user
                      CachedNetworkImage(
                        imageUrl: snapshot.data!.profilePic!,
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
                      // text field
                      textFieldEntry(
                        title: 'First Name',
                        controller: _firstNameController,
                        value: snapshot.data!.firstName!,
                      ),
                      textFieldEntry(
                        title: 'Last Name',
                        controller: _lastNameController,
                        value: snapshot.data!.lastName!,
                      ),
                      textFieldEntry(
                        title: 'Nick Name',
                        controller: _nickNameController,
                        value: snapshot.data!.nickname!,
                      ),
                      textFieldEntry(
                        title: 'Email',
                        controller: _emailController,
                        value: snapshot.data!.email!,
                      ),
                      textFieldEntry(
                        title: 'Website Url',
                        controller: _websiteUrl,
                        value: snapshot.data!.websiteUrl!,
                      ),
                      textFieldEntry(
                        title: 'Phone Number',
                        isFieldActive: false,
                        controller: _phoneNumber,
                        value: snapshot.data!.phoneNumber!,
                      ),
                      textFieldEntry(
                        title: 'Bio',
                        controller: _bioController,
                        value: snapshot.data!.bio!,
                      ),
                      // toggle buttons
                      switchWidget('Premium User', _isPremiumUser, (value) {
                        toggleSwitch(value, 'premium');
                      }),
                      switchWidget('Activate Push', _activatePush, (value) {
                        toggleSwitch(value, 'activatePush');
                      }),
                      switchWidget('Verified User', _isVerified, (value) {
                        toggleSwitch(value, 'verified');
                      }),
                      const SizedBox(height: 10),
                      // awards list
                      awardsShowcaseWidget(snapshot.data!.awardsModel!),
                      // courses list
                      coursesShowWidget(snapshot.data!.coursesModel!),
                      loadInvitedUserWidget(),
                      // showcasing when user was created
                      userCreated(snapshot.data!.createdAt!),
                      Container(
                        width: double.infinity,
                        margin: const EdgeInsets.only(top: 5),
                        height: 40,
                        child: ElevatedButton(
                          onPressed: () {
                            submitData();
                          },
                          style: ElevatedButton.styleFrom(
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(30)),
                              backgroundColor: kPrimaryColor),
                          child: const Text('Save'),
                        ),
                      )
                    ],
                  ),
                );
              } else if (snapshot.hasError) {
                return emptyPage(FontAwesomeIcons.circleXmark, 'Error!');
              } else if (snapshot.hasData) {
                return emptyPage(FontAwesomeIcons.solidUser, 'No user data');
              }
              return const Center(
                child: CircularProgressIndicator(
                  color: kPrimaryColor,
                ),
              );
            },
          )),
    );
  }

  Widget textFieldEntry({
    required String title,
    bool isFieldActive = true,
    required TextEditingController controller,
    required String value,
  }) {
    controller.text = value;
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
          enabled: isFieldActive,
          maxLines: controller == _bioController ? 4 : 1,
          controller: controller,
          cursorColor: kPrimaryColor,
          decoration: InputDecoration(
            disabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: Colors.grey, width: 1),
            ),
            filled: isFieldActive == true ? false : true,
            fillColor: Colors.grey.shade200,
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

  Widget awardsShowcaseWidget(List<AwardsModel> initialData) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('User Awards'),
            IconButton(
                icon: const Icon(
                  FontAwesomeIcons.circlePlus,
                  color: kPrimaryColor,
                  size: 20,
                ),
                onPressed: () {
                  showDialog(
                      barrierDismissible: false,
                      context: context,
                      builder: (context) {
                        return const UsersAwardsList();
                      });
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
            scrollDirection: Axis.vertical,
            child: Wrap(
              children: [
                ...userProvider.selectedUserAwards.map((e) => singleCardWidget(
                    title: e.name!,
                    onDelete: () {
                      userProvider.removeSelectUserAwards(e.id!);
                    })),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget coursesShowWidget(List<CoursesModel> initialData) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('User Courses'),
            IconButton(
                icon: const Icon(
                  FontAwesomeIcons.circlePlus,
                  color: kPrimaryColor,
                  size: 20,
                ),
                onPressed: () {
                  showDialog(
                      barrierDismissible: false,
                      context: context,
                      builder: (context) {
                        return const UsersCoursesList();
                      });
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
            scrollDirection: Axis.vertical,
            child: Wrap(
              children: [
                ...userProvider.selectedCourses.map((e) => singleCardWidget(
                    title: e.name!,
                    onDelete: () {
                      userProvider.removeSelectCourses(e.id!);
                    })),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget singleCardWidget(
      {required String title, required VoidCallback onDelete}) {
    return Container(
      height: 50,
      constraints: const BoxConstraints(maxWidth: 200),
      margin: const EdgeInsets.only(right: 10, bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 5),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(5),
      ),
      child: ListTile(
        title: Text(
          title,
          maxLines: 1,
        ),
        trailing: IconButton(
          onPressed: onDelete,
          icon: const Icon(FontAwesomeIcons.circleXmark, size: 15),
        ),
      ),
    );
  }

  String getUserCreatedDate(int timestamp) {
    tz.initializeTimeZones();
    final berlin = tz.getLocation('Europe/Berlin');
    final berlinTime =
        tz.TZDateTime.fromMillisecondsSinceEpoch(berlin, timestamp);
    final formatter = DateFormat('d.M.y H:m:s');
    final berlinFormatted = formatter.format(berlinTime);
    return 'User created at: $berlinFormatted (Berlin)';
  }

  Widget userCreated(String createdAt) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 30),
      padding: const EdgeInsets.all(10.0),
      width: MediaQuery.of(context).size.width,
      child: Text(
        getUserCreatedDate(int.parse(createdAt)),
        style: const TextStyle(color: Colors.grey, fontWeight: FontWeight.w600),
      ),
    );
  }

  Widget loadInvitedUserWidget() {
    return Container(
        width: MediaQuery.of(context).size.width,
        margin: const EdgeInsets.only(top: 20, bottom: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Invited By User',
              style: TextStyle(fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 10),
            isLoading
                ? const Center(
                    child: SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        color: kPrimaryColor,
                      ),
                    ),
                  )
                : userProvider.invitedByUser == null
                    ? ElevatedButton(
                        onPressed: () {
                          showDialog(
                            context: context,
                            builder: (context) {
                              return const UserListNotificationSelection(
                                isUser: true,
                                isEditUser: true,
                              );
                            },
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: kPrimaryColor,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(0),
                          ),
                        ),
                        child: const Text('Add User'),
                      )
                    : ListTile(
                        leading: CachedNetworkImage(
                          imageUrl: userProvider.invitedByUser!.profilePic!,
                          placeholder: (context, url) {
                            return Container(
                              height: 50,
                              width: 50,
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
                          errorWidget: (context, url, errr) {
                            return Container(
                              height: 50,
                              width: 50,
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
                              height: 50,
                              width: 50,
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
                        title: Text(
                          '${userProvider.invitedByUser!.firstName} ${userProvider.invitedByUser!.lastName}',
                        ),
                        subtitle: Text(
                          '${userProvider.invitedByUser!.userId}',
                          style: const TextStyle(color: Colors.grey),
                        ),
                        trailing: userProvider.invitedByUser != null
                            ? IconButton(
                                onPressed: () {
                                  userProvider.removeInvitedByUser();
                                },
                                icon: const Icon(
                                  FontAwesomeIcons.circleXmark,
                                  size: 20,
                                  color: kPrimaryColor,
                                ),
                              )
                            : IconButton(
                                onPressed: () {
                                  showDialog(
                                    context: context,
                                    builder: (context) {
                                      return const UserListNotificationSelection(
                                        isUser: true,
                                        isEditUser: true,
                                      );
                                    },
                                  );
                                },
                                icon: const Icon(
                                  FontAwesomeIcons.pencil,
                                  size: 20,
                                  color: kPrimaryColor,
                                ),
                              ),
                      )
          ],
        ));
  }

  // submitting data
  void submitData() async {
    if (userProvider.invitedByUser == null) {
      showSnackbar(context, 'Please select a invited by user first');
    } else {
      UserModel userModelLatest = UserModel(
        firstName: _firstNameController.text.trim(),
        lastName: _lastNameController.text.trim(),
        nickname: _nickNameController.text.trim(),
        awardsModel: userProvider.selectedUserAwards,
        coursesModel: userProvider.selectedCourses,
        email: _emailController.text.trim(),
        bio: _bioController.text.trim(),
        isPremiumUser: _isPremiumUser,
        isVerified: _isVerified,
        invitedBy: userProvider.invitedByUser!.userId!,
        phoneNumber: _phoneNumber.text.trim(),
        websiteUrl: _websiteUrl.text.trim(),
      );
      await userProvider
          .updateUserData(
        userModel: userModelLatest,
        userId: widget.userId,
        activatePush: _activatePush,
      )
          .whenComplete(() {
        showSnackbar(context, 'User data updated successfully');
      });
    }
  }
}
