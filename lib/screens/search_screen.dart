import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application/screens/userProfile_screen.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  String searchQuery = '';
  List<Map<String, dynamic>> searchResults = [];

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

    List<Map<String, dynamic>> users = snapshot.docs.map((doc) {
      return {
        'userId': doc.id,
        'username': doc['username'],
      };
    }).toList();

    setState(() {
      searchResults = users;
    });
  }

  String getInitials(String username) {
    if (username.isEmpty) return '';
    return username[0].toUpperCase();
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
              hintText: "Kullanıcı Ara",
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
        body: ListView.builder(
          itemCount: searchResults.length,
          itemBuilder: (context, index) {
            return Card(
              elevation: 2,
              margin:
                  const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: Colors.black,
                  child: Text(
                    getInitials(searchResults[index]['username']),
                    style: const TextStyle(color: Colors.white),
                  ),
                ),
                title: Text(
                  searchResults[index]['username'],
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                trailing: Icon(Icons.arrow_forward, color: Colors.grey[600]),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => UserProfileScreen(
                          userId: searchResults[index]['userId']),
                    ),
                  );
                },
              ),
            );
          },
        ),
      ),
    );
  }
}
