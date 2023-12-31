import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthProvider with ChangeNotifier {
  bool _isLoggedIn = false;
  String _firstName = '';
  String _userId = '';
  String _email = '';
  String _profileImage = '';
  bool _isDarkMode = false;

  bool get isLoggedIn => _isLoggedIn;
  String get firstName => _firstName;
  String get userId => _userId;
  String get email => _email;
  String get profileImage => _profileImage;
  bool get isDarkMode => _isDarkMode;

  AuthProvider() {
    _loadUserInformation();
    _loadDarkModeSetting();
  }

  Future<void> _loadUserInformation() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    _isLoggedIn = prefs.getBool('isLoggedIn') ?? false;
    _firstName = prefs.getString('firstName') ?? '';
    _userId = prefs.getString('userId') ?? '';
    _email = prefs.getString('email') ?? '';
    _profileImage = prefs.getString('profileImage') ?? '';

    notifyListeners();
  }

  Future<void> _loadDarkModeSetting() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    _isDarkMode = prefs.getBool('isDarkMode') ?? false;
    notifyListeners();
  }

  Future<void> _saveDarkModeSetting(bool value) async {
    _isDarkMode = value;
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setBool('isDarkMode', _isDarkMode);
    notifyListeners();
  }

  Future<void> login(String firstName, String userId, String email, String profileImage) async {
    _isLoggedIn = true;
    _firstName = firstName;
    _userId = userId;
    _email = email;
    _profileImage = profileImage;

    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setBool('isLoggedIn', _isLoggedIn);
    prefs.setString('firstName', _firstName);
    prefs.setString('userId', _userId);
    prefs.setString('email', _email);
    prefs.setString('profileImage', _profileImage);

    notifyListeners();
  }

  Future<void> logout() async {
    _isLoggedIn = false;
    _firstName = '';
    _userId = '';
    _email = '';
    _profileImage = '';

    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.remove('isLoggedIn');
    prefs.remove('firstName');
    prefs.remove('userId');
    prefs.remove('email');
    prefs.remove('profileImage');

    notifyListeners();
  }

  Future<void> toggleDarkMode(bool value) async {
    await _saveDarkModeSetting(value);
  }
}
