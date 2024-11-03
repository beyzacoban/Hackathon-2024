import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class ArchiveSongsScreen extends StatefulWidget {
  const ArchiveSongsScreen({super.key});

  @override
  State<ArchiveSongsScreen> createState() => _ArchiveSongsScreenState();
}

class _ArchiveSongsScreenState extends State<ArchiveSongsScreen> {
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: StreamBuilder(
          stream: FirebaseFirestore.instance
              .collection('users')
              .doc(FirebaseAuth.instance.currentUser!.uid)
              .collection('archive')
              .doc('songs')
              .snapshots(),
          builder: (context, snapshot) {
            if (!snapshot.hasData || !snapshot.data!.exists) {
              return const Center(child: Text('Arşivde şarkı yok.'));
            }

            var archivedSongs = snapshot.data!.data()?['songs'] ?? [];

            return ListView.builder(
              itemCount: archivedSongs.length,
              itemBuilder: (context, index) {
                var song = archivedSongs[index];
                return Card(
                  margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
                  elevation: 4,
                  child: ListTile(
                    title: Text(song['Şarkı Adı'] ?? 'Bilinmeyen Şarkı'),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: () async {
                        bool confirmDelete = await _showDeleteDialog(context);
                        if (confirmDelete) {
                          await _deleteSong(song);
                        }
                      },
                    ),
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }

  Future<bool> _showDeleteDialog(BuildContext context) async {
    return showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Sil?'),
          content: const Text('Bu şarkıyı arşivden silmek istediğinize emin misiniz?'),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(false); // Hayır seçeneği
              },
              child: const Text('Hayır'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(true); // Evet seçeneği
              },
              child: const Text('Evet'),
            ),
          ],
        );
      },
    ).then((value) => value ?? false); // Null kontrolü
  }

  Future<void> _deleteSong(Map<String, dynamic> song) async {
    final userId = FirebaseAuth.instance.currentUser!.uid;
    DocumentReference docRef = FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .collection('archive')
        .doc('songs');

    try {
      await docRef.update({
        'songs': FieldValue.arrayRemove([song]),
      });
    } catch (e) {
      print("Hata: $e");
    }
  }
}
