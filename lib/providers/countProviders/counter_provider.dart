import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';

final counterProvider = StateProvider<int>((ref) => 0);

final doubleCountProvider = StateProvider<int>((ref) {
  return ref.watch(counterProvider) * 2;
});

final userProvider = FutureProvider<String>((ref) async {
  await Future.delayed(const Duration(milliseconds: 50));
  return "Ankit";
});

final numberStreamProvider = StreamProvider<int>((ref) async* {
  yield 1;
  await Future.delayed(const Duration(milliseconds: 10));
  yield 2;
  await Future.delayed(const Duration(milliseconds: 10));
  yield 3;
});

class CounterNotifier extends StateNotifier<int> {
  CounterNotifier() : super(0);

  void increment() => state++;

  void decrement() => state--;

  void reset() => state = 0;
}

final counterNotifierprovider = StateNotifierProvider<CounterNotifier, int>((
  ref,
) {
  return CounterNotifier();
});


class UserAsyncNotifier extends AsyncNotifier<String>{
  @override
  Future<String> build() async {
  await Future.delayed(Duration(milliseconds: 500));
  return "Ankit";
  }


  Future<void>refreshUser()async{
    state=AsyncLoading();
    state=AsyncData("Refreshed");
  }

}

final userAsyncProvider=AsyncNotifierProvider<UserAsyncNotifier,String>(UserAsyncNotifier.new);

class ApiService{
  String getData()=>"real data";
}

final apiServiceProvider=Provider<ApiService>((ref)=>ApiService());

final dataProvider=Provider<String>((ref){
  final api=ref.read(apiServiceProvider);
  return api.getData();
});


class FakeApiService extends ApiService{
  @override
  String getData()=>"fake data";
}