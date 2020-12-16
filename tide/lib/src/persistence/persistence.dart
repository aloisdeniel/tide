/// A persistence layer that allow to save and restore a state.
abstract class Persistence<State> {
  /// Create a new persistence layer.
  const Persistence();

  /// Reads the state from storage.
  Future<State> read();

  /// Write the state to the storage.
  Future<void> write(State state);

  /// Clear the state from the storage.
  Future<void> clear();
}

/// A persistence layer that does nothing.
class IgnoredPersistence<State> extends Persistence<State> {
  /// Create a new persistence layer.
  factory IgnoredPersistence() => const IgnoredPersistence._();

  const IgnoredPersistence._();

  @override
  Future<void> clear() => Future.value();

  @override
  Future<State> read() => Future<State>.value(null);

  @override
  Future<void> write(State state) => Future.value();
}
