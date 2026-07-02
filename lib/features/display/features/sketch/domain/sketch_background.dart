import 'package:flutter/foundation.dart';

@immutable
class SketchBackground {
  final String title;
  final String url;

  const SketchBackground({required this.title, required this.url});

  factory SketchBackground.fromMap(Map<String, dynamic> map) {
    return SketchBackground(
      title: map['title'] as String? ?? 'Untitled',
      url: map['url'] as String? ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {'title': title, 'url': url};
  }

  @override
  bool operator ==(Object other) =>
      other is SketchBackground && other.url == url;

  @override
  int get hashCode => url.hashCode;
}
