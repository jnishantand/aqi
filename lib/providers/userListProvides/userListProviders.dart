import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:getaqi/Services/user_service.dart';
import 'package:getaqi/models/userModel.dart';


final userActionLoadingProvider = StateProvider<bool>((ref) => false);

final userServiceProvider = Provider<UserService>((ref) => UserService());

class UserNotifier extends AsyncNotifier<List<User>> {
  @override
  FutureOr<List<User>> build() async {
    return await ref.watch(userServiceProvider).getUsers();
  }

  Future<void> addUser(User user) async {
    try {
      state = AsyncLoading();
      await ref.read(userServiceProvider).addUser(user);
      final users = await ref.read(userServiceProvider).getUsers();
      state = AsyncData(users);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> deleteUser(User user) async {
    try {
      state = AsyncLoading();
      await ref.read(userServiceProvider).deleteUser(user);
      final users = await ref.read(userServiceProvider).getUsers();
      state = AsyncData(users);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> updateUser(User user) async {
    try {
      ref.read(userActionLoadingProvider.notifier).state = true;
      await ref.read(userServiceProvider).updateUser(user);
      final users = await ref.read(userServiceProvider).getUsers();
      state = AsyncData(users);
      ref.read(userActionLoadingProvider.notifier).state = false;

    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }
}

final usersProvider = AsyncNotifierProvider<UserNotifier, List<User>>(
  UserNotifier.new,
);
