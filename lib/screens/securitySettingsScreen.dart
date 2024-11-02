import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class SecuritySettingsScreen extends StatefulWidget {
  const SecuritySettingsScreen({super.key});

  @override
  State<SecuritySettingsScreen> createState() => _SecuritySettingsScreenState();
}

class _SecuritySettingsScreenState extends State<SecuritySettingsScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<void> _changePassword() async {
    String currentPassword = '';
    String newPassword = '';

    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Şifre Değiştir'),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                TextField(
                  decoration: const InputDecoration(labelText: 'Mevcut Şifre'),
                  obscureText: true,
                  onChanged: (value) {
                    currentPassword = value;
                  },
                ),
                TextField(
                  decoration: const InputDecoration(labelText: 'Yeni Şifre'),
                  obscureText: true,
                  onChanged: (value) {
                    newPassword = value;
                  },
                ),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('İptal'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('Değiştir'),
              onPressed: () async {
                if (currentPassword.isNotEmpty && newPassword.isNotEmpty) {
                  User? user = _auth.currentUser;
                  if (user != null) {
                    try {
                      // Re-authenticate the user
                      AuthCredential credential = EmailAuthProvider.credential(
                        email: user.email!,
                        password: currentPassword,
                      );
                      await user.reauthenticateWithCredential(credential);
                      
                      // Change password
                      await user.updatePassword(newPassword);
                      Navigator.of(context).pop();
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Şifreniz başarıyla değiştirildi!'),
                        ),
                      );
                    } on FirebaseAuthException catch (e) {
                      // Handle errors here
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(e.message ?? 'Bir hata oluştu.'),
                        ),
                      );
                    }
                  }
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Lütfen tüm alanları doldurun.'),
                    ),
                  );
                }
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: const Text(
            "GÜVENLİK AYARLARI",
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
            icon: const Icon(Icons.arrow_back),
          ),
        ),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: ListView(
            children: [
              ListTile(
                leading: const Icon(Icons.lock),
                title: const Text('Şifre Değiştir'),
                subtitle: const Text('Şifrenizi değiştirin.'),
                onTap: _changePassword,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
