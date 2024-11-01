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
  String?
      _profileImageUrl; // Firebase'den gelen mevcut profil resmi URL'sini saklayacak
  final ImagePicker _picker = ImagePicker();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _usernameController = TextEditingController();
  String? _selectedClassLevel;

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
<<<<<<< HEAD
        _selectedClassLevel = data['classLevel'] ?? '9.Sınıf';
        setState(() {
          _profileImageUrl = data['profileImage'] ?? '';
        });
=======
        if (data['profileImage'] != null) {
          setState(() {
            _selectedImage = null; 
          });
        }
>>>>>>> e0e37d913fde8c946c0a0498794468b5791dd24f
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

<<<<<<< HEAD
      // UUID oluşturma
      var uuid = const Uuid();
=======
      var uuid = Uuid();
>>>>>>> e0e37d913fde8c946c0a0498794468b5791dd24f
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
    final classLevel = _selectedClassLevel ??
        (currentData != null ? currentData['classLevel'] ?? '' : '');

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
      'classLevel': classLevel,
    });
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
          title: const Text(
            "PROFİL AYARLARI",
            style: TextStyle(
              fontFamily: 'Lorjuk',
              fontWeight: FontWeight.bold,
              fontSize: 28,
            ),
          ),
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
                            Container(
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: Colors.black, // Border rengi
                                  width: 3.0, // Border kalınlığı
                                ),
                              ),
                              child: CircleAvatar(
                                radius: 50,
                                backgroundColor: Colors.grey[100],
                                backgroundImage: _selectedImage != null
                                    ? FileImage(_selectedImage!)
                                    : (_profileImageUrl != null &&
                                            _profileImageUrl!.isNotEmpty
                                        ? NetworkImage(_profileImageUrl!)
                                        : const AssetImage(
                                                "lib/assets/images/avatar.png")
                                            as ImageProvider),
                              ),
                            ),
                            GestureDetector(
                              onTap: () {
                                _showImageOptions(); // Resim seçeneklerini göster
                              },
                              child: Container(
                                padding: const EdgeInsets.all(8),
                                child: const Text(
                                  "Profili düzenle",
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 22,
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
                    padding: const EdgeInsets.fromLTRB(10.0, 8.0, 10.0, 8.0),
                    child: TextField(
                      controller: _nameController,
                      decoration: const InputDecoration(
                          hintText: "Ad",
                          labelText: "Ad",
                          labelStyle: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Color.fromARGB(255, 85, 77, 77),
                          ),
                          border: OutlineInputBorder()),
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(10.0, 8.0, 10.0, 8.0),
                    child: TextField(
                      controller: _usernameController,
                      decoration: const InputDecoration(
                          hintText: "Kullanıcı Adı",
                          labelText: "Kullanıcı Adı",
                          labelStyle: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Color.fromARGB(255, 85, 77, 77),
                          ),
                          border: OutlineInputBorder()),
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(10.0, 8.0, 10.0, 8.0),
                    child: DropdownButtonFormField<String>(
                      value: _selectedClassLevel,
                      decoration: const InputDecoration(
                          border: OutlineInputBorder(),
                          labelText: "Sınıf Seviyesi",
                          labelStyle: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Color.fromARGB(255, 85, 77, 77),
                            fontSize: 20,
                          )),
                      items: ['9.Sınıf', '10.Sınıf', '11.Sınıf', '12.Sınıf']
                          .map((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(value,
                              style: const TextStyle(
                                color: Colors.black,
                                fontSize: 18,
                              )),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          _selectedClassLevel = value;
                        });
                      },
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: ElevatedButton(
                      onPressed: () {
                        _saveProfile();
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Profil güncellendi!')),
                        );
                      },
                      child: const Text(
                        "Kaydet",
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // Resim seçeneklerini gösteren fonksiyon
  void _showImageOptions() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Profil Resmi"),
          content: const Text(
              "Profil resmini değiştirmek veya silmek ister misiniz?"),
          actions: <Widget>[
            TextButton(
              child: const Text("Yeni Profil Resmi"),
              onPressed: () async {
                Navigator.of(context).pop(); // Diyalog penceresini kapat
                _pickImage(); // Resim seçme fonksiyonunu çağır
              },
            ),
            TextButton(
              child: const Text("Sil"),
              onPressed: () async {
                // Mevcut profil resmini silme işlemi
                await _deleteProfileImage();
                Navigator.of(context).pop(); // Diyalog penceresini kapat
              },
            ),
            TextButton(
              child: const Text("İptal"),
              onPressed: () {
                Navigator.of(context).pop(); // Diyalog penceresini kapat
              },
            ),
          ],
        );
      },
    );
  }

  // Profil resmini silme fonksiyonu
  Future<void> _deleteProfileImage() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      // Firebase Firestore'dan kullanıcı belgesini güncelle
      await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .update({
        'profileImage': '',
      });
      setState(() {
        _profileImageUrl = null; // State'i güncelle
        _selectedImage = null; // Seçilen resmi sıfırla
      });
      // Başarılı bir silme işlemi için bir Snackbar göster
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Profil resmi silindi!')),
      );
    }
  }
}
