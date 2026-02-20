import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:getaqi/models/userModel.dart';
import 'package:getaqi/providers/countProviders/counter_provider.dart';
import 'package:getaqi/providers/userListProvides/userListProviders.dart';
import 'package:getaqi/wigets.dart';

void main() {
  //count test
  test("counter test", () async {
    final container = ProviderContainer();
    addTearDown(container.dispose);

    container.read(counterProvider.notifier).state++;
    expect(container.read(counterProvider), 1);
    container.read(counterProvider.notifier).state++;
    expect(container.read(counterProvider), 2);

    for (int i = 0; i < 5; i++) {
      container.read(counterProvider.notifier).state++;
    }
    expect(container.read(counterProvider), 7);
  });

  //depended provider test

  test("double provider test", () {
    final container = ProviderContainer();
    addTearDown(container.dispose);

    container.read(counterProvider.notifier).state = 6;
    final doubleProvier = container.read(doubleCountProvider);
    expect(doubleProvier, 12);
  });

  //future provider etst

  test("future api test", () async {
    // final container = ProviderContainer(overrides: [userProvider.overrideWithValue(AsyncData("nishant"))]);
    final container = ProviderContainer();
    addTearDown(container.dispose);

    final user = await container.read(userProvider.future);

    expect(user, "Ankit");
    //expect(user, "Ankit");
  });

  test("loading test", () async {
    final container = ProviderContainer();
    addTearDown(container.dispose);
    final user = container.read(userProvider);

    expect(user.isLoading, true);
    final userloaded = await container.read(userProvider.future);

    expect(userloaded, "Ankit");
  });

  test("stream test", () async {
    final container = ProviderContainer();

    addTearDown(container.dispose);

    List<int> mylist = [];

    final sub = container.listen(numberStreamProvider, (_, next) {
      next.whenData(mylist.add);
    }, fireImmediately: true);

    await Future.delayed(const Duration(milliseconds: 50));

    expect(mylist, containsAll([1, 2, 3]));

    sub.close();
  });

  test('state notifier test', () {
    final container = ProviderContainer();
    addTearDown(container.dispose);

    final notifier = container.read(counterNotifierprovider.notifier);

    notifier.increment();
    notifier.increment();

    expect(container.read(counterNotifierprovider), 2);

    notifier.decrement();

    expect(container.read(counterNotifierprovider), 1);
    notifier.reset();

    expect(container.read(counterNotifierprovider), 0);
  });

  test("async notifier test", () async {
    final container = ProviderContainer();
    addTearDown(container.dispose);

    final res = await container.read(userAsyncProvider.future);
    expect(res, "Ankit");
    final ref = container.read(userAsyncProvider.notifier).refreshUser();
    final res_new1 = container.read(userAsyncProvider);
    expect(res_new1.isLoading, false);
    final res_new = container.read(userAsyncProvider);
    expect(res_new.value, "Refreshed");
  });

  test("api test", () async {
    final container = ProviderContainer();
    addTearDown(container.dispose);

    final res = container.read(dataProvider);
    expect(res, "real data");
  });

  test("mock test", () async {
    final container = ProviderContainer(
      overrides: [apiServiceProvider.overrideWithValue(FakeApiService())],
    );

    addTearDown(container.dispose);
    final res = container.read(dataProvider);
    expect(res, "fake data");
  });

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

  test("users async test", () async {
    final container = ProviderContainer();
    addTearDown(container.dispose);
    await container.read(usersProvider.future);
    final noifier = await container.read(usersProvider.notifier);
    await noifier.addUser(User(id: 100, name: "test", isLiked: true));
    final data = await container.read(usersProvider).value;
    expect(data!.last.id, 100);
    expect(data!.length, 4);
  });
}
