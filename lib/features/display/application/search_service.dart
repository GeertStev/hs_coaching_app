import 'package:flutter_riverpod/flutter_riverpod.dart';

abstract class SearchNotifier extends Notifier<String> {
  void setQuery(String query);
}

abstract class TagNotifier extends Notifier<String?> {
  void setTag(String? newTag);
}
