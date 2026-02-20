import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:getaqi/providers/storeProviders/storeProviders.dart';

class StoreList extends ConsumerWidget{
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final storeState=ref.watch(storeNotifierProvider);

    if(storeState.loading)return Center(child: CircularProgressIndicator(),);

    if(storeState.fail==true) Center(child: Text("Failed"),);

    return ListView.builder(

        itemCount:storeState.storeList.length,
        itemBuilder: (c,i){

      final store=storeState.storeList[i];
      return ListTile(leading: Text(store.name??"NA",),trailing: IconButton(onPressed: (){

        final state=ref.read(storeNotifierProvider.notifier);
        state.deleteStore(store.id);
      }, icon: Icon(Icons.delete,size: 5,)),);
    });

  }

}