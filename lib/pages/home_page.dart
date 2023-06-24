import 'package:dellenhauer_admin/pages/awards/awards_screen.dart';
import 'package:dellenhauer_admin/pages/channels/channels_screen.dart';
import 'package:dellenhauer_admin/pages/courses/courses_screen.dart';
import 'package:dellenhauer_admin/pages/overview/overview_screen.dart';
import 'package:dellenhauer_admin/pages/pending_users/pending_users.dart';
import 'package:dellenhauer_admin/pages/push_notification/logs/push_notification_logs.dart';
import 'package:dellenhauer_admin/pages/push_notification/push_notitification_main.dart';
import 'package:dellenhauer_admin/pages/requests/requests_screen.dart';
import 'package:dellenhauer_admin/pages/services/services_screen.dart';
import 'package:dellenhauer_admin/pages/settings/settings_screen.dart';
import 'package:dellenhauer_admin/pages/signin_page.dart';
import 'package:dellenhauer_admin/pages/users/users_screen.dart';
import 'package:dellenhauer_admin/utils/colors.dart';
import 'package:dellenhauer_admin/utils/nextscreen.dart';
import 'package:dellenhauer_admin/utils/widgets/verticaltabs.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int pageIndex = 0;

  final icons = [
    FontAwesomeIcons.chartPie,
    FontAwesomeIcons.peopleGroup,
    FontAwesomeIcons.solidUser,
    FontAwesomeIcons.userPlus,
    FontAwesomeIcons.solidBell,
    FontAwesomeIcons.clockRotateLeft,
    FontAwesomeIcons.userPlus,
    FontAwesomeIcons.briefcase,
    FontAwesomeIcons.book,
    FontAwesomeIcons.trophy,
    FontAwesomeIcons.gear,
  ];
  final titles = [
    'Overview',
    'Channels',
    'Users',
    'Pending Users',
    'Push Notifications',
    'Notification Logs',
    'Requests',
    'Services',
    'Courses',
    'Awards',
    'Settings',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: _appBar() as PreferredSizeWidget,
        body: SafeArea(
          child: Column(
            children: [
              Expanded(
                child: Container(
                  color: Colors.white,
                  child: VerticalTabs(
                    tabBackgroundColor: Colors.white,
                    backgroundColor: Colors.grey[200],
                    tabsElevation: 0.5,
                    tabsShadowColor: Colors.grey[500],
                    tabsWidth: 200,
                    indicatorColor: kPrimaryColor,
                    selectedTabBackgroundColor: kPrimaryColor.withOpacity(0.1),
                    indicatorWidth: 5,
                    disabledChangePageFromContentView: true,
                    initialIndex: pageIndex,
                    changePageDuration: const Duration(milliseconds: 1),
                    tabs: [
                      tab(titles[0], icons[0]) as Tab,
                      tab(titles[1], icons[1]) as Tab,
                      tab(titles[2], icons[2]) as Tab,
                      tab(titles[3], icons[3]) as Tab,
                      tab(titles[4], icons[4]) as Tab,
                      tab(titles[5], icons[5]) as Tab,
                      tab(titles[6], icons[6]) as Tab,
                      tab(titles[7], icons[7]) as Tab,
                      tab(titles[8], icons[8]) as Tab,
                      tab(titles[9], icons[9]) as Tab,
                      tab(titles[10], icons[10]) as Tab,
                    ],
                    contents: const [
                      PushNotificationMain(),
                      OverviewScreen(),
                      ChannelsScreen(),
                      UserScreen(),
                      PendingUsers(),
                      PushNotificationLogsScreen(),
                      RequestsScreenList(),
                      ServicesScreen(),
                      CoursesScreen(),
                      AwardsScreen(),
                      SettingsScreen(),
                    ],
                  ),
                ),
              )
            ],
          ),
        ));
  }

  // tab
  Widget tab(String title, IconData icon) {
    return Tab(
      child: Container(
        padding: const EdgeInsets.only(left: 10),
        height: 45,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Icon(icon, size: 20, color: Colors.grey[800]),
            const SizedBox(width: 10),
            Text(
              title,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[900],
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // app bar
  Widget _appBar() {
    return PreferredSize(
        preferredSize: const Size.fromHeight(80),
        child: Container(
          height: 60,
          padding: const EdgeInsets.only(left: 20, right: 20),
          decoration: BoxDecoration(color: Colors.white, boxShadow: [
            BoxShadow(
              color: Colors.grey[300]!,
              blurRadius: 10,
              offset: const Offset(0, 5),
            ),
          ]),
          child: Row(
            children: [
              RichText(
                text: TextSpan(
                  text: '#DELLENHAUER',
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: kPrimaryColor,
                  ),
                  children: [
                    TextSpan(
                      text: "  App - Backend Software",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w400,
                        color: Colors.grey[800],
                      ),
                    ),
                  ],
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.only(
                    left: 15, right: 15, top: 5, bottom: 5),
                decoration: BoxDecoration(
                  color: kPrimaryColor,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey[400]!,
                      blurRadius: 2,
                      offset: const Offset(0, 0),
                    )
                  ],
                ),
                child: TextButton.icon(
                  onPressed: handleLogout,
                  icon: const Icon(Icons.logout, color: Colors.white),
                  label: const Text(
                    'Logout',
                    style: TextStyle(
                      fontWeight: FontWeight.w400,
                      color: Colors.white,
                      fontSize: 16,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Container(
                margin: const EdgeInsets.all(5),
                padding: const EdgeInsets.only(left: 10, right: 20),
                decoration: BoxDecoration(
                  border: Border.all(color: kPrimaryColor),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: TextButton.icon(
                  onPressed: () {},
                  icon: Icon(Icons.account_circle,
                      color: Colors.grey[800], size: 20),
                  label: const Text(
                    'Signed as admin',
                    style: TextStyle(
                      fontWeight: FontWeight.w400,
                      color: kPrimaryColor,
                      fontSize: 16,
                    ),
                  ),
                ),
              )
            ],
          ),
        ));
  }

  Future handleLogout() async {
    final SharedPreferences s = await SharedPreferences.getInstance();
    await s
        .clear()
        .then((value) => {nextScreenCloseOther(context, const SignInPage())});
  }
}
