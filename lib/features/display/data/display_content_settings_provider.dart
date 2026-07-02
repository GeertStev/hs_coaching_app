import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hs_coaching_app/features/display/data/display_device_ids_provider.dart';
import 'package:hs_coaching_app/features/display/domain/display_content_settings.dart';

/// A provider that fetches the content settings for a display.
///
/// This is a `StreamProvider` to listen for real-time changes to the content type.
final displayContentSettingsProvider = StreamProvider<DisplayContentSettings>((
  ref,
) {
  // Watch the provider for the device IDs.
  // This provider will automatically re-run if the IDs change.
  final ids = ref.watch(displayDeviceIdsProvider);

  //ToDo: Move to repositories?
  final stream = FirebaseFirestore.instance
      .collection('clubs')
      .doc(ids.clubId)
      .collection('displays')
      .doc(ids.displayDeviceId)
      .collection('settings')
      .doc('content')
      .snapshots();

  return stream.map((snapshot) {
    if (!snapshot.exists || snapshot.data() == null) {
      // If the document doesn't exist, create a default settings object.
      // This can happen when a new screen is created.
      return const DisplayContentSettings(contentType: DisplayContentType.main);
    }
    return DisplayContentSettings.fromMap(snapshot.data()!);
  });
});
