import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class ArchiveBooksScreen extends StatefulWidget {
  const ArchiveBooksScreen({super.key});

  @override
  State<ArchiveBooksScreen> createState() => _ArchiveBooksScreenState();
}

class _ArchiveBooksScreenState extends State<ArchiveBooksScreen> {
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: StreamBuilder(
          stream: FirebaseFirestore.instance
              .collection('users')
              .doc(FirebaseAuth.instance.currentUser!.uid)
              .collection('archive')
              .doc('books')
              .snapshots(),
          builder: (context, snapshot) {
            if (!snapshot.hasData || !snapshot.data!.exists) {
              return const Center(child: Text('Arşivde kitap yok.'));
            }

            var archivedBooks = snapshot.data!.data()?['books'] ?? [];

            return ListView.builder(
              itemCount: archivedBooks.length,
              itemBuilder: (context, index) {
                var book = archivedBooks[index];
                return Container(
                  padding: const EdgeInsets.all(8.0),
                  decoration: const BoxDecoration(
                    border: Border(bottom: BorderSide(color: Colors.grey)),
                  ),
                  child: ListTile(
                    title: Text(book['Kitap Adı'] ?? 'Bilinmeyen Kitap'),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: () async {
                        bool confirmDelete = await _showDeleteDialog(context);
                        if (confirmDelete) {
                          await _deleteBook(book);
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
          content: const Text(
              'Bu kitabı arşivden silmek istediğinize emin misiniz?'),
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

  Future<void> _deleteBook(Map<String, dynamic> book) async {
    final userId = FirebaseAuth.instance.currentUser!.uid;
    DocumentReference docRef = FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .collection('archive')
        .doc('books');

    try {
      await docRef.update({
        'books': FieldValue.arrayRemove([book]),
      });
    } catch (e) {
      print("Hata: $e");
    }
  }
}
