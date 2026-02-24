import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:getaqi/riverpod_clean/user_model/user_model.dart';
import 'package:getaqi/riverpod_clean/user_service/user_service.dart';

class UserController extends AsyncNotifier<List<UserModel>> {
  final UserService _userService;
  UserController(this._userService);

  @override
  FutureOr<List<UserModel>> build() async {
    return await _userService.fetchUsers();
  }

  addUser(UserModel user) async {
    state = AsyncValue.loading();
    try {
      await _userService.addUser(user);
      state = AsyncValue.data(await _userService.fetchUsers());
    } catch (e, at) {
      state = AsyncValue.error(e, at);
    }
  }

  deleteUser(int id) async {
    state = AsyncValue.loading();
    try {
      await _userService.deleteUser(id);
      state = AsyncValue.data(await _userService.fetchUsers());
    } catch (e, at) {
      state = AsyncValue.error(e, at);
    }
  }

  updateUser(UserModel user) async {
    state = AsyncValue.loading();
    try {
      await _userService.updateUser(user);
      state = AsyncValue.data(await _userService.fetchUsers());
    } catch (e, at) {
      state = AsyncValue.error(e, at);
    }
  }
}

final userControllerProvider =
    AsyncNotifierProvider<UserController, List<UserModel>>(
      () => UserController(UserService()),
    );
