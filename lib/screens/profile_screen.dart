import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_application/screens/userProfile_screen.dart';
import 'package:intl/intl.dart';
import 'post_model.dart'; // Post modelinizi ekleyin
import 'follower_model.dart'; // Takipçi modelinizi ekleyin (yukarıda tanımladığınız model)

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  List<Post> _posts = [];
  List<Follower> _following = [];
  List<Follower> _followers = [];

  Future<Map<String, dynamic>?> _getUserProfile() async {
    User? user = _auth.currentUser;
    if (user != null) {
      DocumentSnapshot userDoc =
          await _firestore.collection('users').doc(user.uid).get();
      return userDoc.data() as Map<String, dynamic>?; // Profil verilerini al
    }
    return null;
  }

  Future<void> _loadFollowingUsers() async {
    // Kullanıcının takip ettiği kullanıcıları yükleme işlemi
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser != null) {
      QuerySnapshot followingSnapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(currentUser.uid)
          .collection('following')
          .get();
      setState(() {
        _following = followingSnapshot.docs.map((doc) {
          return Follower.fromMap(doc.data() as Map<String, dynamic>, doc.id);
        }).toList();
      });
    }
  }

  void _updateFollowingList() {
    _loadFollowingUsers(); // Takip edilenleri yeniden yükle
  }

  Future<void> _getFollowingAndFollowers() async {
    User? user = _auth.currentUser;

    if (user != null) {
      // Takip edilenleri al
      QuerySnapshot followingSnapshot = await _firestore
          .collection('users')
          .doc(user.uid)
          .collection('following')
          .get();

      // Takip edilenlerin bilgilerini al
      _following = await Future.wait(followingSnapshot.docs.map((doc) async {
        DocumentSnapshot followingUserDoc =
            await _firestore.collection('users').doc(doc.id).get();
        return Follower.fromMap(followingUserDoc.data() as Map<String, dynamic>,
            followingUserDoc.id);
      }));
      setState(() {});

      // Takipçileri al
      QuerySnapshot followersSnapshot = await _firestore
          .collection('users')
          .doc(user.uid)
          .collection('followers')
          .get();

      // Takipçilerin bilgilerini al
      _followers = await Future.wait(followersSnapshot.docs.map((doc) async {
        DocumentSnapshot followerUserDoc =
            await _firestore.collection('users').doc(doc.id).get();
        return Follower.fromMap(
            followerUserDoc.data() as Map<String, dynamic>, followerUserDoc.id);
      }));
    }
  }

  Future<void> _deletePost(String postId) async {
    try {
      // Firestore'dan postu sil
      await FirebaseFirestore.instance.collection('posts').doc(postId).delete();

      // UI'daki post listesinden de sil
      setState(() {
        _posts.removeWhere((post) => post.id == postId);
      });
      print('Silinmeye çalışılan post ID: $postId');

      print('Post silindi');
    } catch (e) {
      print('Post silme hatası: $e');
    }
  }

  @override
  void initState() {
    super.initState();
    _getFollowingAndFollowers(); // Takip edilenler ve takipçileri al
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
                    height: height_ / 3.8,
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
                                  width: 3.0,
                                ),
                              ),
                              child: CircleAvatar(
                                radius: 35,
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
                                fontSize: 24,
                              ),
                            ),
                          ),
                          // Takipçi ve takip edilenler kısmı
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              GestureDetector(
                                onTap: () {
                                  _showFollowers(context);
                                },
                                child: Column(
                                  children: [
                                    Text(
                                      "${_followers.length}",
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight
                                            .bold, // Sayıyı vurgulamak için kalın
                                      ),
                                    ),
                                    const SizedBox(
                                        height:
                                            4), // Sayı ve etiket arasında boşluk
                                    const Text(
                                      "Takipçi",
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: Colors
                                            .black87, // Renk değişimi örneği
                                      ),
                                    ),
                                    const SizedBox(height: 6),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 20),
                              GestureDetector(
                                onTap: () {
                                  _showFollowing(context);
                                },
                                child: Column(
                                  children: [
                                    Text(
                                      "${_following.length}",
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight
                                            .bold, // Sayıyı vurgulamak için kalın
                                      ),
                                    ),
                                    const SizedBox(
                                        height:
                                            4), // Sayı ve etiket arasında boşluk
                                    const Text(
                                      "Takip Edilen",
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: Colors
                                            .black87, // Renk değişimi örneği
                                      ),
                                    ),
                                    const SizedBox(height: 6),
                                  ],
                                ),
                              ),
                            ],
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
                            isEqualTo: _auth.currentUser!
                                .uid) // archive yerine posts koleksiyonunu kullanın
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
                        return const Center(child: Text('Henüz gönderi yok'));
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
                                              width: 3.0,
                                            ),
                                          ),
                                          child: CircleAvatar(
                                            radius: 18,
                                            backgroundColor: Colors.grey[300],
                                            backgroundImage: post.imageUrl !=
                                                    null
                                                ? NetworkImage(post.imageUrl!)
                                                : const AssetImage(
                                                        "lib/assets/images/avatar.png")
                                                    as ImageProvider<Object>?,
                                          ),
                                        ),
                                        const SizedBox(width: 8),
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
                                              print(post.id);
                                              _deletePost(post.id);
                                            }
                                          },
                                          itemBuilder: (BuildContext context) =>
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
                                  if (post.imageUrl != null)
                                    Padding(
                                      padding:
                                          const EdgeInsets.only(bottom: 12.0),
                                      child: Image.network(
                                        post.imageUrl!,
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

  // Takipçileri gösteren fonksiyon
  void _showFollowers(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => UserListScreen(
          title: 'Takipçiler',
          users: _followers,
        ),
      ),
    );
  }

  // Takip edilenleri gösteren fonksiyon
  void _showFollowing(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => UserListScreen(
          title: 'Takip Edilenler',
          users: _following,
        ),
      ),
    );
  }
}

// Takipçi listesini gösteren ekran
// Takipçi listesini gösteren ekran
class UserListScreen extends StatelessWidget {
  final String title;
  final List<Follower> users;

  const UserListScreen({
    Key? key,
    required this.title,
    required this.users,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
      ),
      body: users.isEmpty
          ? const Center(child: Text('Henüz takipçi yok'))
          : ListView.builder(
              itemCount: users.length,
              itemBuilder: (context, index) {
                final user = users[index];
                return ListTile(
                  title: Text(user.name), // Burada kullanıcı adı gösterilmeli
                  // Eğer ID de isteniyorsa burada gösterilebilir
                );
              },
            ),
    );
  }
}
