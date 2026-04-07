import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/game.dart'; // ignore: unused_import (used for List<Game> param)
import '../models/player.dart';
import '../models/score_categories.dart';
import '../providers/games_provider.dart';

class StatsScreen extends ConsumerWidget {
  const StatsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final games = ref.watch(gamesProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Statistics')),
      body: games.isEmpty
          ? _emptyState()
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  _OverallStatsCard(games: games),
                  const SizedBox(height: 16),
                  _PlayerLeaderboard(games: games),
                  const SizedBox(height: 16),
                  _CategoryAverages(games: games),
                ],
              ),
            ),
    );
  }

  Widget _emptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.bar_chart, size: 72, color: Colors.grey.withValues(alpha: 0.4)),
          const SizedBox(height: 16),
          const Text('No stats yet',
              style: TextStyle(fontSize: 18, color: Colors.grey)),
          const SizedBox(height: 8),
          const Text('Play some games to see statistics',
              style: TextStyle(color: Colors.grey)),
        ],
      ),
    );
  }
}

class _OverallStatsCard extends StatelessWidget {
  final List<Game> games;
  const _OverallStatsCard({required this.games});

  @override
  Widget build(BuildContext context) {
    final allScores = games.expand((g) =>
        List.generate(g.numPlayers, (i) => g.totalForPlayer(i)));
    final scores = allScores.toList();
    final avgScore =
        scores.isEmpty ? 0.0 : scores.reduce((a, b) => a + b) / scores.length;
    final highScore = scores.isEmpty ? 0 : scores.reduce((a, b) => a > b ? a : b);

    // Find player with highest score
    String? bestPlayer;
    for (final g in games) {
      for (int i = 0; i < g.numPlayers; i++) {
        if (g.totalForPlayer(i) == highScore) {
          bestPlayer = g.playerNames[i];
        }
      }
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Overview',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
            const SizedBox(height: 12),
            Row(
              children: [
                _statTile('Games\nPlayed', '${games.length}', kHeaderGreen),
                _statTile('Avg\nScore', avgScore.toStringAsFixed(1),
                    const Color(0xFF2196F3)),
                _statTile('High\nScore', '$highScore', const Color(0xFFDAA520)),
              ],
            ),
            if (bestPlayer != null) ...[
              const Divider(height: 20),
              Row(
                children: [
                  const Text('🏆', style: TextStyle(fontSize: 18)),
                  const SizedBox(width: 8),
                  Text('Record holder: $bestPlayer ($highScore pts)'),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _statTile(String label, String value, Color color) {
    return Expanded(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 4),
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Column(
          children: [
            Text(value,
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  color: color,
                )),
            const SizedBox(height: 4),
            Text(label,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 11, color: Colors.grey)),
          ],
        ),
      ),
    );
  }
}

class _PlayerLeaderboard extends StatelessWidget {
  final List<Game> games;
  const _PlayerLeaderboard({required this.games});

