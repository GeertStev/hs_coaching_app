import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

enum SketchStatus {
  active,
  archived;

  static SketchStatus fromString(String? value) {
    if (value == null) return SketchStatus.active;
    return SketchStatus.values.firstWhere(
      (e) => e.name == value,
      orElse: () => SketchStatus.active,
    );
  }
}

@immutable
class Sketch {
  final String id;
  final String title;
  final String? description;
  final DateTime lastModified;
  final String userId;
  final List<String> tags;
  final SketchStatus status;
  final String? backgroundUrl;

  const Sketch({
    required this.id,
    required this.title,
    this.description,
    required this.lastModified,
    required this.userId,
    required this.tags,
    required this.status,
    this.backgroundUrl,
  });

  factory Sketch.fromJson(Map<String, dynamic> json) {
    return Sketch(
      id: json['id'] as String? ?? '',
      // ToDo Name is legacy code
      title: json['title'] as String? ?? json['name'] as String,
      description: json['description'] as String?,
      // Handle temporary null from FieldValue.serverTimestamp()
      lastModified:
          (json['lastModified'] as Timestamp?)?.toDate() ?? DateTime.now(),
      userId: json['userId'] as String,
      tags: List<String>.from(json['tags'] as List<dynamic>? ?? []),
      status: SketchStatus.fromString(json['status'] as String?),
      backgroundUrl: json['backgroundUrl'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'description': description,
      'lastModified': Timestamp.fromDate(lastModified),
      'userId': userId,
      'tags': tags,
      'status': status.name,
      if (backgroundUrl != null) 'backgroundUrl': backgroundUrl,
    };
  }

  Sketch copyWith({
    String? id,
    String? title,
    String? description,
    DateTime? lastModified,
    String? userId,
    List<String>? tags,
    SketchStatus? status,
    String? backgroundUrl,
    bool setNullDescription = false,
  }) {
    return Sketch(
      id: id ?? this.id,
      title: title ?? this.title,
      description: setNullDescription ? null : description ?? this.description,
      lastModified: lastModified ?? this.lastModified,
      userId: userId ?? this.userId,
      tags: tags ?? this.tags,
      status: status ?? this.status,
      backgroundUrl: backgroundUrl ?? this.backgroundUrl,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Sketch && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;
}
