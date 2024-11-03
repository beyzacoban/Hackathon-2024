import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'archiveService.dart';

class BooksScreen extends StatefulWidget {
  const BooksScreen({super.key});

  @override
  State<BooksScreen> createState() => _BooksScreenState();
}

class _BooksScreenState extends State<BooksScreen> {
  late ArchiveService archiveService;
  List<String> archivedBookIds = [];
  Set<String> favoriteBooks = {};
  @override
  void initState() {
    super.initState();
    archiveService = ArchiveService();
    _loadArchivedBooks();
    _loadFavoriteBooks();
  }

  Future<void> _loadArchivedBooks() async {
    final userId = FirebaseAuth.instance.currentUser!.uid;
    var snapshot = await FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .collection('archive')
        .doc('books')
        .get();

    if (snapshot.exists) {
      var data = snapshot.data();
      if (data != null && data['books'] != null) {
        setState(() {
          archivedBookIds =
              List<String>.from(data['books'].map((book) => book['Kitap Adı']));
        });
      }
    }
  }

  Future<void> _loadFavoriteBooks() async {
    final userId = FirebaseAuth.instance.currentUser!.uid;
    var snapshot = await FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .collection('favorites')
        .get();

    setState(() {
      favoriteBooks = snapshot.docs
          .map((doc) => doc.id) // Favori kitapların ID'lerini al
          .toSet();
    });
  }

  Future<void> _toggleFavorite(String bookTitle) async {
    final userId = FirebaseAuth.instance.currentUser!.uid;
    final docRef = FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .collection('favorites')
        .doc(bookTitle);

    if (favoriteBooks.contains(bookTitle)) {
      // Favorilerden çıkar
      await docRef.delete();
      setState(() {
        favoriteBooks.remove(bookTitle);
      });
    } else {
      // Favorilere ekle
      await docRef.set({'timestamp': FieldValue.serverTimestamp()});
      setState(() {
        favoriteBooks.add(bookTitle);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "KİTAPLAR",
          style: TextStyle(
            fontFamily: 'Lorjuk',
            fontWeight: FontWeight.bold,
            fontSize: 30,
          ),
        ),
        backgroundColor: Colors.blueGrey[300],
      ),
      body: StreamBuilder(
        stream: FirebaseFirestore.instance.collection('books').snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          var books = snapshot.data!.docs;

          return ListView.builder(
            itemCount: books.length,
            itemBuilder: (context, index) {
              var book = books[index].data();
              String bookTitle = book['Kitap Adı'] ?? 'No Title';
              String publisher =
                  book['Yayınevi'] ?? 'No Publisher'; // Yayın evi bilgisi
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
                      FontAwesomeIcons.book,
                      color: Colors.black,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            bookTitle,
                            
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                              fontSize: 18,
                            ),
                          ),
                          Text(
                            publisher, // Yayın evi bilgisi burada ekleniyor
                            style: const TextStyle(
                              color: Colors.grey, // Yayın evi için gri renk
                              fontSize: 14, // Alt başlık boyutu
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: archivedBookIds.contains(bookTitle)
                          ? const Icon(Icons.check_circle, color: Colors.green)
                          : const Icon(Icons.add_circle_outlined,
                              color: Colors.black),
                      onPressed: () async {
                        if (!archivedBookIds.contains(bookTitle)) {
                          await archiveService.addBookToArchive(book);
                          setState(() {
                            archivedBookIds.add(bookTitle);
                          });
                        }
                      },
                    ),
                    IconButton(
                      icon: favoriteBooks.contains(bookTitle)
                          ? const Icon(Icons.favorite,
                              color: Colors.red) // Favori ise dolu kalp
                          : const Icon(Icons.favorite_border,
                              color: Colors.red), // Favori değilse boş kalp
                      onPressed: () =>
                          _toggleFavorite(bookTitle), // Favori durumunu değişti
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
