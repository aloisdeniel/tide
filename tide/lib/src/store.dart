import 'package:meta/meta.dart';
import 'package:state_notifier/state_notifier.dart';
import 'package:tide/src/service.dart';

import 'action.dart';
import 'mapping.dart';

/// A simple state notifier that adds support for dispatching `StoreActions`.
///
/// The [StoreAction<State>] are executed to update the current [state], and [Action<T>] are mapped
/// from the mapper registered with [registerMapper<T>].
class Store<State> extends StateNotifier<State> {
  /// Create a new store from an [initialState].
  Store({
    @required State initialState,
  }) : super(initialState) {
    _serviceLocator = ServiceLocator(() => state);
  }

  /// Mappers are used to convert `StoreAction<[T]>` to `StoreAction<State>`.
  final Map<Type, Mapper> _mappers = {};

  ServiceLocator _serviceLocator;

  /// Dispatch an action into the store.
  ///
  /// If the action is an [StoreAction<State>], the action is executed, and each emitted state
  /// will replace the current [state].
  ///
  /// If the action is an [StoreAction<T>], then a registered mapper will be used to map the
  /// action and execute it as an [StoreAction<State>].
  ///
  /// The [onDispatchedAction] is called before the [StoreAction<State>] is executed.
  ///
  /// The [onStateChanged] method is called after each [state] update.
  ///
  /// The [onDispatchFailed] method is called if an exception is thrown during action execution.
  @mustCallSuper
  void dispatch(StoreAction action) async {
    if (action.stateType == State) {
      try {
        onDispatchedAction(action);
        await for (var newState
            in action.execute(() => state, dispatch, _serviceLocator)) {
          state = newState;
          onStateChanged(state);
        }
      } catch (error, stackTrace) {
        onDispatchFailed(action, error, stackTrace);
      }
    } else {
      final mapper = _getMapper(action.stateType);
      dispatch(MappedStoreAction<State>(mapper, action));
    }
  }

  /// Registering a mapper that allows to dispatch [StoreAction<Substate>] actions.
  ///
  /// The `state` parameter of this action is mapped from the state with the [reader], and
  /// the resulting new state is created out of the [writer] which merges the new substate
  /// into the current state, and produces a new state.
  void registerMapper<Substate>(MapperReader<State, Substate> reader,
      MapperWriter<State, Substate> writer) {
    _mappers[Substate] = Mapper<State, Substate>(
      reader: reader,
      writer: writer,
    );
  }

  /// Registering an external service.
  ///
  /// Services may be instantiated from action execute method when then rely on external systems.
  void registerService<Service>(
      Service Function(State state, ServiceLocator services) builder) {
    _serviceLocator.register<Service, State>(builder);
  }

  /// The [onDispatchFailed] method is called if an exception occurs during action execution.
  @protected
  void onDispatchFailed(
    StoreAction<State> action,
    dynamic error,
    StackTrace stackTrace,
  ) {}

  /// This method called whenever the state as changed from the [previousState]
  ///
  /// It may be usefull to trigger new actions regarding the transition, or for tracing reasons.
  @protected
  void onStateChanged(State previousState) {}

  /// This method is called whenever an [StoreAction<State>] is dispatched and before it is executed.
  @protected
  void onDispatchedAction(StoreAction<State> action) {}

  /// Gets the mapper for `StoreAction<[type]>`.
  Mapper _getMapper(Type type) {
    final mapper = _mappers[type];
    assert(mapper != null, 'No registered action mapper for type $type');
    return mapper;
  }
}
