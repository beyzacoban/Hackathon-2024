import 'package:flutter/material.dart';
import 'package:flutter_application/screens/archiveBooks_screen.dart';
import 'package:flutter_application/screens/archiveMovies_screen.dart';
import 'package:flutter_application/screens/archiveSongs_screen.dart';

class LibraryScreen extends StatefulWidget {
  const LibraryScreen({super.key});

  @override
  State<LibraryScreen> createState() => _LibraryScreenState();
}

class _LibraryScreenState extends State<LibraryScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: const Text(
            "KİTAPLIĞIM",
            style: TextStyle(
              fontFamily: 'Lorjuk',
              fontWeight: FontWeight.bold,
            ),
          ),
          centerTitle: true,
          backgroundColor: Colors.blueGrey[100],
          leading: IconButton(
            onPressed: () {
              Navigator.pop(context);
            },
            icon: const Icon(Icons.arrow_back),
          ),
          bottom: PreferredSize(
            preferredSize: Size.fromHeight(MediaQuery.of(context).size.height /
                16), // TabBar yüksekliğini ayarlayın
            child: Container(
              color: Colors.teal[200], // TabBar'ın arka plan rengi
              child: TabBar(
                controller: _tabController,
                tabs: const [
                  Tab(text: "Şarkılar"),
                  Tab(text: "Filmler"),
                  Tab(text: "Kitaplar"),
                ],
              ),
            ),
          ),
        ),
        body: TabBarView(
          controller: _tabController,
          children: const [
            ArchiveSongsScreen(),
            ArchiveMoviesScreen(),
            ArchiveBooksScreen(),
          ],
        ),
      ),
    );
  }
}
