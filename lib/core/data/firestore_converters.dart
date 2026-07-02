import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

/// A generic converter for Firestore Timestamps to Dart's DateTime objects.
/// It handles both reading from and writing to Firestore.
class TimestampConverter implements JsonConverter<DateTime?, Object> {
  const TimestampConverter();

  @override
  DateTime? fromJson(Object json) {
    return json is Timestamp ? json.toDate() : null;
  }

  @override
  Object toJson(DateTime? object) => object == null
      ? FieldValue.serverTimestamp()
      : Timestamp.fromDate(object);
}

/// A converter for Firestore's server-generated timestamps.
/// This is identical to the one used in the `Chrono` feature.
class ServerTimestampConverter implements JsonConverter<Timestamp?, Object> {
  const ServerTimestampConverter();

  @override
  Timestamp? fromJson(Object json) => json is Timestamp ? json : null;

  @override
  Object toJson(Timestamp? object) => object ?? FieldValue.serverTimestamp();
}
