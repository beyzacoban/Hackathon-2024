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
  List<String> followingUsers = []; // To store IDs of followed users
  List<Post> posts = []; // To store posts

  @override
  void initState() {
    super.initState();
    fetchFollowingUsers();
  }

  Future<void> fetchFollowingUsers() async {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser != null) {
      var followingSnapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(currentUser.uid)
          .collection('following')
          .get();

      if (followingSnapshot.docs.isNotEmpty) {
        setState(() {
          followingUsers = followingSnapshot.docs.map((doc) => doc.id).toList();
          print("Following users: $followingUsers");
        });
      }
      await fetchPosts();
    }
  }

  Future<void> fetchPosts() async {
    try {
      for (String userId in followingUsers) {
        print("Fetching posts for user: $userId");
        var postsSnapshot = await FirebaseFirestore.instance
            .collection('users')
            .doc(userId)
            .collection('posts')
            .get();
        print("Posts snapshot for $userId: ${postsSnapshot.docs.length}");
      }
    } catch (e) {
      print("Error fetching posts: $e");
    }

    setState(() {}); // UI'yi güncelle
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
          leading: Builder(builder: (context) {
            return IconButton(
              onPressed: () {
                Scaffold.of(context).openDrawer();
              },
              icon: const Icon(Icons.menu),
            );
          }),
        ),
        drawer: Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(topRight: Radius.circular(20)),
          ),
          child: Drawer(
            child: Column(
              children: [
                Container(
                  height: MediaQuery.of(context).size.height / 10,
                  width: MediaQuery.of(context).size.width,
                  color: Colors.black,
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
                ),
                Expanded(
                  child: ListView(
                    children: [
                      ListTile(
                        title: const Text(
                          "Planım",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 20,
                          ),
                        ),
                        leading: const Icon(
                          Icons.calendar_month_outlined,
                          size: 25,
                          color: Colors.black,
                        ),
                        onTap: () => {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const PlanScreen(),
                            ),
                          )
                        },
                      ),
                      ListTile(
                        title: const Text(
                          "Kitaplığım",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 20,
                          ),
                        ),
                        leading: const Icon(
                          Icons.comment,
                          size: 25,
                          color: Colors.black,
                        ),
                        onTap: () => {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const LibraryScreen(),
                            ),
                          )
                        },
                      ),
                      ListTile(
                        title: const Text(
                          "Denemelerim",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 20,
                          ),
                        ),
                        leading: const Icon(
                          Icons.bar_chart,
                          size: 25,
                          color: Colors.black,
                        ),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => TestScreen(),
                            ),
                          );
                        },
                      ),
                      ListTile(
                        title: const Text(
                          "Filmler",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 20,
                          ),
                        ),
                        leading: const Icon(
                          FontAwesomeIcons.film,
                          size: 25,
                          color: Colors.black,
                        ),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => MoviesScreen(),
                            ),
                          );
                        },
                      ),
                      ListTile(
                        title: const Text(
                          "Şarkılar",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 20,
                          ),
                        ),
                        leading: const Icon(
                          Icons.music_note,
                          size: 25,
                          color: Colors.black,
                        ),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => SongsScreen(),
                            ),
                          );
                        },
                      ),
                      ListTile(
                        title: const Text(
                          "Kronometre",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 20,
                          ),
                        ),
                        leading: const Icon(
                          Icons.timer,
                          size: 25,
                          color: Colors.black,
                        ),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const TimerScreen(),
                            ),
                          );
                        },
                      ),
                      ListTile(
                        title: const Text(
                          "Kitaplar",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 20,
                          ),
                        ),
                        leading: const Icon(
                          Icons.menu_book_outlined,
                          size: 25,
                          color: Colors.black,
                        ),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const BooksScreen(),
                            ),
                          );
                        },
                      ),
                      ListTile(
                        title: const Text(
                          "Sor",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 20,
                          ),
                        ),
                        leading: const Icon(
                          Icons.comment,
                          size: 25,
                          color: Colors.black,
                        ),
                        onTap: () => {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const AiScreen(),
                            ),
                          )
                        },
                      ),
                      ListTile(
                        title: const Text(
                          "Ayarlar",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 20,
                          ),
                        ),
                        leading: const Icon(
                          Icons.settings,
                          size: 25,
                          color: Colors.black,
                        ),
                        onTap: () => {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const SettingsScreen(),
                            ),
                          )
                        },
                      ),
                    ],
                  ),
                )
              ],
            ),
          ),
        ),
        body: posts.isEmpty
            ? const Center(child: CircularProgressIndicator())
            : ListView.builder(
                itemCount: posts.length,
                itemBuilder: (context, index) {
                  final post = posts[index];

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
                                    backgroundImage: post.imagePath != null
                                        ? NetworkImage(post.imagePath!)
                                        : const AssetImage(
                                                "lib/assets/images/avatar.png")
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
                          if (post.imagePath != null)
                            Padding(
                              padding: const EdgeInsets.only(bottom: 12.0),
                              child: Image.network(
                                post.imagePath!,
                                fit: BoxFit.cover,
                              ),
                            ),
                          Padding(
                            padding:
                                const EdgeInsets.fromLTRB(8.0, 2.0, 0.0, 10.0),
                            child: RichText(
                              text: TextSpan(
                                children: [
                                  TextSpan(
                                    text: post.username,
                                    style: const TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.black),
                                  ),
                                  TextSpan(
                                    text: post.content,
                                    style: const TextStyle(
                                        fontSize: 20, color: Colors.black),
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
              ),
      ),
    );
  }
}
