import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:uuid/uuid.dart';

class ProfileSettingsScreen extends StatefulWidget {
  const ProfileSettingsScreen({super.key});

  @override
  State<ProfileSettingsScreen> createState() => _ProfileSettingsScreenState();
}

class _ProfileSettingsScreenState extends State<ProfileSettingsScreen> {
  File? _selectedImage;
  final ImagePicker _picker = ImagePicker();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _usernameController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadCurrentUserProfile();
  }

  Future<void> _loadCurrentUserProfile() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();
      if (doc.exists) {
        final data = doc.data()!;
        _nameController.text = data['name'] ?? '';
        _usernameController.text = data['username'] ?? '';
        if (data['profileImage'] != null) {
          setState(() {
            _selectedImage = null; 
          });
        }
      }
    }
  }

  Future<void> _pickImage() async {
    final XFile? pickedImage =
        await _picker.pickImage(source: ImageSource.gallery);
    if (pickedImage != null) {
      setState(() {
        _selectedImage = File(pickedImage.path);
      });
    }
  }

  Future<String?> _uploadImage(File image) async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        throw Exception('Kullanıcı doğrulanmamış. Giriş yapın.');
      }

      var uuid = Uuid();
      String uniqueFileName =
          '${user.uid}/${uuid.v4()}.jpg'; 

      final ref = FirebaseStorage.instance
          .ref()
          .child('profile_images/$uniqueFileName');

      final uploadTask = await ref.putFile(image);

      if (uploadTask.state == TaskState.success) {
        String downloadUrl = await ref.getDownloadURL();
        print("Resim başarıyla yüklendi: $downloadUrl");
        return downloadUrl;
      } else {
        throw Exception("Dosya yükleme başarısız oldu.");
      }
    } catch (e) {
      print("Resim yükleme hatası: ${e.toString()}");
      return null;
    }
  }

  Future<void> _saveProfile() async {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) return;

    final doc = await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .get();
    final currentData = doc.data();

    final name = _nameController.text.trim().isEmpty
        ? (currentData != null ? currentData['name'] ?? '' : '')
        : _nameController.text.trim();
    final username = _usernameController.text.trim().isEmpty
        ? (currentData != null ? currentData['username'] ?? '' : '')
        : _usernameController.text.trim();

    String? imageUrl =
        currentData != null ? currentData['profileImage'] ?? '' : '';

    if (_selectedImage != null) {
      imageUrl = await _uploadImage(_selectedImage!);
      if (imageUrl == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Resim yüklenemedi!')),
        );
        return;
      }
    }

    await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
      'name': name,
      'username': username,
      'profileImage': imageUrl ?? '',
    });

    print("Kullanıcı profili başarıyla kaydedildi.");
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Profil bilgileri kaydedildi!')));
      Navigator.pop(context);
    }
  }

  void _closeKeyboard(BuildContext context) {
    FocusScope.of(context).unfocus();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _usernameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: const Text("PROFİL AYARLARI"),
          backgroundColor: Colors.blueGrey[100],
          centerTitle: true,
          leading: IconButton(
              onPressed: () {
                Navigator.pop(context);
              },
              icon: const Icon(Icons.arrow_back)),
        ),
        body: GestureDetector(
          onTap: () => _closeKeyboard(context),
          child: SingleChildScrollView(
            child: Center(
              child: Column(
                children: [
                  SizedBox(
                    height: MediaQuery.of(context).size.height / 4.2,
                    child: Center(
                      child: Padding(
                        padding: const EdgeInsets.only(top: 5),
                        child: Column(
                          children: [
                            CircleAvatar(
                              radius: 50,
                              backgroundImage: _selectedImage != null
                                  ? FileImage(_selectedImage!)
                                  : null,
                              child: _selectedImage == null
                                  ? const Icon(Icons.account_circle,
                                      size: 100, color: Colors.grey)
                                  : null,
                            ),
                            GestureDetector(
                              onTap: () {
                                _pickImage();
                              },
                              child: Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(10),
                                  color: Colors.blueGrey[100],
                                ),
                                child: const Text(
                                  "Profili düzenle",
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 20,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: TextField(
                      controller: _nameController,
                      decoration: const InputDecoration(
                          hintText: "Ad", border: OutlineInputBorder()),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: TextField(
                      controller: _usernameController,
                      decoration: const InputDecoration(
                          hintText: "Kullanıcı Adı",
                          border: OutlineInputBorder()),
                    ),
                  ),
                  ElevatedButton(
                    onPressed: _saveProfile,
                    child: const Text("Kaydet"),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
