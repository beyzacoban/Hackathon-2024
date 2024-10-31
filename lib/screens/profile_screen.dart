import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'post_model.dart'; // Eğer bu model başka bir yerde kullanılıyorsa, buradan çıkarmayın.

class ProfileScreen extends StatelessWidget {
  ProfileScreen({Key? key}) : super(key: key);
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<Map<String, dynamic>?> _getUserProfile() async {
    User? user = _auth.currentUser;
    if (user != null) {
      DocumentSnapshot userDoc =
          await _firestore.collection('users').doc(user.uid).get();
      return userDoc.data() as Map<String, dynamic>?;
    }
    return null;
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
            final String username = userData['username'] ?? 'Username';
            final String? profileImage = userData['profileImage'] as String?;

            return Column(
              children: [
                Container(
                  height: height_ / 4,
                  color: Colors.amber[50],
                  child: Center(
                    child: Column(
                      children: [
                        CircleAvatar(
                          radius: 50,
                          backgroundImage:
                              profileImage != null && profileImage.isNotEmpty
                                  ? NetworkImage(profileImage)
                                  : null,
                          child: profileImage == null || profileImage.isEmpty
                              ? const Icon(Icons.account_circle,
                                  size: 100, color: Colors.grey)
                              : null,
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text(
                            name,
                            style: const TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 24),
                          ),
                        ),
                        // Kullanıcı adı yazısı kaldırıldı
                      ],
                    ),
                  ),
                ),
                // Diğer içerikler buraya eklenebilir
                Expanded(
                  child: StreamBuilder<QuerySnapshot>(
                    stream: FirebaseFirestore.instance
                        .collection('posts')
                        .snapshots(),
                    builder: (context, snapshot) {
                      if (!snapshot.hasData) {
                        return const Center(child: CircularProgressIndicator());
                      }

                      final posts = snapshot.data!.docs.map((doc) {
                        return Post.fromMap(doc.data() as Map<String, dynamic>);
                      }).toList();

                      if (posts.isEmpty) {
                        return const Center(child: Text('Henüz gönderi yok'));
                      }

                      return ListView.builder(
                        itemCount: posts.length,
                        itemBuilder: (context, index) {
                          return SizedBox(
                            height: height_ / 2.4,
                            child: Card(
                              color: Colors.amber,
                              child: ListTile(
                                title: Text(posts[index].content),
                                subtitle: posts[index].imagePath != null
                                    ? Image.file(
                                        File(posts[index].imagePath!),
                                        width: double.infinity,
                                        height: height_ / 3,
                                        fit: BoxFit.cover,
                                      )
                                    : null,
                              ),
                            ),
                          );
                        },
                      );
                    },
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
