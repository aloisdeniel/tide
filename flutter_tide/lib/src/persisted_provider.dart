import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';
import 'package:tide/tide.dart';

import '../flutter_tide.dart';
import 'helpers/debounce.dart';

typedef Store<S> PersistedStoreInitializer<S>(
    BuildContext context, Store<S> store);

/// A [Store<S>] that saves its state to a [persistence] layer on a regular base
/// and restores it at launch.
///
/// If no state has been saved yet, the [initialState] is used.
///
/// While restoring, the [restoringBuilder] is used to build its child, and once restored
/// the [restoredbuilder] is used.
///
/// The saves are debounced with the [debouncing] period.
///
/// A [storeInitializer] can be used to customize the store once loaded.
class PersistedStoreProvider<S> extends StatefulWidget {
  /// Creates a [StoreProvider] instance and exposes both the [Store]
  /// and its [Store.state] using `provider`.
  ///
  /// **DON'T** use this with an existing [Store] instance, as removing
  /// the provider from the widget tree will dispose the [Store].\
  /// Instead consider using [StateNotifierBuilder].
  ///
  /// `create` cannot be `null`.
  const PersistedStoreProvider({
    Key key,
    @required this.initialStore,
    @required this.persistence,
    @required this.restoredbuilder,
    @required this.restoringBuilder,
    this.debouncing = const Duration(milliseconds: 500),
    this.storeInitializer,
  })  : assert(initialStore != null),
        assert(persistence != null),
        assert(restoredbuilder != null),
        assert(restoringBuilder != null),
        super(
          key: key,
        );

  final Duration debouncing;
  final Persistence<S> persistence;
  final Create<Store<S>> initialStore;
  final WidgetBuilder restoredbuilder;
  final WidgetBuilder restoringBuilder;
  final PersistedStoreInitializer<S> storeInitializer;

  @override
  _PersistedStoreProviderState<S> createState() =>
      _PersistedStoreProviderState<S>();
}

class _PersistedStoreProviderState<S> extends State<PersistedStoreProvider<S>> {
  Future<Store<S>> future;
  Store<S> store;

  @override
  void initState() {
    future = _restoreState();
    super.initState();
    return null;
  }

  Future<Store<S>> _restoreState() async {
    try {
      final result = await widget.persistence.read();
      store = result != null
          ? Store<S>(initialState: result)
          : widget.initialStore(context);
    } catch (e) {
      store = widget.initialStore(context);
    }

    if (widget.storeInitializer != null) {
      store = widget.storeInitializer?.call(context, store);
    }

    store.addListener(_onStateChanged);

    return store;
  }

  void _onStateChanged(S state) async {
    if (widget.debouncing != null) {
      debounce('write_state', widget.debouncing, () async {
        await widget.persistence.write(state);
      });
    } else {
      await widget.persistence.write(state);
    }
  }

  @override
  void dispose() {
    store.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Store<S>>(
      future: future,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          return StoreProvider<S>.state(
            state: snapshot.data,
            child: Builder(builder: widget.restoredbuilder),
          );
        }

        return widget.restoringBuilder(context);
      },
    );
  }
}
