import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'post_model.dart'; // Post modelinizi ekleyin

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  List<Post> _posts = [];

  Future<Map<String, dynamic>?> _getUserProfile() async {
    User? user = _auth.currentUser;
    if (user != null) {
      DocumentSnapshot userDoc =
          await _firestore.collection('users').doc(user.uid).get();
      return userDoc.data() as Map<String, dynamic>?; // Profil verilerini al
    }
    return null;
  }

  Future<void> _deletePost(String postId) async {
    try {
      // Firestore'dan postu sil
      await FirebaseFirestore.instance.collection('posts').doc(postId).delete();

      // UI'daki post listesinden de sil
      setState(() {
        _posts.removeWhere((post) => post.id == postId);
      });

      print('Post silindi');
    } catch (e) {
      print('Post silme hatası: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final double height_ = MediaQuery.of(context).size.height;

    return SafeArea(
      child: Scaffold(
        body: FutureBuilder<Map<String, dynamic>?>(
          future: _getUserProfile(),
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return const Center(child: CircularProgressIndicator());
            }

            final userData = snapshot.data!;
            final String name = userData['name'] ?? 'Kullanıcı Adı';
            final String userName = userData['username'] ?? 'Ad';
            final String? profileImage = userData['profileImage'] as String?;

            return SingleChildScrollView(
              child: Column(
                children: [
                  Container(
                    decoration: const BoxDecoration(
                      border: Border(
                        bottom: BorderSide(color: Colors.black, width: 1),
                      ),
                    ),
                    height: height_ / 4,
                    child: Center(
                      child: Column(
                        children: [
                          Padding(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 6.0),
                            child: Container(
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: Colors.black, // Border rengi
                                  width: 3.0, // Border kalınlığı
                                ),
                              ),
                              child: CircleAvatar(
                                  radius: 50,
                                  backgroundColor: Colors.grey[300],
                                  backgroundImage: profileImage != null &&
                                          profileImage.isNotEmpty
                                      ? NetworkImage(profileImage)
                                      : const AssetImage(
                                              "lib/assets/images/avatar.png")
                                          as ImageProvider<Object>?),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text(
                              name,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 24,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // Kullanıcının gönderileri
                  StreamBuilder<QuerySnapshot>(
                    stream: FirebaseFirestore.instance
                        .collection('posts')
                        .where('userId',
                            isEqualTo:
                                _auth.currentUser?.uid) // userId ile filtreleme
                        .snapshots(),
                    builder: (context, snapshot) {
                      if (!snapshot.hasData) {
                        return const Center(child: CircularProgressIndicator());
                      }

                      // Postları UI içinde tutmak için listeye ekle
                      _posts = snapshot.data!.docs.map((doc) {
                        return Post.fromMap(
                            doc.id, doc.data() as Map<String, dynamic>);
                      }).toList();

                      if (_posts.isEmpty) {
                        return const Center(child: Text('Henüz gönderi yok'));
                      }

                      return ListView.builder(
                        itemCount: _posts.length,
                        shrinkWrap:
                            true, // ListView'ın boyutunu sınırlamak için
                        physics:
                            const NeverScrollableScrollPhysics(), // Kaydırma etkinliğini devre dışı bırak
                        itemBuilder: (context, index) {
                          final post = _posts[index];

                          return Expanded(
                            child: Padding(
                              padding:
                                  const EdgeInsets.symmetric(vertical: 8.0),
                              child: Container(
                                color: Colors.transparent,
                                child: Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.stretch,
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 8.0, vertical: 8.0),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Container(
                                            decoration: BoxDecoration(
                                              shape: BoxShape.circle,
                                              border: Border.all(
                                                color: Colors
                                                    .black, // Border rengi
                                                width: 3.0, // Border kalınlığı
                                              ),
                                            ),
                                            child: CircleAvatar(
                                                radius: 18,
                                                backgroundColor:
                                                    Colors.grey[300],
                                                backgroundImage: profileImage !=
                                                            null &&
                                                        profileImage.isNotEmpty
                                                    ? NetworkImage(profileImage)
                                                    : const AssetImage(
                                                            "lib/assets/images/avatar.png")
                                                        as ImageProvider<
                                                            Object>?),
                                          ),
                                          const SizedBox(
                                              width:
                                                  8), // Avatar ile isim arasında boşluk
                                          Text(
                                            userName,
                                            style: const TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 16,
                                            ),
                                          ),
                                          const Spacer(),
                                          PopupMenuButton<String>(
                                            onSelected: (String result) {
                                              if (result == 'delete') {
                                                _deletePost(
                                                    post.id); // Gönderiyi silme
                                              }
                                            },
                                            itemBuilder:
                                                (BuildContext context) =>
                                                    <PopupMenuEntry<String>>[
                                              const PopupMenuItem<String>(
                                                value: 'delete',
                                                child: Text('Sil'),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                    if (post.imagePath != null)
                                      Padding(
                                        padding:
                                            const EdgeInsets.only(bottom: 12.0),
                                        child: Image.network(
                                          post.imagePath!,
                                          fit: BoxFit.cover,
                                        ),
                                      ),
                                    Padding(
                                      padding: const EdgeInsets.fromLTRB(
                                          8.0, 2.0, 0.0, 10.0),
                                      child: RichText(
                                        text: TextSpan(
                                          children: [
                                            TextSpan(
                                              text: "$userName  ",
                                              style: const TextStyle(
                                                  fontSize: 20,
                                                  fontWeight: FontWeight.bold,
                                                  color: Colors.black),
                                            ),
                                            TextSpan(
                                              text: post.content,
                                              style: const TextStyle(
                                                  fontSize: 20,
                                                  color: Colors.black),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                      );
                    },
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}