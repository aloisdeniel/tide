import 'dart:async';

Map<String, Timer> _timers = {};

/// Allow to “group” multiple sequential calls to [execute] with [tag] in a single one.
void debounce(String tag, Duration duration, void Function() execute) {
  if (duration == Duration.zero) {
    _timers[tag]?.cancel();
    _timers.remove(tag);
    execute();
  } else {
    _timers[tag]?.cancel();

    _timers[tag] = Timer(duration, () {
      _timers[tag]?.cancel();
      _timers.remove(tag);

      execute();
    });
  }
}
