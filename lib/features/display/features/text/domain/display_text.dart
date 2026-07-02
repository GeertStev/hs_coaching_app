import 'package:cloud_firestore/cloud_firestore.dart';

enum DisplayTextStatus { active, archived }

class DisplayText {
  const DisplayText({
    required this.id,
    this.title,
    required this.text,
    required this.userId,
    required this.timestamp,
    this.status = DisplayTextStatus.active,
    this.tags = const [],
  });

  final String id;
  final String? title;
  final String text;
  final String userId;
  final DateTime timestamp;
  final DisplayTextStatus status;
  final List<String> tags;

  DisplayText copyWith({
    String? id,
    String? title,
    String? text,
    String? userId,
    DateTime? timestamp,
    DisplayTextStatus? status,
    List<String>? tags,
  }) {
    return DisplayText(
      id: id ?? this.id,
      title: title ?? this.title,
      text: text ?? this.text,
      userId: userId ?? this.userId,
      timestamp: timestamp ?? this.timestamp,
      status: status ?? this.status,
      tags: tags ?? this.tags,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title, // Can be null
      'text': text,
      'userId': userId,
      'timestamp': FieldValue.serverTimestamp(),
      'status': status.name,
      'tags': tags,
    };
  }

  factory DisplayText.fromMap(Map<String, dynamic> map) {
    return DisplayText(
      // The 'id' is set from the document snapshot ID, not from the map.
      id: '',
      title: map['title'] as String?,
      text: map['text'] as String,
      userId: map['userId'] as String,
      // Handle temporary null from FieldValue.serverTimestamp()
      timestamp: (map['timestamp'] as Timestamp?)?.toDate() ?? DateTime.now(),
      status: DisplayTextStatus.values.firstWhere(
        (e) => e.name == map['status'],
        orElse: () => DisplayTextStatus.active,
      ),
      tags: List<String>.from(map['tags'] ?? []),
    );
  }
}
