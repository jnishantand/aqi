class User {
  final int id;
  final String name;
  final bool isLiked;

  User({required this.id, required this.name, required this.isLiked});

  User copyWith({String? name, bool? isLiked}) {
    return User(
      id: this.id,
      name: name ?? this.name,
      isLiked: isLiked ?? this.isLiked,
    );
  }
}
