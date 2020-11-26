import 'package:example/services.dart';
import 'package:flutter_tide/flutter_tide.dart';

import 'state.dart';

class Increment extends StoreAction<CounterState> {
  @override
  Stream<CounterState> execute(
    StateReader<CounterState> state,
    Dispatcher dispatch,
    ServiceLocator services,
  ) async* {
    if (!state().isLoading) {
      yield CounterState(state().value + 1, false);
    }
  }
}

class AddServerValue extends StoreAction<CounterState> {
  @override
  Stream<CounterState> execute(
    StateReader<CounterState> state,
    Dispatcher dispatch,
    ServiceLocator services,
  ) async* {
    if (!state().isLoading) {
      yield CounterState(state().value, true);
      final client = services.create<ServerClient>();
      final serverValue = await client.getValue();
      yield CounterState(state().value + serverValue, false);
    }
  }
}

class ResetThenAddValueverySecond extends StoreAction<CounterState> {
  const ResetThenAddValueverySecond(this.value);
  final int value;

  @override
  Stream<CounterState> execute(
    StateReader<CounterState> state,
    Dispatcher dispatch,
    ServiceLocator services,
  ) async* {
    if (!state().isLoading) {
      yield CounterState(0, true);
      for (var i = 0; i < 5; i++) {
        await Future.delayed(const Duration(seconds: 1));
        yield CounterState(state().value + value, true);
      }
      yield CounterState(state().value, false);
    }
  }
}
