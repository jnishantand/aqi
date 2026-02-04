import 'package:getaqi/models/userModel.dart';
import 'package:getaqi/providers/userListProvides/userListProviders.dart';

class ApiService {
  static Future<List<User>> getUsers() async {
    await Future.delayed(const Duration(seconds: 2));
    return [
      User(id: 1, name: "name1"),
      User(id: 2, name: "name2"),
      User(id: 3, name: "name3"),
    ];
  }
}

