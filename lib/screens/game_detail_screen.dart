import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/game.dart';
import '../models/player.dart';
import '../providers/games_provider.dart';
import '../widgets/planted_header.dart';
import '../widgets/scoresheet_table.dart';

class GameDetailScreen extends ConsumerWidget {
  final Game game;

  const GameDetailScreen({super.key, required this.game});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    final winnerIdx = game.winnerIndex();
    final winnerName = game.winnerName();

    return Scaffold(
      appBar: AppBar(
        title: Text(game.name ?? _formatDate(game.date)),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_outline),
            onPressed: () => _confirmDelete(context, ref),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const PlantedTableHeader(),
            if (winnerName != null) _buildWinnerBanner(context, winnerName, winnerIdx!, game, dark),
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildMetaCard(context, dark),
                  const SizedBox(height: 16),
                  ScoresheetTable(game: game),
                  const SizedBox(height: 16),
                  _buildScoreSummary(context, dark),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWinnerBanner(BuildContext context, String winner, int winnerIdx,
      Game game, bool dark) {
    final colorVal = kPlayerColorValues[
        game.playerColorIndexes[winnerIdx] % kPlayerColorValues.length];
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 20),
      color: Color(colorVal).withValues(alpha: dark ? 0.3 : 0.15),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text('🏆', style: TextStyle(fontSize: 24)),
          const SizedBox(width: 10),
          Column(
            children: [
              Text(
                winner,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  color: Color(colorVal),
                ),
              ),
              Text(
                '${game.totalForPlayer(winnerIdx)} points',
                style: TextStyle(
                  fontSize: 13,
                  color: dark ? Colors.white60 : Colors.black54,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMetaCard(BuildContext context, bool dark) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          children: [
            _metaRow(Icons.calendar_today_outlined, _formatDate(game.date), dark),
            if (game.notes != null && game.notes!.isNotEmpty) ...[
              const Divider(height: 16),
              _metaRow(Icons.notes_outlined, game.notes!, dark),
            ],
          ],
        ),
      ),
    );
  }

  Widget _metaRow(IconData icon, String text, bool dark) {
    return Row(
      children: [
        Icon(icon, size: 18, color: dark ? Colors.white54 : Colors.black45),
        const SizedBox(width: 10),
        Expanded(
          child: Text(text,
              style: TextStyle(
                  color: dark ? Colors.white70 : Colors.black87)),
        ),
      ],
    );
  }

  Widget _buildScoreSummary(BuildContext context, bool dark) {
    final sorted = List.generate(game.numPlayers, (i) => i)
      ..sort((a, b) => game.totalForPlayer(b).compareTo(game.totalForPlayer(a)));

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Final Scores',
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700)),
            const SizedBox(height: 12),
            ...sorted.asMap().entries.map((entry) {
              final rank = entry.key;
              final idx = entry.value;
              final colorVal = kPlayerColorValues[
                  game.playerColorIndexes[idx] % kPlayerColorValues.length];
              return Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  children: [
                    SizedBox(
                      width: 28,
                      child: Text(
                        rank == 0 ? '🥇' : rank == 1 ? '🥈' : rank == 2 ? '🥉' : '${rank + 1}.',
                        style: const TextStyle(fontSize: 16),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    const SizedBox(width: 8),
                    CircleAvatar(
                      radius: 14,
                      backgroundColor: Color(colorVal),
                      child: Text(
                        game.playerNames[idx][0].toUpperCase(),
                        style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.bold),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(game.playerNames[idx],
                          style: const TextStyle(fontWeight: FontWeight.w500)),
                    ),
                    Text(
                      '${game.totalForPlayer(idx)}',
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 16,
                        color: rank == 0 ? const Color(0xFFDAA520) : null,
                      ),
                    ),
                  ],
                ),
              );
            }),
          ],
        ),
      ),
    );
  }

  Future<void> _confirmDelete(BuildContext context, WidgetRef ref) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Game'),
        content: const Text('This game will be permanently deleted.'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Cancel')),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: FilledButton.styleFrom(backgroundColor: Colors.redAccent),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      ref.read(gamesProvider.notifier).deleteGame(game.id);
      if (context.mounted) Navigator.pop(context);
    }
  }

  String _formatDate(DateTime d) =>
      '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';
}
