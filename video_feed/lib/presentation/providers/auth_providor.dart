import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/api/api_client.dart';
import '../../data/models/models.dart';

class AuthProvider extends ChangeNotifier {
  final ApiClient _apiClient;
  final SharedPreferences _prefs;
  
  bool _isLoading = false;
  bool _isAuthenticated = false;
  String? _error;
  String? _token;

  AuthProvider(this._apiClient, this._prefs) {
    _loadToken();
  }

  bool get isLoading => _isLoading;
  bool get isAuthenticated => _isAuthenticated;
  String? get error => _error;
  String? get token => _token;

  void _loadToken() {
    _token = _prefs.getString('access_token');
    if (_token != null) {
      _apiClient.setToken(_token!);
      _isAuthenticated = true;
      notifyListeners();
    }
  }

  Future<bool> login(String countryCode, String phone) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await _apiClient.postFormData(
        'otp_verified',
        {
          'country_code': countryCode,
          'phone': phone,
        },
        includeAuth: false,
      );

      final loginResponse = LoginResponse.fromJson(response);

      if (loginResponse.status && loginResponse.access != null) {
        _token = loginResponse.access;
        _apiClient.setToken(_token!);
        await _prefs.setString('access_token', _token!);
        _isAuthenticated = true;
        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        _error = loginResponse.message;
        _isLoading = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _error = 'Login failed: ${e.toString()}';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<void> logout() async {
    _token = null;
    _isAuthenticated = false;
    await _prefs.remove('access_token');
    notifyListeners();
  }
}