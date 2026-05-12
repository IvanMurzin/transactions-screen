// Shared mock helpers for unit and widget tests.
//
// Add project-specific mocks here as the product grows.
// Each feature should have its own mock file in test/<layer>/<feature>/,
// but cross-cutting stubs belong here.
//
// Example usage in a Cubit test:
//
//   class MockAuthRepository extends Mock implements AuthRepository {}
//
//   void main() {
//     late MockAuthRepository repo;
//     late AuthCubit cubit;
//
//     setUp(() {
//       repo = MockAuthRepository();
//       cubit = AuthCubit(repo);
//     });
//
//     tearDown(() => cubit.close());
//
//     blocTest<AuthCubit, AuthState>(
//       'emits [loading, authenticated] on successful sign-in',
//       build: () {
//         when(() => repo.signIn(any(), any())).thenAnswer((_) async {});
//         return cubit;
//       },
//       act: (c) => c.signIn('user@example.com', 'secret'),
//       expect: () => [AuthState.loading(), AuthState.authenticated()],
//     );
//   }
