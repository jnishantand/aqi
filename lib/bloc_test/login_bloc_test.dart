// import 'package:flutter_test/flutter_test.dart';
// import 'package:bloc_test/bloc_test.dart';
//
// import 'package:mocktail/mocktail.dart';
//
// class MockAuthRepo extends Mock implements AuthRepo {}
//
// void main() {
//   late MockAuthRepo mockRepo;
//
//   setUp(() {
//     mockRepo = MockAuthRepo();
//   });
//
//   group('LoginBloc Tests', () {
//
//     // ✅ TEST 1: SUCCESS STATE
//     blocTest<LoginBloc, LoginState>(
//       'emits [isLoading=true, isLoading=false with message="nishant"] when login is successful',
//       build: () {
//         when(() => mockRepo.getUserData())
//             .thenAnswer((_) async => "Success");
//         return LoginBloc(mockRepo);
//       },
//       act: (bloc) => bloc.add(LoginButtonPressed()),
//       expect: () => [
//         // First state: loading = true
//         predicate<LoginState>((state) =>
//         state.isLoading == true &&
//             state.error == null &&
//             state.message == null
//         ),
//         // Second state: loading = false, success message = "nishant"
//         predicate<LoginState>((state) =>
//         state.isLoading == false &&
//             state.error == null &&
//             state.message == "nishant"
//         ),
//       ],
//     );
//
//     // ✅ TEST 2: EMPTY RESPONSE STATE
//     blocTest<LoginBloc, LoginState>(
//       'emits [isLoading=true, isLoading=false with message="failed"] when user data is empty',
//       build: () {
//         when(() => mockRepo.getUserData())
//             .thenAnswer((_) async => "");
//         return LoginBloc(mockRepo);
//       },
//       act: (bloc) => bloc.add(LoginButtonPressed()),
//       expect: () => [
//         // First state: loading = true
//         predicate<LoginState>((state) =>
//         state.isLoading == true &&
//             state.error == null
//         ),
//         // Second state: loading = false, failed message
//         predicate<LoginState>((state) =>
//         state.isLoading == false &&
//             state.message == "failed" &&
//             state.error == null
//         ),
//       ],
//     );
//
//     // ✅ TEST 3: ERROR STATE
//     blocTest<LoginBloc, LoginState>(
//       'emits [isLoading=true, isLoading=false with error] when exception occurs',
//       build: () {
//         when(() => mockRepo.getUserData())
//             .thenThrow(Exception('Network error'));
//         return LoginBloc(mockRepo);
//       },
//       act: (bloc) => bloc.add(LoginButtonPressed()),
//       expect: () => [
//         // First state: loading = true
//         predicate<LoginState>((state) =>
//         state.isLoading == true &&
//             state.error == null
//         ),
//         // Second state: loading = false, error and message="failed"
//         predicate<LoginState>((state) =>
//         state.isLoading == false &&
//             state.message == "failed" &&
//             state.error != null &&
//             state.error!.contains('Network error')
//         ),
//       ],
//     );
//
//     // ✅ TEST 4: INITIAL STATE
//     test('initial state is correct', () {
//       final bloc = LoginBloc(mockRepo);
//       expect(bloc.state.isLoading, null);
//       expect(bloc.state.error, null);
//       expect(bloc.state.message, null);
//     });
//
//     // ✅ TEST 5: CLOSE BLOC
//     test('bloc closes without errors', () {
//       final bloc = LoginBloc(mockRepo);
//       expect(bloc.close, returnsNormally);
//     });
//   });
// }