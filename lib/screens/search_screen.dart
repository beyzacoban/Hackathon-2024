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
                searchQuery = value; // Arama sorgusunu güncelle
              });
            },
            decoration: InputDecoration(
              hintText: "Search username...",
              hintStyle:
                  TextStyle(color: Colors.grey[600]), // Hint rengini ayarla
              prefixIcon:
                  Icon(Icons.search, color: Colors.grey[600]), // Arama simgesi
              filled: true, // Arka plan rengi doldur
              fillColor: Colors.white, // Arka plan rengi
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(30.0), // Kenar yuvarlama
                borderSide: BorderSide.none, // Kenar çizgisi yok
              ),
              contentPadding: const EdgeInsets.symmetric(
                  vertical: 10.0, horizontal: 20.0), // İçerik dolgu ayarları
            ),
          ),
        ),
      ),
    );
  }
}
