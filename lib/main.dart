import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:getaqi/providers/countProviders/count_provider.dart';
import 'package:getaqi/ui/dashoboard/dash.dart';
import 'package:getaqi/ui/homePage.dart' show HomePage;

void main() {
  runApp(ProviderScope(observers: [
    
  ], child: const MyApp()));
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  int count = 0;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: Colors.blue,
      ),
      home: const HomePage(),
    );
  }
}

class MyCounter extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final counter = ref.watch(countProvider);
    return Scaffold(
      floatingActionButton: Align(
        alignment: AlignmentGeometry.bottomCenter,
        child: FloatingActionButton(onPressed: (){

          ref.read(countProvider.notifier).state++;
          if(counter==5){
            Navigator.push(context, MaterialPageRoute(builder: (_)=>DashBoard()));
          }
        },child: Icon(Icons.add),),
      ),
      body: SafeArea(
        child: Center(child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text("Counter"),
          Text("${counter}")
        ],),)
      ),
    );
  }
}
