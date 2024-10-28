import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class ProfileSettingsScreen extends StatefulWidget {
  const ProfileSettingsScreen({super.key});

  @override
  State<ProfileSettingsScreen> createState() => _ProfileSettingsScreenState();
}

class _ProfileSettingsScreenState extends State<ProfileSettingsScreen> {
  File? _selectedImage;
  final ImagePicker _picker = ImagePicker();

  // Resim seçme fonksiyonu
  Future<void> _pickImage() async {
    final XFile? pickedImage =
        await _picker.pickImage(source: ImageSource.gallery);
    if (pickedImage != null) {
      setState(() {
        _selectedImage = File(pickedImage.path); // Seçilen resmi sakla
      });
    }
  }

  // Klavyeyi kapatma fonksiyonu
  void _closeKeyboard(BuildContext context) {
    FocusScope.of(context).unfocus(); // Klavyeyi kapatır
  }

  @override
  Widget build(BuildContext context) {
    double height_ = MediaQuery.of(context).size.height;
    return SafeArea(
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        home: Scaffold(
          resizeToAvoidBottomInset:
              true, // Klavyenin ekranı kaplamasını engelle
          appBar: AppBar(
            title: const Text(
              "PROFİL AYARLARI",
              style: TextStyle(
                fontFamily: 'Lorjuk',
                fontWeight: FontWeight.bold,
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
            onTap: () {
              _closeKeyboard(context); // Ekrana tıklayınca klavye kapanır
            },
            child: SingleChildScrollView(
              child: Center(
                child: Column(
                  children: [
                    Container(
                      height: height_ / 4.2,
                      color: Colors.amber[50],
                      child: Center(
                        child: Padding(
                          padding: const EdgeInsets.only(top: 5),
                          child: Column(
                            children: [
                              CircleAvatar(
                                backgroundColor: Colors.black,
                                radius: 50,
                                backgroundImage: _selectedImage != null
                                    ? FileImage(_selectedImage!)
                                    : null, // Seçilen resmi göster
                              ),
                              GestureDetector(
                                onTap: () {
                                  _pickImage(); // Resim seçme fonksiyonunu çağır
                                },
                                child: Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(10),
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
                        maxLines: 1,
                        decoration: InputDecoration(
                          hintText: "Ad",
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10.0),
                          ),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: TextField(
                        maxLines: 1,
                        decoration: InputDecoration(
                          hintText: "Kullanıcı Adı",
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10.0),
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
      ),
    );
  }
}
