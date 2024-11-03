import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'archiveService.dart';

class SongsScreen extends StatefulWidget {
  @override
  State<SongsScreen> createState() => _SongsScreenState();
}

class _SongsScreenState extends State<SongsScreen> {
  late ArchiveService archiveService;
  List<String> archivedSongIds = [];
  Set<String> favoriteSongs = {}; // Favori kitapların ID'lerini tutacak
  @override
  void initState() {
    super.initState();
    archiveService = ArchiveService();
    _loadArchivedSongs();
    _loadFavoriteSongs();
  }

  Future<void> _loadArchivedSongs() async {
    final userId = FirebaseAuth.instance.currentUser!.uid;
    var snapshot = await FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .collection('archive')
        .doc('songs')
        .get();

    if (snapshot.exists) {
      var data = snapshot.data();
      if (data != null && data['songs'] != null) {
        setState(() {
          archivedSongIds =
              List<String>.from(data['songs'].map((song) => song['Şarkı Adı']));
        });
      }
    }
  }

  Future<void> _loadFavoriteSongs() async {
    final userId = FirebaseAuth.instance.currentUser!.uid;
    var snapshot = await FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .collection('favorites')
        .get();

    setState(() {
      favoriteSongs = snapshot.docs
          .map((doc) => doc.id) // Favori kitapların ID'lerini al
          .toSet();
    });
  }

  Future<void> _toggleFavorite(String songsTitle) async {
    final userId = FirebaseAuth.instance.currentUser!.uid;
    final docRef = FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .collection('favorites')
        .doc(songsTitle);

    if (favoriteSongs.contains(songsTitle)) {
      // Favorilerden çıkar
      await docRef.delete();
      setState(() {
        favoriteSongs.remove(songsTitle);
      });
    } else {
      // Favorilere ekle
      await docRef.set({'timestamp': FieldValue.serverTimestamp()});
      setState(() {
        favoriteSongs.add(songsTitle);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "ŞARKILAR",
          style: TextStyle(
            fontFamily: 'Lorjuk',
            fontWeight: FontWeight.bold,
            fontSize: 30,
          ),
        ),
        backgroundColor: Colors.blueGrey[300],
      ),
      body: StreamBuilder(
        stream: FirebaseFirestore.instance.collection('songs').snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          var songs = snapshot.data!.docs;

          return ListView.builder(
            itemCount: songs.length,
            itemBuilder: (context, index) {
              var song = songs[index].data();
              String songTitle = song['Şarkı Adı'];

              return Container(
                padding: const EdgeInsets.all(16.0),
                decoration: BoxDecoration(
                  border: Border(
                    bottom: BorderSide(
                      color: Colors.grey.shade300,
                      width: 1.0,
                    ),
                  ),
                ),
                child: Row(
                  children: [
                    const Icon(
                      FontAwesomeIcons.music,
                      color: Colors.black,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            songTitle,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                              fontSize: 18,
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: archivedSongIds.contains(songTitle)
                          ? const Icon(Icons.check_circle, color: Colors.green)
                          : const Icon(Icons.add_circle_outlined,
                              color: Colors.black),
                      onPressed: () async {
                        if (!archivedSongIds.contains(songTitle)) {
                          await archiveService.addSongToArchive(song);

                          setState(() {
                            archivedSongIds.add(songTitle);
                          });
                        }
                      },
                    ),
                    IconButton(
                      icon: favoriteSongs.contains(songTitle)
                          ? const Icon(Icons.favorite,
                              color: Colors.red) // Favori ise dolu kalp
                          : const Icon(Icons.favorite_border,
                              color: Colors.red), // Favori değilse boş kalp
                      onPressed: () =>
                          _toggleFavorite(songTitle), // Favori durumunu değişti
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}
