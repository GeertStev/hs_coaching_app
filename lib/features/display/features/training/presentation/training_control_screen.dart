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
import 'package:hs_coaching_app/features/display/features/tag_and_search/domain/tag_ops.dart';
import 'package:hs_coaching_app/features/display/features/tag_and_search/presentation/tag_filter_bar.dart';
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

  Future<void> _editTemplate(
    BuildContext context,
    WidgetRef ref,
    TrainingTemplate template,
  ) async {
    final details = await showTrainingTemplateDetailsDialog(
      context,
      dialogTitle: 'Edit template',
      initialTitle: template.title,
      initialTags: template.tags,
      allTags: ref.read(trainingTemplateTagCountsProvider).keys.toList(),
    );
    if (details == null) return;
    await ref
        .read(trainingCommandsProvider)
        .updateTemplate(template.id, title: details.title, tags: details.tags);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final templatesAsync = ref.watch(trainingTemplatesProvider);
    final selectedTags = ref.watch(selectedTemplateTagsProvider);
    final commands = ref.read(trainingCommandsProvider);

    return templatesAsync.when(
      data: (templates) {
        if (templates.isEmpty) {
          return const Center(child: Text('Nog geen templates opgeslagen.'));
        }

        final visible = templates
            .where((t) => matchesAllTags(t.tags, selectedTags))
            .toList();

        return Column(
          children: [
            ReusableTagFilterBar(
              tagCounts: ref.watch(trainingTemplateTagCountsProvider),
              selectedTagsProvider: selectedTemplateTagsProvider,
              tagMaintenanceProvider: trainingRepositoryProvider,
            ),
            Expanded(
              child: visible.isEmpty
                  ? const Center(
                      child: Text('No templates with all selected tags.'),
                    )
                  : ListView(
                      padding: const EdgeInsets.all(12),
                      children: [
                        for (final kind in TrainingTemplateKind.values)
                          if (visible.any((t) => t.kind == kind)) ...[
                            Padding(
                              padding: const EdgeInsets.symmetric(vertical: 8),
                              child: Text(
                                _kindGroupLabel(kind),
                                style: Theme.of(context).textTheme.titleMedium
                                    ?.copyWith(fontWeight: FontWeight.bold),
                              ),
                            ),
                            for (final template
                                in visible.where((t) => t.kind == kind).toList()
                                  ..sort((a, b) => a.title.compareTo(b.title)))
                              Card(
                                child: ListTile(
                                  title: Text(template.title),
                                  subtitle: template.tags.isEmpty
                                      ? null
                                      : Text(template.tags.join(' · ')),
                                  onTap: () =>
                                      _editTemplate(context, ref, template),
                                  trailing: IconButton(
                                    icon: const Icon(Icons.delete_outline),
                                    onPressed: () async {
                                      final confirmed =
                                          await showTrainingDeleteConfirmDialog(
                                            context,
                                            itemLabel: template.title,
                                          );
                                      if (confirmed == true) {
                                        await commands.deleteTemplate(
                                          template.id,
                                        );
                                      }
                                    },
                                  ),
                                ),
                              ),
                          ],
                      ],
                    ),
            ),
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

  Future<void> _confirmReset(
    BuildContext context,
    TrainingCommands commands,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Reset session?'),
        content: const Text(
          'The session goes back to the start. The training itself is kept.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Reset'),
          ),
        ],
      ),
    );
    if (confirmed == true) await commands.resetSession(training);
  }

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

    if (progress.isBeforeStart && !progress.isFinished) {
      return Center(
        child: ElevatedButton.icon(
          onPressed: training.children.isEmpty
              ? null
              : () => commands.moveToFirstStep(training),
          icon: const Icon(Icons.play_arrow),
          label: const Text('Start session'),
        ),
      );
    }

    ButtonStyle buttonStyle(Color background, Color foreground) =>
        ElevatedButton.styleFrom(
          backgroundColor: background,
          foregroundColor: foreground,
          disabledBackgroundColor: colorScheme.surfaceContainerHighest,
          disabledForegroundColor: colorScheme.onSurfaceVariant,
          minimumSize: const Size(0, 52),
          padding: const EdgeInsets.symmetric(horizontal: 8),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(metrics.radiusDefault),
          ),
        );

    Widget button(String label, VoidCallback? onPressed, ButtonStyle style) =>
        Expanded(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: metrics.spacingXs),
            child: ElevatedButton(
              onPressed: onPressed,
              style: style,
              child: Text(
                label,
                style: buttonLabelStyle,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ),
        );

    final isRunning = training.status == TrainingStatus.running;

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
                          'Training finished',
                          style: Theme.of(context).textTheme.headlineSmall,
                        ),
                      ],
                    ),
                  )
                : _StepView(step: step!, progress: progress),
          ),
          SizedBox(height: metrics.spacingLg),
          // Rechts ruimte laten voor de "cast naar scherm"-knop van
          // `ContentControlScreen`, die anders over de laatste knop valt.
          Padding(
            padding: const EdgeInsets.only(right: 72),
            child: Row(
              children: [
                button(
                  'Previous',
                  () => commands.previous(training),
                  buttonStyle(
                    colorScheme.tertiaryContainer,
                    colorScheme.onTertiaryContainer,
                  ),
                ),
                button(
                  isRunning ? 'Pause' : 'Resume',
                  progress.isFinished
                      ? null
                      : isRunning
                      ? () => commands.pause(training)
                      : () => commands.start(training),
                  isRunning
                      ? buttonStyle(
                          colorScheme.secondary,
                          colorScheme.onSecondary,
                        )
                      : buttonStyle(colorScheme.primary, colorScheme.onPrimary),
                ),
                button(
                  'Next',
                  progress.isFinished ? null : () => commands.next(training),
                  buttonStyle(
                    colorScheme.primaryContainer,
                    colorScheme.onPrimaryContainer,
                  ),
                ),
                button(
                  'Reset',
                  () => _confirmReset(context, commands),
                  buttonStyle(
                    colorScheme.errorContainer,
                    colorScheme.onErrorContainer,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Toont de huidige stap: herhalings-context ("Set 2/14"), de oefening
/// binnen de set ("Step 1/4"), oefening + timing-rij-naam, werk/rust-label,
/// aftellende tijd (of "Waiting for coach" als de stap ongetimed is — zie
/// `training.dart`'s doc comment), en de parameter-rijen
/// (reps/afstand/slag/intensiteit/zone).
class _StepView extends StatelessWidget {
  const _StepView({required this.step, required this.progress});
  final TrainingStep step;
  final TrainingSessionProgress progress;

  String _formatSeconds(int totalSeconds) {
    final minutes = (totalSeconds ~/ 60).toString().padLeft(2, '0');
    final seconds = (totalSeconds % 60).toString().padLeft(2, '0');
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
    final remainingSeconds = progress.remainingSeconds;

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          for (final repeat in step.repeats)
            Text(
              '${repeat.groupTitle ?? "Set"} ${repeat.iteration}/${repeat.repeatCount}',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          const SizedBox(height: 8),
          Text(
            'Step ${step.siblingIndex + 1}/${step.siblingCount}',
            style: Theme.of(context).textTheme.bodySmall,
          ),
          const SizedBox(height: 8),
          Text(
            step.exerciseTitle,
            style: Theme.of(context).textTheme.headlineSmall,
            textAlign: TextAlign.center,
          ),
          if (step.groupName.isNotEmpty)
            Text(step.groupName, style: Theme.of(context).textTheme.bodyMedium),
          const SizedBox(height: 8),
          Text(
            progress.status == TrainingStatus.paused
                ? 'Paused'
                : step.phase == TrainingStepPhase.rest
                ? 'Rest'
                : 'Work',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: progress.status == TrainingStatus.paused
                  ? colorScheme.outline
                  : phaseColor,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          if (remainingSeconds != null)
            Text(
              _formatSeconds(remainingSeconds),
              style: Theme.of(context).textTheme.displayLarge?.copyWith(
                fontFamily: 'monospace',
                fontWeight: FontWeight.bold,
                color: phaseColor,
              ),
            )
          else
            Text(
              'Waiting for coach',
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
