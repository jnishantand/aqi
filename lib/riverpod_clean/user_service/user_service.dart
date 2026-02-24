import 'package:getaqi/riverpod_clean/user_model/user_model.dart';

class UserService {
  List<UserModel> _list = [];
  Future<List<UserModel>> fetchUsers() async {
    await Future.delayed(const Duration(seconds: 2));
    if (_list.isEmpty) {
      _list = [
        UserModel(id: 1, name: "John Doe"),
        UserModel(id: 2, name: "Jane Smith"),
        UserModel(id: 3, name: "Bob Johnson"),
      ];
    }
    return _list;
  }

  Future<void> addUser(UserModel user) async {
    await Future.delayed(const Duration(seconds: 1));
    _list.add(user);
  }

  Future<void> deleteUser(int id) async {
    await Future.delayed(const Duration(seconds: 1));
    _list.removeWhere((user) => user.id == id);
  }

  Future<void> updateUser(UserModel updatedUser) async {
    await Future.delayed(const Duration(seconds: 1));
    int index = _list.indexWhere((user) => user.id == updatedUser.id);
    if (index != -1) {
      _list[index] = updatedUser;
    }
  }
}
