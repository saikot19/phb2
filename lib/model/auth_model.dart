import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthModel with ChangeNotifier {
  String? userCode;
  bool _isLoading = true;

  bool get isLoading => _isLoading;

  Future<void> checkLoginStatus() async {
    _isLoading = true;
    notifyListeners();

    SharedPreferences prefs = await SharedPreferences.getInstance();
    userCode = prefs.getString("userCode");

    _isLoading = false;
    notifyListeners();
  }

  bool isLoggedIn() {
    return userCode != null && userCode!.isNotEmpty;
  }

  Future<void> logout() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove('userCode');
    userCode = null;
    notifyListeners();
  }
}
