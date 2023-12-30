// auth_provider.dart

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthProvider with ChangeNotifier {
  bool _isLoggedIn = false;
  String _firstName = '';
  String _userId = '';

  bool get isLoggedIn => _isLoggedIn;

  String get firstName => _firstName;

  String get userId => _userId;

  AuthProvider() {
    // Check for saved user information on app startup
    _loadUserInformation();
  }

  Future<void> _loadUserInformation() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    _isLoggedIn = prefs.getBool('isLoggedIn') ?? false;
    _firstName = prefs.getString('firstName') ?? '';
    _userId = prefs.getString('userId') ?? '';

    notifyListeners();
  }

  // Login method with SharedPreferences
  Future<void> login(String firstName, String userId) async {
    _isLoggedIn = true;
    _firstName = firstName;
    _userId = userId;


    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setBool('isLoggedIn', _isLoggedIn);
    prefs.setString('firstName', _firstName);
    prefs.setString('userId', _userId);

    notifyListeners();
  }

  // Logout method with SharedPreferences
  Future<void> logout() async {
    _isLoggedIn = false;
    _firstName = '';
    _userId = '';


    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.remove('isLoggedIn');
    prefs.remove('firstName');
    prefs.remove('userId');

    notifyListeners();
  }
}
