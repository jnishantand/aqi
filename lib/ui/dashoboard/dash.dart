import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:getaqi/providers/userListProvides/userListProviders.dart';
import 'package:getaqi/ui/user_stores/user_store.dart';

class DashBoard extends ConsumerStatefulWidget {
  const DashBoard({super.key});

  @override
  ConsumerState<DashBoard> createState() => _DashBoardState();
}

class _DashBoardState extends ConsumerState<DashBoard> {
  @override
  void initState() {
    super.initState();

    Future.microtask(() async {
      final users = await ref.read(userListProvider.future);
      debugPrint(users.toString());
    });
  }

  @override
  Widget build(BuildContext context) {
    final usersAsync = ref.watch(userListProvider);

    return Scaffold(
      floatingActionButton: FloatingActionButton(onPressed: (){
        ref.refresh(userListProvider);
      },child: Icon(Icons.refresh),),
      appBar: AppBar(title: const Text("Users")),
      body: usersAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, st) => Center(child: Text("Error: ${e.toString()}")),
        data: (users) => ListView.builder(
          itemCount: users.length,
          itemBuilder: (context, index) {
            final user = users[index];
            return ListTile(
              title: Text(user.name),
              onTap: () {
               Navigator.push(context, MaterialPageRoute(builder: (c)=>UserStors()));
              },
            );
          },
        ),
      ),
    );
  }
}
