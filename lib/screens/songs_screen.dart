import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'archiveService.dart'; // ArchiveService sınıfını ekleyin

class SongsScreen extends StatefulWidget {
  @override
  State<SongsScreen> createState() => _SongsScreenState();
}

class _SongsScreenState extends State<SongsScreen> {
  late ArchiveService archiveService;
  List<String> archivedSongIds = []; // Arşivlenmiş şarkıların ID'lerini tutacak

  @override
  void initState() {
    super.initState();
    archiveService = ArchiveService();
    _loadArchivedSongs(); // Arşivli şarkıları yükle
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
          archivedSongIds = List<String>.from(data['songs']
              .map((song) => song['Şarkı Adı'])); // Şarkı isimlerini alın
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Şarkılar"),
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
                      icon: archivedSongIds
                              .contains(songTitle) // Şarkı arşivdeyse
                          ? const Icon(Icons.check_circle,
                              color: Colors
                                  .green) // Arşivdeyse yeşil onay ikonu göster
                          : const Icon(Icons.add_circle_outlined,
                              color: Colors
                                  .black), // Arşivde değilse ekleme butonu göster
                      onPressed: () async {
                        if (!archivedSongIds.contains(songTitle)) {
                          // Sadece arşivde değilse ekle
                          await archiveService.addSongToArchive(song);
                          
                          setState(() {
                            archivedSongIds.add(songTitle); // Durumu güncelle
                          });
                        }
                      },
                    ),
                    IconButton(
                      icon:
                          const Icon(Icons.favorite_border, color: Colors.red),
                      onPressed: () {
                        // Favorilere ekle
                      },
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
