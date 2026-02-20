import 'package:flutter_riverpod/legacy.dart';
import 'package:getaqi/models/storeModel.dart';


class StoreStates {
  final bool loading;
  final List<Store> storeList;
  final String? fail;

  StoreStates({ this.loading=false, this.storeList=const [], this.fail});

  StoreStates copywith({bool? load,List<Store>? store,String? err}){
    return StoreStates(loading: load??loading, storeList: store??storeList, fail: err);
  }
}

class StoreProvider extends StateNotifier<StoreStates>{
  StoreProvider():super(StoreStates());

  Future<void> fetchStores()async{
    await Future.delayed(Duration(seconds: 2));
    state=state.copywith(load: false,store: [Store(id: 1, name: "MyStore one"),Store(id: 2, name: "MyStore two"),]);
  }

  Future<void> addStore(Store store)async{
    await Future.delayed(Duration(seconds: 2));
    state=state.copywith(store: [...state.storeList,store]);
  }

  Future<void> deleteStore(int id)async{
    await Future.delayed(Duration(seconds: 2));
    state=state.copywith(store: state.storeList.where((store)=>store.id!=id).toList());
  }

}
final storeNotifierProvider=StateNotifierProvider<StoreProvider,StoreStates>((ref)=>StoreProvider());