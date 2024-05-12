import 'dart:async';

import 'package:dellenhauer_admin/pages/settings/settings_provider.dart';
import 'package:dellenhauer_admin/providers/admin_provider.dart';
import 'package:dellenhauer_admin/utils/colors.dart';
import 'package:dellenhauer_admin/utils/styles.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class AdminPasswordChange extends StatefulWidget {
  const AdminPasswordChange({super.key});

  @override
  State<AdminPasswordChange> createState() => _AdminPasswordChangeState();
}

class _AdminPasswordChangeState extends State<AdminPasswordChange> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _oldPasswordController = TextEditingController();
  final TextEditingController _newPasswordController = TextEditingController();
  late AdminDataProvider adminDataProvider;
  late SettingsProvider settingsProvider;
  @override
  void initState() {
    super.initState();
    Future.delayed(Duration.zero, () {
      adminDataProvider =
          Provider.of<AdminDataProvider>(context, listen: false);
      // adminDataProvider.getAdminPassword();
    });
  }

  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.of(context).size.width;
    adminDataProvider = Provider.of<AdminDataProvider>(context, listen: true);
    settingsProvider = Provider.of<SettingsProvider>(context, listen: true);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        centerTitle: true,
        title: const Text('Change Login Password'),
        elevation: 0,
      ),
      body: Container(
        width: MediaQuery.of(context).size.width,
        margin: const EdgeInsets.only(left: 30, right: 30, top: 30, bottom: 30),
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
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(height: MediaQuery.of(context).size.height * 0.05),
            Form(
              key: _formKey,
              child: Column(
                children: [
                  TextFormField(
                    cursorColor: kPrimaryColor,
                    controller: _oldPasswordController,
                    decoration: inputDecoration(
                      'Enter old password',
                      'Old Password',
                      _oldPasswordController,
                    ),
                  ),
                  TextFormField(
                    cursorColor: kPrimaryColor,
                    controller: _newPasswordController,
                    decoration: inputDecoration(
                      'Enter new password',
                      'New Password',
                      _newPasswordController,
                    ),
                  ),
                  Container(
                    width: MediaQuery.of(context).size.width,
                    color: kPrimaryColor,
                    height: 45,
                    child: TextButton(
                      child: settingsProvider.isLoading
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                              ),
                            )
                          : const Text(
                              'Update Password',
                              style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600),
                            ),
                      onPressed: () async {
                        // if (_oldPasswordController.text.trim() !=
                        //     adminDataProvider.adminPassword!.trim()) {
                        //   showSnackbar(
                        //     context,
                        //     'Wrong old-password entered. Please enter correct password to update',
                        //   );
                        //   settingsProvider.setLoading(false);
                        // } else if (_oldPasswordController.text.trim() ==
                        //         adminDataProvider.adminPassword!.trim() &&
                        //     _newPasswordController.text.trim().isNotEmpty) {
                        //   settingsProvider.setLoading(true);
                        //   settingsProvider
                        //       .updateAdminPassword(
                        //         _newPasswordController.text.trim(),
                        //       )
                        //       .then((value) =>
                        //           adminDataProvider.getAdminPassword())
                        //       .whenComplete(() {
                        //     showSnackbar(
                        //       context,
                        //       'Password changed successfully',
                        //     );
                        //     Timer(
                        //       const Duration(milliseconds: 400),
                        //       () => Navigator.of(context).pop(),
                        //     );
                        //   });
                        // } else if (_oldPasswordController.text.trim() ==
                        //         adminDataProvider.adminPassword!.trim() &&
                        //     _newPasswordController.text.trim().isEmpty) {
                        //   showSnackbar(context, 'Please enter new password');
                        // } else {
                        //   showSnackbar(context, 'Unexpected error!');
                        // }
                      },
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
