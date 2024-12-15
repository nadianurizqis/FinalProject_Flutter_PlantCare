import 'dart:io';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class DetailNotes extends StatefulWidget {
  final String plantKey;
  final String gambarTanaman;
  final String namaTanaman;
  final String tanggalPenanaman;
  final String jenisTanaman;
  final String kebutuhanCahaya;
  final String frekuensiPenyiraman;
  final String catatanKhusus;

  const DetailNotes({
    super.key,
    required this.plantKey,
    required this.gambarTanaman,
    required this.namaTanaman,
    required this.tanggalPenanaman,
    required this.jenisTanaman,
    required this.kebutuhanCahaya,
    required this.frekuensiPenyiraman,
    required this.catatanKhusus,
  });

  @override
  State<DetailNotes> createState() => _DetailNotesState();
}

class _DetailNotesState extends State<DetailNotes> {
  final DatabaseReference _databaseRef = FirebaseDatabase.instance.ref('plants');
  final TextEditingController namaTanamanController = TextEditingController();
  final TextEditingController tanggalController = TextEditingController();
  final TextEditingController cahayaController = TextEditingController();
  final TextEditingController penyiramanController = TextEditingController();
  final TextEditingController catatanController = TextEditingController();
  String? selectedPlantType;
  File? selectedImage;

  @override
  void initState() {
    super.initState();
    _initializeData();
  }

  void _initializeData() {
    namaTanamanController.text = widget.namaTanaman;
    tanggalController.text = widget.tanggalPenanaman;
    cahayaController.text = widget.kebutuhanCahaya;
    penyiramanController.text = widget.frekuensiPenyiraman;
    catatanController.text = widget.catatanKhusus;
    selectedPlantType = widget.jenisTanaman;
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
      return storage.getPublicUrl(fileName);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal mengunggah gambar: $e')),
      );
      return null;
    }
  }

  Future<void> _deleteImageFromSupabase(String imageUrl) async {
    try {
      final storage = Supabase.instance.client.storage.from('assets');
      final fileName = Uri.parse(imageUrl).pathSegments.last;
      await storage.remove([fileName]);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal menghapus gambar: $e')),
      );
    }
  }

  Future<void> _updatePlantNote() async {
    String? imageUrl = widget.gambarTanaman;
    if (selectedImage != null) {
      if (imageUrl.isNotEmpty) {
        await _deleteImageFromSupabase(imageUrl);
      }
      imageUrl = await _uploadImageToSupabase(selectedImage!);
      if (imageUrl == null) return;
    }

    final updatedData = {
      'namaTanaman': namaTanamanController.text,
      'tanggalPenanaman': tanggalController.text,
      'jenisTanaman': selectedPlantType,
      'kebutuhanCahaya': cahayaController.text,
      'frekuensiPenyiraman': penyiramanController.text,
      'catatanKhusus': catatanController.text,
      'imageUrl': imageUrl,
    };

    try {
      await _databaseRef.child(widget.plantKey).update(updatedData);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Data tanaman berhasil diperbarui!')),
      );
      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal memperbarui data: $e')),
      );
    }
  }

  Future<void> _deletePlantNote() async {
    try {
      if (widget.gambarTanaman.isNotEmpty) {
        await _deleteImageFromSupabase(widget.gambarTanaman);
      }
      await _databaseRef.child(widget.plantKey).remove();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Data tanaman berhasil dihapus!')),
      );
      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal menghapus data: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Detail Tanaman',
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
                          : (widget.gambarTanaman.isNotEmpty
                          ? Image.network(widget.gambarTanaman,
                          fit: BoxFit.cover)
                          : const Icon(Icons.image, size: 80)),
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
                    items: const [
                      'Buah',
                      'Bunga',
                      'Sayur',
                      'Herbal',
                      'Rempah'
                    ].map((type) {
                      return DropdownMenuItem<String>(
                          value: type, child: Text(type));
                    }).toList(),
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
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      foregroundColor: const Color(0xFF85AFA4),
                      side: const BorderSide(color: Color(0xFF85AFA4)),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    onPressed: _deletePlantNote,
                    child: const Text(
                      'Hapus',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF85AFA4),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    onPressed: _updatePlantNote,
                    child: const Text(
                      'Edit',
                      style: TextStyle(
                          fontWeight: FontWeight.bold, color: Colors.white),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
