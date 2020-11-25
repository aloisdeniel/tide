import 'package:meta/meta.dart';

import 'action.dart';

/// A [StoreAction<T>] that is converted to a [StoreAction<State>] by converting its parameters
/// from a given mapper.
class MappedStoreAction<State> extends StoreAction<State> {
  /// Create a new action from the mapper and a [subaction] that has the execution logic from
  /// a child state.
  const MappedStoreAction(this._mapper, this.subaction);

  final Mapper _mapper;
  final StoreAction subaction;

  @override
  Stream<State> execute(StateReader<State> state, Dispatcher dispatch) {
    return subaction
        .execute(() => _mapper.reader(state()), dispatch)
        .map((event) => _mapper.writer(state(), event));
  }

  @override
  String toString() {
    return 'MappedStoreAction<${_mapper.substateType}>(subaction: ${subaction})';
  }
}

/// Converts the [State] to a [Substate].
typedef MapperReader<State, Substate> = Substate Function(State state);

/// Converts a [State] and a [Substate] into a new [State].
typedef MapperWriter<State, Substate> = State Function(
    State state, Substate substate);

/// A mapper is responsible for converting a value back and forth between a
/// main [State] and a [Substate].
class Mapper<State, Substate> {
  /// Create a new mapper from the [reader] and [writer].
  const Mapper({
    @required this.reader,
    @required this.writer,
  })  : assert(reader != null),
        assert(writer != null);

  /// The state runtime type.
  Type get stateType => State;

  /// The substate runtime type.
  Type get substateType => Substate;

  /// Converts the [State] to a [Substate].
  final MapperReader<State, Substate> reader;

  /// Converts a [State] and a [Substate] into a new [State].
  final MapperWriter<State, Substate> writer;
}
