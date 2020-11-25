/// Dispatched to a [Store<State>] to update its state by emmiting
/// values from the [execute] method.
abstract class StoreAction<State> {
  /// Create a new action.
  const StoreAction();

  /// The [State] runtime type.
  Type get stateType => State;

  /// Execute asynchronous logic to send state updates to a [Store<State>].
  ///
  /// The [state] reads the current value of the store. It should be read regularly during all the execution to make
  /// sure to sends up-to-date versions of a new resulting state.
  ///
  /// The [dispatch] allows to trigger new actions execution from the store.
  Stream<State> execute(
    StateReader<State> state,
    Dispatcher dispatch,
  );
}

/// Gets the current value of a [State].
typedef StateReader<State> = State Function();

/// Trigger new actions execution from a store.
typedef Dispatcher = void Function(StoreAction action);
