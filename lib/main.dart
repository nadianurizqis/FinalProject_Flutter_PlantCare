import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'firebase_options.dart';
import 'screens/auth/auth.dart';
import 'screens/index.dart';
import 'services/auth.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    await initializeServices();
    final authService = AuthService();
    final userData = await authService.loadUserData();
    runApp(MyApp(
      username: userData['username'],
      email: userData['email'],
    ));
  } catch (e) {
    runApp(const MyApp());
  }
}

Future<void> initializeServices() async {
  await Supabase.initialize(
    url: 'https://hhpwmckxxlvqttmaoplw.supabase.co',
    anonKey:
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImhocHdtY2t4eGx2cXR0bWFvcGx3Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3MzQyNjgzNzMsImV4cCI6MjA0OTg0NDM3M30.Xo1NTY0APAqtvdS0ktUF8OxE6DYqvsm5HuyDlNg-meQ',
  );
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
}

class MyApp extends StatelessWidget {
  final String? username;
  final String? email;

  const MyApp({super.key, this.username, this.email});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Aplikasi Tanaman',
      home: (username != null && email != null)
          ? const IndexPage()
          : const AuthPage(),
      routes: {
        '/auth': (context) => const AuthPage(),
        '/index': (context) => const IndexPage(),
      },
    );
  }
}
