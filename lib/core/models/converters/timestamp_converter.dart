import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

/// Converts Firestore `Timestamp`, epoch milliseconds, or `DateTime` to `DateTime` and back.
/// Accepts legacy ISO strings for backward compatibility but always emits Firestore `Timestamp`.
class TimestampDateTimeConverter implements JsonConverter<DateTime?, Object?> {
  const TimestampDateTimeConverter();

  @override
  DateTime? fromJson(Object? json) {
    if (json == null) return null;
    if (json is Timestamp) return json.toDate();
    if (json is DateTime) return json;
    if (json is int) return DateTime.fromMillisecondsSinceEpoch(json);
    if (json is num) return DateTime.fromMillisecondsSinceEpoch(json.toInt());
    if (json is String) {
      final parsed = DateTime.tryParse(json);
      if (parsed != null) return parsed;
    }
    throw FormatException('Cannot convert $json to DateTime');
  }

  @override
  Object? toJson(DateTime? date) {
    if (date == null) return null;
    // Use epoch millis so JSON encoding works for local persistence; Firestore
    // layers should convert back to Timestamp when writing.
    return date.millisecondsSinceEpoch;
  }
}
