import 'dart:async';

import 'package:flutter/material.dart';
import 'package:hs_coaching_app/features/display/features/training/domain/training_tree.dart';

/// Sleeplast voor Training-kaarten: het [TrainingPath] van de bron-knoop.
/// Dat pad is genoeg identiteit — het duidt uniek een knoop aan binnen de
/// huidige boom, dus er is geen apart drag-id nodig.
class TrainingDragPayload {
  const TrainingDragPayload(this.path);
  final TrainingPath path;
}

/// Sleepgreep links op een kaart. Op de kaart zelf zit een
/// `LongPressDraggable` (lang indrukken, handig op de tablet); deze greep
/// is daarnaast zelf meteen sleepbaar, zonder wachten — zo verplaatst de
/// muis een kaart met gewoon klikken-en-slepen. [payload] en [label] (tekst
/// in de sleep-preview) horen bij de kaart; de volledige kaart als preview
/// kan hier niet, die bevat deze greep zelf.
class TrainingDragHandle extends StatelessWidget {
  const TrainingDragHandle({
    super.key,
    required this.payload,
    required this.label,
  });

  final TrainingDragPayload payload;
  final String label;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final icon = Icon(Icons.drag_indicator, color: scheme.onSurfaceVariant);
    return MouseRegion(
      cursor: SystemMouseCursors.grab,
      child: Draggable<TrainingDragPayload>(
        data: payload,
        dragAnchorStrategy: pointerDragAnchorStrategy,
        feedback: Material(
          elevation: 4,
          borderRadius: BorderRadius.circular(8),
          color: scheme.surfaceContainerHigh,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.drag_indicator, color: scheme.onSurfaceVariant),
                const SizedBox(width: 4),
                Text(label, style: Theme.of(context).textTheme.titleMedium),
              ],
            ),
          ),
        ),
        childWhenDragging: Opacity(opacity: 0.3, child: icon),
        child: icon,
      ),
    );
  }
}

String _defaultRejectionMessage(String? reason) =>
    reason ?? 'This item cannot go here.';

/// Dunne laat-hier-los-om-te-herordenen/verplaatsen strook tussen twee
/// kaarten (of aan het begin/einde van een lijst). Licht accentkleurig op
/// zodra een geldige knoop erover zweeft, gedimd rood wanneer de zwevende
/// knoop hier niet mag komen (zie `canInsert` in `training_tree.dart`) —
/// zichtbaar vóórdat wordt losgelaten, niet pas erna (ontwerpdocument §8).
///
/// Accepteert nu bewust ook knopen uit een andere lijst dan de eigen ouder:
/// cross-diepte/cross-ouder verplaatsen is precies wat v2 mogelijk maakt.
/// v1's versie accepteerde altijd zonder [canAccept], omdat de aanroeper
/// zelf al filterde op "alleen knopen uit mijn eigen lijst" — dat filter
/// bestaat hier niet meer, [canAccept] is nu de enige poortwachter.
class TrainingInsertGap extends StatelessWidget {
  const TrainingInsertGap({
    super.key,
    required this.onAccept,
    required this.canAccept,
    this.rejectionMessage,
  });

  final ValueChanged<TrainingDragPayload> onAccept;
  final bool Function(TrainingDragPayload data) canAccept;
  final String Function(TrainingDragPayload data)? rejectionMessage;

  @override
  Widget build(BuildContext context) {
    return DragTarget<TrainingDragPayload>(
      // Altijd accepteren tijdens het zweven (ook als canAccept straks
      // false blijkt) — anders verschijnt de rood-gedimde "niet
      // toegestaan"-visual nooit, en zou een ongeldige drop stil mislukken
      // in plaats van dat de coach het vóóraf ziet.
      onWillAcceptWithDetails: (details) => true,
      onAcceptWithDetails: (details) {
        if (canAccept(details.data)) {
          onAccept(details.data);
          return;
        }
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              _defaultRejectionMessage(rejectionMessage?.call(details.data)),
            ),
          ),
        );
      },
      builder: (context, candidateData, rejectedData) {
        final payload = candidateData.isNotEmpty ? candidateData.first : null;
        final valid = payload != null && canAccept(payload);
        final invalid = payload != null && !valid;
        final scheme = Theme.of(context).colorScheme;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 120),
          height: payload != null ? 24 : 8,
          margin: const EdgeInsets.symmetric(vertical: 2),
          decoration: BoxDecoration(
            color: valid
                ? scheme.primary.withValues(alpha: 0.25)
                : invalid
                ? scheme.error.withValues(alpha: 0.2)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(4),
          ),
        );
      },
    );
  }
}

/// Laat-hier-los-om-te-groeperen doelvlak: wikkelt om een kaart heen. Lost
/// op in een accentomranding zodra een geldige knoop erboven zweeft,
/// gedimd rood wanneer niet (zelfde live-`canAccept`-principe als
/// [TrainingInsertGap], zie `groupWithTarget` in `training_tree.dart`).
class TrainingGroupTarget extends StatelessWidget {
  const TrainingGroupTarget({
    super.key,
    required this.child,
    required this.onAccept,
    required this.canAccept,
    this.rejectionMessage,
  });

