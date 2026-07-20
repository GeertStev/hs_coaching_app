import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hs_coaching_app/core/providers/firebase_providers.dart';
import 'package:hs_coaching_app/features/display/data/display_device_ids_provider.dart';
import 'package:hs_coaching_app/features/display/features/team/models/player_model.dart';
import 'package:hs_coaching_app/features/display/features/team/models/team_model.dart';
import 'package:http/http.dart' as http;

/// Repository for fetching team composition data.
///
/// This class abstracts the data source (currently a Google Script) from the
/// rest of the application.
class TeamRepository {
  // ToDo: The URL should be configurable, possibly from global settings.
  final baseUrl =
      'https://script.google.com/macros/s/AKfycbwWrPIm8SPX5KP4ZQQiySbozRDmtgEjm1fqDEf4vQpHfgLuMO5JyJGmpSpxWOnodtm0/exec';

  /// Fetches the team compositions and returns a list containing both teams.
  Future<List<Team>> fetchTeams() async {
    final teamsUrl = Uri.parse(
      '$baseUrl?t=${DateTime.now().millisecondsSinceEpoch}',
    );

    final response = await http.get(teamsUrl);

    if (response.statusCode == 200) {
      final jsonData = jsonDecode(response.body);

      SchedulerBinding.instance.ensureVisualUpdate();

      return [
        Team.fromGoogleScriptResponse(jsonData, TeamColor.white),
        Team.fromGoogleScriptResponse(jsonData, TeamColor.black),
      ];
    } else {
      throw Exception(
        'Failed to load team composition: ${response.reasonPhrase}',
      );
    }
  }
}

class DummyTeamRepository {
  Future<List<Team>> fetchTeams() async {
    return [
      Team(
        teamColor: TeamColor.white,
        front: [
          Player(name: 'Player A'),
          Player(name: 'Player B'),
          Player(name: 'Player B'),
        ],
        center: [Player(name: 'Player C')],
        wing: [
          Player(name: 'Player D'),
          Player(name: 'Player E'),
        ],
        goalie: [Player(name: 'Player F')],
      ),
      Team(
        teamColor: TeamColor.black,
        front: [
          Player(name: 'Player G'),
          Player(name: 'Player H'),
        ],
        center: [Player(name: 'Player I')],
        wing: [
          Player(name: 'Player J'),
          Player(name: 'Player K'),
          Player(name: 'Player K'),
        ],
        goalie: [Player(name: 'Player L')],
      ),
    ];
  }
}

/// Repository for managing team settings in Firestore (e.g. update triggers).
class TeamSettingsRepository {
  TeamSettingsRepository({
    required FirebaseFirestore firestore,
    required String clubId,
    required String displayId,
  }) : _firestore = firestore,
       _clubId = clubId,
       _displayId = displayId;

  final FirebaseFirestore _firestore;
  final String _clubId;
  final String _displayId;

  DocumentReference get _teamSettingsRef {
    return _firestore
        .collection('clubs')
        .doc(_clubId)
        .collection('displays')
        .doc(_displayId)
        .collection('settings')
        .doc('team');
  }

  /// Watches the document and emits the snapshot data.
  Stream<DocumentSnapshot> watchTeamSettings() {
    return _teamSettingsRef.snapshots();
  }

  /// Resets the update flag to false.
  Future<void> acknowledgeUpdate() async {
    await _teamSettingsRef.update({'update': false});
  }
}

// --- Providers ---

/// Provider for the TeamRepository instance.
final teamRepositoryProvider = Provider<TeamRepository>(
  (ref) => TeamRepository(),
);

/// Provider for the TeamSettingsRepository instance.
final teamSettingsRepositoryProvider = Provider<TeamSettingsRepository>((ref) {
  final firestore = ref.watch(firebaseFirestoreProvider);
  final ids = ref.watch(displayDeviceIdsProvider);

  return TeamSettingsRepository(
    firestore: firestore,
    clubId: ids.clubId,
    displayId: ids.displayDeviceId,
  );
});

/// Provider that fetches the list of teams using the TeamRepository.
/// The `FutureProvider` automatically handles caching and error states.
final teamsProvider = FutureProvider<List<Team>>((ref) {
  return ref.watch(teamRepositoryProvider).fetchTeams();
});

/// A provider that listens for remote update triggers and invalidates the teams provider.
final teamUpdateListenerProvider = Provider<void>((ref) {
  final repository = ref.watch(teamSettingsRepositoryProvider);

  final subscription = repository.watchTeamSettings().listen((snapshot) {
    if (!snapshot.exists) return;

    final data = snapshot.data() as Map<String, dynamic>?;

    // Controleer of de Android app het update signaal heeft gestuurd
    if (data != null && data['update'] == true) {
      // 1. Invalideer de teamsProvider. Dit verwijdert de gecachte HTTP-data
      // en dwingt de FutureProvider om direct opnieuw fetchTeams() aan te roepen.
      ref.invalidate(teamsProvider);

      // 2. Handshake: Zet de update flag in Firestore terug op false via de repository.
      repository.acknowledgeUpdate();
    }
  });

  // Zorg ervoor dat de stream netjes wordt afgesloten als deze provider wordt vernietigd
  ref.onDispose(() {
    subscription.cancel();
  });
});
