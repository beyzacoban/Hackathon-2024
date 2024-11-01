import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application/screens/userProfile_screen.dart';
// Kullanıcı profil ekranını ekleyin

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  String searchQuery = '';
  List<Map<String, dynamic>> searchResults =
      []; // Kullanıcı bilgilerini tutacak liste

  Future<void> searchUsernames(String query) async {
    if (query.isEmpty) {
      setState(() {
        searchResults = [];
      });
      return;
    }

    QuerySnapshot snapshot = await FirebaseFirestore.instance
        .collection('users')
        .where('username', isGreaterThanOrEqualTo: query)
        .where('username', isLessThan: '$query\uf8ff')
        .get();

    // Kullanıcı bilgilerini (userId ve username) al
    List<Map<String, dynamic>> users = snapshot.docs.map((doc) {
      return {
        'userId': doc.id, // Kullanıcı ID'si
        'username': doc['username'], // Kullanıcı adı
      };
    }).toList();

    setState(() {
      searchResults = users; // Artık List<Map<String, dynamic>> türünde
    });
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: TextField(
            onChanged: (value) {
              setState(() {
                searchQuery = value;
              });
              searchUsernames(value);
            },
            decoration: InputDecoration(
              hintText: "Search user-name...",
              hintStyle: TextStyle(color: Colors.grey[600]),
              prefixIcon: Icon(Icons.search, color: Colors.grey[600]),
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(30.0),
                borderSide: BorderSide.none,
              ),
              contentPadding:
                  const EdgeInsets.symmetric(vertical: 10.0, horizontal: 20.0),
            ),
          ),
        ),
        body: searchResults.isEmpty
            ? Center(child: Text('No users found'))
            : ListView.builder(
                itemCount: searchResults.length,
                itemBuilder: (context, index) {
                  return ListTile(
                    title: Text(searchResults[index]
                        ['username']), // Kullanıcı adını göster
                    onTap: () {
                      // Kullanıcı adına tıkladığında UserProfileScreen'i aç
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => UserProfileScreen(
                              userId: searchResults[index]['userId']),
                        ),
                      );
                    },
                  );
                },
              ),
      ),
    );
  }
}
