import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';

import '../../services/auth.dart';
import 'detail_plant.dart';

class FavoritePage extends StatefulWidget {
  const FavoritePage({super.key});

  @override
  State<FavoritePage> createState() => _FavoritePageState();
}

class _FavoritePageState extends State<FavoritePage> {
  final AuthService authService = AuthService();
  final DatabaseReference _databaseRef =
      FirebaseDatabase.instance.ref('plants');
  String? username;
  List<Map<String, dynamic>> favoriteTanaman = [];

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final userData = await authService.loadUserData();
    setState(() {
      username = userData['username'];
    });
    _fetchFavoritePlants();
  }

  Future<void> _fetchFavoritePlants() async {
    if (username == null) return;
    try {
      final snapshot =
          await _databaseRef.orderByChild('createdBy').equalTo(username).get();
      if (snapshot.exists) {
        final data = Map<String, dynamic>.from(snapshot.value as Map);
        final List<Map<String, dynamic>> fetchedList = data.entries
            .where((entry) => entry.value['isFavorite'] == true)
            .map((entry) {
          final plant = Map<String, dynamic>.from(entry.value);
          plant['key'] = entry.key;
          return plant;
        }).toList();
        setState(() {
          favoriteTanaman = fetchedList;
        });
      } else {
        setState(() {
          favoriteTanaman = [];
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Gagal memuat data: $e')));
    }
  }

  Future<void> _toggleFavorite(Map<String, dynamic> tanaman) async {
    final key = tanaman['key'];
    final isFavorite = tanaman['isFavorite'] ?? false;
    try {
      await _databaseRef.child(key).update({'isFavorite': !isFavorite});
      _fetchFavoritePlants(); // Refresh data setelah update
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal mengubah status favorit: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Daftar Tanaman Favorite',
          style: TextStyle(
            color: Color(0xFF558D7E),
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Color(0xFF558D7E)),
      ),
      body: favoriteTanaman.isEmpty
          ? const Center(
              child: Text(
                'Tidak ada tanaman favorit.',
                style: TextStyle(color: Colors.grey),
              ),
            )
          : ListView.builder(
              itemCount: favoriteTanaman.length,
              itemBuilder: (context, index) {
                final tanaman = favoriteTanaman[index];
                return Container(
                  margin:
                      const EdgeInsets.symmetric(vertical: 10, horizontal: 15),
                  decoration: BoxDecoration(
                    color: const Color(0xFF558D7E),
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: ListTile(
                    contentPadding:
                        const EdgeInsets.symmetric(vertical: 5, horizontal: 15),
                    leading: Container(
                      width: 100,
                      height: 100,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        color: Colors.black,
                        image: tanaman['imageUrl'] != null &&
                                tanaman['imageUrl'] != ''
                            ? DecorationImage(
                                image: NetworkImage(tanaman['imageUrl']),
                                fit: BoxFit.cover,
                              )
                            : null,
                      ),
                      child: tanaman['imageUrl'] == null ||
                              tanaman['imageUrl'] == ''
                          ? const Icon(
                              Icons.image_not_supported,
                              color: Colors.white,
                              size: 50,
                            )
                          : null,
                    ),
                    title: Text(
                      tanaman['namaTanaman'] ?? '',
                      style: const TextStyle(color: Colors.white),
                    ),
                    subtitle: Text(
                      tanaman['jenisTanaman'] ?? '',
                      style: const TextStyle(color: Colors.white70),
                    ),
                    trailing: GestureDetector(
                      onTap: () => _toggleFavorite(tanaman),
                      child: Container(
                        padding: const EdgeInsets.all(5),
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          tanaman['isFavorite']
                              ? Icons.favorite
                              : Icons.favorite_border,
                          color: tanaman['isFavorite']
                              ? const Color(0xFFC592A4)
                              : Colors.grey.shade400,
                          size: 24,
                        ),
                      ),
                    ),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => DetailNotes(
                            gambarTanaman: tanaman['imageUrl'] ?? '',
                            namaTanaman: tanaman['namaTanaman'] ?? '',
                            tanggalPenanaman: tanaman['tanggalPenanaman'] ?? '',
                            jenisTanaman: tanaman['jenisTanaman'] ?? '',
                            kebutuhanCahaya: tanaman['kebutuhanCahaya'] ?? '',
                            frekuensiPenyiraman:
                                tanaman['frekuensiPenyiraman'] ?? '',
                            catatanKhusus: tanaman['catatanKhusus'] ?? '',
                            plantKey: tanaman['key'] ?? '',
                          ),
                        ),
                      );
                    },
                  ),
                );
              },
            ),
    );
  }
}
