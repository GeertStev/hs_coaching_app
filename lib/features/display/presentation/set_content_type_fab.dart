import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hs_coaching_app/features/display/data/display_content_settings_repository.dart';
import 'package:hs_coaching_app/features/display/data/display_settings_repository.dart';
import 'package:hs_coaching_app/features/display/domain/display_content_settings.dart';

/// A reusable FloatingActionButton that sets the screen's content type
/// when pressed.
class SetContentTypeFAB extends ConsumerWidget {
  const SetContentTypeFAB({super.key, required this.contentType});

  final DisplayContentType contentType;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final screenContentSettings = ref.watch(displayContentSettingsProvider);

    return screenContentSettings.when(
      data: (settings) {
        final isCastingThisContent = settings.contentType == contentType;

        final iconData = isCastingThisContent
            ? Icons.cast_connected
            : Icons.cast;
        final tooltip = isCastingThisContent
            ? 'Stop Casting'
            : 'Cast to Screen';

        return FloatingActionButton(
          heroTag: null,
          onPressed: () {
            final newContentType = isCastingThisContent
                ? DisplayContentType.main
                : contentType;
            ref
                .read(displaySettingsRepositoryProvider)
                .updateContentType(newContentType);
          },
          tooltip: tooltip,
          child: Icon(iconData),
        );
      },
      loading: () => const FloatingActionButton(
        onPressed: null,
        child: CircularProgressIndicator(),
      ),
      error: (e, s) => FloatingActionButton(
        onPressed: null,
        tooltip: 'Error',
        backgroundColor: Theme.of(context).colorScheme.errorContainer,
        foregroundColor: Theme.of(context).colorScheme.onErrorContainer,
        child: const Icon(Icons.error),
      ),
    );
  }
}
