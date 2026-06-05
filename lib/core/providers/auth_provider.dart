import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:dio/dio.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../models/user_model.dart';
import '../services/api_service.dart';

class AuthProvider extends ChangeNotifier {
  UserModel? _currentUser;
  bool _isLoading = false;

  UserModel? get currentUser => _currentUser;
  bool get isAuthenticated => _currentUser != null;
  bool get isLoading => _isLoading;

  final ApiService _apiService = ApiService();

  Future<bool> login(String identifier, String password) async {
    _isLoading = true;
    notifyListeners();

    try {
      // The backend accepts: email OR phone number as identifier
      // If user enters a phone, we send it directly - the backend handles it
      final response = await _apiService.client.post('/auth/login', data: {
        'identifier': identifier,
        'password': password,
      });

      if (response.statusCode == 200 && response.data['success']) {
        final data = response.data;
        _currentUser = UserModel.fromJson(data['data']);
        
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('auth_token', data['token']);

        _isLoading = false;
        notifyListeners();
        return true;
      }
    } on DioException catch (e) {
      debugPrint('Login Error: ${e.response?.data}');
    }

    _isLoading = false;
    notifyListeners();
    return false;
  }

  Future<bool> register(String name, String email, String phone, String password) async {
    _isLoading = true;
    notifyListeners();

    try {
      final response = await _apiService.client.post('/auth/register', data: {
        'full_name': name,
        'email': email,
        'phone': phone,
        'password': password,
      });

      if ((response.statusCode == 200 || response.statusCode == 201) && response.data['success']) {
        // Automatically login the user after successful registration
        // to retrieve the auth_token which is missing from the register response
        bool loginSuccess = await login(email, password);
        return loginSuccess;
      }
    } on DioException catch (e) {
      debugPrint('Register Error: ${e.response?.data}');
    }

    _isLoading = false;
    notifyListeners();
    return false;
  }

  Future<void> logout() async {
    _currentUser = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('auth_token');
    notifyListeners();
  }

  Future<bool> updateProfile(String name, String phone) async {
    _isLoading = true;
    notifyListeners();

    try {
      // API accepts full_name (and optionally phone)
      final response = await _apiService.client.put('/auth/profile', data: {
        'full_name': name,
        if (phone.isNotEmpty) 'phone': phone,
      });

      if (response.statusCode == 200 && response.data['success']) {
        // Response returns updated user under data key
        final updatedData = response.data['data'];
        _currentUser = UserModel.fromJson(updatedData);
        _isLoading = false;
        notifyListeners();
        return true;
      }
    } on DioException catch (e) {
      debugPrint('Update Profile Error: ${e.response?.data}');
    }

    _isLoading = false;
    notifyListeners();
    return false;
  }

  Future<bool> loadUser() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');
      if (token == null || token.isEmpty) return false;

      final response = await _apiService.client.get('/auth/profile');
      if (response.statusCode == 200 && response.data['success']) {
        final userData = response.data['data'];
        _currentUser = UserModel.fromJson(userData);
        notifyListeners();
        return true;
      }
    } on DioException catch (e) {
      debugPrint('Load User Error: ${e.message}');
    }
    return false;
  }

  // Social Login Helpers
  Future<Map<String, String>?> signInWithGoogle() async {
    _isLoading = true;
    notifyListeners();

    try {
      final GoogleSignIn googleSignIn = GoogleSignIn();
      // Force sign out first to allow selecting another account if needed
      await googleSignIn.signOut();
      
      final GoogleSignInAccount? googleUser = await googleSignIn.signIn();
      
      if (googleUser != null) {
        _isLoading = false;
        notifyListeners();
        return {
          'name': googleUser.displayName ?? '',
          'email': googleUser.email,
        };
      }
    } catch (e) {
      debugPrint('Google Sign In Error: $e');
    }

    _isLoading = false;
    notifyListeners();
    return null;
  }
}
