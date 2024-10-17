import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../controller/login_controller.dart';
import '../providers/userProvider.dart';


class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  FocusNode usernameFocusNode = FocusNode();
  bool _isPasswordVisible = false; // Menyimpan status visibilitas password

  @override
  void dispose() {
    // Pastikan untuk membersihkan FocusNode dan TextEditingController
    usernameFocusNode.dispose();
    usernameController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        color: Colors.white,
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _buildLogo(),
                    const SizedBox(height: 20),
                    _buildTitle('Welcome to Charm High School App'),
                    const SizedBox(height: 20),
                    _buildTextInput(
                        usernameController, 'Username', Icons.person,
                        focusNode: usernameFocusNode),
                    const SizedBox(height: 15),
                    _buildTextInput(passwordController, 'Password', Icons.lock,
                        isPassword: true),
                    const SizedBox(height: 25),
                    _buildGradientButton(context, 'Login', _handleLogin),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLogo() {
    return const Icon(
      Icons.school,
      size: 100,
      color: Colors.purple,
    );
  }

  Widget _buildTitle(String text) {
    return Text(
      text,
      style: const TextStyle(
        color: Colors.purple,
        fontSize: 18,
        fontWeight: FontWeight.bold,
      ),
      textAlign: TextAlign.center,
    );
  }

  Widget _buildTextInput(
      TextEditingController controller, String label, IconData icon,
      {bool isPassword = false, FocusNode? focusNode}) {
    return SizedBox(
      height: 50,
      child: TextField(
        controller: controller,
        focusNode: focusNode, // Tambahkan FocusNode di sini
        obscureText: isPassword && !_isPasswordVisible,
        decoration: InputDecoration(
          labelText: label,
          filled: true,
          fillColor: Colors.purple.withOpacity(0.1),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: Colors.purple),
          ),
          prefixIcon: Icon(icon, color: Colors.purple),
          suffixIcon: isPassword
              ? IconButton(
                  icon: Icon(
                    _isPasswordVisible
                        ? Icons.visibility
                        : Icons.visibility_off,
                    color: Colors.purple,
                  ),
                  onPressed: () {
                    setState(() {
                      _isPasswordVisible = !_isPasswordVisible;
                    });
                  },
                )
              : null,
        ),
      ),
    );
  }

  Widget _buildGradientButton(
      BuildContext context, String text, VoidCallback onPressed) {
    return Container(
      width: double.infinity,
      height: 50,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(30),
        gradient: LinearGradient(
          colors: [Colors.purple[400]!, Colors.purple[800]!],
        ),
      ),
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
          ),
        ),
        child: Text(
          text,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  void _handleLogin() {
    LoginController loginController = LoginController();
    loginController.login(
      context,
      usernameController.text,
      passwordController.text,
      usernameController,
      passwordController,
      usernameFocusNode,
      (UserType userType) {
         print('Login successful as: $userType');
        Provider.of<UserProvider>(context, listen: false).setUserType(userType);
        Navigator.pushReplacementNamed(context, '/welcome');
      },
    );
  }
}
