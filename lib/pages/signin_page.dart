import 'package:dellenhauer_admin/pages/home_page.dart';
import 'package:dellenhauer_admin/providers/admin_provider.dart';
import 'package:dellenhauer_admin/utils/styles.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class SignInPage extends StatefulWidget {
  const SignInPage({super.key});

  @override
  State<SignInPage> createState() => _SignInPageState();
}

class _SignInPageState extends State<SignInPage> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _passwordController = TextEditingController();
  String? password;

  @override
  void dispose() {
    super.dispose();
    _passwordController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final adminProvider =
        Provider.of<AdminDataProvider>(context, listen: false);

    return Scaffold(
      backgroundColor: Colors.grey[200],
      body: Center(
          child: Container(
        height: 400,
        width: 600,
        padding: const EdgeInsets.all(30),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(0),
          boxShadow: [
            BoxShadow(
              color: Colors.grey[300]!,
              blurRadius: 10,
              offset: const Offset(3, 3),
            )
          ],
        ),
        child: Column(
          children: [
            const SizedBox(height: 50),
            const Text(
              'Dellenhauer Admin',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 10),
            const Text(
              'Enter the admin password to login',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w300,
              ),
            ),
            const SizedBox(height: 50),
            Padding(
              padding: const EdgeInsets.only(left: 40, right: 40),
              child: Form(
                key: _formKey,
                child: TextFormField(
                  controller: _passwordController,
                  obscureText: true,
                  cursorColor: Colors.redAccent,
                  decoration: inputDecoration(
                      'Enter password', 'Password', _passwordController),
                  validator: (String? value) {
                    String? adminPassword = adminProvider.adminPassword;
                    if (value!.isEmpty) {
                      return 'Password cannot be empty';
                    } else if (value != adminPassword) {
                      return 'Wrong Password! Please try again';
                    } else {
                      return null;
                    }
                  },
                  onChanged: (String? value) {
                    setState(() {
                      password = value;
                    });
                  },
                ),
              ),
            ),
            const SizedBox(height: 30),
            Container(
              height: 45,
              width: 200,
              decoration: BoxDecoration(
                color: Colors.red,
                borderRadius: BorderRadius.circular(30),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey[400]!,
                    blurRadius: 10,
                    offset: const Offset(2, 2),
                  ),
                ],
              ),
              child: TextButton(
                onPressed: () {
                  handleSignIn();
                },
                child: const Text(
                  'Sign In',
                  style: TextStyle(
                    fontWeight: FontWeight.w400,
                    color: Colors.white,
                    fontSize: 16,
                  ),
                ),
              ),
            ),
          ],
        ),
      )),
    );
  }

  Future<void> handleSignIn() async {
    final adminprovider =
        Provider.of<AdminDataProvider>(context, listen: false);
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      await adminprovider.setSignIN().then((value) => Navigator.pushReplacement(
          context, CupertinoPageRoute(builder: (context) => const HomePage())));
    }
  }
}
