import 'package:dellenhauer_admin/providers/admin_provider.dart';
import 'package:dellenhauer_admin/utils/colors.dart';
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
  final _formKey = GlobalKey<FormState>();
  final _passwordController = TextEditingController();
  final _emailController = TextEditingController();
  late AdminDataProvider adminDataProvider;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    adminDataProvider = Provider.of<AdminDataProvider>(
      context,
      listen: true,
    );
    return Scaffold(
      backgroundColor: Colors.grey[200],
      body: Center(
          child: Container(
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
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
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
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 30),
              TextFormField(
                controller: _emailController,
                obscureText: false,
                cursorColor: kPrimaryColor,
                decoration: inputDecoration(
                  'Enter email',
                  'Email',
                  _emailController,
                ),
                onChanged: (_) {
                  setState(() {});
                },
                validator: (String? value) {
                  final pattern =
                      RegExp(r'^[a-zA-Z0-9.-]+@[a-zA-Z0-9-]+\.[a-zA-Z]+');

                  if (value != null && value.trim().isEmpty) {
                    return 'Email cannot be empty';
                  } else if (value != null &&
                      value.isNotEmpty &&
                      !pattern.hasMatch(value)) {
                    return 'Invalid email address';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _passwordController,
                obscureText: true,
                cursorColor: kPrimaryColor,
                decoration: inputDecoration(
                  'Enter password',
                  'Password',
                  _passwordController,
                ),
                validator: (String? value) {
                  if (value != null && value.trim().isEmpty) {
                    return 'Password cannot be empty';
                  } else if (value != null &&
                      value.isNotEmpty &&
                      value.length < 4) {
                    return 'Password cannot be less than 4 characters';
                  }
                  return null;
                },
                onChanged: (_) {
                  setState(() {});
                },
              ),
              const SizedBox(height: 30),
              Container(
                height: 45,
                width: 200,
                decoration: BoxDecoration(
                  color: kPrimaryColor,
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
                  onPressed: handleSignIn,
                  child: adminDataProvider.isLoading
                      ? const CupertinoActivityIndicator(
                          color: Colors.white,
                        )
                      : const Text(
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
        ),
      )),
    );
  }

  Future<void> handleSignIn() async {
    if (_formKey.currentState != null &&
        _formKey.currentState!.validate() &&
        !adminDataProvider.isLoading) {
      await adminDataProvider.signInAdmin(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );
    }
  }
}
