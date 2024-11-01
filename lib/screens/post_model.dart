class Post {
  final String id;
  final String title;
  final String content;
  final String? imagePath;
  final String? userId; // Kullanıcı kimliği

  Post({
    required this.id,
    required this.title,
    required this.content,
    this.imagePath,
    this.userId, // Kullanıcı kimliği ekleyin
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'content': content,
      'imagePath': imagePath,
      'userId': userId, // Firebase'e kullanıcı kimliğini gönderin
    };
  }

  static Post fromMap(String id, Map<String, dynamic> map) {
    return Post(
      id: id,
      title: map['title'] as String,
      content: map['content'] as String,
      imagePath: map['imagePath'] as String?,
      userId:
          map['userId'] as String?, // Firestore'dan kullanıcı kimliğini alın
    );
  }
}
