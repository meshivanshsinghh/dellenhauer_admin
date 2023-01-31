import 'package:dellenhauer_admin/pages/channels/channels_screen.dart';
import 'package:dellenhauer_admin/pages/overview/overview_screen.dart';
import 'package:dellenhauer_admin/pages/push_notification/push_notification_screen.dart';
import 'package:dellenhauer_admin/pages/requests/requests_screen.dart';
import 'package:dellenhauer_admin/pages/services/services_screen.dart';
import 'package:dellenhauer_admin/pages/settings/settings_screen.dart';
import 'package:dellenhauer_admin/pages/signin_page.dart';
import 'package:dellenhauer_admin/pages/users/users_screen.dart';
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
    FontAwesomeIcons.solidBell,
    FontAwesomeIcons.userPlus,
    FontAwesomeIcons.briefcase,
    FontAwesomeIcons.gear,
  ];
  final titles = [
    'Overview',
    'Channels',
    'Users',
    'Push Notifications',
    'Requests',
    'Services',
    'Settings'
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
                    indicatorColor: Colors.red,
                    selectedTabBackgroundColor: Colors.red.withOpacity(0.1),
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
                    ],
                    contents: const [
                      OverviewScreen(),
                      ChannelsScreen(),
                      UserScreen(),
                      PushNotificationScreen(),
                      RequestsScreenList(),
                      ServicesScreen(),
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
                  text: 'Dellenhauer',
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: Colors.red,
                  ),
                  children: [
                    TextSpan(
                      text: " - Admin Panel",
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
                  color: Colors.red,
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
                  border: Border.all(color: Colors.red),
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
                      color: Colors.red,
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
