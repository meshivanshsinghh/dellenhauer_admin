import 'package:dellenhauer_admin/constants.dart';
import 'package:dellenhauer_admin/pages/new_channel_requests/new_channel_requests_provider.dart';
import 'package:dellenhauer_admin/pages/pending_users/pending_users_provider.dart';
import 'package:dellenhauer_admin/pages/push_notification/push_notification_logs_provider.dart';
import 'package:dellenhauer_admin/pages/push_notification/push_notification_main_provider.dart';
import 'package:dellenhauer_admin/pages/settings/settings_provider.dart';
import 'package:dellenhauer_admin/providers/awards_provider.dart';
import 'package:dellenhauer_admin/providers/channels_provider.dart';
import 'package:dellenhauer_admin/providers/courses_provider.dart';
import 'package:dellenhauer_admin/pages/home_page.dart';
import 'package:dellenhauer_admin/providers/overview_provider.dart';
import 'package:dellenhauer_admin/providers/requests_provider.dart';
import 'package:dellenhauer_admin/providers/services_provider.dart';
import 'package:dellenhauer_admin/pages/signin_page.dart';
import 'package:dellenhauer_admin/providers/admin_provider.dart';
import 'package:dellenhauer_admin/providers/users_provider.dart';
import 'package:dellenhauer_admin/utils/colors.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_web_plugins/flutter_web_plugins.dart';
import 'package:provider/provider.dart';

final mainNavigatorKey = GlobalKey<NavigatorState>();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: AppConstants.firebaseOptions,
  );
  setUrlStrategy(PathUrlStrategy());
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<AdminDataProvider>(
            create: (_) => AdminDataProvider()),
        ChangeNotifierProvider<OverviewProvider>(
            create: (_) => OverviewProvider()),
        ChangeNotifierProvider<RequestsProvider>(
            create: (_) => RequestsProvider()),
        ChangeNotifierProvider<ChannelProvider>(
            create: (_) => ChannelProvider()),
        ChangeNotifierProvider<ServicesProvider>(
            create: (_) => ServicesProvider()),
        ChangeNotifierProvider<CoursesProvider>(
            create: (_) => CoursesProvider()),
        ChangeNotifierProvider<AwardsProvider>(create: (_) => AwardsProvider()),
        ChangeNotifierProvider<UsersProvider>(create: (_) => UsersProvider()),
        ChangeNotifierProvider<PushNotificationLogsProvider>(
            create: (_) => PushNotificationLogsProvider()),
        ChangeNotifierProvider<PushNotificationMainProvider>(
            create: (_) => PushNotificationMainProvider()),
        ChangeNotifierProvider<PendingUsersProvider>(
            create: (_) => PendingUsersProvider()),
        ChangeNotifierProvider<NewChannelRequestsProvider>(
            create: (_) => NewChannelRequestsProvider()),
        ChangeNotifierProvider<SettingsProvider>(
            create: (_) => SettingsProvider()),
      ],
      child: Builder(builder: (context) {
        return MaterialApp(
          navigatorKey: mainNavigatorKey,
          debugShowCheckedModeBanner: false,
          scrollBehavior: TouchAndMouseScrollbehaviour(),
          theme: ThemeData(
            useMaterial3: false,
            fontFamily: 'Poppins',
            primaryColor: kPrimaryColor,
            appBarTheme: AppBarTheme(
              color: Colors.white,
              titleTextStyle: TextStyle(
                  color: Colors.grey[900],
                  fontWeight: FontWeight.w600,
                  fontSize: 18,
                  fontFamily: 'Poppins'),
              elevation: 0,
              actionsIconTheme: IconThemeData(color: Colors.grey[900]),
              iconTheme: IconThemeData(color: Colors.grey[900]),
            ),
            inputDecorationTheme: const InputDecorationTheme(
              border: OutlineInputBorder(
                borderSide: BorderSide(color: kPrimaryColor),
              ),
            ),
          ),
          home: context.watch<AdminDataProvider>().isSignedIn
              ? const HomePage()
              : const SignInPage(),
        );
      }),
    );
  }
}

class TouchAndMouseScrollbehaviour extends MaterialScrollBehavior {
  @override
  Set<PointerDeviceKind> get dragDevices => {
        PointerDeviceKind.touch,
        PointerDeviceKind.mouse,
      };
}
