import 'package:provider/provider.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_state_notifier/flutter_state_notifier.dart';
import 'package:tide/tide.dart';

class StoreProvider<S> extends StatelessWidget {
  /// Creates a [StoreProvider] instance and exposes both the [Store]
  /// and its [Store.state] using `provider`.
  ///
  /// **DON'T** use this with an existing [Store] instance, as removing
  /// the provider from the widget tree will dispose the [Store].\
  /// Instead consider using [StateNotifierBuilder].
  ///
  /// `create` cannot be `null`.
  const StoreProvider({
    Key key,
    @required this.createStore,
    this.lazy,
    this.child,
  })  : this.state = null,
        assert(createStore != null),
        super(
          key: key,
        );

  const StoreProvider.state({
    Key key,
    @required this.state,
    this.child,
  })  : this.lazy = false,
        this.createStore = null,
        assert(state != null),
        super(
          key: key,
        );

  final Create<Store<S>> createStore;
  final bool lazy;
  final Widget child;
  final Store<S> state;

  /// Dispatch the [action] into the declared [Store].
  static void dispatch<S>(BuildContext context, StoreAction<S> action) {
    final dispatch = Provider.of<Dispatcher>(context, listen: false);
    assert(dispatch != null, 'No store registered in tree');
    dispatch(action);
  }

  @override
  Widget build(BuildContext context) {
    final child = Builder(
      builder: (context) {
        final store = context.watch<Store<S>>();
        return Provider<Dispatcher>.value(
          value: store.dispatch,
          child: this.child,
        );
      },
    );

    if (state != null) {
      return StateNotifierProvider<Store<S>, S>.value(
        key: key,
        value: state,
        child: child,
      );
    }

    return StateNotifierProvider<Store<S>, S>(
      key: key,
      create: createStore,
      lazy: lazy,
      child: child,
    );
  }
}

extension StoreProviderExtension on BuildContext {
  void dispatch<S>(StoreAction<S> action) {
    StoreProvider.dispatch<S>(this, action);
  }
}
