import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hs_coaching_core/training/training.dart';
import 'package:hs_coaching_core/training/training_parameter_row.dart';
import 'package:hs_coaching_core/training/training_session_progress.dart';
import 'package:hs_coaching_core/training/training_status.dart';
import 'package:hs_coaching_core/training/training_step.dart';
import 'package:hs_coaching_core/training/training_step_phase.dart';
import 'package:hs_coaching_app/core/theme/app_theme.dart';
import 'package:hs_coaching_app/features/display/domain/display_content_settings.dart';
import 'package:hs_coaching_app/features/display/presentation/content_control_screen.dart';
import 'package:hs_coaching_app/features/display/features/training/data/training_provider.dart';
import 'package:hs_coaching_app/features/display/features/training/domain/training_template.dart';
import 'package:hs_coaching_app/features/display/features/training/presentation/training_children_editor.dart';
import 'package:hs_coaching_app/features/display/features/training/presentation/training_dialogs.dart';
import 'package:hs_coaching_app/features/display/features/training/presentation/training_screen_controller.dart';

/// `ContentControlScreen`-wrapper zoals Sketch/Image/Tabata/etc. — Training
/// heeft sinds de live-sessietab hieronder (`_LiveTab`) een echte
/// `DisplayContentType.training`-waarde en dus een "cast naar scherm"-knop.
class TrainingControlScreen extends ConsumerWidget {
  const TrainingControlScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final trainingAsync = ref.watch(trainingNotifierProvider);

    return ContentControlScreen(
      contentType: DisplayContentType.training,
      body: trainingAsync.when(
        data: (training) => _TrainingConfigView(training: training),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) =>
            Center(child: Text('Error loading Training: $err')),
      ),
    );
  }
}

