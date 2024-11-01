import 'package:flutter/material.dart';
import 'package:flutter_application/screens/profileSettings_screen.dart';
import 'package:flutter_application/screens/securitySettingsScreen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> _signOut() async {
    await _auth.signOut();
    Navigator.of(context)
        .pushReplacementNamed('/login'); // Giriş sayfasına yönlendirin
  }

  Future<void> _deleteAccount() async {
    User? user = _auth.currentUser;
    if (user != null) {
      try {
        // Kullanıcının verilerini sil
        await _firestore.collection('users').doc(user.uid).delete();

        // Kullanıcının gönderilerini sil
        QuerySnapshot postsSnapshot = await _firestore
            .collection('posts')
            .where('userId', isEqualTo: user.uid)
            .get();
        for (var doc in postsSnapshot.docs) {
          await doc.reference.delete();
        }

        // Firebase Authentication'dan hesabı sil
        await user.delete();

        // Kullanıcıyı giriş sayfasına yönlendir
        Navigator.of(context).pushReplacementNamed('/login');
      } catch (e) {
        print('Hesap silme hatası: $e');
        // Hata mesajı gösterilebilir
      }
    }
  }

  void _showConfirmationDialog(String action) {
    String title;
    String content;

    if (action == 'signOut') {
      title = 'Çıkış Yap';
      content = 'Çıkış yapmak istediğinize emin misiniz?';
    } else {
      title = 'Hesabı Sil';
      content =
          'Hesabınızı silmek istediğinize emin misiniz? Bu işlem geri alınamaz.';
    }

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(content),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(); // Dialog'u kapat
            },
            child: const Text('İptal'),
          ),
          TextButton(
            onPressed: () {
              if (action == 'signOut') {
                _signOut(); // Çıkış yap
              } else {
                _deleteAccount(); // Hesabı sil
              }
              Navigator.of(context).pop(); // Dialog'u kapat
            },
            child: const Text('Evet'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        appBar: AppBar(
          title: const Text(
            "AYARLAR",
            style: TextStyle(
              fontFamily: 'Lorjuk',
              fontWeight: FontWeight.bold,
              fontSize: 30,
            ),
          ),
          centerTitle: true,
          backgroundColor: Colors.blueGrey[100],
          leading: IconButton(
            onPressed: () {
              Navigator.pop(context);
            },
            icon: const Icon(Icons.arrow_back),
          ),
        ),
        body: ListView(
          children: [
            ListTile(
              title: const Text(
                "Güvenlik Ayarları",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                ),
              ),
              leading: const Icon(
                Icons.security,
                color: Colors.black,
                size: 30,
              ),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const SecuritySettingsScreen(),
                  ),
                );
              },
            ),
            ListTile(
              title: const Text(
                "Profil Ayarları",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                ),
              ),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const ProfileSettingsScreen(),
                  ),
                );
              },
              leading: const Icon(
                Icons.account_circle,
                color: Colors.black,
                size: 30,
              ),
            ),
            ListTile(
              title: const Text(
                "Çıkış",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                ),
              ),
              onTap: () =>
                  _showConfirmationDialog('signOut'), // Onay penceresini göster
              leading: const Icon(
                Icons.logout_outlined,
                color: Colors.red,
                size: 30,
              ),
            ),
            ListTile(
              title: const Text(
                "Hesabı Sil",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                ),
              ),
              onTap: () => _showConfirmationDialog(
                  'deleteAccount'), // Onay penceresini göster
              leading: const Icon(
                Icons.delete_sharp,
                color: Colors.black,
                size: 30,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
