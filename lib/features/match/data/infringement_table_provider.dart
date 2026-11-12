import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hs_coaching_core/match/engine/infringement_table.dart';

/// De overtredingentabel 17.7.1 uit het asset van core. De engine zelf laadt
/// geen assets; dat gebeurt hier.
final infringementTableProvider = FutureProvider<InfringementTable>((
  ref,
) async {
  final text = await rootBundle.loadString(
    'packages/hs_coaching_core/${InfringementTable.assetPath}',
  );
  return InfringementTable.fromJson(jsonDecode(text) as Map<String, dynamic>);
});
