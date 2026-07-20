import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'chrono.freezed.dart';
part 'chrono.g.dart';

enum ChronoStatus { stopped, running, paused }

@freezed
abstract class Chrono with _$Chrono {
  const factory Chrono({
    @Default(ChronoStatus.stopped) ChronoStatus status,

    /// The local timestamp from the control app when the button was pressed.
    @Default(0) int authoritativeStartTimeMillis,

    /// Firestore server timestamp of when the start event was written.
    @ServerTimestampConverter() Timestamp? serverWriteTimestamp,

    /// Time accumulated before the current running session.
    @Default(0) int accumulatedElapsedMillis,

    /// Lijst met rondetijden (opgeslagen als geaccumuleerde verstreken tijd in millis)
    @Default([]) List<int> laps,
  }) = _Chrono;

  factory Chrono.fromJson(Map<String, dynamic> json) => _$ChronoFromJson(json);
}

class ServerTimestampConverter implements JsonConverter<Timestamp?, Object> {
  const ServerTimestampConverter();

  @override
  Timestamp? fromJson(Object json) => json is Timestamp ? json : null;

  @override
  Object toJson(Timestamp? object) => object ?? FieldValue.serverTimestamp();
}
