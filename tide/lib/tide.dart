library tide;

import 'package:meta/meta.dart';
import 'package:state_notifier/state_notifier.dart';

/// A simple state notifier that adds support for dispatching a `StoreAction`.
class Store<State> extends StateNotifier<State> {
  Store({
    @required State initialState,
  }) : super(initialState);

  @mustCallSuper
  void dispatch(StoreAction<State> action) async {
    try {
      onDispatchedAction(action);
      await for (var newState in action.execute(() => state, dispatch)) {
        state = newState;
        onStateChanged(state);
      }
    } catch (error, stackTrace) {
      onDispatchFailed(action, error, stackTrace);
    }
  }

  @protected
  void onDispatchFailed(
    StoreAction<State> action,
    dynamic error,
    StackTrace stackTrace,
  ) {}

  @protected
  void onStateChanged(State previousState) {}

  @protected
  void onDispatchedAction(StoreAction<State> previousState) {}
}

abstract class StoreAction<State> {
  const StoreAction();

  Stream<State> execute(
    StateReader<State> state,
    Dispatcher<State> dispatch,
  );
}

typedef StateReader<State> = State Function();

typedef Dispatcher<State> = void Function(StoreAction<State> event);
