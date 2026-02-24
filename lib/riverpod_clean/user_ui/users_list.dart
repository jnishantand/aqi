import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:getaqi/riverpod_clean/user_controller/user_controller.dart';
import 'package:getaqi/riverpod_clean/user_model/user_model.dart';

class UsersList extends ConsumerStatefulWidget {
  const UsersList({super.key});

  @override
  ConsumerState<UsersList> createState() => _UsersListState();
}

class _UsersListState extends ConsumerState<UsersList> {
  @override
  Widget build(BuildContext context) {
    final usersAsync = ref.watch(userControllerProvider);

    final users = usersAsync.value ?? [];
    final isLoading = usersAsync.isLoading;

    return Scaffold(
      body: Column(
        children: [
          Text("User List"),
          Expanded(
            child: Stack(
              children: [
                if (isLoading)
                  Positioned(
                    bottom: 20,
                    left: 0,
                    right: 0,

                    child: Container(
                      width: 20,
                      height: 2,
                      color: Colors.amber,
                      child: LinearProgressIndicator(),
                    ),
                  ),
                ListView.builder(
                  itemCount: users.length,
                  itemBuilder: (context, index) {
                    final user = users[index];
                    return ListTile(
                      title: Text(user.name),
                      trailing: IconButton(
                        icon: const Icon(Icons.delete),
                        onLongPress: () {
                          showDialog(
                            context: context,
                            builder: (context) => StatefulBuilder(
                              builder: (context, setState) {
                                final TextEditingController controller =
                                    TextEditingController(text: user.name);
                                return AlertDialog(
                                  title: const Text("Update User"),
                                  content: TextField(
                                    textInputAction: TextInputAction
                                        .done, // shows Done/Enter
                                    onSubmitted: (value) {
                                      if (controller.text.trim().isEmpty) {
                                        return;
                                      }
                                      ref
                                          .read(userControllerProvider.notifier)
                                          .updateUser(
                                            user.copyWith(
                                              name: controller.text,
                                            ),
                                          );
                                      Navigator.pop(context);
                                    },
                                    controller: controller,
                                    onChanged: (val) {},
                                    decoration: const InputDecoration(
                                      hintText: "Enter new name",
                                    ),
                                  ),
                                  actions: [
                                    TextButton(
                                      onPressed: () {
                                        if (controller.text.trim().isEmpty) {
                                          return;
                                        }
                                        ref
                                            .read(
                                              userControllerProvider.notifier,
                                            )
                                            .updateUser(
                                              user.copyWith(
                                                name: controller.text,
                                              ),
                                            );
                                        Navigator.pop(context);
                                      },
                                      child: const Text("Update"),
                                    ),
                                  ],
                                );
                              },
                            ),
                          );
                        },
                        onPressed: () {
                          ref
                              .read(userControllerProvider.notifier)
                              .deleteUser(user.id);
                        },
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          final newUser = UserModel(
            id: DateTime.now().millisecondsSinceEpoch,
            name: "User ${DateTime.now().second}",
          );
          ref.read(userControllerProvider.notifier).addUser(newUser);
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