  final Widget child;
  final ValueChanged<TrainingDragPayload> onAccept;
  final bool Function(TrainingDragPayload data) canAccept;
  final String Function(TrainingDragPayload data)? rejectionMessage;

  @override
  Widget build(BuildContext context) {
    return DragTarget<TrainingDragPayload>(
      onWillAcceptWithDetails: (details) => true,
      onAcceptWithDetails: (details) {
        if (canAccept(details.data)) {
          onAccept(details.data);
          return;
        }
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              _defaultRejectionMessage(rejectionMessage?.call(details.data)),
            ),
          ),
        );
      },
      builder: (context, candidateData, rejectedData) {
        final payload = candidateData.isNotEmpty ? candidateData.first : null;
        final valid = payload != null && canAccept(payload);
        final invalid = payload != null && !valid;
        final scheme = Theme.of(context).colorScheme;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 120),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: valid
                ? Border.all(color: scheme.primary, width: 2)
                : invalid
                ? Border.all(color: scheme.error, width: 2)
                : null,
          ),
          child: child,
        );
      },
    );
  }
}

/// Laat een scrollbare lijst vanzelf scrollen terwijl een kaart (een
/// [TrainingDragPayload]) boven- of onderaan tegen de rand gehouden wordt:
/// Flutter's `Draggable` doet dat zelf niet, waardoor een kaart niet naar
/// een plek buiten beeld te slepen was. Twee onzichtbare randstroken boven
/// de lijst reageren enkel op een sleepbeweging (ze aanvaarden niets), en
/// scrollen sneller naarmate de vinger/muis dichter bij de rand komt.
class TrainingDragAutoScroll extends StatefulWidget {
  const TrainingDragAutoScroll({super.key, required this.builder});

  /// Bouwt de lijst met de [ScrollController] die hier gescrold wordt.
  final Widget Function(BuildContext context, ScrollController controller)
  builder;

  @override
  State<TrainingDragAutoScroll> createState() => _TrainingDragAutoScrollState();
}

class _TrainingDragAutoScrollState extends State<TrainingDragAutoScroll> {
  static const _edgeHeight = 64.0;
  static const _maxSpeed = 18.0; // pixels per tik
  static const _tick = Duration(milliseconds: 16);

  final _controller = ScrollController();
  Timer? _timer;

  // Pixels per tik: negatief = omhoog.
  double _velocity = 0;
  double _pointerY = 0;

  @override
  void dispose() {
    _timer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  void _update(double velocity) {
    _velocity = velocity;
    if (velocity == 0) {
      _timer?.cancel();
      _timer = null;
      return;
    }
    _timer ??= Timer.periodic(_tick, (_) => _scroll());
  }

  void _scroll() {
    if (!_controller.hasClients) return;
    final position = _controller.position;
    final target = (position.pixels + _velocity).clamp(
      position.minScrollExtent,
      position.maxScrollExtent,
    );
    if (target != position.pixels) _controller.jumpTo(target);
  }

  /// Snelheid voor de pointer op [globalY] in de strook van [context]:
  /// vol aan de buitenrand, een derde aan de binnenrand.
  double _speedIn(BuildContext context, double globalY, {required bool top}) {
    final box = context.findRenderObject() as RenderBox?;
    if (box == null || !box.hasSize) return 0;
    final local = box.globalToLocal(Offset(0, globalY)).dy;
    final depth = (top ? 1 - local / _edgeHeight : local / _edgeHeight).clamp(
      0.0,
      1.0,
    );
    final speed = _maxSpeed * (0.33 + 0.67 * depth);
    return top ? -speed : speed;
  }

  Widget _edge({required bool top}) {
    return Builder(
      builder: (context) => DragTarget<TrainingDragPayload>(
        onWillAcceptWithDetails: (_) => false,
        onMove: (_) => _update(_speedIn(context, _pointerY, top: top)),
        onLeave: (_) => _update(0),
        builder: (context, candidate, rejected) =>
            const SizedBox(height: _edgeHeight, width: double.infinity),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // De [Listener] volgt de echte pointerpositie: `DragTargetDetails.offset`
    // is de hoek van de sleep-preview, die ver van de vinger kan liggen.
    return Listener(
      onPointerMove: (event) => _pointerY = event.position.dy,
      onPointerUp: (_) => _update(0),
      onPointerCancel: (_) => _update(0),
      child: Stack(
        children: [
          Positioned.fill(child: widget.builder(context, _controller)),
          Positioned(top: 0, left: 0, right: 0, child: _edge(top: true)),
          Positioned(bottom: 0, left: 0, right: 0, child: _edge(top: false)),
        ],
      ),
    );
  }
}
