import 'package:tide/tide.dart';

@immutable
class CounterState {
  const CounterState(this.value, this.isLoading);
  final int value;
  final bool isLoading;

  @override
  bool operator ==(dynamic other) {
    return identical(this, other) ||
        (other is CounterState &&
            value == other.value &&
            isLoading == other.isLoading);
  }

  @override
  int get hashCode =>
      runtimeType.hashCode ^ value.hashCode ^ isLoading.hashCode;
}

class Increment extends StoreAction<CounterState> {
  @override
  Stream<CounterState> execute(
      StateReader<CounterState> state, Dispatcher dispatch) async* {
    if (!state().isLoading) {
      yield CounterState(state().value + 1, false);
    }
  }
}

class AddServerValue extends StoreAction<CounterState> {
  @override
  Stream<CounterState> execute(
      StateReader<CounterState> state, Dispatcher dispatch) async* {
    if (!state().isLoading) {
      yield CounterState(state().value, true);
      final serverValue = await const ServerClient().getValue();
      yield CounterState(state().value + serverValue, false);
    }
  }
}

class ResetThenAddValueverySecond extends StoreAction<CounterState> {
  const ResetThenAddValueverySecond(this.value);
  final int value;

  @override
  Stream<CounterState> execute(
      StateReader<CounterState> state, Dispatcher dispatch) async* {
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

class ServerClient {
  const ServerClient();
  Future<int> getValue() async {
    await Future.delayed(const Duration(seconds: 2));
    return 128;
  }
}
