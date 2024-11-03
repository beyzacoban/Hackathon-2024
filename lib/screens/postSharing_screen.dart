import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart'; 
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

    if (currentUser == null) {
      _showSnackBar('User is not logged in.');
      return;
    }

    final userInfo = await _getUserInfo(currentUser.uid);
    if (userInfo == null) {
      _showSnackBar('Error fetching user info.');
      return;
    }

    if (_postController.text.isNotEmpty || _image != null) {
      String? imageUrl;

      if (_image != null) {
        try {
          final storageRef = FirebaseStorage.instance.ref().child(
              'post_images/${DateTime.now().millisecondsSinceEpoch}.png');
          await storageRef.putFile(File(_image!.path));
          imageUrl = await storageRef.getDownloadURL();
        } catch (e) {
          _showSnackBar('Error uploading image: $e');
          return;
        }
      }

      String postId = FirebaseFirestore.instance.collection('posts').doc().id;
      final post = Post(
        id: postId,
        content: _postController.text,
        imageUrl: imageUrl,
        userId: currentUser.uid,
        username: userInfo['username'],
        name: userInfo['name'],
        profileImageUrl: userInfo['profileImageUrl'],
      );

      try {
        await FirebaseFirestore.instance
            .collection('posts')
            .doc(postId)
            .set(post.toMap());

        _showSnackBar('Post shared successfully!');
        Navigator.of(context).pop();
      } catch (e) {
        _showSnackBar('Error sharing post: $e');
      }
    } else {
      _showSnackBar('Please add content or an image.');
    }
  }

  Future<Map<String, String>?> _getUserInfo(String userId) async {
    try {
      DocumentSnapshot userSnapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .get();

      if (userSnapshot.exists) {
        final data = userSnapshot.data() as Map<String, dynamic>;
        return {
          'username': data['username'] ?? 'Unknown',
          'name': data['name'] ?? 'Unknown',
        };
      }
    } catch (e) {
      print('Error fetching user info: $e');
    }
    return null;
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Paylaş'),
        // centerTitle: true,
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
                hintText: "Neler Düşünüyorsun?",
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
              label: const Text("Resim Ekle"),
            ),
          ],
        ),
      ),
    );
  }
}
