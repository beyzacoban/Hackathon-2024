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

  // Resim seçme fonksiyonu
  Future<void> _pickImage() async {
    final XFile? selectedImage =
        await _picker.pickImage(source: ImageSource.gallery);
    if (selectedImage != null) {
      setState(() {
        _image = selectedImage; // Seçilen resmi duruma kaydet
      });
    }
  }

  // Gönderiyi paylaşma fonksiyonu
  Future<void> _sharePost() async {
    if (_postController.text.isNotEmpty || _image != null) {
      // Gönderi oluştur
      final newPost = Post(
        id: DateTime.now().toString(), // Benzersiz bir ID oluştur
        title: "Yeni Gönderi", // Başlık, isteğe bağlı olarak değiştirilebilir
        content: _postController.text,
      );
      try {
        await FirebaseFirestore.instance.collection('posts').add(newPost.toMap());

        if (mounted) {
          Navigator.of(context).pop(newPost); // Gönderiyi paylaştıktan sonra geri dön
        }
      } catch (e) {
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
            // Metin girişi için TextField
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
            // Resim görüntüleme
            _image != null
                ? Container(
                    color: Colors.amber,
                    constraints: const BoxConstraints(
                      maxHeight: 200,
                    ),
                    child: Image.file(
                      File(_image!.path),
                      width: double.infinity,
                      fit: BoxFit.scaleDown,
                    ),
                  )
                : const SizedBox.shrink(),
            const SizedBox(height: 20),
            // Resim ekleme butonu
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
