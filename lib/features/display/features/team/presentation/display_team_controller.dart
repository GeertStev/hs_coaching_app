import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hs_coaching_app/features/display/data/display_settings_repository.dart';
import 'package:hs_coaching_app/features/display/domain/display_content_settings.dart';
import 'package:hs_coaching_app/features/display/features/team/data/display_team_repository.dart';

/// Beheert de mutaties en Firebase state voor de Team weergave.
class TeamController extends AsyncNotifier<void> {
  @override
  FutureOr<void> build() {
    // Geen initiële state nodig
  }

  /*
  /// Triggert enkel een verversing van de team data
  Future<void> triggerTeamUpdate() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final repository = ref.read(displayTeamRepositoryProvider);
      await repository.triggerTeamUpdate();
    });
  }
  */

  /// Stuurt de opstelling van de Team scheduler naar het scherm en zet de
  /// teamweergave actief.
  Future<void> castLineup(Map<String, dynamic> lineup) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      await ref.read(displayTeamRepositoryProvider).castLineup(lineup);
      await ref
          .read(displaySettingsRepositoryProvider)
          .updateContentType(DisplayContentType.team);
    });
  }

  /// Triggert een verversing en zet de weergave actief op het scherm
  Future<void> castToScreen() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      await ref.read(displayTeamRepositoryProvider).triggerTeamUpdate();
      await ref
          .read(displaySettingsRepositoryProvider)
          .updateContentType(DisplayContentType.team);
    });
  }
}

final teamControllerProvider =
    AsyncNotifierProvider.autoDispose<TeamController, void>(TeamController.new);
