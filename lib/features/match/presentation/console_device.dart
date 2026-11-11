import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hs_coaching_core/core/errors/error_reporting.dart';
import 'package:wakelock_plus/wakelock_plus.dart';

/// Wat de console van het toestel zelf nodig heeft: scherm aan, liggend
/// formaat, trillen en geluid. Achter een provider zodat tests het kunnen
/// vervangen.
class ConsoleDevice {
  const ConsoleDevice();

  /// Console open: liggend formaat en het scherm blijft aan (03 §1).
  Future<void> enterConsole() async {
    await SystemChrome.setPreferredOrientations(const [
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
    await _guard(WakelockPlus.enable, 'scherm aan houden');
  }

  Future<void> leaveConsole() async {
    await SystemChrome.setPreferredOrientations(const []);
    await _guard(WakelockPlus.disable, 'scherm aan houden uitzetten');
  }

  /// Korte bevestiging dat een tik aanvaard is.
  void confirmTap() => HapticFeedback.mediumImpact();

  /// Hint aan de tafel (einde straf, einde periode, ...): trillen en geluid.
  void hint() {
    HapticFeedback.heavyImpact();
    SystemSound.play(SystemSoundType.alert);
  }

  Future<void> _guard(Future<void> Function() action, String context) async {
    try {
      await action();
    } on Object catch (error, stack) {
      // Zonder wakelock werkt de tafel nog; wel melden.
      reportError(error, stack, context: context);
    }
  }
}

final consoleDeviceProvider = Provider<ConsoleDevice>(
  (ref) => const ConsoleDevice(),
);
