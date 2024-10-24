import 'package:flutter/material.dart';
import 'package:flutter_application/screens/profile_screen.dart';
import 'package:flutter_application/screens/settings_screen.dart';
import 'package:flutter_application/screens/home_screen.dart';

class NavigationbarScreen extends StatefulWidget {
  const NavigationbarScreen({super.key});

  @override
  State<NavigationbarScreen> createState() => _NavigationbarScreenState();
}

class _NavigationbarScreenState extends State<NavigationbarScreen> {
  int _currentIndex = 0; 

  final List<Widget> _pages = <Widget>[
    const HomeScreen(),
    const SettingsScreen(),
    const ProfileScreen(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _currentIndex = index; 
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_currentIndex], 
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: _onItemTapped,
        items: [
          const BottomNavigationBarItem(
              icon: Icon(
                Icons.home,
                color: Colors.black,
              ),
              label: ''),
          BottomNavigationBarItem(
              icon: Transform.scale(
                scale: 1.2,
                child: const Icon(
                  Icons.search,
                  color: Colors.black,
                ),
              ),
              label: ''),
          const BottomNavigationBarItem(
              icon: Icon(
                Icons.account_circle,
                color: Colors.black,
              ),
              label: ''),
        ],
      ),
    );
  }
}
