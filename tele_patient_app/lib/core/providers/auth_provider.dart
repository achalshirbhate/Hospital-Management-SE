import 'package:flutter/material.dart';
import '../models/user_model.dart';
import '../services/api_service.dart';

class AuthProvider extends ChangeNotifier {
  UserModel? _user;
  bool _loading = false;
  String? _error;

  UserModel? get user    => _user;
  bool       get loading => _loading;
  String?    get error   => _error;
  bool       get isLoggedIn => _user != null;

  Future<bool> login(String email, String password) async {
    _loading = true; _error = null; notifyListeners();
    try {
      final data = await ApiService.login(email, password);
      _user = UserModel.fromJson(data);
      _loading = false; notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString().replaceAll('Exception: ', '');
      _loading = false; notifyListeners();
      return false;
    }
  }

  Future<bool> register(String fullName, String email, String password) async {
    _loading = true; _error = null; notifyListeners();
    try {
      await ApiService.register(fullName, email, password);
      _loading = false; notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString().replaceAll('Exception: ', '');
      _loading = false; notifyListeners();
      return false;
    }
  }

  void logout() {
    _user = null;
    notifyListeners();
  }

  void clearError() { _error = null; notifyListeners(); }
}
