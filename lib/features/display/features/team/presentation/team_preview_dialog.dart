import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hs_coaching_core/team/team_repository.dart';
import 'package:hs_coaching_app/features/display/features/team/presentation/display_team_controller.dart';

class TeamPreviewDialog extends ConsumerWidget {
  const TeamPreviewDialog({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final teamsAsync = ref.watch(teamsProvider);

    // Luister ook hier in de dialog voor fouten, zodat de gebruiker direct feedback heeft
    ref.listen<AsyncValue<void>>(teamControllerProvider, (_, state) {
      if (state.hasError && !state.isLoading) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Fout bij het casten: ${state.error}')),
        );
      }
    });

    return AlertDialog(
      title: const Text('Preview team'),
      content: SizedBox(
        width: MediaQuery.of(context).size.width * 0.8,
        child: teamsAsync.when(
          loading: () => const SizedBox(
            height: 100,
            child: Center(child: CircularProgressIndicator()),
          ),
          error: (err, stack) => Text(
            'Error while loading: $err',
            style: const TextStyle(color: Colors.red),
          ),
          data: (teams) {
            final whiteTeam = teams[0];
            final blackTeam = teams[1];

            return _buildTeamTable(whiteTeam, blackTeam);
          },
        ),
      ),
      actions: [
        OutlinedButton.icon(
          icon: const Icon(Icons.refresh, size: 18),
          // Spinning icon on refresh
          label: const Text('Refresh local'),
          style: OutlinedButton.styleFrom(
            side: BorderSide(color: Theme.of(context).colorScheme.outline),
          ),
          onPressed: () => ref.invalidate(teamsProvider),
        ),
        ElevatedButton.icon(
          icon: const Icon(Icons.cast),
          label: const Text('Cast to screen'),
          style: ElevatedButton.styleFrom(
            backgroundColor: Theme.of(context).colorScheme.primary,
            foregroundColor: Theme.of(context).colorScheme.onPrimary,
          ),
          onPressed: () async {
            final controller = ref.read(teamControllerProvider.notifier);

            // Wacht tot de Controller de logica verwerkt heeft
            await controller.castToScreen();

            // Controleer of de widget nog steeds in de tree zit en de actie gelukt is
            if (context.mounted) {
              final state = ref.read(teamControllerProvider);
              if (!state.hasError) {
                Navigator.of(context).pop();
                ScaffoldMessenger.of(
                  context,
                ).showSnackBar(const SnackBar(content: Text('Casting team!')));
              }
            }
          },
        ),
      ],
    );
  }

  /// Bouwt de opstelling als een compacte matrix/tabel
  Widget _buildTeamTable(dynamic whiteTeam, dynamic blackTeam) {
    return Table(
      columnWidths: const {
        0: FlexColumnWidth(1),
        1: FlexColumnWidth(4),
        2: FlexColumnWidth(4),
      },
      defaultVerticalAlignment: TableCellVerticalAlignment.middle,

      children: [
        TableRow(
          children: [
            _buildPositionCell('', hasBackground: false),
            _buildHeaderCell('White', isWhiteTeam: true),
            _buildHeaderCell('Black', isWhiteTeam: false),
          ],
        ),
        TableRow(
          children: [
            _buildPositionCell('F'),
            _buildPlayerCell(whiteTeam.front, isWhiteTeam: true),
            _buildPlayerCell(blackTeam.front, isWhiteTeam: false),
          ],
        ),
        TableRow(
          children: [
            _buildPositionCell('C'),
            _buildPlayerCell(whiteTeam.center, isWhiteTeam: true),
            _buildPlayerCell(blackTeam.center, isWhiteTeam: false),
          ],
        ),
        TableRow(
          children: [
            _buildPositionCell('W'),
            _buildPlayerCell(whiteTeam.wing, isWhiteTeam: true),
            _buildPlayerCell(blackTeam.wing, isWhiteTeam: false),
          ],
        ),
        TableRow(
          children: [
            _buildPositionCell('G'),
            _buildPlayerCell(whiteTeam.goalie, isWhiteTeam: true),
            _buildPlayerCell(blackTeam.goalie, isWhiteTeam: false),
          ],
        ),
      ],
    );
  }

  Widget _buildHeaderCell(String text, {required bool isWhiteTeam}) {
    return Container(
      color: isWhiteTeam ? Colors.white : Colors.black,
      padding: const EdgeInsets.all(8.0),
      child: Text(
        text,
        textAlign: TextAlign.center,
        style: TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 16,
          color: isWhiteTeam ? Colors.black : Colors.white,
        ),
      ),
    );
  }

  Widget _buildPositionCell(String text, {bool hasBackground = true}) {
    return Container(
      padding: const EdgeInsets.all(10.0),
      child: Text(
        text,
        textAlign: TextAlign.center,
        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
      ),
    );
  }

  Widget _buildPlayerCell(List<dynamic> players, {required bool isWhiteTeam}) {
    final playerNames = players.map((p) => p.name).join('\n');

    return Container(
      color: isWhiteTeam ? Colors.white : Colors.black,
      padding: const EdgeInsets.all(6.0),
      alignment: Alignment.center,
      child: Text(
        playerNames.isEmpty ? '-' : playerNames,
        style: TextStyle(
          height: 1.4,
          fontWeight: FontWeight.w500,
          color: isWhiteTeam ? Colors.black87 : Colors.white,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }
}
