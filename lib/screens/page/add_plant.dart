import 'dart:io';

import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../services/auth.dart';

class AddPlantPage extends StatefulWidget {
  const AddPlantPage({super.key});

  @override
  State<AddPlantPage> createState() => _AddPlantPageState();
}

class _AddPlantPageState extends State<AddPlantPage> {
  final AuthService authService = AuthService();
  String? username;
  final List<String> plantTypes = [
    'Buah',
    'Bunga',
    'Sayur',
    'Herbal',
    'Rempah'
  ];
  String? selectedPlantType;
  final TextEditingController namaTanamanController = TextEditingController();
  final TextEditingController tanggalController = TextEditingController();
  final TextEditingController cahayaController = TextEditingController();
  final TextEditingController penyiramanController = TextEditingController();
  final TextEditingController catatanController = TextEditingController();
  File? selectedImage;
  final DatabaseReference _databaseRef =
      FirebaseDatabase.instance.ref('plants');

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
  }

  Future<void> _pickImage() async {
    final pickedFile =
        await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        selectedImage = File(pickedFile.path);
      });
    }
  }

  Future<String?> _uploadImageToSupabase(File image) async {
    try {
      final storage = Supabase.instance.client.storage.from('assets');
      final fileExtension = image.path.split('.').last;
      final fileName = '${DateTime.now().millisecondsSinceEpoch}.$fileExtension';

      await storage.upload(fileName, image, fileOptions: const FileOptions(upsert: true));
      final publicUrl = storage.getPublicUrl(fileName);
      return publicUrl;
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal mengunggah gambar: $e')),
      );
      return null;
    }
  }


  Future<void> _savePlantNote() async {
    if (namaTanamanController.text.isEmpty ||
        tanggalController.text.isEmpty ||
        selectedPlantType == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Harap isi semua field yang diperlukan!')));
      return;
    }
    String? imageUrl;
    if (selectedImage != null) {
      imageUrl = await _uploadImageToSupabase(selectedImage!);
      if (imageUrl == null) {
        return;
      }
    }
    final Map<String, dynamic> plantData = {
      'namaTanaman': namaTanamanController.text,
      'tanggalPenanaman': tanggalController.text,
      'jenisTanaman': selectedPlantType,
      'kebutuhanCahaya': cahayaController.text,
      'frekuensiPenyiraman': penyiramanController.text,
      'catatanKhusus': catatanController.text,
      'createdBy': username,
      'imageUrl': imageUrl ?? '',
    };
    try {
      await _databaseRef.push().set(plantData);
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Data tanaman berhasil disimpan!')));
      namaTanamanController.clear();
      tanggalController.clear();
      cahayaController.clear();
      penyiramanController.clear();
      catatanController.clear();
      setState(() {
        selectedImage = null;
        selectedPlantType = null;
      });
      Navigator.pushReplacementNamed(context, '/index');
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Gagal menyimpan data: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Catatan Tanaman',
          style: TextStyle(
            color: Color(0xFF558D7E),
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(
          color: Color(0xFF558D7E),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    '1. Informasi General',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF558D7E),
                    ),
                  ),
                  const SizedBox(height: 16),
                  GestureDetector(
                    onTap: _pickImage,
                    child: Container(
                      height: 150,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        border: Border.all(color: const Color(0xFF85AFA4)),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: selectedImage != null
                          ? Image.file(selectedImage!, fit: BoxFit.cover)
                          : const Icon(Icons.add_photo_alternate,
                              color: Color(0xFF85AFA4), size: 50),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: namaTanamanController,
                    decoration: InputDecoration(
                      labelText: 'Nama Tanaman',
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: tanggalController,
                    decoration: InputDecoration(
                      labelText: 'Tanggal Penanaman',
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12)),
                    ),
                    readOnly: true,
                    onTap: () async {
                      DateTime? pickedDate = await showDatePicker(
                        context: context,
                        initialDate: DateTime.now(),
                        firstDate: DateTime(2000),
                        lastDate: DateTime(2100),
                      );
                      if (pickedDate != null) {
                        tanggalController.text =
                            "${pickedDate.day}/${pickedDate.month}/${pickedDate.year}";
                      }
                    },
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    decoration: InputDecoration(
                      labelText: 'Jenis Tanaman',
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12)),
                    ),
                    value: selectedPlantType,
                    onChanged: (String? value) {
                      setState(() {
                        selectedPlantType = value;
                      });
                    },
                    items: plantTypes.map((type) {
                      return DropdownMenuItem<String>(
                          value: type, child: Text(type));
                    }).toList(),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    '2. Detail Perawatan',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF558D7E),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: cahayaController,
                    decoration: InputDecoration(
                      labelText: 'Kebutuhan Cahaya',
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: penyiramanController,
                    decoration: InputDecoration(
                      labelText: 'Frekuensi Penyiraman',
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: catatanController,
                    decoration: InputDecoration(
                      labelText: 'Catatan Khusus',
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12)),
                    ),
                    maxLines: 3,
                  ),
                  const SizedBox(height: 32),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _savePlantNote,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF85AFA4),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                      ),
                      child: const Text(
                        'Simpan',
                        style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.white),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
