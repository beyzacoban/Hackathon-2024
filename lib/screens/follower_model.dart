class Follower {
  final String id;
  final String name;
  final String username; // username alanını ekliyoruz

  Follower({
    required this.id,
    required this.name,
    required this.username, // username parametresini burada tanımlıyoruz
  });

  factory Follower.fromMap(Map<String, dynamic> data, String id) {
    return Follower(
      id: id,
      name: data['name'] ?? '', // Veri haritasından isim al
      username: data['username'] ?? '', // Veri haritasından kullanıcı adını al
    );
  }
}
