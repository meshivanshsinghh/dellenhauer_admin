import 'package:dellenhauer_admin/pages/push_notification/push_notification_provider.dart';
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
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_web_plugins/flutter_web_plugins.dart';
import 'package:provider/provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: const FirebaseOptions(
      apiKey: "AIzaSyBW5QMvs76hSmLz6XkhF87G_Badzom-67o",
      appId: "1:337585374916:web:925d5442d2f8c7bfb5eb91",
      messagingSenderId: "337585374916",
      projectId: "dellenhauer-eae5f",
    ),
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
        ChangeNotifierProvider<PushNotificationProvider>(
            create: (_) => PushNotificationProvider()),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        scrollBehavior: TouchAndMouseScrollbehaviour(),
        theme: ThemeData(
          fontFamily: 'Poppins',
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
        ),
        home: const AppLogic(),
      ),
    );
  }
}

class AppLogic extends StatelessWidget {
  const AppLogic({super.key});

  @override
  Widget build(BuildContext context) {
    final ap = context.watch<AdminDataProvider>();
    return ap.isSignedIn == true ? const HomePage() : const SignInPage();
  }
}

class TouchAndMouseScrollbehaviour extends MaterialScrollBehavior {
  @override
  Set<PointerDeviceKind> get dragDevices => {
        PointerDeviceKind.touch,
        PointerDeviceKind.mouse,
      };
}
