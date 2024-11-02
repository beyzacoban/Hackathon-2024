import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'chat_screen.dart';
import 'post_model.dart'; // Post modelinizi ekleyin

class UserProfileScreen extends StatefulWidget {
  final String userId; // Başka bir kullanıcının userId'si

  const UserProfileScreen({Key? key, required this.userId}) : super(key: key);

  @override
  _UserProfileScreenState createState() => _UserProfileScreenState();
}

class _UserProfileScreenState extends State<UserProfileScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  List<Post> _posts = [];
  String? userName;
  bool isFollowing = false;

  Future<Map<String, dynamic>?> _getUserProfile() async {
    DocumentSnapshot userDoc =
        await _firestore.collection('users').doc(widget.userId).get();
    return userDoc.data() as Map<String, dynamic>?; // Profil verilerini al
  }

  Future<void> _checkIfFollowing() async {
    final currentUser = _auth.currentUser;
    if (currentUser == null) return;

    DocumentSnapshot followingDoc = await _firestore
        .collection('users')
        .doc(currentUser.uid)
        .collection('following')
        .doc(widget.userId)
        .get();

    setState(() {
      isFollowing = followingDoc.exists; // Takip ediliyor mu kontrol et
    });
  }

  Future<void> _toggleFollow() async {
    final currentUser = _auth.currentUser;
    if (currentUser == null) return;

    final followingRef = _firestore
        .collection('users')
        .doc(currentUser.uid)
        .collection('following')
        .doc(widget.userId);

    if (isFollowing) {
      // Takipten çık
      await followingRef.delete();
    } else {
      // Takip et
      await followingRef.set({});
    }

    // Takip durumunu güncelle
    setState(() {
      isFollowing = !isFollowing;
    });
  }

  @override
  void initState() {
    super.initState();
    _checkIfFollowing();
  }

  @override
  Widget build(BuildContext context) {
    final double height_ = MediaQuery.of(context).size.height;

    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: FutureBuilder<Map<String, dynamic>?>(
            future: _getUserProfile(),
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return const Text('Yükleniyor...');
              }
              final userData = snapshot.data!;
              userName = userData['username'] ?? 'Ad';
              return Text(
                userName!,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              );
            },
          ),
          leading: IconButton(
              onPressed: () {
                Navigator.pop(context);
              },
              icon: const Icon(Icons.arrow_back)),
        ),
        body: FutureBuilder<Map<String, dynamic>?>(
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
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor:
                                  isFollowing ? Colors.white : Colors.blue,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              elevation: 5,
                              fixedSize: Size(
                                  MediaQuery.of(context).size.width / 2.5,
                                  MediaQuery.of(context).size.height / 18),
                            ),
                            onPressed: () {
                              _toggleFollow();
                            },
                            child: Text(
                              isFollowing ? "Takip" : "Takip Et",
                              style: TextStyle(
                                color:
                                    isFollowing ? Colors.black : Colors.white,
                                fontSize: 15,
                              ),
                            ),
                          ),
                          if (isFollowing) ...[
                            ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                elevation: 5,
                                fixedSize: Size(
                                    MediaQuery.of(context).size.width / 2.5,
                                    MediaQuery.of(context).size.height / 18),
                              ),
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => ChatScreen(
                                      userId: widget.userId,
                                      username: '',
                                      friendName: '',
                                    ),
                                  ),
                                );
                              },
                              child: const Text(
                                "Mesaj",
                                style: TextStyle(
                                  color: Colors.black,
                                  fontSize: 15,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),

                  // Kullanıcının gönderileri
                  if (isFollowing)
                    StreamBuilder<QuerySnapshot>(
                      stream: FirebaseFirestore.instance
                          .collection('posts')
                          .where('userId', isEqualTo: widget.userId)
                          .snapshots(),
                      builder: (context, snapshot) {
                        if (!snapshot.hasData) {
                          return const Center(
                              child: CircularProgressIndicator());
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
                                                  color: Colors.black,
                                                  width: 3.0),
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
                                          const SizedBox(width: 8),
                                          Text(
                                            userName ?? 'Anonim',
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
                                                  fontWeight: FontWeight.bold,
                                                  color: Colors.black),
                                            ),
                                            TextSpan(
                                              text: post.content,
                                              style: const TextStyle(
                                                color: Colors.black,
                                              ),
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
