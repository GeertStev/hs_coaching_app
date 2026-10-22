import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hs_coaching_app/core/theme/app_theme.dart';
import 'package:hs_coaching_app/features/display/features/tag_and_search/presentation/tag_editor.dart';
import 'package:hs_coaching_app/features/display/features/tag_and_search/presentation/tag_widgets.dart';

Widget _wrap(Widget child) => MaterialApp(
  theme: AppTheme.light(),
  home: Scaffold(body: child),
);

void main() {
  testWidgets('tag-dropdown opent meteen bij aantikken', (tester) async {
    await tester.pumpWidget(
      _wrap(
        ReusableTagEditor(
          initialTags: const [],
          allTags: const ['Apnea', 'Defense'],
          onTagsChanged: (_) {},
        ),
      ),
    );

    await tester.tap(find.byType(TextField));
    await tester.pumpAndSettle();

    expect(find.text('Apnea'), findsOneWidget);
    expect(find.text('Defense'), findsOneWidget);
  });

  testWidgets('nieuwe tag in andere schrijfwijze hergebruikt de bestaande', (
    tester,
  ) async {
    List<String>? result;
    await tester.pumpWidget(
      _wrap(
        ReusableTagEditor(
          initialTags: const [],
          allTags: const ['Defense'],
          onTagsChanged: (tags) => result = List.of(tags),
        ),
      ),
    );

    await tester.enterText(find.byType(TextField), 'defense');
    await tester.testTextInput.receiveAction(TextInputAction.done);
    await tester.pumpAndSettle();

    expect(result, ['Defense']);
  });

  testWidgets('filterbalk toont tellers, multi-select en lang drukken', (
    tester,
  ) async {
    final toggled = <String>[];
    String? longPressed;
    await tester.pumpWidget(
      _wrap(
        TagFilterBar(
          tagCounts: const {'Apnea': 2, 'Defense': 1},
          selectedTags: const {'Apnea'},
          onTagToggled: toggled.add,
          onClear: () {},
          onTagLongPress: (tag) => longPressed = tag,
        ),
      ),
    );

    expect(find.text('Apnea (2)'), findsOneWidget);
    expect(find.text('Defense (1)'), findsOneWidget);

    await tester.tap(find.text('Defense (1)'));
    expect(toggled, ['Defense']);

    await tester.longPress(find.text('Apnea (2)'));
    expect(longPressed, 'Apnea');
  });
}
