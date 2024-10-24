import 'package:flutter/material.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  @override
  Widget build(BuildContext context) {
    final double height_ = MediaQuery.of(context).size.height;
    final double width_ = MediaQuery.of(context).size.width;
    return SafeArea(
        child: Scaffold(
      body: Column(
        children: [
          Container(
            height: MediaQuery.of(context).size.height / 4,
            color: Colors.amber[50],
            child: Center(
              child: Padding(
                padding: EdgeInsets.only(top: height_ / 35),
                child: const Column(
                  children: [
                    CircleAvatar(
                      backgroundColor: Colors.black,
                      radius: 50,
                    ),
                    Padding(
                      padding: EdgeInsets.all(8.0),
                      child: Text(
                        "SULTAN KOCAGÖZ",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 24,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    ));
  }
}
