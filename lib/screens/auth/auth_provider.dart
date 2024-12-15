import 'package:flutter/material.dart';

class AuthProvider with ChangeNotifier {
  bool _obscureText = true;
  bool _isLoading = false;

  bool get obscureText => _obscureText;
  bool get isLoading => _isLoading;

  void toggleObscureText() {
    _obscureText = !_obscureText;
    notifyListeners();
  }

  void setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }
}
