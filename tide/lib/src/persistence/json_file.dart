import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:meta/meta.dart';

import 'persistence.dart';

/// Gets a file asynchronously.
/// This is
typedef AsyncFileGetter = Future<File> Function();

/// Stores the state into a [file] as JSON content.
class JsonFilePersistence<State> extends Persistence<State> {
  /// Create a new persistence layer with [file] and [converter].
  const JsonFilePersistence({
    @required this.file,
    @required this.converter,
  })  : assert(file != null),
        assert(converter != null);

  /// The converter used to serialize and deserialize JSON.
  final JsonConverter<State> converter;

  /// The asynchronous file accessor.
  final AsyncFileGetter file;

  /// A backup file which is a copy of the last successful saved state.
  ///
  /// This adds security in case of a corrupted save for the main [file].
  File backupFile(File file) => File('${file.path}.backup');

  @override
  Future<void> clear() async {
    final file = await this.file();
    await file.delete();
    await backupFile(file).delete();
  }

  @override
  Future<State> read() async {
    final file = await this.file();

    if (file.existsSync()) {
      /// Veryfing that hashcode is equivalent to avoid corrupted content
      final content = await file.readAsString();
      final splits = content.indexOf(';');
      int hashCode;
      String json;
      if (splits >= 0) {
        hashCode = int.parse(content.substring(0, splits));
        json = content.substring(splits + 1);
      }

      /// File is corrupted, trying to load backup file
      if (json == null || hashCode != json.hashCode) {
        json = null;

        final content = await backupFile(file).readAsString();

        if (splits >= 0) {
          hashCode = int.parse(content.substring(0, splits));
          json = content.substring(splits + 1);
        }

        /// Even backup file is corrupted
        if (json == null || hashCode != json.hashCode) {
          return null;
        }
      }

      return converter.fromJson(jsonDecode(json));
    }

    return null;
  }

  @override
  Future<void> write(State state) async {
    final file = await this.file();
    final contents = jsonEncode(converter.toJson(state));

    if (!file.existsSync()) {
      await file.create(recursive: true);
    }

    await file.writeAsString('${contents.hashCode};' + contents);

    /// We create a backup in case a following write is corrupted
    await file.copy(backupFile(file).path);
  }
}

/// Converts a [State] to and from JSON.
abstract class BaseJsonConverter<State> {
  /// Create a new converter.
  const BaseJsonConverter();

  /// Deserialize the json [value] as a [State].
  State fromJson(dynamic value);

  /// Deserialize the [state] to a JSON map.
  dynamic toJson(State state);
}

/// Converts a [State] to and from JSON.
class JsonConverter<State> extends BaseJsonConverter<State> {
  /// Create a new converter from the given [fromJson] and [toJson].
  const JsonConverter({
    @required FromJsonConverter<State> fromJson,
    @required ToJsonConverter<State> toJson,
  })  : assert(fromJson != null),
        assert(toJson != null),
        _fromJson = fromJson,
        _toJson = toJson;
  final FromJsonConverter<State> _fromJson;
  final ToJsonConverter<State> _toJson;

  @override
  State fromJson(dynamic value) => _fromJson(value);

  @override
  dynamic toJson(State state) => _toJson(state);
}

/// Json deserializer for [State].
typedef FromJsonConverter<State> = State Function(dynamic value);

/// Json serializer for [State].
typedef ToJsonConverter<State> = dynamic Function(State state);
