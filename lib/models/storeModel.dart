class Store{

  final int id;
  final String? name;
  Store({required this.id,required this.name});

 Store copyWith({String? name}){
   return Store(id:id,name: name??name);
 }

}


