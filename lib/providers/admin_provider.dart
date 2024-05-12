import 'package:dellenhauer_admin/main.dart';
import 'package:dellenhauer_admin/pages/home_page.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AdminDataProvider extends ChangeNotifier {
  final _firebaseAuth = FirebaseAuth.instance;
  bool _isSignedIn = false;
  bool get isSignedIn => _isSignedIn;
  bool _isLoading = false;
  bool get isLoading => _isLoading;
  String? _adminPassword;
  String? get adminPassword => _adminPassword;

  AdminDataProvider() {
    checkSignIn();
  }

  // check sign in
  void checkSignIn() async {
    final SharedPreferences sf = await SharedPreferences.getInstance();
    _isSignedIn = sf.getBool('signed_in') ?? false;
    notifyListeners();
  }

  // set sign in
  Future setSignIN() async {
    final SharedPreferences sf = await SharedPreferences.getInstance();
    sf.setBool('signed_in', true);
    _isSignedIn = true;
    notifyListeners();
  }

  Future<void> signInAdmin({
    required String password,
    required String email,
  }) async {
    setLoading(true);
    try {
      UserCredential user = await _firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      if (user.user != null) {
        await setSignIN();
        Navigator.pushReplacement(
          mainNavigatorKey.currentContext!,
          CupertinoPageRoute(
            builder: (context) => const HomePage(),
          ),
        );
      }
    } catch (e) {
      debugPrint(e.toString());
    } finally {
      setLoading(false);
    }
  }

  void setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }
}
