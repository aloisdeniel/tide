import 'dart:io';

import 'package:fake_async/fake_async.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_tide/flutter_tide.dart';

void main() {
  testWidgets('PersistedStoreProvider', (WidgetTester tester) async {
    await fakeAsync((async) async {
      Widget create() => MaterialApp(
            home: PersistedStoreProvider<String>(
              initialStore: (context) => Store(initialState: 'INIT'),
              debouncing: null,
              persistence: JsonFilePersistence(
                file: () => Future.value(File('./test/storage/state')),
                converter: JsonConverter(
                  fromJson: (s) => s,
                  toJson: (s) => s,
                ),
              ),
              restoredbuilder: (context) {
                final value = context.select((String value) => value);
                return Text('Restored: $value');
              },
              restoringBuilder: (context) {
                return Text('Restoring');
              },
            ),
          );

      await tester.pumpWidget(create());
      expect(find.text('Restoring'), findsOneWidget);

      await tester.pump(Duration(seconds: 3));

      await tester.pumpWidget(create());
      expect(find.text('Restored: INIT'), findsOneWidget);

      await tester.pump(Duration(seconds: 3));

      await tester.pumpWidget(create());
      expect(find.text('Restored: INIT'), findsOneWidget);

      await tester.pump(Duration(seconds: 3));
    });
  });
}
