import 'package:flutter/material.dart';
import 'dart:io';

class UserService extends ChangeNotifier {
  static final UserService _instance = UserService._internal();
  factory UserService() => _instance;
  UserService._internal();

  String _userName = '';
  String _userEmail = '';
  File? _avatarImage;
  String? _avatarUrl;

  String get userName => _userName;
  String get userEmail => _userEmail;
  File? get avatarImage => _avatarImage;
  String? get avatarUrl => _avatarUrl;

  void updateUserInfo({
    String? name,
    String? email,
    File? avatarImage,
    String? avatarUrl,
  }) {
    if (name != null) _userName = name;
    if (email != null) _userEmail = email;
    if (avatarImage != null) _avatarImage = avatarImage;
    if (avatarUrl != null) _avatarUrl = avatarUrl;
    notifyListeners();
  }

  // Initialize user data from registration
  void initializeUser(String firstName, String lastName, String email) {
    _userName = '$firstName $lastName';
    _userEmail = email;
    notifyListeners();
  }
}
