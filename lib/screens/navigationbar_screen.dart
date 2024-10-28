import 'package:flutter/material.dart';
import 'package:flutter_application/screens/postSharing_screen.dart';
import 'package:flutter_application/screens/profile_screen.dart';
import 'package:flutter_application/screens/search_screen.dart';
import 'package:flutter_application/screens/home_screen.dart';
import 'post_model.dart'; // Post modelini dahil edin

class NavigationbarScreen extends StatefulWidget {
  const NavigationbarScreen({super.key});

  @override
  State<NavigationbarScreen> createState() => _NavigationbarScreenState();
}

class _NavigationbarScreenState extends State<NavigationbarScreen> {
  int _currentIndex = 0; // Seçili öğeyi tutar
  final List<Post> _posts = []; // Paylaşılan postlar için liste

  // Farklı sayfaları içeren bir liste
  List<Widget> get _pages {
    return [
      const HomeScreen(),
      const SearchScreen(),
      const PostSharingScreen(),
      const ProfileScreen(),
    ];
  }

  void _onItemTapped(int index) {
    if (index == 2) {
      // Post paylaşma sayfasına geçiş yap
      Navigator.of(context)
          .push(MaterialPageRoute(
              builder: (context) => const PostSharingScreen()))
          .then((newPost) {
        if (newPost is Post) {
          setState(() {
            _posts.add(newPost); // Paylaşılan postu ekle
            _currentIndex = 3; // Profil sayfasına geç
          });
        }
      });
    } else {
      setState(() {
        _currentIndex = index; // Diğer sayfalara geçiş yap
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_currentIndex], 
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: _onItemTapped,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home, color: Colors.black),
            label: '',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.search, color: Colors.black),
            label: '',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.add_a_photo_rounded, color: Colors.black),
            label: '',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.account_circle, color: Colors.black),
            label: '',
          ),
        ],
      ),
    );
  }
}
