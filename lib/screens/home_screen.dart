import 'package:flutter/material.dart';

import 'package:flutter_application/screens/ai_screen.dart';
import 'package:flutter_application/screens/library_screen.dart';
import 'package:flutter_application/screens/message_screen.dart';
import 'package:flutter_application/screens/movies_screen.dart';
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
                      ));
                },
                icon: const Icon(Icons.message_rounded)),
          ],
          leading: Builder(builder: (context) {
            return IconButton(
                onPressed: () {
                  Scaffold.of(context).openDrawer();
                },
                icon: const Icon(Icons.menu));
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
                              ))
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
                              ))
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
                              ));
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
                              ));
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
                              ));
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
                              ));
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
                                builder: (context) => BooksScreen(),
                              ));
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
                              ))
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
                              ))
                        },
                      ),
                    ],
                  ),
                )
              ],
            ),
          ),
        ),
        body: ListView(
          scrollDirection: Axis.vertical,
        ),
      ),
    );
  }
}
