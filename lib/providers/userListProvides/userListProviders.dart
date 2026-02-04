import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:getaqi/apiService/api_service.dart';
import 'package:getaqi/models/userModel.dart';



final userListProvider = FutureProvider<List<User>>((ref) async {
  return ApiService.getUsers();
});
