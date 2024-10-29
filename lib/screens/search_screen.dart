import 'package:flutter/material.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  String searchQuery = '';

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
            },
            decoration: InputDecoration(
              hintText: "Search user-name...",
              hintStyle:
                  TextStyle(color: Colors.grey[600]), 
              prefixIcon:
                  Icon(Icons.search, color: Colors.grey[600]),
              filled: true, 
              fillColor: Colors.white, 
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(30.0), 
                borderSide: BorderSide.none, 
              ),
              contentPadding: const EdgeInsets.symmetric(
                  vertical: 10.0, horizontal: 20.0),
            ),
          ),
        ),
      ),
    );
  }
}
