import 'package:getaqi/models/userModel.dart';

class UserService {
  List<User> _usersList = [];

  Future<List<User>> getUsers() async {
    await Future.delayed(Duration(seconds: 1));
    if (_usersList.isEmpty) {
      _usersList.addAll([
        User(id: 1, name: "user 1", isLiked: false),
        User(id: 2, name: "user 2", isLiked: false),
        User(id: 3, name: "user 3", isLiked: false),
      ]);
      return _usersList;
    }
    return _usersList;
  }

  Future<void> addUser(User user) async {
    await Future.delayed(Duration(seconds: 1));
    _usersList.add(user);
    getUsers();
  }

  Future<void> updateUser(User user) async {
    await Future.delayed(Duration(seconds: 1));
    final index = _usersList.indexWhere((_user) => _user.id == user.id);
    _usersList[index] = user.copyWith(name: user.name,isLiked: user.isLiked);
    getUsers();
  }

  Future<void> deleteUser(User _user) async {
    await Future.delayed(Duration(seconds: 1));
     _usersList.removeWhere((user) => user.id == _user.id);
    getUsers();
  }
}
