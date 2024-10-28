import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'post_model.dart';
import 'dart:io';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final double height_ = MediaQuery.of(context).size.height;
    final double width_ = MediaQuery.of(context).size.width;

    return SafeArea(
      child: Scaffold(
        body: Column(
          children: [
            Container(
              height: height_ / 4,
              color: Colors.amber[50],
              child: Center(
                child: Padding(
                  padding: EdgeInsets.only(top: height_ / 35),
                  child: const Column(
                    children: [
                      CircleAvatar(
                        backgroundColor: Colors.black,
                        radius: 50,
                      ),
                      Padding(
                        padding: EdgeInsets.all(8.0),
                        child: Text(
                          "SULTAN KOCAGÖZ", // Profil adı
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 24,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance.collection('posts').snapshots(),
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
                                ? Container(
                                    constraints: BoxConstraints(
                                      maxHeight: height_ / 3,
                                      maxWidth: width_ * 0.2,
                                    ),
                                    child: Image.file(
                                      File(posts[index].imagePath!),
                                      width: double.infinity,
                                      height: height_ / 3,
                                      fit: BoxFit.cover,
                                    ),
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
        ),
      ),
    );
  }
}
