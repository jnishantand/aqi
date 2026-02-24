import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:getaqi/wigets.dart';

void main() {
  //widget test
  testWidgets("test ontap", (tester) async {
    bool isTaped = false;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: MyButton(
            onTap: () {
              isTaped = true;
            },
          ),
        ),
      ),
    );

    await tester.tap(find.text("button"));
    await tester.pump();

    expect(isTaped, true);
    expect(find.text("button"), findsOneWidget);
    expect(find.byType(MaterialButton), findsOneWidget);
  });
}
