import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hs_coaching_app/features/display/features/chrono/data/chrono_repository.dart';
import 'package:hs_coaching_app/features/display/features/chrono/domain/chrono.dart';

/// Provider for the chrono repository.
final chronoRepositoryProvider = Provider<ChronoRepository>((ref) {
  return ChronoRepository(ref);
});

/// A provider that streams the latest chrono settings from Firestore.
final chronoProvider = StreamProvider<Chrono>((ref) {
  final repository = ref.watch(chronoRepositoryProvider);
  return repository.watchChrono();
});
