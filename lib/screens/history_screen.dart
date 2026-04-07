import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/game.dart';
import '../models/player.dart';
import '../providers/games_provider.dart';
import 'game_detail_screen.dart';

class HistoryScreen extends ConsumerWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final games = ref.watch(gamesProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('History')),
      body: games.isEmpty
          ? _emptyState()
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: games.length,
              itemBuilder: (context, i) => _GameCard(game: games[i]),
            ),
    );
  }

  Widget _emptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.history_outlined,
              size: 72, color: Colors.grey.withValues(alpha: 0.4)),
          const SizedBox(height: 16),
          const Text('No games yet',
              style: TextStyle(fontSize: 18, color: Colors.grey)),
          const SizedBox(height: 8),
          const Text('Finish a game to see it here',
              style: TextStyle(color: Colors.grey)),
        ],
      ),
    );
  }
}

class _GameCard extends StatelessWidget {
  final Game game;
  const _GameCard({required this.game});

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    final winnerIdx = game.winnerIndex();

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => GameDetailScreen(game: game),
          ),
        ),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      game.name ?? _formatDate(game.date),
                      style: const TextStyle(
                          fontSize: 16, fontWeight: FontWeight.w700),
                    ),
                  ),
                  Text(
                    _formatDate(game.date),
                    style: TextStyle(
                      fontSize: 12,
                      color: dark ? Colors.white54 : Colors.black45,
                    ),
                  ),
                ],
              ),
              if (game.name != null) ...[
                const SizedBox(height: 2),
                Text(
                  _formatDate(game.date),
                  style: TextStyle(
                    fontSize: 12,
                    color: dark ? Colors.white54 : Colors.black45,
                  ),
                ),
              ],
              const SizedBox(height: 10),
              // Player score pills
              Wrap(
                spacing: 6,
                runSpacing: 4,
                children: List.generate(game.numPlayers, (i) {
                  final colorVal = kPlayerColorValues[
                      game.playerColorIndexes[i] %
                          kPlayerColorValues.length];
                  final isWinner = i == winnerIdx;
                  return Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: Color(colorVal)
                          .withValues(alpha: dark ? 0.25 : 0.15),
                      borderRadius: BorderRadius.circular(20),
                      border: isWinner
                          ? Border.all(
                              color: Color(colorVal), width: 1.5)
                          : null,
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (isWinner) ...[
                          const Text('🏆', style: TextStyle(fontSize: 11)),
                          const SizedBox(width: 3),
                        ],
                        Text(
                          game.playerNames[i],
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: isWinner
                                ? FontWeight.w700
                                : FontWeight.w500,
                            color: Color(colorVal),
                          ),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '${game.totalForPlayer(i)}',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: dark ? Colors.white70 : Colors.black87,
                          ),
                        ),
                      ],
                    ),
                  );
                }),
              ),
              const SizedBox(height: 6),
              Row(
                children: [
                  Icon(Icons.people_outline,
                      size: 14,
                      color: dark ? Colors.white38 : Colors.black38),
                  const SizedBox(width: 4),
                  Text(
                    '${game.numPlayers} players',
                    style: TextStyle(
                      fontSize: 12,
                      color: dark ? Colors.white38 : Colors.black38,
                    ),
                  ),
                  const Spacer(),
                  const Icon(Icons.chevron_right, size: 18, color: Colors.grey),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatDate(DateTime d) =>
      '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';
}
