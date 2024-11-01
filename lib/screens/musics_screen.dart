import 'package:flutter/material.dart';

class MusicsScreen extends StatefulWidget {
  const MusicsScreen({super.key});

  @override
  State<MusicsScreen> createState() => _MusicsScreenState();
}

class _MusicsScreenState extends State<MusicsScreen> {
  @override
  Widget build(BuildContext context) {
    return SafeArea(
        child: MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.blueGrey[100],
          title: const Text(
            "Müzikler",
            style: TextStyle(
              fontFamily: 'Lorjuk',
              fontWeight: FontWeight.bold,
              fontSize: 36,
            ),
          ),
          centerTitle: true,
          leading: IconButton(
              onPressed: () {
                Navigator.pop(context);
              },
              icon: const Icon(Icons.arrow_back)),
        ),
      ),
    ));
  }
}
