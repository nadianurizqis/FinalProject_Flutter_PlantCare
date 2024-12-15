import 'package:flutter/material.dart';
import 'package:provider/provider.dart';


import 'auth_provider.dart';
import 'login.dart';
import 'register.dart';

class AuthPage extends StatefulWidget {
  const AuthPage({super.key});

  @override
  State<AuthPage> createState() => _AuthPageState();
}

class _AuthPageState extends State<AuthPage> {
  int _currentIndex = 0;
  late List<Widget> _pages;

  void _switchPage(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  void initState() {
    super.initState();
    _pages = [
      const LoginPage(),
      RegisterPage(
        onSwitchToLogin: () => _switchPage(0),
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => AuthProvider(),
      child: Scaffold(
        body: Column(
          children: [
            Expanded(
              child: _pages[_currentIndex],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  _currentIndex == 0
                      ? 'Belum punya akun?'
                      : 'Sudah punya akun?',
                  style: const TextStyle(fontSize: 14, color: Colors.grey),
                ),
                const SizedBox(width: 5),
                GestureDetector(
                  onTap: () {
                    _switchPage(_currentIndex == 0 ? 1 : 0);
                  },
                  child: Text(
                    _currentIndex == 0 ? 'Daftar' : 'Login',
                    style: const TextStyle(
                      fontSize: 14,
                      color: Color(0xFFC592A4),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
