import 'package:cloud_firestore/cloud_firestore.dart';

enum DisplayImageStatus { active, archived }

class DisplayImage {
  const DisplayImage({
    required this.id,
    this.title,
    this.description,
    required this.url,
    required this.userId,
    required this.timestamp,
    this.status = DisplayImageStatus.active,
    this.tags = const [],
  });

  final String id;
  final String? title;
  final String? description;
  final String url;
  final String userId;
  final DateTime timestamp;
  final DisplayImageStatus status;
  final List<String> tags;

  DisplayImage copyWith({
    String? id,
    String? title,
    String? description,
    String? url,
    String? userId,
    DateTime? timestamp,
    DisplayImageStatus? status,
    List<String>? tags,
  }) {
    return DisplayImage(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      url: url ?? this.url,
      userId: userId ?? this.userId,
      timestamp: timestamp ?? this.timestamp,
      status: status ?? this.status,
      tags: tags ?? this.tags,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'description': description,
      'url': url,
      'userId': userId,
      'timestamp': FieldValue.serverTimestamp(),
      'status': status.name,
      'tags': tags,
    };
  }

  factory DisplayImage.fromMap(Map<String, dynamic> map) {
    return DisplayImage(
      // The 'id' is set from the document snapshot ID, not from the map.
      id: '',
      title: map['title'] as String?,
      description: map['description'] as String?,
      url: map['url'] as String,
      userId: map['userId'] as String,
      timestamp: (map['timestamp'] as Timestamp).toDate(),
      status: DisplayImageStatus.values.firstWhere(
        (e) => e.name == map['status'],
        orElse: () => DisplayImageStatus.active,
      ),
      tags: List<String>.from(map['tags'] ?? []),
    );
  }
}
