import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hs_coaching_app/features/display/data/display_device_ids_provider.dart';
import 'package:hs_coaching_app/features/display/domain/display_global_settings.dart';

/// A provider that fetches the static global settings for a display.
///
/// This is a `FutureProvider` because this data is expected to be read once
/// once on startup and not change. Riverpod will cache the result.
final globalSettingsProvider = FutureProvider<DisplayGlobalSettings>((
  ref,
) async {
  // Watch the provider for the device IDs.
  // This provider will automatically re-run if the IDs change.
  final ids = ref.watch(displayDeviceIdsProvider);

  //ToDo: Move to repositories?
  final doc = await FirebaseFirestore.instance
      .collection('clubs')
      .doc(ids.clubId)
      .collection('displays')
      .doc(ids.displayDeviceId)
      .collection('settings')
      .doc('global')
      .get();

  if (!doc.exists || doc.data() == null) {
    //Should this be a redirect to a login, or an information page?
    //In what scenario are there no global settings? No connection? Hacking?
    throw Exception(
      'Global settings not found for display: ${ids.displayDeviceId}',
    );
  }
  return DisplayGlobalSettings.fromMap(doc.data()!);
});

/// Provides the actual size available for the image content on the display.
///
/// This is calculated by taking the total screen dimensions from
/// [globalSettingsProvider] and subtracting the known padding/margins.
final imageContentSizeProvider = Provider<Size?>((ref) {
  final settings = ref.watch(globalSettingsProvider).value;
  if (settings == null) return null;

  // These values represent the horizontal and vertical padding/margins
  // around the image content area on the display screen.
  const double horizontalPadding = 12.0 * 2; // e.g., 12px on each side
  const double verticalPadding = 12.0 + 42.0; // e.g., 12px top, 42px bottom

  final contentWidth = settings.width - horizontalPadding;
  final contentHeight = settings.height - verticalPadding;

  return Size(contentWidth, contentHeight);
});
