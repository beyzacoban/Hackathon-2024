class Post {
  final String id;
  final String content;
  final String? imageUrl;
  final String? userId; // Kullanıcı kimliği
  final String? username; // Kullanıcı adı
  final String? name; // Kullanıcı ismi
  // Tarih alanı

  Post({
    required this.id,
    required this.content,
    this.imageUrl,
    this.userId, // Kullanıcı kimliği
    this.username, // Kullanıcı adı
    this.name, // Kullanıcı ismi
  });

  // Post'u Firestore'a kaydederken kullanılan harita yapısı
  Map<String, dynamic> toMap() {
    return {
      'id': id,

      'content': content,
      'imageUrl': imageUrl,
      'userId': userId, // Firebase'e kullanıcı kimliğini gönder
      'username': username, // Firebase'e kullanıcı adını gönder
      'name': name, // Firebase'e kullanıcı ismini gönder
      // Tarihi ISO formatında kaydet
    };
  }

  // Firestore'dan verileri çekerken kullanılan yapı
  static Post fromMap(String id, Map<String, dynamic> map) {
    return Post(
      id: id,

      content: map['content'] as String,
      imageUrl: map['imageUrl'] as String?,
      userId: map['userId'] as String?, // Firestore'dan kullanıcı kimliğini al
      username: map['username'] as String?, // Firestore'dan kullanıcı adını al
      name: map['name'] as String?, // Firestore'dan kullanıcı ismini al
    );
  }
}
