import 'package:flutter/material.dart';

class MyButton extends StatelessWidget {
  final VoidCallback onTap;
  const MyButton({super.key,required this.onTap});

  @override
  Widget build(BuildContext context) {
    return MaterialButton(onPressed: onTap,child: Center(child: Text("button"),),);
  }
}
