import 'package:flutter/widgets.dart';

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
