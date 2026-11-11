import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hs_coaching_app/core/theme/app_theme.dart';
import 'package:hs_coaching_app/features/match/data/infringement_table_provider.dart';
import 'package:hs_coaching_app/features/match/data/practice_match.dart';
import 'package:hs_coaching_app/features/match/presentation/console_device.dart';
import 'package:hs_coaching_app/features/match/presentation/match_console_screen.dart';
import 'package:hs_coaching_app/features/match/presentation/penalty_dialog.dart';
import 'package:hs_coaching_core/match/engine/infringement_table.dart';
import 'package:hs_coaching_core/match/engine/match_config.dart';
import 'package:hs_coaching_core/match/engine/match_event.dart';
import 'package:hs_coaching_core/match/engine/match_state.dart';
import 'package:hs_coaching_core/match/match_session.dart';
import 'package:hs_coaching_core/team/team_model.dart';

class _FakeDevice extends ConsoleDevice {
  int taps = 0;
  int hints = 0;

  @override
  Future<void> enterConsole() async {}
  @override
  Future<void> leaveConsole() async {}
  @override
  void confirmTap() => taps++;
  @override
  void hint() => hints++;
}

void main() {
  final table = InfringementTable.fromJson(
    jsonDecode(
          File(
            '../hs_coaching_core/${InfringementTable.assetPath}',
          ).readAsStringSync(),
        )
        as Map<String, dynamic>,
  );
  var now = 1700000000000;
  late MatchSession session;
  late _FakeDevice device;

  Finder key(String value) => find.byKey(ValueKey(value));

  /// Laat de timer van de console en de streams van de sessie lopen.
  Future<void> settle(WidgetTester tester) async {
    await tester.pump(const Duration(milliseconds: 250));
    await tester.pump(const Duration(milliseconds: 250));
  }

  Future<void> tap(WidgetTester tester, String value) async {
    await tester.tap(key(value));
    await settle(tester);
  }

  Future<void> openConsole(
    WidgetTester tester, {
    Size size = const Size(1280, 800),
  }) async {
    tester.view.physicalSize = size;
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    device = _FakeDevice();
    session = (await tester.runAsync(
      () =>
          startPracticeMatch(config: const MatchConfig(), nowMillis: () => now),
    ))!;
    addTearDown(session.dispose);
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          consoleDeviceProvider.overrideWithValue(device),
          infringementTableProvider.overrideWith((ref) async => table),
        ],
        child: MaterialApp(
          theme: AppTheme.dark(),
          home: MatchConsoleScreen(session: session),
        ),
      ),
    );
    await settle(tester);
  }

  /// Sluit de console af zodat de timer stopt voor het einde van de test.
  Future<void> closeConsole(WidgetTester tester) async {
    await tester.pumpWidget(const SizedBox());
    await tester.pump(const Duration(milliseconds: 250));
  }

  testWidgets('03 §2 een goal registreren met kapnummer', (tester) async {
    await openConsole(tester);
    expect(find.text('15:00'), findsOneWidget);
    expect(find.text('STOPPED'), findsOneWidget);

    await tap(tester, 'start');
    expect(find.text('RUNNING'), findsOneWidget);
    now += 60000;
    await settle(tester);
    expect(find.text('14:00'), findsOneWidget);

    await tap(tester, 'goal-white');
    await tap(tester, 'cap-7');

    final goal = session.state.goals.single;
    expect(goal.team, TeamColor.white);
    expect(goal.scorerCap, 7);
    expect(goal.elapsedInPhase, const Duration(minutes: 1));
    expect(tester.widget<Text>(key('score-white')).data, '1');
    expect(tester.widget<Text>(key('score-black')).data, '0');
    expect(device.taps, 2);
    await closeConsole(tester);
  });

  testWidgets('03 §2 een straf geven met kapnummer', (tester) async {
    await openConsole(tester);
    await tap(tester, 'start');
    await tap(tester, 'stop');

    await tap(tester, 'penalty-black');
    // Zonder overtreding kan de straf niet bevestigd worden.
    expect(find.text('Choose the infringement.'), findsOneWidget);
    await tap(tester, 'cap-4');
    await tap(tester, 'infringement');
    await tester.tap(
      find.text('16.3.1 Standing on playing area (Obstruction)').last,
    );
    await settle(tester);
    // De suggestie uit tabel 17.7.1 staat voorgeselecteerd.
    expect(find.text('Caution (suggested)'), findsOneWidget);
    // De scheidsrechter beslist anders.
    await tap(tester, 'penalty-${PenaltyChoice.twoMinutes.name}');
    await tap(tester, 'penalty-confirm');

    final penalty = session.state.penalties.single;
    expect(penalty.team, TeamColor.black);
    expect(penalty.cap, 4);
    expect(penalty.minutes, 2);
    expect(penalty.infringementCode, '16.3.1');
    expect(penalty.status, PenaltyStatus.pending);
    expect(find.text('#4 2:00'), findsOneWidget);
    await closeConsole(tester);
  });

  testWidgets('14.3 een geweigerde time-out: grijs, reden bij lange druk', (
    tester,
  ) async {
    await openConsole(tester);
    await tap(tester, 'start');
    final before = session.events.length;

    // Het spel loopt: tikken doet niets.
    await tap(tester, 'timeout-white');
    expect(session.events.length, before);
    expect(session.state.activeTimeOut, isNull);

    await tester.longPress(key('timeout-white'));
    await settle(tester);
    expect(find.text('Stop play before a time-out.'), findsOneWidget);

    // Na de stop mag het wel, en een tweede in dezelfde helft niet meer.
    await tap(tester, 'stop');
    await tap(tester, 'timeout-white');
    expect(session.state.activeTimeOut?.team, TeamColor.white);
    expect(find.text('Time-out White'), findsOneWidget);
    await tap(tester, 'start');
    await tap(tester, 'stop');
    await tester.longPress(key('timeout-white'));
    await settle(tester);
    expect(
      find.text('This team already used its time-out this half.'),
      findsOneWidget,
    );
    await closeConsole(tester);
  });

  testWidgets('02 §2 undo vanuit het eventlog maakt een EventVoided', (
    tester,
  ) async {
    await openConsole(tester);
    await tap(tester, 'start');
    await tap(tester, 'goal-black');
    await tester.tap(find.text('No number'));
    await settle(tester);
    expect(session.state.score.black, 1);

    await tap(tester, 'open-log');
    expect(find.text('Goal Black'), findsWidgets);
    // De opzet van de wedstrijd kan niet ongedaan gemaakt worden.
    await tester.longPress(key('undo-1'));
    await settle(tester);
    expect(find.text('The match setup cannot be undone.'), findsOneWidget);

    await tap(tester, 'undo-3');
    expect(session.state.score.black, 0);
    expect(session.events.last.data, isA<EventVoided>());
    expect(session.events.length, 4);
    expect(find.text('Goal Black (undone)'), findsOneWidget);
    await closeConsole(tester);
  });

  testWidgets('03 §1 past op een telefoon in liggend formaat', (tester) async {
    await openConsole(tester, size: const Size(740, 360));
    await tap(tester, 'start');
    await tap(tester, 'stop');
    // Niet alles past op de hoogte van een telefoon: de kolommen scrollen.
    await tester.ensureVisible(key('shot-white'));
    await tap(tester, 'shot-white');
    expect(find.text('Penalty shot for White'), findsOneWidget);
    expect(tester.takeException(), isNull);
    await closeConsole(tester);
  });
}
