import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'archiveService.dart'; // ArchiveService sınıfını ekleyin

class MoviesScreen extends StatefulWidget {
  @override
  State<MoviesScreen> createState() => _MoviesScreenState();
}

class _MoviesScreenState extends State<MoviesScreen> {
  late ArchiveService archiveService;
  List<String> archivedMovieIds = []; // Arşivlenmiş filmlerin ID'lerini tutacak

  @override
  void initState() {
    super.initState();
    archiveService = ArchiveService(); // Arşiv servisini başlat
    _loadArchivedMovies(); // Arşivli filmleri yükle
  }

  Future<void> _loadArchivedMovies() async {
    final userId = FirebaseAuth.instance.currentUser!.uid;
    var snapshot = await FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .collection('archive')
        .doc('movies')
        .get();

    if (snapshot.exists) {
      var data = snapshot.data();
      if (data != null && data['movies'] != null) {
        setState(() {
          archivedMovieIds = List<String>.from(data['movies']
              .map((movie) => movie['Film Adı'])); // Film isimlerini alın
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Filmler"),
      ),
      body: StreamBuilder(
        stream: FirebaseFirestore.instance.collection('movies').snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          var movies = snapshot.data!.docs; // Filmleri al

          return ListView.builder(
            itemCount: movies.length,
            itemBuilder: (context, index) {
              var movie = movies[index].data(); // Film verisini al
              String movieTitle = movie['Film Adı'] ?? 'No Title';

              return Container(
                padding: const EdgeInsets.all(16.0),
                decoration: BoxDecoration(
                  border: Border(
                    bottom: BorderSide(
                      color: Colors.grey.shade300, // Alt çizgi rengi
                      width: 1.0, // Alt çizgi kalınlığı
                    ),
                  ),
                ),
                child: Row(
                  children: [
                    const Icon(
                      FontAwesomeIcons.film, // Film ikonu
                      color: Colors.black,
                    ),
                    const SizedBox(width: 10), // İkon ile yazı arası boşluk
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            movieTitle,
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
                      icon: archivedMovieIds
                              .contains(movieTitle) // Şarkı arşivdeyse
                          ? const Icon(Icons.check_circle,
                              color: Colors
                                  .green) // Arşivdeyse yeşil onay ikonu göster
                          : const Icon(Icons.add_circle_outlined,
                              color: Colors
                                  .black), // Arşivde değilse ekleme butonu göster
                      onPressed: () async {
                        if (!archivedMovieIds.contains(movieTitle)) {
                          // Sadece arşivde değilse ekle
                          await archiveService.addMovieToArchive(movie);
                          setState(() {
                            archivedMovieIds.add(movieTitle); // Durumu güncelle
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
