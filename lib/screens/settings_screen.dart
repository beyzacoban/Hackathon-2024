import 'package:flutter/material.dart';
import 'package:flutter_application/screens/profileSettings_screen.dart';
import 'package:flutter_application/screens/securitySettingsScreen.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
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
            ),
          ),
          centerTitle: true,
          backgroundColor: Colors.blueGrey[100],
          leading: IconButton(
              onPressed: () {
                Navigator.pop(context);
              },
              icon: const Icon(Icons.arrow_back)),
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
              ),
              onTap: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const SecuritySettingsScreen(),
                    ));
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
                    ));
              },
              leading: const Icon(
                Icons.account_circle,
                color: Colors.black,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