  @override
  Widget build(BuildContext context) {
    // Aggregate per player name
    final Map<String, _PlayerStats> stats = {};
    for (final game in games) {
      final winnerIdx = game.winnerIndex();
      for (int i = 0; i < game.numPlayers; i++) {
        final name = game.playerNames[i];
        final colorIdx = game.playerColorIndexes[i];
        final total = game.totalForPlayer(i);
        stats.putIfAbsent(name, () => _PlayerStats(name, colorIdx));
        stats[name]!.addGame(total, i == winnerIdx);
      }
    }

    final sorted = stats.values.toList()
      ..sort((a, b) => b.winCount.compareTo(a.winCount));

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Player Leaderboard',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
            const SizedBox(height: 4),
            const Text('Sorted by wins',
                style: TextStyle(fontSize: 12, color: Colors.grey)),
            const SizedBox(height: 12),
            ...sorted.asMap().entries.map((e) {
              final rank = e.key;
              final s = e.value;
              final colorVal = kPlayerColorValues[
                  s.colorIndex % kPlayerColorValues.length];
              return Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: Row(
                  children: [
                    SizedBox(
                      width: 28,
                      child: Text(
                        rank == 0
                            ? '🥇'
                            : rank == 1
                                ? '🥈'
                                : rank == 2
                                    ? '🥉'
                                    : '${rank + 1}.',
                        style: const TextStyle(fontSize: 16),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    const SizedBox(width: 8),
                    CircleAvatar(
                      radius: 16,
                      backgroundColor: Color(colorVal),
                      child: Text(
                        s.name[0].toUpperCase(),
                        style: const TextStyle(
                            color: Colors.white,
                            fontSize: 13,
                            fontWeight: FontWeight.bold),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(s.name,
                              style: const TextStyle(
                                  fontWeight: FontWeight.w600)),
                          Text(
                            '${s.winCount} wins · avg ${s.avgScore.toStringAsFixed(1)} · best ${s.highScore}',
                            style: const TextStyle(
                                fontSize: 11, color: Colors.grey),
                          ),
                        ],
                      ),
                    ),
                    _WinPctBadge(pct: s.winPct, color: Color(colorVal)),
                  ],
                ),
              );
            }),
          ],
        ),
      ),
    );
  }
}

class _PlayerStats {
  final String name;
  final int colorIndex;
  int gameCount = 0;
  int winCount = 0;
  int totalScore = 0;
  int highScore = 0;

  _PlayerStats(this.name, this.colorIndex);

  void addGame(int score, bool won) {
    gameCount++;
    totalScore += score;
    if (score > highScore) highScore = score;
    if (won) winCount++;
  }

  double get winPct => gameCount == 0 ? 0 : winCount / gameCount;
  double get avgScore => gameCount == 0 ? 0 : totalScore / gameCount;
}

class _WinPctBadge extends StatelessWidget {
  final double pct;
  final Color color;
  const _WinPctBadge({required this.pct, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        '${(pct * 100).toStringAsFixed(0)}%',
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w700,
          color: color,
        ),
      ),
    );
  }
}

class _CategoryAverages extends StatelessWidget {
  final List<Game> games;
  const _CategoryAverages({required this.games});

  @override
  Widget build(BuildContext context) {
    // Calculate average score per category across all players/games
    final totals = List<int>.filled(kNumCategories, 0);
    int playerGameCount = 0;
    for (final g in games) {
      for (int p = 0; p < g.numPlayers; p++) {
        for (int c = 0; c < kNumCategories; c++) {
          totals[c] += g.scores[p][c];
        }
        playerGameCount++;
      }
    }

    final avgs = List.generate(
        kNumCategories,
        (c) =>
            playerGameCount == 0 ? 0.0 : totals[c] / playerGameCount);

    final maxAvg =
        avgs.isEmpty ? 1.0 : avgs.reduce((a, b) => a > b ? a : b);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Category Averages',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
            const SizedBox(height: 4),
            const Text('Average points per player per game',
                style: TextStyle(fontSize: 12, color: Colors.grey)),
            const SizedBox(height: 12),
            ...List.generate(kNumCategories, (c) {
              final avg = avgs[c];
              final frac =
                  maxAvg > 0 ? (avg / maxAvg).clamp(0.0, 1.0) : 0.0;
              final barColor = rowColorForCategory(c);
              return Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  children: [
                    SizedBox(
                      width: 100,
                      child: Text(
                        kCategoryLabels[c],
                        style: const TextStyle(
                            fontSize: 12, fontWeight: FontWeight.w500),
                      ),
                    ),
                    Expanded(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: LinearProgressIndicator(
                          value: frac,
                          backgroundColor: barColor.withValues(alpha: 0.3),
                          valueColor:
                              AlwaysStoppedAnimation<Color>(barColor),
                          minHeight: 16,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    SizedBox(
                      width: 36,
                      child: Text(
                        avg.toStringAsFixed(1),
                        style: const TextStyle(
                            fontSize: 12, fontWeight: FontWeight.w600),
                        textAlign: TextAlign.right,
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
}
