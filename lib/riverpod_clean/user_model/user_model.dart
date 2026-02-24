class UserModel {
  final int id;
  final String name;
  UserModel({required this.id, required this.name});

  UserModel copyWith({int? id, String? name}) {
    return UserModel(id: id ?? this.id, name: name ?? this.name);
  }
}
