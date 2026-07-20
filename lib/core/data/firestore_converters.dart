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

/// Converter voor optionele Timestamps (zoals birthday): null blijft null,
/// er wordt nooit een serverTimestamp geschreven.
class NullableTimestampConverter implements JsonConverter<DateTime?, dynamic> {
  const NullableTimestampConverter();

  @override
  DateTime? fromJson(dynamic json) {
    if (json is Timestamp) return json.toDate();
    return null;
  }

  @override
  dynamic toJson(DateTime? date) =>
      date != null ? Timestamp.fromDate(date) : null;
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

/// Converts a non-null `DateTime` field to/from a Firestore [Timestamp],
/// reading as "now" while a pending `FieldValue.serverTimestamp()` write on
/// the same field has not yet resolved (briefly reads back as null).
class TimestampOrNowConverter implements JsonConverter<DateTime, Object?> {
  const TimestampOrNowConverter();

  @override
  DateTime fromJson(Object? json) =>
      json is Timestamp ? json.toDate() : DateTime.now();

  @override
  Object toJson(DateTime object) => Timestamp.fromDate(object);
}

/// For fields that always record the server's write time (e.g. "created at").
/// Every write emits a fresh `FieldValue.serverTimestamp()` regardless of the
/// model's current value; reads tolerate the same not-yet-resolved gap as
/// [TimestampOrNowConverter].
class ServerWriteTimestampConverter implements JsonConverter<DateTime, Object?> {
  const ServerWriteTimestampConverter();

  @override
  DateTime fromJson(Object? json) =>
      json is Timestamp ? json.toDate() : DateTime.now();

  @override
  Object toJson(DateTime object) => FieldValue.serverTimestamp();
}
