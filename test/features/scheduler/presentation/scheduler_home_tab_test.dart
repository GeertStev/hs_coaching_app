import 'dart:io';

import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hs_coaching_app/core/theme/app_theme.dart';
import 'package:hs_coaching_app/features/scheduler/data/scheduler_providers.dart';
import 'package:hs_coaching_app/features/scheduler/data/scheduler_repository.dart';
import 'package:hs_coaching_app/features/scheduler/presentation/scheduler_home_tab.dart';
import 'package:hs_coaching_core/core/providers/firebase_providers.dart';
import 'package:hs_coaching_core/scheduler/scheduler_models.dart';

final _fixture = File(
  '../hs_coaching_core/test/scheduler/fixtures/teamscheduler_sheet.json',
).readAsStringSync();

const _f = PlayerPosition.forward;
const _g = PlayerPosition.goalie;

void main() {
  late FakeFirebaseFirestore firestore;
  late SchedulerRepository repository;

  setUp(() {
    firestore = FakeFirebaseFirestore();
    repository = SchedulerRepository(firestore: firestore, clubId: 'holySquid');
  });

  Future<void> pumpTab(
    WidgetTester tester, {
    bool allowed = true,
    Future<String?> Function()? pick,
  }) async {
    tester.view.physicalSize = const Size(1280, 1600);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          firebaseFirestoreProvider.overrideWithValue(firestore),
          schedulerTodayProvider.overrideWithValue('2026-11-16'),
          canUseSchedulerProvider.overrideWithValue(allowed),
          if (pick != null) sheetExportPickerProvider.overrideWithValue(pick),
        ],
        child: MaterialApp(
          theme: AppTheme.dark(),
          home: const Scaffold(body: SchedulerHomeTab()),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('een speler ziet de ranking niet', (tester) async {
    await repository.savePlayer(
      const SquadPlayer(firstName: 'Ann', startRatings: {_f: 1500}),
    );
    await pumpTab(tester, allowed: false);
    expect(find.textContaining('trainers and club admins'), findsOneWidget);
    expect(find.text('Ann'), findsNothing);
  });

  testWidgets('lege lijst: importeren zet de spelers in de ranking', (
    tester,
  ) async {
    await pumpTab(tester, pick: () async => _fixture);
    expect(find.textContaining('No players yet'), findsOneWidget);

    await tester.runAsync(() async {
      await tester.tap(find.text('Import sheet export'));
      // De import schrijft in batches naar de nagebootste Firestore.
      await Future<void>.delayed(const Duration(milliseconds: 500));
    });
    await tester.pumpAndSettle();

    expect(
      find.text('Imported 80 players, 166 games and 34 adjustments.'),
      findsOneWidget,
    );
    expect(find.textContaining('No players yet'), findsNothing);
    expect(await repository.watchPlayers().first, hasLength(80));
  });

  testWidgets('een verkeerd bestand geeft een duidelijke melding', (
    tester,
  ) async {
    await pumpTab(tester, pick: () async => '{"schemaVersion": 99}');
    await tester.runAsync(() async {
      await tester.tap(find.text('Import sheet export'));
      await Future<void>.delayed(const Duration(milliseconds: 100));
    });
    await tester.pumpAndSettle();
    expect(
      find.text('This file is not a Teamscheduler export.'),
      findsOneWidget,
    );
  });

  testWidgets('ranking toont rating en rang, sorteert en verbergt inactieven', (
    tester,
  ) async {
    await repository.savePlayer(
      const SquadPlayer(
        firstName: 'Ann',
        positions: [_f, _g],
        startRatings: {_f: 1510, _g: 1900},
      ),
    );
    await repository.savePlayer(
      const SquadPlayer(
        firstName: 'Bob',
        nickname: 'Bobby',
        positions: [_f],
        startRatings: {_f: 2050},
      ),
    );
    await repository.savePlayer(
      const SquadPlayer(
        firstName: 'Old',
        active: false,
        startRatings: {_f: 1000},
      ),
    );
    await pumpTab(tester);

    expect(find.text('Ann'), findsOneWidget);
    expect(find.text('Bobby'), findsOneWidget);
    expect(find.text('Old'), findsNothing);
    expect(find.text('1510'), findsOneWidget);
    expect(find.text('Dolphin'), findsOneWidget);
    expect(find.text('Great White'), findsOneWidget);
    // Op naam: Ann boven Bobby.
    expect(
      tester.getTopLeft(find.text('Ann')).dy,
      lessThan(tester.getTopLeft(find.text('Bobby')).dy),
    );

    // Op rating voorspeler: Bobby (2050) boven Ann (1510).
    await tester.tap(find.text('F').first);
    await tester.pumpAndSettle();
    expect(
      tester.getTopLeft(find.text('Bobby')).dy,
      lessThan(tester.getTopLeft(find.text('Ann')).dy),
    );

    await tester.tap(find.text('Inactive'));
    await tester.pumpAndSettle();
    expect(find.text('Old'), findsOneWidget);
  });

  testWidgets('speler toevoegen en een aanpassing geven', (tester) async {
    await repository.savePlayer(
      const SquadPlayer(
        firstName: 'Ann',
        positions: [_f],
        startRatings: {_f: 1500},
      ),
    );
    await pumpTab(tester);

    await tester.tap(find.text('Add player'));
    await tester.pumpAndSettle();
    await tester.enterText(
      find.widgetWithText(TextFormField, 'First name'),
      'Cleo',
    );
    await tester.tap(find.text('Goalie'));
    await tester.pumpAndSettle();
    // Een aangevinkte positie heeft een startrating nodig.
    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();
    expect(find.text('Required'), findsOneWidget);
    await tester.enterText(find.byKey(const ValueKey('start-G')), '1700');
    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();

    final cleo = (await repository.watchPlayers().first).singleWhere(
      (p) => p.firstName == 'Cleo',
    );
    expect(cleo.positions, [_g]);
    expect(cleo.startRatings, {_g: 1700});
    expect(find.text('1700'), findsOneWidget);

    // Bewerken: aanpassing van -50 vandaag telt meteen mee.
    await tester.tap(find.text('Cleo'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Add adjustment'));
    await tester.pumpAndSettle();
    await tester.enterText(
      find.widgetWithText(TextFormField, 'Change in rating points'),
      '-50',
    );
    await tester.enterText(
      find.widgetWithText(TextFormField, 'Reason'),
      'Injury',
    );
    await tester.tap(find.text('Add'));
    await tester.pumpAndSettle();

    final adjustment = (await repository.watchAdjustments().first).single;
    expect(adjustment.playerId, cleo.id);
    expect(adjustment.change, -50);
    expect(adjustment.start, '2026-11-16');
    expect(find.text('Injury'), findsOneWidget);

    await tester.pageBack();
    await tester.pumpAndSettle();
    expect(find.text('1650'), findsOneWidget);
  });
}
