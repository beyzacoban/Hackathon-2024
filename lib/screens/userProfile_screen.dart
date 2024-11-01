import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'post_model.dart'; // Post modelinizi ekleyin

class UserProfileScreen extends StatefulWidget {
  final String userId; // Başka bir kullanıcının userId'si

<<<<<<< HEAD
  const UserProfileScreen({Key? key, required this.userId}) : super(key: key);
=======
  const UserProfileScreen({super.key, required this.uid});
>>>>>>> e0e37d913fde8c946c0a0498794468b5791dd24f

  @override
  _UserProfileScreenState createState() => _UserProfileScreenState();
}

class _UserProfileScreenState extends State<UserProfileScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  List<Post> _posts = [];
  String? userName; // Kullanıcı adını burada saklayacağız

  Future<Map<String, dynamic>?> _getUserProfile() async {
    DocumentSnapshot userDoc =
        await _firestore.collection('users').doc(widget.userId).get();
    return userDoc.data() as Map<String, dynamic>?; // Profil verilerini al
  }

  @override
  Widget build(BuildContext context) {
    final double height_ = MediaQuery.of(context).size.height;

    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: FutureBuilder<Map<String, dynamic>?>(
            // FutureBuilder ile kullanıcı adını al
            future: _getUserProfile(),
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return const Text('Yükleniyor...');
              }
              final userData = snapshot.data!;
              userName = userData['username'] ?? 'Ad'; // Kullanıcı adını sakla
              return Text(
                userName!,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ); // Kullanıcı adını göster
            },
          ),
          leading: IconButton(
              onPressed: () {
                Navigator.pop(context);
              },
              icon: const Icon(Icons.arrow_back)),
        ),
        body: FutureBuilder<Map<String, dynamic>?>(
          // Kullanıcı profil bilgilerini almak için tekrar FutureBuilder kullan
          future: _getUserProfile(),
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return const Center(child: CircularProgressIndicator());
            }

            final userData = snapshot.data!;
            final String name = userData['name'] ?? 'Kullanıcı Adı';
            final String? profileImage = userData['profileImage'] as String?;

            return SingleChildScrollView(
              child: Column(
                children: [
                  SizedBox(
                    height: height_ / 6,
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
                                  color: Colors.black,
                                  width: 2,
                                ),
                              ),
                              child: CircleAvatar(
                                radius: 30,
                                backgroundColor: Colors.grey[300],
                                backgroundImage: profileImage != null &&
                                        profileImage.isNotEmpty
                                    ? NetworkImage(profileImage)
                                    : const AssetImage(
                                            "lib/assets/images/avatar.png")
                                        as ImageProvider<Object>?,
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text(
                              name,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 20,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8.0),
                    child: Container(
                      decoration: const BoxDecoration(
                          border: Border(
                              bottom: BorderSide(
                        color: Colors.black,
                        width: 1.5,
                      ))),
                      height: MediaQuery.of(context).size.height / 9,
                      child: Row(
                        mainAxisAlignment:
                            MainAxisAlignment.spaceAround, // Butonları yay
                        children: [
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(
                                    10), // Kenar yuvarlama
                              ),
                              elevation: 5, // Gölge efekti
                              padding: const EdgeInsets.symmetric(
                                  vertical: 12, horizontal: 20),
                              fixedSize: Size(
                                  MediaQuery.of(context).size.width / 2.5,
                                  MediaQuery.of(context).size.height / 15),
                            ),
                            onPressed: () {
                              // Takip et butonuna tıklandığında yapılacak işlemler
                            },
                            child: const Text(
                              "Takip et",
                              style: TextStyle(
                                color: Colors.black, // Buton metni rengi
                                fontSize: 18,
                              ),
                            ),
                          ),
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(
                                    10), // Kenar yuvarlama
                              ),
                              elevation: 5, // Gölge efekti
                              padding: const EdgeInsets.symmetric(
                                  vertical: 12, horizontal: 20),
                              fixedSize: Size(
                                  MediaQuery.of(context).size.width / 2.5,
                                  MediaQuery.of(context).size.height / 15),
                            ),
                            onPressed: () {
                              // Takip et butonuna tıklandığında yapılacak işlemler
                            },
                            child: const Text(
                              "Mesaj",
                              style: TextStyle(
                                color: Colors.black, // Buton metni rengi
                                fontSize: 18,
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
                            isEqualTo: widget
                                .userId) // Başka bir kullanıcının gönderilerini al
                        .snapshots(),
                    builder: (context, snapshot) {
                      if (!snapshot.hasData) {
                        return const Center(child: CircularProgressIndicator());
                      }

                      _posts = snapshot.data!.docs.map((doc) {
                        return Post.fromMap(
                            doc.id, doc.data() as Map<String, dynamic>);
                      }).toList();

                      if (_posts.isEmpty) {
                        return const Center(
                          child: Text("Henüz Gönderi Yok"),
                        );
                      }

                      return ListView.builder(
                        itemCount: _posts.length,
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemBuilder: (context, index) {
                          final post = _posts[index];

                          return Padding(
                            padding: const EdgeInsets.symmetric(vertical: 8.0),
                            child: Container(
                              color: Colors.transparent,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
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
                                                color: Colors.black,
                                                width: 3.0),
                                          ),
                                          child: CircleAvatar(
                                              radius: 18,
                                              backgroundColor: Colors.grey[300],
                                              backgroundImage: profileImage !=
                                                          null &&
                                                      profileImage.isNotEmpty
                                                  ? NetworkImage(profileImage)
                                                  : const AssetImage(
                                                          "lib/assets/images/avatar.png")
                                                      as ImageProvider<
                                                          Object>?),
                                        ),
                                        const SizedBox(width: 8),
                                        Text(
                                          userName ??
                                              'Anonim', // Kullanıcı adını göster
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 16,
                                          ),
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
                                            text: "${userName ?? 'Ad'}  ",
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
