import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hs_coaching_app/core/providers/firebase_providers.dart';
import 'package:hs_coaching_app/features/display/data/display_device_ids_provider.dart';
import 'package:hs_coaching_app/features/display/features/chrono/data/chrono_repository.dart';
import 'package:hs_coaching_app/features/display/features/chrono/domain/chrono.dart';

/// Provider for the chrono repository.
final chronoRepositoryProvider = Provider<ChronoRepository>((ref) {
  final firestore = ref.watch(firebaseFirestoreProvider);
  final ids = ref.watch(displayDeviceIdsProvider);

  return ChronoRepository(
    firestore: firestore,
    clubId: ids.clubId,
    displayId: ids.displayDeviceId,
  );
});

/// A provider that streams the latest chrono settings from Firestore.
final chronoProvider = StreamProvider<Chrono>((ref) {
  final repository = ref.watch(chronoRepositoryProvider);
  return repository.watchChrono();
});
