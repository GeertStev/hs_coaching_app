import 'package:flutter_riverpod/flutter_riverpod.dart';

/// A record to hold the IDs required to fetch a display device.
typedef DisplayDeviceIds = ({String clubId, String displayDeviceId});

/// A provider that holds the IDs for the current display device.
///
/// Reading from environment variables / local configuration
/// Initial setup/login flow.
///
final displayDeviceIdsProvider = Provider<DisplayDeviceIds>((ref) {
  // TODO: Replace hardcoded values with a robust method for ID retrieval.
  return (clubId: 'holySquid', displayDeviceId: 'bilzen');
});
