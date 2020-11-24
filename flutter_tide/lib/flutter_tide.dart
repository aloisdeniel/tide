library flutter_tide;

import 'package:provider/provider.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_state_notifier/flutter_state_notifier.dart';
import 'package:state_notifier/state_notifier.dart';
import 'package:tide/tide.dart';

export 'package:tide/tide.dart';
export 'package:provider/provider.dart';

class StoreProvider<State> extends StatelessWidget {
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
    this.builder,
    this.child,
  })  : this.state = null,
        assert(createStore != null),
        super(
          key: key,
        );

  /// Exposes an existing [Store] and its [state].
  ///
  /// This will not call [StateNotifier.dispose] when the provider is removed
  /// from the widget tree.
  ///
  /// It will also not setup [LocatorMixin].
  ///
  /// `value` cannot be `null`.
  const StoreProvider.state({
    Key key,
    @required this.state,
    this.builder,
    this.child,
  })  : this.lazy = false,
        this.createStore = null,
        assert(state != null),
        super(
          key: key,
        );

  final Create<Store<State>> createStore;
  final bool lazy;
  final TransitionBuilder builder;
  final Widget child;
  final Store<State> state;

  static void dispatch<State>(BuildContext context, StoreAction<State> action) {
    final store = Provider.of<Store<State>>(context, listen: false);
    assert(store != null);
    store.dispatch(action);
  }

  @override
  Widget build(BuildContext context) {
    if (state != null) {
      return StateNotifierProvider<Store<State>, State>.value(
        key: key,
        value: state,
        builder: builder,
        child: child,
      );
    }

    return StateNotifierProvider<Store<State>, State>(
      key: key,
      create: createStore,
      builder: builder,
      lazy: lazy,
      child: child,
    );
  }
}

extension StoreProviderExtension on BuildContext {
  void dispatch<State>(StoreAction<State> action) {
    StoreProvider.dispatch<State>(this, action);
  }
}
