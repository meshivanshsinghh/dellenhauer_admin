import 'package:dellenhauer_admin/pages/settings/admin_password_change.dart';
import 'package:dellenhauer_admin/pages/settings/blocked_numbers.dart';
import 'package:dellenhauer_admin/utils/colors.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final TextEditingController oldPasswordController = TextEditingController();
  final TextEditingController newPasswordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.of(context).size.width;

    return Container(
      margin: const EdgeInsets.only(left: 30, right: 30, top: 30),
      padding: EdgeInsets.only(
        left: w * 0.05,
        right: w * 0.20,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: <BoxShadow>[
          BoxShadow(
              color: Colors.grey[300]!,
              blurRadius: 10,
              offset: const Offset(3, 3))
        ],
      ),
      child: Container(
        alignment: Alignment.centerLeft,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              height: MediaQuery.of(context).size.height * 0.05,
            ),
            const Text(
              "Settings Screen",
              style: TextStyle(fontSize: 25, fontWeight: FontWeight.w800),
            ),
            Container(
              margin: const EdgeInsets.only(top: 5, bottom: 10),
              height: 3,
              width: 50,
              decoration: BoxDecoration(
                  color: kPrimaryColor,
                  borderRadius: BorderRadius.circular(15)),
            ),
            const SizedBox(
              height: 30,
            ),
            buildItem(
              'Change Login Password',
              FontAwesomeIcons.lock,
              () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const AdminPasswordChange(),
                  ),
                );
              },
            ),
            buildItem(
              'Blocked Numbers',
              FontAwesomeIcons.phone,
              () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const BlockedNumbers(),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget buildItem(
    String title,
    IconData icon,
    Function onPressed,
  ) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () {
        onPressed();
      },
      child: Container(
        margin: const EdgeInsets.only(top: 10, bottom: 10),
        padding: const EdgeInsets.all(15),
        height: 100,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey[200]!),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 20,
              color: kPrimaryColor,
            ),
            const SizedBox(width: 30),
            Text(title),
            const Spacer(),
            const Icon(
              FontAwesomeIcons.arrowRight,
              size: 20,
              color: kPrimaryColor,
            ),
          ],
        ),
      ),
    );
  }
}
