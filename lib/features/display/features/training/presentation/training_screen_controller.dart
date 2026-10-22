import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hs_coaching_core/core/providers/server_time_offset_provider.dart';
import 'package:hs_coaching_core/training/training.dart';
import 'package:hs_coaching_core/training/training_flatten.dart';
import 'package:hs_coaching_core/training/training_session_progress.dart';
import 'package:hs_coaching_app/features/display/features/training/data/training_provider.dart';

/// Vertaalt de gesynchroniseerde [Training] state naar een lokaal tikkende
/// [TrainingSessionProgress], zelfde RTDB-klokdrift-principe als
/// `TabataScreenController`. De positie wordt vanaf het anker
/// (`Training.currentStepIndex`) met de verstreken tijd doorgerekend
/// (`trainingProgressAt`), dus getimede stappen schuiven vanzelf door zonder
/// dat deze controller iets schrijft — de display rekent precies hetzelfde
/// uit en loopt ook door als de tablet slaapt. Er wordt alleen getikt
/// zolang de huidige stap getimed is en de sessie loopt; op een ongetimede
/// stap wacht de sessie op "volgende" van de coach.
class TrainingScreenController extends Notifier<TrainingSessionProgress> {
  Timer? _timer;

  @override
  TrainingSessionProgress build() {
    final training =
        ref.watch(trainingNotifierProvider).value ?? const Training();
    final offsetMillis = ref.watch(serverTimeOffsetProvider).value ?? 0;

    ref.onDispose(() => _timer?.cancel());
    _timer?.cancel();

    final steps = flattenTraining(training);
    final progress = trainingProgressAt(
      training,
      steps,
      nowServerMillis: serverNowMillis(offsetMillis),
    );

    if (progress.isTicking) {
      _timer = Timer.periodic(const Duration(milliseconds: 100), (_) {
        final currentOffset = ref.read(serverTimeOffsetProvider).value ?? 0;
        final tickProgress = trainingProgressAt(
          training,
          steps,
          nowServerMillis: serverNowMillis(currentOffset),
        );
        state = tickProgress;
        // Op een ongetimede stap of na de laatste stap verandert er niets
        // meer tot de volgende Firestore-wijziging (nieuwe [build]).
        if (!tickProgress.isTicking) _timer?.cancel();
      });
    }

    return progress;
  }
}

final trainingScreenControllerProvider =
    NotifierProvider<TrainingScreenController, TrainingSessionProgress>(
      TrainingScreenController.new,
    );
