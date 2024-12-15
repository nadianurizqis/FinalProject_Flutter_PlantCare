import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final DatabaseReference _dbRef = FirebaseDatabase.instance.ref();

  Future<String?> login(String email, String password) async {
    try {
      final userCredential = await _auth.signInWithEmailAndPassword(
          email: email, password: password);
      return userCredential.user?.uid;
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') {
        return 'Pengguna tidak ditemukan!';
      } else if (e.code == 'wrong-password') {
        return 'Password salah!';
      }
      return 'Login gagal: ${e.message}';
    }
  }

  Future<Map<String, dynamic>?> getUserData(String uid) async {
    final snapshot = await _dbRef.child('users/$uid').get();
    if (snapshot.exists) {
      return Map<String, dynamic>.from(snapshot.value as Map);
    }
    return null;
  }

  Future<String?> register(
      String email, String username, String password) async {
    try {
      final userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      final uid = userCredential.user?.uid;
      if (uid != null) {
        await _dbRef.child('users/$uid').set({
          'username': username,
          'email': email,
        });
      }
      return null;
    } on FirebaseAuthException catch (e) {
      if (e.code == 'email-already-in-use') {
        return 'Email sudah terdaftar!';
      } else if (e.code == 'weak-password') {
        return 'Password terlalu lemah!';
      }
      return 'Pendaftaran gagal: ${e.message}';
    }
  }

  Future<void> saveUserData(Map<String, dynamic> userData) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('username', userData['username']);
    await prefs.setString('email', userData['email']);
  }

  Future<Map<String, String?>> loadUserData() async {
    final prefs = await SharedPreferences.getInstance();
    return {
      'username': prefs.getString('username'),
      'email': prefs.getString('email'),
    };
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear(); // Hapus semua data di SharedPreferences
    await _auth.signOut(); // Logout dari Firebase Auth
  }
}
