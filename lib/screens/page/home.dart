import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';

import '../../services/auth.dart';
import 'add_plant.dart';
import 'detail_plant.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final AuthService authService = AuthService();
  String? username;
  final DatabaseReference _databaseRef =
      FirebaseDatabase.instance.ref('plants');
  List<Map<String, dynamic>> tanamanList = [];
  List<Map<String, dynamic>> filteredList = [];
  final TextEditingController searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadUserData();
    searchController.addListener(_filterList);
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  Future<void> _loadUserData() async {
    final userData = await authService.loadUserData();
    setState(() {
      username = userData['username'];
    });
    _fetchData();
  }

  Future<void> _fetchData() async {
    if (username == null) return;
    try {
      final snapshot =
          await _databaseRef.orderByChild('createdBy').equalTo(username).get();
      if (snapshot.exists) {
        final data = Map<String, dynamic>.from(snapshot.value as Map);
        final List<Map<String, dynamic>> fetchedList =
            data.entries.map((entry) {
          final plant = Map<String, dynamic>.from(entry.value);
          plant['key'] = entry.key;
          return plant;
        }).toList();
        setState(() {
          tanamanList = fetchedList;
          filteredList = fetchedList;
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Gagal memuat data: $e')));
    }
  }

  void _filterList() {
    final query = searchController.text.toLowerCase();
    setState(() {
      filteredList = tanamanList.where((plant) {
        final name = (plant['namaTanaman'] ?? '').toLowerCase();
        return name.contains(query);
      }).toList();
    });
  }

  Future<void> _toggleFavorite(Map<String, dynamic> tanaman) async {
    final key = tanaman['key'];
    final isFavorite = tanaman['isFavorite'] ?? false;
    try {
      await _databaseRef.child(key).update({'isFavorite': !isFavorite});
      setState(() {
        tanaman['isFavorite'] = !isFavorite;
      });
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
          'Daftar Tanaman',
          style: TextStyle(
            color: Color(0xFF558D7E),
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Color(0xFF558D7E)),
      ),
      body: Column(
        children: [
          Container(
            color: Colors.white,
            child: Container(
              padding: const EdgeInsets.all(5),
              color: const Color(0xFFCADCD7),
              child: TextField(
                controller: searchController,
                decoration: InputDecoration(
                  hintText: 'Cari tanaman...',
                  hintStyle: TextStyle(color: Colors.black.withOpacity(0.6)),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30),
                    borderSide: BorderSide.none,
                  ),
                  filled: true,
                  fillColor: Colors.white,
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
                ),
              ),
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: filteredList.length,
              itemBuilder: (context, index) {
                final tanaman = filteredList[index];
                return _buildTanamanCard(context, tanaman);
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.white,
        child: const Icon(Icons.add, color: Color(0xFF85AFA4)),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const AddPlantPage()),
          );
        },
      ),
    );
  }

  Widget _buildTanamanCard(BuildContext context, Map<String, dynamic> tanaman) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 15),
      decoration: BoxDecoration(
        color: const Color(0xFF558D7E),
        borderRadius: BorderRadius.circular(15),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(vertical: 5, horizontal: 15),
        leading: Container(
          width: 100,
          height: 100,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            color: Colors.black,
            image: tanaman['imageUrl'] != null && tanaman['imageUrl'] != ''
                ? DecorationImage(
                    image: NetworkImage(tanaman['imageUrl']),
                    fit: BoxFit.cover,
                  )
                : null,
          ),
          child: tanaman['imageUrl'] == null || tanaman['imageUrl'] == ''
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
              tanaman['isFavorite'] ?? false
                  ? Icons.favorite
                  : Icons.favorite_border,
              color: tanaman['isFavorite'] ?? false
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
                frekuensiPenyiraman: tanaman['frekuensiPenyiraman'] ?? '',
                catatanKhusus: tanaman['catatanKhusus'] ?? '',
                plantKey: tanaman['key'] ?? '',
              ),
            ),
          );
        },
      ),
    );
  }
}
