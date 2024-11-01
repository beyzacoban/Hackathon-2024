import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart'; // Firebase Storage paketi eklendi
import 'post_model.dart';

class PostSharingScreen extends StatefulWidget {
  const PostSharingScreen({Key? key}) : super(key: key);

  @override
  _PostSharingScreenState createState() => _PostSharingScreenState();
}

class _PostSharingScreenState extends State<PostSharingScreen> {
  final TextEditingController _postController = TextEditingController();
  XFile? _image;
  final ImagePicker _picker = ImagePicker();
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<void> _pickImage() async {
    final XFile? selectedImage =
        await _picker.pickImage(source: ImageSource.gallery);
    if (selectedImage != null) {
      setState(() {
        _image = selectedImage;
      });
    }
  }

  Future<void> _sharePost() async {
    User? currentUser = _auth.currentUser;

    if (_postController.text.isNotEmpty || _image != null) {
      final newPost = Post(
        id: DateTime.now().toString(), 
        title: "Yeni Gönderi", 
        content: _postController.text,
        imagePath: imageUrl, // Resim URL'sini gönderiye ekle
        userId: currentUser?.uid,
      );
      print(newPost.toMap());

      try {
        await FirebaseFirestore.instance
            .collection('posts')
            .add(newPost.toMap());

        if (mounted) {
          Navigator.of(context).pop(newPost); 
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error sharing post: $e')),
          );
        }
        print("error sharing post : $e");
      }
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please add content or an image.')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Post Paylaşımı'),
        centerTitle: true,
        backgroundColor: Colors.blueGrey[100],
        actions: [
          IconButton(
            icon: const Icon(Icons.send, color: Colors.black),
            onPressed: _sharePost,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: _postController,
              maxLines: null,
              keyboardType: TextInputType.multiline,
              textInputAction: TextInputAction.newline,
              decoration: InputDecoration(
                hintText: "What's on your mind?",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10.0),
                ),
              ),
            ),
            const SizedBox(height: 20),
            _image != null
                ? Container(
                    constraints: const BoxConstraints(maxHeight: 200),
                    child: Image.file(
                      File(_image!.path),
                      width: double.infinity,
                      fit: BoxFit.scaleDown,
                    ),
                  )
                : const SizedBox.shrink(),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: _pickImage,
              icon: const Icon(Icons.image),
              label: const Text("Add Image"),
            ),
          ],
        ),
      ),
    );
  }
}
