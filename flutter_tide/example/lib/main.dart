import 'dart:io';

import 'package:example/services.dart';
import 'package:flutter/material.dart';
import 'package:flutter_tide/flutter_tide.dart';
import 'package:path_provider/path_provider.dart';

import 'actions.dart';
import 'state.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return PersistedStoreProvider<CounterState>(
      persistence: JsonFilePersistence(
        converter: JsonConverter(
          fromJson: (value) => CounterState(value, false),
          toJson: (value) => value.value,
        ),
        file: () async {
          final directory = await getApplicationDocumentsDirectory();
          return File(directory.path + '/state');
        },
      ),
      initialStore: (context) => Store<CounterState>(
        initialState: CounterState(0, false),
      ),
      storeInitializer: (context, store) => store
        ..registerService<ServerClient>(
            (state, services) => MockServerClient()),
      restoringBuilder: (context) => SizedBox(),
      restoredbuilder: (context) => MaterialApp(
        title: 'Tide Demo',
        theme: ThemeData(
          primarySwatch: Colors.blue,
        ),
        home: CounterPage(),
      ),
    );
  }
}

class CounterPage extends StatelessWidget {
  CounterPage({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isLoading = context.select((CounterState state) => state.isLoading);
    return Scaffold(
      appBar: AppBar(
        title: Text('Tide'),
      ),
      body: Center(
        child: isLoading ? Center(child: CircularProgressIndicator()) : Count(),
      ),
      floatingActionButton: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          FloatingActionButton(
            onPressed: () => context.dispatch(Increment()),
            tooltip: 'Increment',
            child: Icon(Icons.add),
          ),
          FloatingActionButton(
            onPressed: () => context.dispatch(AddServerValue()),
            tooltip: 'AddServerValue',
            child: Icon(Icons.arrow_downward),
          ),
          FloatingActionButton(
            onPressed: () => context.dispatch(ResetThenAddValueverySecond(10)),
            tooltip: 'ResetThenAddValueverySecond',
            child: Icon(Icons.alarm_add),
          ),
        ],
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}

class Count extends StatelessWidget {
  const Count({
    Key key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final count = context.select((CounterState state) => state.value);
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Text(
          'You have pushed the button this many times:',
        ),
        Text(
          '$count',
          style: Theme.of(context).textTheme.headline4,
        ),
      ],
    );
  }
}
