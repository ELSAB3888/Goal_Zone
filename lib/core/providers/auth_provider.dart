import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_model.dart';

class AuthProvider extends ChangeNotifier {
  UserModel? _currentUser;
  bool _isLoading = false;

  UserModel? get currentUser => _currentUser;
  bool get isAuthenticated => _currentUser != null;
  bool get isLoading => _isLoading;

  Future<void> login(String phone, String password) async {
    _isLoading = true;
    notifyListeners();

    // Mock delay for API
    await Future.delayed(const Duration(seconds: 2));

    // Mock User Data
    _currentUser = UserModel(id: '1', name: 'John Doe', phone: phone);
    
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('token', 'mock_token_123');

    _isLoading = false;
    notifyListeners();
  }

  Future<void> logout() async {
    _currentUser = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('token');
    notifyListeners();
  }
}
