class Post {
  String id;
  String title;
  String content;
  String? imagePath; // Resim yolu için ekledim

  Post({required this.id, required this.title, required this.content, this.imagePath});

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'content': content,
      'imagePath': imagePath, // Resim yolunu ekleyin
    };
  }

  static Post fromMap(String id, Map<String, dynamic> map) {
    return Post(
      id: id,
      title: map['title'] ?? '',
      content: map['content'] ?? '',
      imagePath: map['imagePath'], // Resim yolunu al
    );
  }
}
