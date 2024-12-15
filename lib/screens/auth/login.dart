import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/auth.dart';
import 'auth_provider.dart';

class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    final TextEditingController emailController = TextEditingController();
    final TextEditingController passwordController = TextEditingController();
    final authService = AuthService();

    Future<void> login() async {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final email = emailController.text.trim();
      final password = passwordController.text.trim();

      if (email.isEmpty || password.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Harap isi semua field!')),
        );
        return;
      }

      authProvider.setLoading(true);

      final uid = await authService.login(email, password);
      if (uid != null) {
        final userData = await authService.getUserData(uid);
        if (userData != null) {
          await authService.saveUserData(userData);
          if (context.mounted) {
            Navigator.pushReplacementNamed(context, '/index');
          }
        }
      } else if (uid is String) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(uid)),
        );
      }

      authProvider.setLoading(false);
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Center(
            child: Image.asset(
              'images/plants.png',
              height: 200,
            ),
          ),
          const SizedBox(height: 30),
          const Text(
            'Selamat Datang Kembali',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          TextField(
            controller: emailController,
            decoration: InputDecoration(
              labelText: 'Email',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
          const SizedBox(height: 20),
          Consumer<AuthProvider>(
            builder: (context, authProvider, child) {
              return TextField(
                obscureText: authProvider.obscureText,
                controller: passwordController,
                decoration: InputDecoration(
                  labelText: 'Password',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  suffixIcon: IconButton(
                    icon: Icon(
                      authProvider.obscureText
                          ? Icons.visibility_off
                          : Icons.visibility,
                    ),
                    onPressed: authProvider.toggleObscureText,
                  ),
                ),
              );
            },
          ),
          const SizedBox(height: 30),
          Consumer<AuthProvider>(
            builder: (context, authProvider, child) {
              return SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: authProvider.isLoading ? null : login,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF85AFA4),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 15),
                  ),
                  child: authProvider.isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text(
                    'Masuk',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              );
            },
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}
