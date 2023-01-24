import 'package:flutter/material.dart';

class AdminDataProvider extends ChangeNotifier {
  bool _isSignedIn = false;
  bool get isSignedIn => _isSignedIn;
}