class _TrainingConfigView extends StatelessWidget {
  const _TrainingConfigView({required this.training});
  final Training training;

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Column(
        children: [
          Material(
            color: Theme.of(context).colorScheme.surface,
            child: const TabBar(
              tabs: [
                Tab(icon: Icon(Icons.edit_note), text: 'Editor'),
                Tab(icon: Icon(Icons.list), text: 'List'),
                Tab(icon: Icon(Icons.play_circle_outline), text: 'Live'),
              ],
            ),
          ),
          Expanded(
            child: TabBarView(
              children: [
                _EditorTab(training: training),
                const _ListTab(),
                _LiveTab(training: training),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Editor-tab: de root-lijst van groepen en losse oefeningen
// ---------------------------------------------------------------------------

/// Dunne wrapper rond [TrainingChildrenEditor] voor de root-lijst — v1's
/// hand-uitgeschreven `_reorder`/`_updateChild`/`_removeChild`/`_group`/
/// `_addExercise`/`_addSet`/`_openTemplate` (inclusief een inline dubbel
/// van `groupWithTarget`'s root-logica) zijn allemaal opgegaan in die ene
/// gedeelde editor, die nu op elk niveau hetzelfde werkt.
class _EditorTab extends ConsumerWidget {
  const _EditorTab({required this.training});
  final Training training;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(12, 12, 12, 32),
      children: [
        TrainingChildrenEditor(
          children: training.children,
          parentPath: const [],
          onChanged: (updated) {
            ref
                .read(trainingCommandsProvider)
                .save(training.copyWith(children: updated));
          },
        ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// List-tab: bibliotheek van opgeslagen groep-/oefening-templates
// ---------------------------------------------------------------------------

String _kindGroupLabel(TrainingTemplateKind kind) => switch (kind) {
  TrainingTemplateKind.group => 'Sets',
  TrainingTemplateKind.exercise => 'Oefeningen',
};

class _ListTab extends ConsumerWidget {
  const _ListTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final templatesAsync = ref.watch(trainingTemplatesProvider);
    final commands = ref.read(trainingCommandsProvider);

    return templatesAsync.when(
      data: (templates) {
        if (templates.isEmpty) {
          return const Center(child: Text('Nog geen templates opgeslagen.'));
        }

        return ListView(
          padding: const EdgeInsets.all(12),
          children: [
            for (final kind in TrainingTemplateKind.values)
              if (templates.any((t) => t.kind == kind)) ...[
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Text(
                    _kindGroupLabel(kind),
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                for (final template
                    in templates.where((t) => t.kind == kind).toList()
                      ..sort((a, b) => a.title.compareTo(b.title)))
                  Card(
                    child: ListTile(
                      title: Text(template.title),
                      trailing: IconButton(
                        icon: const Icon(Icons.delete_outline),
                        onPressed: () async {
                          final confirmed = await showTrainingDeleteConfirmDialog(
                            context,
                            itemLabel: template.title,
                          );
                          if (confirmed == true) {
                            await commands.deleteTemplate(template.id);
                          }
                        },
                      ),
                    ),
                  ),
              ],
          ],
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (err, stack) => Center(child: Text('Fout bij laden: $err')),
    );
  }
}

// ---------------------------------------------------------------------------
// Live-tab: sessiebediening (play/pause/next/previous) + huidige stap
// ---------------------------------------------------------------------------

class _LiveTab extends ConsumerWidget {
  const _LiveTab({required this.training});
  final Training training;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final progress = ref.watch(trainingScreenControllerProvider);
    final commands = ref.read(trainingCommandsProvider);
    final metrics = Theme.of(context).appMetrics;
    final colorScheme = Theme.of(context).colorScheme;
    final buttonLabelStyle = Theme.of(
      context,
    ).textTheme.labelLarge?.copyWith(fontSize: 16);

    final step = progress.currentStep;

    if (step == null && !progress.isFinished) {
      return Center(
        child: ElevatedButton.icon(
          onPressed: training.children.isEmpty
              ? null
              : () => commands.moveToFirstStep(training),
          icon: const Icon(Icons.play_arrow),
          label: const Text('Start sessie'),
        ),
      );
    }

    return Padding(
      padding: EdgeInsets.all(metrics.spacingMd),
      child: Column(
        children: [
          Expanded(
            child: progress.isFinished
                ? Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.check_circle,
                          size: 64,
                          color: colorScheme.primary,
                        ),
                        SizedBox(height: metrics.spacingMd),
                        Text(
                          'Training voltooid',
                          style: Theme.of(context).textTheme.headlineSmall,
                        ),
                      ],
                    ),
                  )
                : _StepView(step: step!, progress: progress),
          ),
          SizedBox(height: metrics.spacingLg),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(
                width: 100,
                height: 48,
                child: ElevatedButton(
                  onPressed: () => commands.previous(training),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: colorScheme.tertiaryContainer,
                    foregroundColor: colorScheme.onTertiaryContainer,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(
                        metrics.radiusDefault,
                      ),
                    ),
                  ),
                  child: Text('Vorige', style: buttonLabelStyle),
                ),
              ),
              SizedBox(width: metrics.spacingMd),
              SizedBox(
                width: 150,
                height: 54,
                child: progress.isFinished
                    ? ElevatedButton(
                        onPressed: () => commands.resetSession(training),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: colorScheme.tertiary,
                          foregroundColor: colorScheme.onTertiary,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(
                              metrics.radiusDefault,
                            ),
                          ),
                        ),
                        child: Text('Reset', style: buttonLabelStyle),
                      )
                    : training.status == TrainingStatus.running
                    ? ElevatedButton(
                        onPressed: () => commands.pause(training),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: colorScheme.secondary,
                          foregroundColor: colorScheme.onSecondary,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(
                              metrics.radiusDefault,
                            ),
                          ),
                        ),
                        child: Text('Pause', style: buttonLabelStyle),
                      )
                    : ElevatedButton(
                        onPressed: () => commands.start(training),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: colorScheme.primary,
                          foregroundColor: colorScheme.onPrimary,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(
                              metrics.radiusDefault,
                            ),
                          ),
                        ),
                        child: Text('Hervat', style: buttonLabelStyle),
                      ),
              ),
              SizedBox(width: metrics.spacingMd),
              SizedBox(
                width: 100,
                height: 48,
                child: ElevatedButton(
                  onPressed: progress.isFinished
                      ? null
                      : () => commands.next(training),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: colorScheme.primaryContainer,
                    foregroundColor: colorScheme.onPrimaryContainer,
                    disabledBackgroundColor: colorScheme.surfaceContainerHighest,
                    disabledForegroundColor: colorScheme.onSurfaceVariant,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(
                        metrics.radiusDefault,
                      ),
                    ),
                  ),
                  child: Text('Volgende', style: buttonLabelStyle),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// Toont de huidige stap: herhalings-context ("Set 2/3"), stapteller,
/// oefening + timing-rij-naam, werk/rust-label, aftellende tijd (of "Wacht
/// op coach" als de stap ongetimed is — zie `training.dart`'s doc comment),
/// en de parameter-rijen (reps/afstand/slag/intensiteit/zone).
class _StepView extends StatelessWidget {
  const _StepView({required this.step, required this.progress});
  final TrainingStep step;
  final TrainingSessionProgress progress;

  String _formatRemaining(Duration d) {
    final minutes = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final seconds = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }

  String _formatParameterRow(TrainingParameterRow row) {
    final parts = <String>[
      if (row.reps != null) '${row.reps}x',
      if (row.distance != null) '${row.distance}m',
      if (row.stroke != null) row.stroke!,
      if (row.intensity != null) '${row.intensity}%',
      if (row.zone != null) row.zone!,
    ];
    return parts.join(' ');
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final phaseColor = step.phase == TrainingStepPhase.rest
        ? colorScheme.tertiary
        : colorScheme.primary;

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          for (final repeat in step.repeats)
            Text(
              '${repeat.groupTitle ?? "Herhaling"}: ${repeat.iteration}/${repeat.repeatCount}',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          const SizedBox(height: 8),
          Text(
            'Stap ${progress.stepIndex + 1}/${progress.totalSteps}',
            style: Theme.of(context).textTheme.bodySmall,
          ),
          const SizedBox(height: 8),
          Text(
            step.exerciseTitle,
            style: Theme.of(context).textTheme.headlineSmall,
            textAlign: TextAlign.center,
          ),
          if (step.groupName.isNotEmpty)
            Text(
              step.groupName,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          const SizedBox(height: 8),
          Text(
            step.phase == TrainingStepPhase.rest ? 'Rust' : 'Werk',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: phaseColor,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          if (progress.remaining != null)
            Text(
              _formatRemaining(progress.remaining!),
              style: Theme.of(context).textTheme.displayLarge?.copyWith(
                fontFamily: 'monospace',
                fontWeight: FontWeight.bold,
                color: phaseColor,
              ),
            )
          else
            Text(
              'Wacht op coach',
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(color: colorScheme.outline),
            ),
          const SizedBox(height: 16),
          for (final row in step.parameterRows)
            if (_formatParameterRow(row).isNotEmpty)
              Text(
                _formatParameterRow(row),
                style: Theme.of(context).textTheme.bodyLarge,
              ),
        ],
      ),
    );
  }
}
