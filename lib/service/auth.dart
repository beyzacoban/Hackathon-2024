import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

class Auth {
  User? get currentUser => _firebaseAuth.currentUser;
  Stream<User?> get authStateChanges => _firebaseAuth.authStateChanges();
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

  Future<void> createUser({
    required String email,
    required String password,
  }) async {
    await _firebaseAuth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
  }

  Future<void> signIn({
    required String email,
    required String password,
  }) async {
    await _firebaseAuth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
  }

  Future<void> signOut() async {
    await _firebaseAuth.signOut();
  }

  Future<User?> signInWithGoogle() async {
    // Oturum açma işlemi
    final GoogleSignInAccount? gUser = await GoogleSignIn().signIn();

    // Eğer kullanıcı giriş yapmadıysa null dönebilir
    if (gUser == null) {
      // Kullanıcı giriş yapmadı
      print("Kullanıcı giriş yapmadı");
      return null;
    }

    // Süreç içerisinde bilgileri al
    final GoogleSignInAuthentication gAuth = await gUser.authentication;

    // Kullanıcı nesnesi oluştur
    final credential = GoogleAuthProvider.credential(
        accessToken: gAuth.accessToken, idToken: gAuth.idToken);

    // Firebase ile kullanıcıyı doğrula
    final UserCredential userCredential =
        await _firebaseAuth.signInWithCredential(credential);

    // Kullanıcı girişini sağla
    return userCredential.user;
  }
}
