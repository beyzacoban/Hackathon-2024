import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'archiveService.dart';

class MoviesScreen extends StatefulWidget {
  @override
  State<MoviesScreen> createState() => _MoviesScreenState();
}

class _MoviesScreenState extends State<MoviesScreen> {
  late ArchiveService archiveService;
  List<String> archivedMovieIds = [];
  Set<String> favoriteMovies = {}; // Favori kitapların ID'lerini tutacak
  @override
  void initState() {
    super.initState();
    archiveService = ArchiveService();
    _loadArchivedMovies();
    _loadFavoriteMovies();
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
          archivedMovieIds = List<String>.from(
              data['movies'].map((movie) => movie['Film Adı']));
        });
      }
    }
  }

  Future<void> _loadFavoriteMovies() async {
    final userId = FirebaseAuth.instance.currentUser!.uid;
    var snapshot = await FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .collection('favorites')
        .get();

    setState(() {
      favoriteMovies = snapshot.docs
          .map((doc) => doc.id) // Favori kitapların ID'lerini al
          .toSet();
    });
  }

  Future<void> _toggleFavorite(String movieTitle) async {
    final userId = FirebaseAuth.instance.currentUser!.uid;
    final docRef = FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .collection('favorites')
        .doc(movieTitle);

    if (favoriteMovies.contains(movieTitle)) {
      // Favorilerden çıkar
      await docRef.delete();
      setState(() {
        favoriteMovies.remove(movieTitle);
      });
    } else {
      // Favorilere ekle
      await docRef.set({'timestamp': FieldValue.serverTimestamp()});
      setState(() {
        favoriteMovies.add(movieTitle);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("FİLMLER",
            style: TextStyle(
              fontFamily: 'Lorjuk',
              fontWeight: FontWeight.bold,
              fontSize: 30,
            )),
        backgroundColor: Colors.blueGrey[300],
      ),
      body: StreamBuilder(
        stream: FirebaseFirestore.instance.collection('movies').snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          var movies = snapshot.data!.docs;

          return ListView.builder(
            itemCount: movies.length,
            itemBuilder: (context, index) {
              var movie = movies[index].data();
              String movieTitle = movie['Film Adı'] ?? 'No Title';

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
                      FontAwesomeIcons.film,
                      color: Colors.black,
                    ),
                    const SizedBox(width: 10),
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
                      icon: archivedMovieIds.contains(movieTitle)
                          ? const Icon(Icons.check_circle, color: Colors.green)
                          : const Icon(Icons.add_circle_outlined,
                              color: Colors.black),
                      onPressed: () async {
                        if (!archivedMovieIds.contains(movieTitle)) {
                          await archiveService.addMovieToArchive(movie);
                          setState(() {
                            archivedMovieIds.add(movieTitle);
                          });
                        }
                      },
                    ),
                    IconButton(
                      icon: favoriteMovies.contains(movieTitle)
                          ? const Icon(Icons.favorite,
                              color: Colors.red) // Favori ise dolu kalp
                          : const Icon(Icons.favorite_border,
                              color: Colors.red), // Favori değilse boş kalp
                      onPressed: () => _toggleFavorite(
                          movieTitle), // Favori durumunu değişti
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
