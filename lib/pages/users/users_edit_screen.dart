import 'dart:typed_data';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:dellenhauer_admin/model/awards/awards_model.dart';
import 'package:dellenhauer_admin/model/courses/courses_model.dart';
import 'package:dellenhauer_admin/model/users/user_model.dart';
import 'package:dellenhauer_admin/pages/pending_users/pending_users_provider.dart';
import 'package:dellenhauer_admin/pages/push_notification/widgets/user_and_channel_list_notification.dart';
import 'package:dellenhauer_admin/pages/users/users_awards_list.dart';
import 'package:dellenhauer_admin/pages/users/users_courses_list.dart';
import 'package:dellenhauer_admin/providers/users_provider.dart';
import 'package:dellenhauer_admin/utils/colors.dart';
import 'package:dellenhauer_admin/utils/utils.dart';
import 'package:dellenhauer_admin/utils/widgets/empty.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:image_picker_web/image_picker_web.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/standalone.dart' as tz;

class UsersEditScreen extends StatefulWidget {
  final String userId;
  final VoidCallback onSaved;

  const UsersEditScreen({
    super.key,
    required this.userId,
    required this.onSaved,
  });

  @override
  State<UsersEditScreen> createState() => _UsersEditScreenState();
}

class _UsersEditScreenState extends State<UsersEditScreen> {
  late UsersProvider userProvider;
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _nickNameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _bioController = TextEditingController();
  final TextEditingController _phoneNumber = TextEditingController();
  final TextEditingController _websiteUrl = TextEditingController();
  final TextEditingController _wordpressCMSId = TextEditingController();
  late bool _isPremiumUser;
  late bool _isVerified;
  late bool _isOnlineUser;
  List<AwardsModel> awardsModel = [];
  List<CoursesModel> coursesModel = [];
  bool _activatePush = false;
  UserModel? currentUser;
  // username
  bool? isUsernameAvailable;
  String? initialUsername;
  bool userEnteredNewUserName = false;
  // email
  bool? isEmailAddressAvailable;
  String? initialEmailAddress;
  bool userEnteredNewEmail = false;
  final GlobalKey<FormState> _formkey = GlobalKey<FormState>();
  Uint8List? _imageFile;
  late PendingUsersProvider pendingUserProvider;

  @override
  void initState() {
    super.initState();
    Future.delayed(Duration.zero, () async {
      userProvider = Provider.of<UsersProvider>(context, listen: false);
      pendingUserProvider =
          Provider.of<PendingUsersProvider>(context, listen: false);
      getData();
    });
  }

  void getData() async {
    userProvider.setLoading(isLoading: true);
    try {
      userProvider.attachContext(context);
      userProvider.removeInvitedByUser();
      userProvider.selectedCourses.clear();
      userProvider.selectedUserAwards.clear();
      userProvider.setCurrentUserUniqueCode(null);
      UserModel? userData = await userProvider.getUserDataFromId(
        userId: widget.userId,
      );
      if (userData != null && mounted) {
        currentUser = userData;
        await setData();
      }
    } catch (_) {
    } finally {
      userProvider.setLoading(isLoading: false);
    }
  }

  Future<void> setData() async {
    try {
      if (currentUser != null && mounted) {
        setState(() {
          _isPremiumUser = currentUser!.isPremiumUser ?? false;
          _isVerified = currentUser!.isVerified!;
          _firstNameController.text = currentUser!.firstName!;
          _lastNameController.text = currentUser!.lastName!;
          _nickNameController.text = currentUser!.nickname!;
          initialUsername = currentUser!.nickname!;
          initialEmailAddress = currentUser!.email;
          _emailController.text = currentUser!.email!;
          _bioController.text = currentUser!.bio!;
          _phoneNumber.text = currentUser!.phoneNumber!;
          _websiteUrl.text = currentUser!.websiteUrl!;
          _isOnlineUser = currentUser!.isOnline!;
          _wordpressCMSId.text =
              (currentUser!.wordpressCMSuserId ?? '').toString();
        });
        userProvider.selectedCourses.addAll(
          currentUser!.coursesModel!,
        );
        userProvider.selectedUserAwards.addAll(
          currentUser!.awardsModel!,
        );

        if (currentUser!.invitedBy != null &&
            currentUser!.invitedBy!.trim().isNotEmpty) {
          UserModel? invitedUserData = await userProvider.getUserDataFromId(
            userId: currentUser!.invitedBy!,
          );
          if (invitedUserData != null) {
            userProvider.setInvitedByUser(invitedUserData);
          }
        }
        await userProvider.getCurrentUserInviteCode(widget.userId);
        await fetchPushPermission(widget.userId);
      }
    } catch (e) {
      debugPrint(e.toString());
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
    } else if (type == 'isOnline') {
      setState(() {
        _isOnlineUser = value;
      });
    }
  }

