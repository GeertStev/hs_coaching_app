import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hs_coaching_app/core/providers/shared_preferences_provider.dart';
import 'package:hs_coaching_app/features/auth/data/auth_providers.dart';
import 'package:hs_coaching_app/features/match/data/firestore_match_write_repository.dart';
import 'package:hs_coaching_core/core/errors/error_reporting.dart';
import 'package:hs_coaching_core/core/providers/display_device_ids_provider.dart';
import 'package:hs_coaching_core/core/providers/firebase_providers.dart';
import 'package:hs_coaching_core/core/providers/server_time_offset_provider.dart';
import 'package:hs_coaching_core/match/match_repository.dart';
import 'package:hs_coaching_core/match/match_session.dart';
import 'package:uuid/uuid.dart';

/// De wedstrijdopslag van de club. Een wedstrijd hangt niet aan een display,
/// dus alleen het `clubId` uit `displayDeviceIdsProvider` wordt gebruikt.
final matchRepositoryProvider = Provider<MatchWriteRepository>((ref) {
  final firestore = ref.watch(firebaseFirestoreProvider);
  final ids = ref.watch(displayDeviceIdsProvider);
  return FirestoreMatchWriteRepository(
    firestore: firestore,
    clubId: ids.clubId,
  );
});

const _deviceIdKey = 'match_device_id';

/// Vast id van dit toestel voor de schrijf-lease van een wedstrijd. Wordt bij
/// het eerste gebruik aangemaakt en daarna bewaard, zodat het toestel na een
/// herstart zijn lease nog heeft.
final matchDeviceIdProvider = Provider<String>((ref) {
  final preferences = ref.watch(sharedPreferencesProvider);
  final stored = preferences.getString(_deviceIdKey);
  if (stored != null && stored.isNotEmpty) return stored;
  final created = const Uuid().v4();
  preferences.setString(_deviceIdKey, created).catchError((
    Object error,
    StackTrace stack,
  ) {
    reportError(error, stack, context: 'match device id bewaren');
    return false;
  });
  return created;
});

/// De sessie van dit tafeltoestel voor één wedstrijd. Per `matchId`, zonder
/// globale "actieve wedstrijd": wie de wedstrijd niet meer bekijkt, sluit de
/// sessie vanzelf.
final matchSessionProvider = Provider.autoDispose.family<MatchSession, String>((
  ref,
  matchId,
) {
  final session = MatchSession(
    matchId: matchId,
    repository: ref.watch(matchRepositoryProvider),
    deviceId: ref.watch(matchDeviceIdProvider),
    // Het tijdstip van de tik: lokale tijd plus de offset van de server,
    // telkens opnieuw gelezen.
    nowServerMs: () =>
        serverNowMillis(ref.read(serverTimeOffsetProvider).value ?? 0),
    newEventId: () => const Uuid().v4(),
    authorId: ref.watch(currentUidProvider),
    onWriteError: (event, error, stack) => reportError(
      error,
      stack,
      context: 'match event ${event.seq} schrijven',
    ),
  );
  ref.onDispose(session.dispose);
  return session;
});
