class Post {
  final String content;
  final String? imagePath;

  Post({required this.content, this.imagePath});

  Map<String, dynamic> toMap() {
    return {
      'content': content,
      'imagePath': imagePath,
    };
  }

  factory Post.fromMap(Map<String, dynamic> map) {
    return Post(
      content: map['content'] as String,
      imagePath: map['imagePath'] as String?,
    );
  }
}
