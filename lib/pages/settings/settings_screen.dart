import 'package:dellenhauer_admin/utils/colors.dart';
import 'package:dellenhauer_admin/utils/styles.dart';
import 'package:flutter/material.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
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
                  "Change Admin Password",
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
                  height: 60,
                ),
                Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      TextFormField(
                        controller: oldPasswordController,
                        decoration: inputDecoration('Enter old password',
                            'Old Password', oldPasswordController),
                      ),
                      const SizedBox(
                        height: 30,
                      ),
                      TextFormField(
                        controller: newPasswordController,
                        decoration: inputDecoration('Enter new password',
                            'New Password', newPasswordController),
                        obscureText: true,
                      ),
                      const SizedBox(
                        height: 100,
                      ),
                      Container(
                          width: MediaQuery.of(context).size.width,
                          color: kPrimaryColor,
                          height: 45,
                          child: TextButton(
                              child: const Text(
                                'Update Password',
                                style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600),
                              ),
                              onPressed: () async {})),
                    ],
                  ),
                )
              ],
            )));
  }
}
