# State management

`flutter_bloc`, **Cubit-first**.

## Why Cubit > Bloc by default

Cubit is Bloc minus events. The mental load is lower; the trace in
`BlocObserver` is just `previous → current`. Use Bloc with events only
when the domain is genuinely event-driven (e.g. a server stream of
discrete updates).

A new state-management framework requires an accepted PROP- spec.

## Cubit shape

```dart
@injectable
class FooCubit extends Cubit<FooState> {
  FooCubit(this._repo) : super(const FooState.initial());

  final FooRepository _repo;

  Future<void> load() async {
    emit(const FooState.loading());
    final result = await _repo.fetch();
    emit(result.match(
      success: FooState.loaded,
      failure: (f) => FooState.error(f.code),
    ));
  }
}
```

```dart
@freezed
sealed class FooState with _$FooState {
  const factory FooState.initial() = _Initial;
  const factory FooState.loading() = _Loading;
  const factory FooState.loaded(Foo data) = _Loaded;
  const factory FooState.error(String code) = _Error;
}
```

## In the widget tree

```dart
BlocProvider(
  create: (_) => getIt<FooCubit>()..load(),
  child: BlocBuilder<FooCubit, FooState>(
    builder: (context, state) => state.when(
      initial: () => const SizedBox.shrink(),
      loading: () => const DSLoader(),
      loaded: (foo) => FooView(foo),
      error: (code) => FooErrorView(code: code),
    ),
  ),
)
```

## Side effects

`BlocListener` for navigation / snackbars / dialogs.
`BlocConsumer` if you need both.
