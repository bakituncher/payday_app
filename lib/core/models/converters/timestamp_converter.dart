import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

/// Converts Firestore `Timestamp`, ISO `String`, or `DateTime` to `DateTime` and back.
/// This keeps model parsing resilient to Firestore and local JSON sources.
class TimestampDateTimeConverter implements JsonConverter<DateTime?, Object?> {
  const TimestampDateTimeConverter();

  @override
  DateTime? fromJson(Object? json) {
    if (json == null) return null;
    if (json is Timestamp) return json.toDate();
    if (json is DateTime) return json;
    if (json is String) return DateTime.tryParse(json);
    throw FormatException('Cannot convert $json to DateTime');
  }

  @override
  Object? toJson(DateTime? date) {
    if (date == null) return null;
    return Timestamp.fromDate(date);
  }
}

