import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:getaqi/models/storeModel.dart';
import 'package:getaqi/providers/storeProviders/storeProviders.dart';
import 'package:getaqi/ui/user_stores/storeList.dart';

class UserStors extends ConsumerStatefulWidget {
  const UserStors({super.key});

  @override
  ConsumerState<UserStors> createState() => _UserStorsState();
}

class _UserStorsState extends ConsumerState<UserStors> {
  @override
  Widget build(BuildContext context) {

    
    return Scaffold(
        floatingActionButton: FloatingActionButton(onPressed: (){
          final state=ref.read(storeNotifierProvider.notifier);
          state.addStore(  Store(
            id: DateTime.now().millisecondsSinceEpoch,
            name: "store one",
          ),);

        },child: Icon(Icons.add),),
        body: StoreList());
  }
}
