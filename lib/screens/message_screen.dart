import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application/screens/chat_screen.dart';

class MessageScreen extends StatefulWidget {
  const MessageScreen({super.key});

  @override
  State<MessageScreen> createState() => _MessageScreenState();
}

class _MessageScreenState extends State<MessageScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  List<String> followingUsers = []; // List to store following users' usernames

  @override
  void initState() {
    super.initState();
    _fetchFollowingUsers();
  }

  void _fetchFollowingUsers() async {
    User? currentUser = _auth.currentUser;
    if (currentUser != null) {
      // Kullanıcının 'users' koleksiyonundaki belgesine ulaş
      DocumentSnapshot userSnapshot =
          await _firestore.collection('users').doc(currentUser.uid).get();

      if (userSnapshot.exists) {
        // Kullanıcının takip ettiği kullanıcıların alt koleksiyonunu al
        QuerySnapshot followingSnapshot = await _firestore
            .collection('users')
            .doc(currentUser.uid)
            .collection(
                'following') // Burada following alt koleksiyonuna erişiyoruz
            .get();

        if (followingSnapshot.docs.isNotEmpty) {
          // Takip edilen kullanıcıların listesi varsa, isimlerini al
          List<String> usernames =
              await Future.wait(followingSnapshot.docs.map((doc) async {
            DocumentSnapshot followingUserDoc =
                await _firestore.collection('users').doc(doc.id).get();
            return followingUserDoc['username']; // Kullanıcı adı alanını al
          }));

          setState(() {
            followingUsers = usernames; // Kullanıcı adlarını listeye ata
          });
        }
      }
    }
  }

  void _navigateToChat(String friendId, String username) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ChatScreen(
          friendName: username, // Use the friend's username
          userId: friendId, // Use the friend's ID
          username: _auth.currentUser?.displayName ??
              'User', // Use the current user's name
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        appBar: AppBar(
          title: const Text(
            "MESAJLARIM",
            style: TextStyle(
              fontFamily: 'Lorjuk',
              fontSize: 30,
              fontWeight: FontWeight.bold,
            ),
          ),
          centerTitle: true,
          backgroundColor: Colors.blueGrey[100],
          leading: IconButton(
              onPressed: () {
                Navigator.pop(context);
              },
              icon: const Icon(Icons.arrow_back)),
        ),
        body: followingUsers.isEmpty // Eğer takip edilen kullanıcı yoksa
            ? const Center()
            : ListView.builder(
                itemCount: followingUsers.length,
                itemBuilder: (context, index) {
                  final username = followingUsers[index];
                  return ListTile(
                    title: Text(
                      username,
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                    onTap: () {
                      _navigateToChat(followingUsers[index],
                          username); // Pass both friend ID and username
                    },
                  );
                },
              ),
      ),
    );
  }
}
