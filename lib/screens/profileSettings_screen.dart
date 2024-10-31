import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'dart:io';

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
            _selectedImage = File(data['profileImage']);
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
      final ref = FirebaseStorage.instance
          .ref()
          .child('profile_images/${DateTime.now().millisecondsSinceEpoch}');
      await ref.putFile(image);
      return await ref.getDownloadURL();
    } catch (e) {
      print("Error uploading image: $e");
      return null;
    }
  }

  Future<void> _saveProfile() async {
    final name = _nameController.text.trim();
    final username = _usernameController.text.trim();

    if (name.isNotEmpty && username.isNotEmpty) {
      String? imageUrl;
      if (_selectedImage != null) {
        imageUrl = await _uploadImage(_selectedImage!);
      }

      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
          'name': name,
          'username': username,
          'profileImage': imageUrl ?? '', // Store the image URL or empty string
        });
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Profil bilgileri kaydedildi!')));
      }
    }
  }

  void _closeKeyboard(BuildContext context) {
    FocusScope.of(context).unfocus();
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
                  GestureDetector(
                    onTap: _pickImage,
                    child: CircleAvatar(
                      radius: 50,
                      backgroundImage: _selectedImage != null
                          ? FileImage(_selectedImage!)
                          : null,
                      child: _selectedImage == null
                          ? const Icon(Icons.account_circle, size: 50)
                          : null,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: TextField(
                      controller: _nameController,
                      decoration:const InputDecoration(
                          hintText: "Ad", border: OutlineInputBorder()),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: TextField(
                      controller: _usernameController,
                      decoration:const InputDecoration(
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
