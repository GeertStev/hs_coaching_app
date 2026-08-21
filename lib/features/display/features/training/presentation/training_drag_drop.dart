import 'package:flutter/material.dart';
import 'package:hs_coaching_app/features/display/features/training/domain/training_tree.dart';

/// Sleeplast voor Training-kaarten: het [TrainingPath] van de bron-knoop.
/// Dat pad is genoeg identiteit — het duidt uniek een knoop aan binnen de
/// huidige boom, dus er is geen apart drag-id nodig.
class TrainingDragPayload {
  const TrainingDragPayload(this.path);
  final TrainingPath path;
}

/// Kleine handle die visueel aangeeft dat een kaart sleepbaar is
/// (long-press-drag, zoals Tabata's oude kaart-builder). Puur decoratief —
/// de daadwerkelijke `LongPressDraggable`-wrapping gebeurt in de
/// aanroepende kaartwidget zelf, omdat sleeplast en feedback-preview per
/// kaarttype verschillen.
class TrainingDragHandle extends StatelessWidget {
  const TrainingDragHandle({super.key});

  @override
  Widget build(BuildContext context) {
    return Icon(
      Icons.drag_indicator,
      color: Theme.of(context).colorScheme.onSurfaceVariant,
    );
  }
}

String _defaultRejectionMessage(String? reason) =>
    reason ?? 'Deze plek kan dit niet bevatten.';

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
