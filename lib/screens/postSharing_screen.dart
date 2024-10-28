import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
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
  if (_postController.text.isNotEmpty || _image != null) {
    final newPost = Post(content: _postController.text, imagePath: _image?.path);
    try {
      // Firebase Firestore'a gönderiyi kaydedin
      await FirebaseFirestore.instance.collection('posts').add(newPost.toMap());

      // Paylaşım başarılı, ekrandan geri dön
      if (mounted) {
        Navigator.of(context).pop(newPost);
      }
    } catch (e) {
      // Hata durumunda mesaj gösterin
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error sharing post: $e')),
        );
      }
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
        title: const Text('Share a Post'),
        actions: [
          IconButton(
            icon: const Icon(Icons.send),
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
              maxLines: 5,
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
                    color: Colors.amber,
                    constraints: const BoxConstraints(
                      maxHeight: 200, // Resmin maksimum yüksekliği
                    ),
                    child: Image.file(
                      File(_image!.path),
                      width: double.infinity, // Ekranın tamamına genişle
                      fit: BoxFit.scaleDown, // Resmi küçült
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
