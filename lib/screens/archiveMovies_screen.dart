import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class ArchiveMoviesScreen extends StatefulWidget {
  const ArchiveMoviesScreen({super.key});

  @override
  State<ArchiveMoviesScreen> createState() => _ArchiveMoviesScreenState();
}

class _ArchiveMoviesScreenState extends State<ArchiveMoviesScreen> {
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: StreamBuilder(
          stream: FirebaseFirestore.instance
              .collection('users')
              .doc(FirebaseAuth.instance.currentUser!.uid)
              .collection('archive')
              .doc('movies')
              .snapshots(),
          builder: (context, snapshot) {
            if (!snapshot.hasData || !snapshot.data!.exists) {
              return const Center(child: Text('Arşivde film yok.'));
            }

            var archivedMovies = snapshot.data!.data()?['movies'] ?? [];

            return ListView.builder(
              itemCount: archivedMovies.length,
              itemBuilder: (context, index) {
                var movie = archivedMovies[index];
                return Card(
                  margin: const EdgeInsets.symmetric(
                      vertical: 8.0, horizontal: 16.0),
                  elevation: 4,
                  child: ListTile(
                    title: Text(movie['Film Adı'] ?? 'Bilinmeyen Film'),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: () async {
                        bool confirmDelete = await _showDeleteDialog(context);
                        if (confirmDelete) {
                          await _deleteMovie(movie);
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
          content:
              const Text('Bu filmi arşivden silmek istediğinize emin misiniz?'),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(false); 
              },
              child: const Text('Hayır'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(true);
              },
              child: const Text('Evet'),
            ),
          ],
        );
      },
    ).then((value) => value ?? false); 
  }

  Future<void> _deleteMovie(Map<String, dynamic> movie) async {
    final userId = FirebaseAuth.instance.currentUser!.uid;
    DocumentReference docRef = FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .collection('archive')
        .doc('movies');

    try {
      await docRef.update({
        'movies': FieldValue.arrayRemove([movie]),
      });
    } catch (e) {
      print("Hata: $e");
    }
  }
}
