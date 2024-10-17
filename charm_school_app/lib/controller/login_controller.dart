import 'package:flutter/material.dart';

class LoginController {
  // Method to handle login
  Future<void> login(
    BuildContext context,
    String username,
    String password,
    TextEditingController usernameController,
    TextEditingController passwordController,
    FocusNode usernameFocusNode,
    Function(UserType) onLoginSuccess,
  ) async {
    if (username.isEmpty || password.isEmpty) {
      _showSnackBar(context, 'Please enter both username and password.', Colors.orange);
      return;
    }

    try {
      final result = await _validateCredentials(username, password);
      if (result.success) {
        onLoginSuccess(result.userType!);
      } else {
        _handleLoginFailure(context, usernameController, passwordController, usernameFocusNode);
      }
    } catch (e) {
      _showSnackBar(context, 'An error occurred: $e', Colors.red);
    }
  }

  Future<LoginResult> _validateCredentials(String username, String password) async {
    // Ganti ini dengan logika autentikasi yang sebenarnya
    if (username == 'petugas' && password == 'petugas123') {
      return LoginResult(true, UserType.petugas);
    } else if (username == 'user' && password == 'user123') {
      return LoginResult(true, UserType.user);
    }
    return LoginResult(false, null);
  }

  void _handleLoginFailure(
    BuildContext context,
    TextEditingController usernameController,
    TextEditingController passwordController,
    FocusNode usernameFocusNode,
  ) {
    usernameController.clear();
    passwordController.clear();
    usernameFocusNode.requestFocus();

    _showSnackBar(context, 'Login failed! Incorrect username or password.', Colors.red);
  }

  void _showSnackBar(BuildContext context, String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: color,
      ),
    );
  }
}

enum UserType { petugas, user }

class LoginResult {
  final bool success;
  final UserType? userType;

  LoginResult(this.success, this.userType);
}
