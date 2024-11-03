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
  final TextEditingController _targetSchoolController =
      TextEditingController(); // Target school controller

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
        _selectedClassLevel = data['classLevel'] ?? '9.Sınıf';
        _targetSchoolController.text = data['targetSchool'] ?? '';

        setState(() {
          _profileImageUrl = data['profileImage'] ?? '';
        });
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

      // UUID oluşturma
      var uuid = const Uuid();
      String uniqueFileName =
          '${user.uid}/${uuid.v4()}.jpg'; // Benzersiz dosya adı oluşturma

      // Dosya referansını oluşturma
      final ref = FirebaseStorage.instance
          .ref()
          .child('profile_images/$uniqueFileName');

      // Yükleme işlemini başlatma
      final uploadTask = await ref.putFile(image);

      // Yüklemenin tamamlandığını kontrol etme
      if (uploadTask.state == TaskState.success) {
        // Yükleme tamamlandıktan sonra URL'yi alma
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

    // Veritabanından mevcut kullanıcı bilgilerini alıyoruz
    final doc = await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .get();
    final currentData = doc.data();

    // Eğer mevcut kullanıcı verisi boş değilse, boş olup olmadığını kontrol et
    final name = _nameController.text.trim().isEmpty
        ? (currentData != null ? currentData['name'] ?? '' : '')
        : _nameController.text.trim();
    final username = _usernameController.text.trim().isEmpty
        ? (currentData != null ? currentData['username'] ?? '' : '')
        : _usernameController.text.trim();
    final classLevel = _selectedClassLevel ??
        (currentData != null ? currentData['classLevel'] ?? '' : '');
    final goal = _nameController.text.trim().isEmpty
        ? (currentData != null ? currentData['targetSchool'] ?? '' : '')
        : _nameController.text.trim();
    String? imageUrl =
        currentData != null ? currentData['profileImage'] ?? '' : '';

    // Eğer yeni bir resim seçilmişse, yükleme işlemi yapılacak
    if (_selectedImage != null) {
      imageUrl = await _uploadImage(_selectedImage!);
      if (imageUrl == null) {
        // Eğer resim yüklenmezse hata mesajı göster
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Resim yüklenemedi!')),
        );
        return;
      }
    }

    // Kullanıcı bilgilerini güncelle
    await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
      'name': name,
      'username': username,
      'profileImage': imageUrl ?? '',
      'classLevel': classLevel,
      'targetSchool': _targetSchoolController.text.trim().isEmpty
          ? (currentData != null ? currentData['targetSchool'] ?? '' : '')
          : _targetSchoolController.text.trim(), // Add targetSchool here
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
                                _pickImage();
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
                      items: [
                        '9.Sınıf',
                        '10.Sınıf',
                        '11.Sınıf',
                        '12.Sınıf',
                        'Mezun'
                      ].map((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(value,
                              style: const TextStyle(
                                color: Colors.black,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              )),
                        );
                      }).toList(),
                      onChanged: (String? newValue) {
                        setState(() {
                          _selectedClassLevel = newValue;
                        });
                      },
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(10.0, 8.0, 10.0, 8.0),
                    child: TextField(
                      controller: _targetSchoolController,
                      decoration: const InputDecoration(
                          hintText: "Hedeflediği Okul",
                          labelText: "Hedeflediği Okul",
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
                  ElevatedButton(
                    style: ButtonStyle(
                      backgroundColor:
                          WidgetStatePropertyAll(Colors.blueGrey[300]),
                    ),
                    onPressed: _saveProfile,
                    child: const Text(
                      "Kaydet",
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 20,
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
}
