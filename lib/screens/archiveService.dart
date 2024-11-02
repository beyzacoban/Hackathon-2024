import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ArchiveService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> createUserArchive() async {
    User? user = _auth.currentUser;
    if (user != null) {
      String userId = user.uid;
      CollectionReference archive =
          _firestore.collection('users').doc(userId).collection('archive');

      // Eğer arşiv yoksa, oluştur
      final archiveSnapshot = await archive.get();
      if (archiveSnapshot.docs.isEmpty) {
        await archive.doc('songs').set({
          'songs': [] // Boş bir şarkı listesiyle dokümanı oluştur
        });
        await archive.doc('movies').set({});
        await archive.doc('books').set({});
        print("Şarkı arşivi oluşturuldu.");
      } else {
        print("Şarkı arşivi zaten mevcut.");
      }
    }
  }

  Future<void> addSongToArchive(Map<String, dynamic> songData) async {
    User? user = _auth.currentUser;
    if (user != null) {
      String userId = user.uid;
      CollectionReference archive =
          _firestore.collection('users').doc(userId).collection('archive');

      // Eğer şarkı dokümanı yoksa, oluştur
      DocumentReference songsDoc = archive.doc('songs');
      await songsDoc.get().then((doc) {
        if (doc.exists) {
          // Eğer doküman varsa, şarkıyı listeye ekle
          songsDoc.update({
            'songs': FieldValue.arrayUnion([songData])
          });
        } else {
          // Doküman yoksa, şarkıyı ekleyerek oluştur
          songsDoc.set({
            'songs': [songData]
          });
        }
      });
    }
  }

  Future<void> addMovieToArchive(Map<String, dynamic> movieData) async {
    User? user = _auth.currentUser;
    if (user != null) {
      String userId = user.uid;
      CollectionReference archive =
          _firestore.collection('users').doc(userId).collection('archive');

      // Eğer şarkı dokümanı yoksa, oluştur
      DocumentReference moviesDoc = archive.doc('movies');
      await moviesDoc.get().then((doc) {
        if (doc.exists) {
          // Eğer doküman varsa, şarkıyı listeye ekle
          moviesDoc.update({
            'movies': FieldValue.arrayUnion([movieData])
          });
        } else {
          // Doküman yoksa, şarkıyı ekleyerek oluştur
          moviesDoc.set({
            'movies': [movieData]
          });
        }
      });
    }
  }

  Future<void> addBookToArchive(Map<String, dynamic> bookData) async {
    User? user = _auth.currentUser;
    if (user != null) {
      String userId = user.uid;
      CollectionReference archive =
          _firestore.collection('users').doc(userId).collection('archive');

      // Eğer şarkı dokümanı yoksa, oluştur
      DocumentReference booksDoc = archive.doc('books');
      await booksDoc.get().then((doc) {
        if (doc.exists) {
          // Eğer doküman varsa, şarkıyı listeye ekle
          booksDoc.update({
            'books': FieldValue.arrayUnion([bookData])
          });
        } else {
          // Doküman yoksa, şarkıyı ekleyerek oluştur
          booksDoc.set({
            'books': [bookData]
          });
        }
      });
    }
  }
}
