import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application/screens/ai_screen.dart';
import 'package:flutter_application/screens/library_screen.dart';
import 'package:flutter_application/screens/message_screen.dart';
import 'package:flutter_application/screens/movies_screen.dart';
import 'package:flutter_application/screens/post_model.dart';
import 'package:flutter_application/screens/songs_screen.dart';
import 'package:flutter_application/screens/plan_screen.dart';
import 'package:flutter_application/screens/settings_screen.dart';
import 'package:flutter_application/screens/books_screen.dart';
import 'package:flutter_application/screens/test_screen.dart';
import 'package:flutter_application/screens/timer_screen.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  List<String> followingUsers = []; // Takip edilen kullanıcıların ID'leri
  List<Post> posts = []; // Gönderiler

  @override
  void initState() {
    super.initState();
    fetchFollowingUsers();
  }

  Future<void> fetchFollowingUsers() async {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser != null) {
      try {
        var followingSnapshot = await FirebaseFirestore.instance
            .collection('users')
            .doc(currentUser.uid)
            .collection('following')
            .get();

        if (followingSnapshot.docs.isNotEmpty) {
          setState(() {
            followingUsers =
                followingSnapshot.docs.map((doc) => doc.id).toList();
          });
        }

        await fetchPosts();
      } catch (e) {
        print("Error fetching following users: $e");
      }
    }
  }

  Future<void> fetchPosts() async {
    try {
      List<Post> fetchedPosts = [];
      for (String userId in followingUsers) {
        // Kullanıcıya ait gönderileri al
        var postsSnapshot = await FirebaseFirestore.instance
            .collection('posts')
            .where('userId', isEqualTo: userId)
            .get();

        // Kullanıcı bilgilerini al
        var userDoc = await FirebaseFirestore.instance
            .collection('users')
            .doc(userId)
            .get();
        String? profileImageUrl = userDoc.data()?['profileImage'];

        for (var doc in postsSnapshot.docs) {
          // Kullanıcı bilgilerini alırken post'u oluştur
          var post = Post.fromMap(doc.id, doc.data());
          post.profileImageUrl =
              profileImageUrl; // Kullanıcı profil resmini atıyoruz
          fetchedPosts.add(post); // Son olarak post'u listeye ekliyoruz
        }
      }

      setState(() {
        posts = fetchedPosts;
      });
    } catch (e) {
      print("Error fetching posts: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: const Text(
            "STUDY",
            style: TextStyle(
              fontFamily: 'KitaharaBrush',
              fontSize: 36,
              fontWeight: FontWeight.bold,
            ),
          ),
          centerTitle: true,
          backgroundColor: Colors.blueGrey[100],
          actions: [
            IconButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const MessageScreen(),
                  ),
                );
              },
              icon: const Icon(Icons.message_rounded),
            ),
          ],
          leading: Builder(
            builder: (context) {
              return IconButton(
                onPressed: () {
                  Scaffold.of(context).openDrawer();
                },
                icon: const Icon(Icons.menu),
              );
            },
          ),
        ),
        drawer: _buildDrawer(context),
        body: posts.isEmpty
            ? const Center()
            : ListView.builder(
                itemCount: posts.length,
                itemBuilder: (context, index) {
                  final post = posts[index];
                  return _buildPostItem(post);
                },
              ),
      ),
    );
  }

  Widget _buildDrawer(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(topRight: Radius.circular(20)),
      ),
      child: Drawer(
        child: Column(
          children: [
            _buildDrawerHeader(),
            Expanded(
              child: ListView(
                children: [
                  _buildDrawerItem(
                    context,
                    title: "Planım",
                    icon: Icons.calendar_month_outlined,
                    destination: const PlanScreen(),
                  ),
                  _buildDrawerItem(
                    context,
                    title: "Arşiv",
                    icon: Icons.folder_copy_rounded,
                    destination: const LibraryScreen(),
                  ),
                  _buildDrawerItem(
                    context,
                    title: "Denemelerim",
                    icon: Icons.bar_chart,
                    destination: TestScreen(),
                  ),
                  _buildDrawerItem(
                    context,
                    title: "Filmler",
                    icon: FontAwesomeIcons.film,
                    destination: MoviesScreen(),
                  ),
                  _buildDrawerItem(
                    context,
                    title: "Şarkılar",
                    icon: Icons.music_note,
                    destination: SongsScreen(),
                  ),
                  _buildDrawerItem(
                    context,
                    title: "Kitaplar",
                    icon: Icons.menu_book_outlined,
                    destination: const BooksScreen(),
                  ),
                  _buildDrawerItem(
                    context,
                    title: "Kronometre",
                    icon: Icons.timer,
                    destination: const TimerScreen(),
                  ),
                  _buildDrawerItem(
                    context,
                    title: "AI Asistanım",
                    icon: Icons.smart_toy,
                    destination: const AiScreen(),
                  ),
                  _buildDrawerItem(
                    context,
                    title: "Ayarlar",
                    icon: Icons.settings,
                    destination: const SettingsScreen(),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDrawerHeader() {
    return Container(
      height: MediaQuery.of(context).size.height / 10,
      width: MediaQuery.of(context).size.width,
      color: Colors.blueGrey[300],
      child: const Center(
        child: Text(
          "STUDY",
          style: TextStyle(
            fontFamily: 'KitaharaBrush',
            fontSize: 36,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  Widget _buildDrawerItem(
    BuildContext context, {
    required String title,
    required IconData icon,
    required Widget destination,
  }) {
    return ListTile(
      title: Text(
        title,
        style: const TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 20,
        ),
      ),
      leading: Icon(
        icon,
        size: 25,
        color: Colors.black,
      ),
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => destination),
        );
      },
    );
  }

  Widget _buildPostItem(Post post) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Container(
        color: Colors.transparent,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 8.0, vertical: 8.0),
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
                      backgroundImage: post.profileImageUrl != null
                          ? NetworkImage(post.profileImageUrl!)
                          : const AssetImage("lib/assets/images/avatar.png")
                              as ImageProvider<Object>?,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    post.username ?? 'Anonim',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            ),
            if (post.imageUrl != null)
              Padding(
                padding: const EdgeInsets.only(bottom: 12.0),
                child: Image.network(
                  post.imageUrl!,
                  fit: BoxFit.cover,
                ),
              ),
            Padding(
              padding: const EdgeInsets.fromLTRB(8.0, 2.0, 0.0, 10.0),
              child: RichText(
                text: TextSpan(
                  children: [
                    TextSpan(
                      text: post.username,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                    const TextSpan(text: '  '),
                    TextSpan(
                      text: post.content,
                      style: const TextStyle(
                        fontSize: 20,
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
  }
}
