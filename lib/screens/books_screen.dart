import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'archiveService.dart'; // ArchiveService sınıfını ekleyin

class BooksScreen extends StatefulWidget {
  const BooksScreen({super.key});

  @override
  State<BooksScreen> createState() => _BooksScreenState();
}

class _BooksScreenState extends State<BooksScreen> {
  late ArchiveService archiveService;
  List<String> archivedBookIds = []; // Arşivlenmiş kitapların ID'lerini tutacak

  @override
  void initState() {
    super.initState();
    archiveService = ArchiveService(); // Arşiv servisini başlat
    _loadArchivedBooks(); // Arşivli kitapları yükle
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
          archivedBookIds = List<String>.from(data['books']
              .map((book) => book['Kitap Adı'])); // Kitap isimlerini alın
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Kitaplar"),
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
              var book = books[index].data(); // Kitap verisini al
              String bookTitle = book['Kitap Adı'] ?? 'No Title';

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
                      FontAwesomeIcons.book, // Kitap ikonu
                      color: Colors.black,
                    ),
                    const SizedBox(width: 10), // İkon ile yazı arası boşluk
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
                        ],
                      ),
                    ),
                    IconButton(
                      icon: archivedBookIds
                              .contains(bookTitle) // Şarkı arşivdeyse
                          ? const Icon(Icons.check_circle,
                              color: Colors
                                  .green) // Arşivdeyse yeşil onay ikonu göster
                          : const Icon(Icons.add_circle_outlined,
                              color: Colors
                                  .black), // Arşivde değilse ekleme butonu göster
                      onPressed: () async {
                        if (!archivedBookIds.contains(bookTitle)) {
                          // Sadece arşivde değilse ekle
                          await archiveService.addBookToArchive(book);
                          setState(() {
                            archivedBookIds.add(bookTitle); // Durumu güncelle
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
