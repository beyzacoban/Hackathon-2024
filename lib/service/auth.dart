import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

class Auth {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance; // Firestore instance

  User? get currentUser => _firebaseAuth.currentUser;

  Stream<User?> get authStateChanges => _firebaseAuth.authStateChanges();

  Future<User?> createUser({
    required String email,
    required String password,
    required String username,
    required String name,
  }) async {
    try {
      final UserCredential userCredential = await _firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      User? user = userCredential.user;

      // Save the username and email to Firestore
      if (user != null) {
        await _firestore.collection('users').doc(user.uid).set({
          'username': username,
          'email': email,
          'name':name,
        });
      }
      return user;
    } catch (e) {
      print("Error creating user: $e");
      throw Exception("Failed to create user: $e");
    }
  }

  Future<void> signIn({
    required String email,
    required String password,
  }) async {
    try {
      await _firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
    } catch (e) {
      print("Error signing in: $e");
      throw Exception("Failed to sign in: $e");
    }
  }

  Future<void> signOut() async {
    await _firebaseAuth.signOut();
    await GoogleSignIn().signOut();
  }

  Future<User?> signInWithGoogle() async {
    try {
      final GoogleSignInAccount? gUser = await GoogleSignIn().signIn();

      if (gUser == null) {
        throw Exception("User did not sign in with Google");
      }

      final GoogleSignInAuthentication gAuth = await gUser.authentication;

      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: gAuth.accessToken,
        idToken: gAuth.idToken,
      );

      final UserCredential userCredential = await _firebaseAuth.signInWithCredential(credential);

      // Save Google user details to Firestore if new user
      if (userCredential.additionalUserInfo?.isNewUser ?? false) {
        await _firestore.collection('users').doc(userCredential.user?.uid).set({
          'username': userCredential.user?.displayName ?? 'Unknown',
          'email': userCredential.user?.email,
        });
      }

      return userCredential.user;
    } catch (e) {
      print("Error signing in with Google: $e");
      throw Exception("Failed to sign in with Google: $e");
    }
  }
}