  Future<void> _pickImage() async {
    final pickedImage = await ImagePickerWeb.getImageAsBytes();
    if (pickedImage != null) {
      setState(() {
        _imageFile = pickedImage;
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
    _wordpressCMSId.dispose();
  }

  void checkUsername(String userName) {
    if (userName.length < 6) {
      return;
    }
    if (userName == initialUsername) {
      setState(() {
        isUsernameAvailable = true;
      });
      return;
    }
    setState(() {
      isUsernameAvailable = null;
    });
    userProvider = Provider.of<UsersProvider>(context, listen: false);
    userProvider.checkUniqueUsername(username: userName).then((value) {
      if (userName == _nickNameController.text) {
        setState(() {
          isUsernameAvailable = value;
        });
      }
    });
  }

  void checkEmail(String emailAddress) {
    if (emailAddress.length < 6) {
      return;
    }
    if (emailAddress == initialEmailAddress) {
      setState(() {
        isEmailAddressAvailable = true;
      });
      return;
    }
    setState(() {
      isEmailAddressAvailable = null;
    });
    userProvider = Provider.of<UsersProvider>(context, listen: false);
    userProvider.checkEmailAddress(email: emailAddress).then((value) {
      if (emailAddress == _emailController.text) {
        setState(() {
          isEmailAddressAvailable = value;
        });
      }
    });
  }

  setNickNameNull() {
    if (mounted) {
      setState(() {
        isUsernameAvailable = null;
      });
    }
  }

  setEmailAddressNull() {
    if (mounted) {
      setState(() {
        isEmailAddressAvailable = null;
      });
    }
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
        child: userProvider.isLoading
            ? const Center(
                child: CircularProgressIndicator(color: kPrimaryColor),
              )
            : currentUser == null
                ? emptyPage(FontAwesomeIcons.solidUser, 'No user data')
                : SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    child: Form(
                      key: _formkey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          InkWell(
                            onTap: () {
                              _pickImage();
                            },
                            child: Stack(
                              children: [
                                _imageFile == null
                                    ? CachedNetworkImage(
                                        imageUrl: currentUser!.profilePic!,
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
                                        borderRadius:
                                            BorderRadius.circular(100),
                                        child: SizedBox(
                                          height: 150,
                                          width: 150,
                                          child: _imageFile != null
                                              ? FittedBox(
                                                  fit: BoxFit.cover,
                                                  child:
                                                      Image.memory(_imageFile!),
                                                )
                                              : const SizedBox.shrink(),
                                        ),
                                      ),
                              ],
                            ),
                          ),
                          textFieldEntry(
                            title: 'First Name',
                            controller: _firstNameController,
                            validator: (value) {
                              if (value!.trim().isEmpty) {
                                return 'First name cannot be empty';
                              }
                              return null;
                            },
                          ),
                          textFieldEntry(
                              title: 'Last Name',
                              controller: _lastNameController,
                              validator: (value) {
                                if (value!.trim().isEmpty) {
                                  return 'Last name cannot be empty';
                                }
                                return null;
                              }),
                          textFieldEntry(
                            title: 'Nickname',
                            controller: _nickNameController,
                            validator: (value) {
                              const pattern = r'^[a-zA-Z0-9_]+$';
                              final regExp = RegExp(pattern);
                              if (!regExp.hasMatch(value!)) {
                                return 'The nickname may only contain the following characters: letters (a-z), digits (0-9) and underscore (_).';
                              } else if (value.trim().isEmpty) {
                                return 'Nickname cannot be empty';
                              } else if (value.length < 6) {
                                return 'Nickname must contain at least 6 characters';
                              }
                              return null;
                            },
                            onChanged: (value) {
                              if (value.length < 6 ||
                                  !RegExp(r'^[a-zA-Z0-9_]+$').hasMatch(value)) {
                                setNickNameNull();
                              } else if (value.trim().isEmpty) {
                                setNickNameNull();
                              } else if (value.length < 6) {
                                setNickNameNull();
                              } else if (value.length >= 6) {
                                checkUsername(value);
                              }
                            },
                          ),
                          const SizedBox(height: 10),
                          Container(
                            width: MediaQuery.of(context).size.width,
                            alignment: Alignment.centerLeft,
                            child: _nickNameController.text.isNotEmpty &&
                                    userEnteredNewUserName
                                ? isUsernameAvailable == null
                                    ? const SizedBox.shrink()
                                    : isUsernameAvailable!
                                        ? Container(
                                            margin: const EdgeInsets.only(
                                                bottom: 10.0, left: 10.0),
                                            child: const Text(
                                              "Nickname is available",
                                              style: TextStyle(
                                                color: Colors.green,
                                                fontWeight: FontWeight.w500,
                                              ),
                                            ),
                                          )
                                        : Container(
                                            margin: const EdgeInsets.only(
                                                bottom: 10.0, left: 10.0),
                                            child: const Text(
                                              "Nickname is not available",
                                              style: TextStyle(
                                                color: Colors.red,
                                                fontWeight: FontWeight.w500,
                                              ),
                                            ),
                                          )
                                : const SizedBox.shrink(),
                          ),
                          const SizedBox(height: 10),
                          textFieldEntry(
                            title: 'E-Mail Address',
                            controller: _emailController,
                            validator: (value) {
                              const pattern =
                                  r'^[a-zA-Z0-9.-]+@[a-zA-Z0-9-]+\.[a-zA-Z]+';
                              final regExp = RegExp(pattern);
                              if (!regExp.hasMatch(value!)) {
                                isEmailAddressAvailable = null;
                                return 'Enter a valid email';
                              } else if (value.trim().isEmpty) {
                                isEmailAddressAvailable = null;
                                return 'The email cannot be empty';
                              }
                              return null;
                            },
                            onChanged: (value) {
                              if (!RegExp(r'^[a-zA-Z0-9.-]+@[a-zA-Z0-9-]+\.[a-zA-Z]+$')
                                      .hasMatch(value) ||
                                  value.trim().isEmpty) {
                                setEmailAddressNull();
                              } else if (value.trim().isEmpty) {
                                setEmailAddressNull();
                              } else if (value.trim().isNotEmpty) {
                                checkEmail(value);
                              }
                            },
                          ),
                          const SizedBox(height: 10),
                          Container(
                            width: MediaQuery.of(context).size.width,
                            alignment: Alignment.centerLeft,
                            child: _emailController.text.isNotEmpty &&
                                    userEnteredNewEmail
                                ? isEmailAddressAvailable == null
                                    ? const SizedBox.shrink()
                                    : isEmailAddressAvailable!
                                        ? Container(
                                            margin: const EdgeInsets.only(
                                                bottom: 10.0, left: 10.0),
                                            child: const Text(
                                              "Email available.",
                                              style: TextStyle(
                                                color: Colors.green,
                                                fontWeight: FontWeight.w500,
                                              ),
                                            ),
                                          )
                                        : Container(
                                            margin: const EdgeInsets.only(
                                                bottom: 10.0, left: 10.0),
                                            child: const Text(
                                              "E-mail address has already been used in the system.",
                                              style: TextStyle(
                                                color: Colors.red,
                                                fontWeight: FontWeight.w500,
                                              ),
                                            ),
                                          )
                                : const SizedBox.shrink(),
                          ),
                          const SizedBox(height: 10),
                          textFieldEntry(
                            title: 'Website-URL',
                            controller: _websiteUrl,
                            validator: (value) {
                              const pattern =
                                  r'^(https?:\/\/)?(www\.)?([a-zA-Z0-9-]+)\.([a-zA-Z]{2,})+(\.[a-zA-Z]{2,})?$';
                              final regExp = RegExp(pattern);
                              if (!regExp.hasMatch(value!)) {
                                return 'Enter a valid website';
                              } else if (value.trim().isEmpty) {
                                return 'Website cannot be empty';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 10),
                          textFieldEntry(
                            title: 'Wordpress User-ID (CMS)',
                            controller: _wordpressCMSId,
                            isFieldActive: false,
                            validator: null,
                          ),
                          const SizedBox(height: 10),
                          textFieldEntry(
                            title: 'Phone Number',
                            isFieldActive: false,
                            controller: _phoneNumber,
                            validator: null,
                          ),
                          const SizedBox(height: 10),
                          textFieldEntry(
                            title: 'Biography / More about',
                            controller: _bioController,
                            validator: null,
                          ),
                          switchWidget('Is Premium User?', _isPremiumUser,
                              (value) {
                            toggleSwitch(value, 'premium');
                          }),
                          switchWidget('Is User Verified?', _isVerified,
                              (value) {
                            toggleSwitch(value, 'verified');
                          }),
                          switchWidget('Is User Online?', _isOnlineUser,
                              (value) {
                            toggleSwitch(value, 'isOnline');
                          }),
                          switchWidget('Activate Push for User?', _activatePush,
                              (value) {
                            toggleSwitch(value, 'activatePush');
                          }),
                          const SizedBox(height: 10),
                          awardsShowcaseWidget(currentUser!.awardsModel!),
                          coursesShowWidget(currentUser!.coursesModel!),
                          loadInvitedUserWidget(),
                          loadTotalInvitedUser(),
                          userCreated(currentUser!.createdAt!),
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
                                backgroundColor: kPrimaryColor,
                              ),
                              child: const Text('Save'),
                            ),
                          )
                        ],
                      ),
                    ),
                  ),
      ),
    );
  }

  Widget textFieldEntry({
    required String title,
    bool isFieldActive = true,
    required TextEditingController controller,
    required String? Function(String?)? validator,
    Function(String)? onChanged,
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
          autovalidateMode: AutovalidateMode.onUserInteraction,
          validator: validator,
          enabled: isFieldActive,
          onChanged: (value) {
            if (controller == _nickNameController) {
              if (!RegExp(r'^[a-zA-Z0-9_]+$').hasMatch(value) ||
                  value.trim().isEmpty) {
                setNickNameNull();
              } else if (value != initialUsername) {
                userEnteredNewUserName = true;
                checkUsername(value);
              } else {
                userEnteredNewUserName = false;
                setState(() {
                  isUsernameAvailable = true;
                });
              }
            } else if (controller == _emailController) {
              if (!RegExp(r'^[a-zA-Z0-9.-]+@[a-zA-Z0-9-]+\.[a-zA-Z]+$')
                      .hasMatch(value) ||
                  value.trim().isEmpty) {
                setEmailAddressNull();
              } else if (value != initialEmailAddress) {
                userEnteredNewEmail = true;
                checkEmail(value);
              } else {
                userEnteredNewEmail = false;
                setState(() {
                  isEmailAddressAvailable = true;
                });
              }
            }
            onChanged?.call(value);
          },
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

  String getUserCreatedDate({
    required int timestamp,
    bool isInvitedSection = false,
  }) {
    tz.initializeTimeZones();
    final berlin = tz.getLocation('Europe/Berlin');

    final berlinTime =
        tz.TZDateTime.fromMillisecondsSinceEpoch(berlin, timestamp);
    final formatter = DateFormat('d.M.y H:m:s');
    final berlinFormatted = formatter.format(berlinTime);
    if (isInvitedSection) {
      return berlinFormatted;
    } else {
      return 'User created at: $berlinFormatted (Berlin)';
    }
  }

  Widget userCreated(String createdAt) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 30),
      width: MediaQuery.of(context).size.width,
      child: Text(
        getUserCreatedDate(timestamp: int.parse(createdAt)),
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
              'User was invited to the app by',
              style: TextStyle(fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 10),
            userProvider.invitedByUser == null
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
                    leading: userProvider.invitedByUser!.profilePic == null
                        ? Container(
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
                          )
                        : CachedNetworkImage(
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
                      '${userProvider.invitedByUser!.nickname} • ${userProvider.invitedByUser!.phoneNumber}',
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

  Widget loadTotalInvitedUser() {
    return Container(
        width: MediaQuery.of(context).size.width,
        margin: const EdgeInsets.only(top: 20, bottom: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'User\'s Invitation',
              style: TextStyle(fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 10),
            RichText(
              text: TextSpan(
                children: [
                  const TextSpan(
                    text:
                        'The user can invite new members to the app with their individual invitation code: ',
                    style: TextStyle(
                      color: Colors.black87,
                      fontFamily: 'Poppins',
                    ),
                  ),
                  TextSpan(
                    text: userProvider.currentUserUniqueCode,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                      fontFamily: 'Poppins',
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10),
            FutureBuilder<Map<String, dynamic>>(
              future: userProvider.getInvitedUsers(currentUser!.userId!),
              builder: (context, snapshot) {
                if (snapshot.hasData && snapshot.data!.isNotEmpty) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: double.infinity,
                        height: 250,
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey, width: 1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        margin: const EdgeInsets.symmetric(vertical: 10),
                        child: SingleChildScrollView(
                          padding: const EdgeInsets.only(top: 10, left: 10),
                          scrollDirection: Axis.vertical,
                          child: Wrap(
                              direction: Axis.horizontal,
                              children: snapshot.data!.entries.map((e) {
                                final value = e.value;
                                return ListTile(
                                  leading: CachedNetworkImage(
                                    imageUrl: value['profilePic'],
                                    placeholder: (context, url) {
                                      return Container(
                                        height: 60,
                                        width: 60,
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          color: Colors.grey[300],
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
                                        height: 60,
                                        width: 60,
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          color: Colors.grey[300],
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
                                    '@${value['nickname']}\nAccepted at: ${getUserCreatedDate(
                                      timestamp: int.parse(value['acceptedAt']),
                                      isInvitedSection: true,
                                    )}',
                                  ),
                                  title: SelectableText(
                                    '${value['firstName']} ${value['lastName']}',
                                    style: const TextStyle(
                                        fontWeight: FontWeight.w600),
                                  ),
                                );
                              }).toList()),
                        ),
                      )
                    ],
                  );
                } else if (snapshot.hasData && snapshot.data!.isEmpty) {
                  return const Text(
                    'No user used your ref-code for registration',
                    style: TextStyle(
                      fontWeight: FontWeight.w400,
                      color: Colors.grey,
                    ),
                  );
                }
                return const Center(
                  child: CircularProgressIndicator(color: kPrimaryColor),
                );
              },
            ),
          ],
        ));
  }

  // submitting data
  void submitData() async {
    if (isUsernameAvailable != null && isUsernameAvailable == false) {
      showSnackbar(context, 'Please select a valid nickname');
    } else if (isEmailAddressAvailable != null &&
        isEmailAddressAvailable == false) {
      showSnackbar(context, 'Please select a valid email');
    } else if (userProvider.invitedByUser != null && !_isVerified) {
      showSnackbar(
        context,
        'Please check isVerified toggle to add/remove invited by user.',
      );
    } else if (_formkey.currentState!.validate()) {
      UserModel userModelLatest = UserModel(
        userId: widget.userId,
        firstName: _firstNameController.text.trim(),
        lastName: _lastNameController.text.trim(),
        nickname: _nickNameController.text.trim(),
        awardsModel: userProvider.selectedUserAwards,
        coursesModel: userProvider.selectedCourses,
        email: _emailController.text.trim(),
        bio: _bioController.text.trim(),
        isPremiumUser: _isPremiumUser,
        isVerified: _isVerified,
        invitedBy: userProvider.invitedByUser != null
            ? userProvider.invitedByUser!.userId
            : '',
        invitedTimestamp: userProvider.invitedByUser != null
            ? DateTime.now().millisecondsSinceEpoch.toString()
            : '',
        phoneNumber: _phoneNumber.text.trim(),
        websiteUrl: _websiteUrl.text.trim(),
        isOnline: _isOnlineUser,
        wordpressCMSuserId: _wordpressCMSId.text.trim().isNotEmpty
            ? int.parse(_wordpressCMSId.text.trim())
            : null,
      );
      await userProvider
          .updateUserData(
        userModel: userModelLatest,
        activatePush: _activatePush,
        imageFile: _imageFile,
        pendingUsersProvider: pendingUserProvider,
      )
          .whenComplete(() {
        showSnackbar(context, 'User data updated successfully');
        widget.onSaved();
        Navigator.of(context).pop();
      });
    } else {
      showSnackbar(context, 'Please check all fields');
    }
  }
}
