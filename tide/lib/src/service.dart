import 'package:tide/tide.dart';

/// A locator that allows to create external services for the current state.
class ServiceLocator {
  /// Create a locator from a state reader.
  ServiceLocator(this._state);

  static const String _defaultName = '__Default__';

  final StateReader _state;

  final Map<Type, Map<String, ServiceBuilder>> _instanciators = {};

  /// Register a service [builder] which allows to call [create].
  ///
  /// If multiple instances of [Service]s are needed, a [name] can be
  /// provided to identify a particular instance.
  void register<Service, State>(
      Service Function(State state, ServiceLocator locator) builder,
      {String name}) {
    final byType = _instanciators.putIfAbsent(
      Service,
      () => <String, ServiceBuilder>{},
    );
    byType[name ?? _defaultName] = (state) => builder(state, this);
  }

  /// Create a [Service] instance for the current state.
  ///
  /// If multiple [Service]s are registered, a [name] can be provided to identify
  /// the needed service.
  Service create<Service>([String name]) {
    final byType = _instanciators[Service];
    if (byType == null) {
      throw Exception('No registered service for type $Service');
    }
    final serviceBuilder = byType[name ?? _defaultName];
    if (serviceBuilder == null) {
      throw Exception(
          'No registered service for type $Service with name "$name"');
    }
    return serviceBuilder(_state()) as Service;
  }
}

/// Instanciates a service for the current [state].
typedef ServiceBuilder = Object Function(Object state);
