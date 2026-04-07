import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/score_categories.dart';
import '../models/game.dart';
import '../models/player.dart';
import '../providers/current_game_provider.dart';
import '../providers/games_provider.dart';
import '../widgets/planted_header.dart';

class ScoringScreen extends ConsumerStatefulWidget {
  const ScoringScreen({super.key});

  @override
  ConsumerState<ScoringScreen> createState() => _ScoringScreenState();
}

class _ScoringScreenState extends ConsumerState<ScoringScreen> {
  // controllers[playerIdx][categoryIdx]
  late List<List<TextEditingController>> _controllers;
  bool _initialized = false;

  @override
  void dispose() {
    for (final row in _controllers) {
      for (final c in row) { c.dispose(); }
    }
    super.dispose();
  }

  void _initControllers(Game game) {
    _controllers = List.generate(
      game.numPlayers,
      (p) => List.generate(
        kNumCategories,
        (c) {
          final v = game.scores[p][c];
          return TextEditingController(text: v == 0 ? '' : '$v');
        },
      ),
    );
    _initialized = true;
  }

  @override
  Widget build(BuildContext context) {
    final game = ref.watch(currentGameProvider);
    if (game == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Scoring')),
        body: const Center(child: Text('No active game')),
      );
    }

    if (!_initialized) _initControllers(game);
    final dark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor:
          dark ? const Color(0xFF1A1F1A) : const Color(0xFFF8F5F0),
      body: SafeArea(
        child: Column(
          children: [
            _buildTopBar(context, game),
            Expanded(
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    children: [
                      const PlantedTableHeader(),
                      const SizedBox(height: 4),
                      _buildTable(context, game, dark),
                      const SizedBox(height: 24),
                      _buildSaveButton(context, game),
                      const SizedBox(height: 16),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTopBar(BuildContext context, Game game) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      color: Theme.of(context).appBarTheme.backgroundColor,
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () => _confirmLeave(context),
          ),
          Expanded(
            child: Text(
              game.name ?? 'Scoring',
              style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w600),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          TextButton.icon(
            onPressed: () => _saveGame(context, game),
            icon: const Icon(Icons.save_outlined, color: Colors.white),
            label: const Text('Save', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  Widget _buildTable(BuildContext context, Game game, bool dark) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(color: dark ? Colors.white12 : Colors.black12),
          borderRadius: BorderRadius.circular(12),
          color: dark ? const Color(0xFF252D25) : Colors.white,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildPlayerHeaderRow(game, dark),
            ...List.generate(
                kNumCategories, (c) => _buildCategoryRow(game, c, dark)),
            _buildTotalRow(game, dark),
          ],
        ),
      ),
    );
  }

  static const double _labelW = 108.0;
  static const double _rowH = 48.0;
  static const double _headerH = 46.0;

  Widget _buildPlayerHeaderRow(Game game, bool dark) {
    final bg = dark ? kPlayerHeaderBgDark : kPlayerHeaderBg;
    return SizedBox(
      height: _headerH,
      child: Row(
        children: [
          _labelCell(
            width: _labelW,
            height: _headerH,
            color: bg,
            child: Text(
              'Player',
              style: TextStyle(
                fontStyle: FontStyle.italic,
                fontWeight: FontWeight.w700,
                fontSize: 13,
                color: dark ? Colors.white60 : Colors.black54,
              ),
            ),
          ),
          ...List.generate(game.numPlayers, (p) {
            final colorVal = kPlayerColorValues[
                game.playerColorIndexes[p] % kPlayerColorValues.length];
            return Expanded(
              child: _cellContainer(
                height: _headerH,
                color: bg,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircleAvatar(
                      radius: 11,
                      backgroundColor: Color(colorVal),
                      child: Text(
                        game.playerNames[p].isNotEmpty
                            ? game.playerNames[p][0].toUpperCase()
                            : '?',
                        style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.bold),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      game.playerNames[p],
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        color: dark ? Colors.white70 : Colors.black87,
                      ),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                    ),
                  ],
                ),
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildCategoryRow(Game game, int catIdx, bool dark) {
    final bg = rowColorForCategory(catIdx, dark: dark);
    return SizedBox(
      height: _rowH,
      child: Row(
        children: [
          _labelCell(
            width: _labelW,
            height: _rowH,
            color: bg,
            child: Text(
              kCategoryLabels[catIdx],
              style: const TextStyle(
                fontStyle: FontStyle.italic,
                fontWeight: FontWeight.w600,
                fontSize: 13,
              ),
            ),
          ),
          ...List.generate(game.numPlayers, (p) {
            return Expanded(
              child: _cellContainer(
                height: _rowH,
                color: bg,
                child: Padding(
                  padding: const EdgeInsets.all(5),
                  child: _ScoreField(
                    controller: _controllers[p][catIdx],
                    dark: dark,
                    onChanged: (v) {
                      final parsed = int.tryParse(v) ?? 0;
                      ref
                          .read(currentGameProvider.notifier)
                          .updateScore(p, catIdx, parsed);
                    },
                  ),
                ),
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildTotalRow(Game game, bool dark) {
    final bg = dark ? const Color(0xFF3A2820) : kTotalPeach;
    return Consumer(builder: (context, ref, _) {
      final g = ref.watch(currentGameProvider);
      return SizedBox(
        height: _rowH,
        child: Row(
          children: [
            _labelCell(
              width: _labelW,
              height: _rowH,
              color: bg,
              child: const Text(
                'Total',
                style: TextStyle(
                  fontStyle: FontStyle.italic,
                  fontWeight: FontWeight.w800,
                  fontSize: 15,
                ),
              ),
            ),
            ...List.generate(game.numPlayers, (p) {
              final total = g?.totalForPlayer(p) ?? 0;
              return Expanded(
                child: _cellContainer(
                  height: _rowH,
                  color: bg,
                  child: Text(
                    '$total',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      color: dark ? Colors.white : Colors.black87,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              );
            }),
          ],
        ),
      );
    });
  }

  Widget _labelCell({
    required double width,
    required double height,
    required Color color,
    required Widget child,
  }) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: color,
        border: const Border(
          right: BorderSide(color: Colors.black12),
          bottom: BorderSide(color: Colors.black12),
        ),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 10),
      alignment: Alignment.centerRight,
      child: child,
    );
  }

  Widget _cellContainer({
    required double height,
    required Color color,
    required Widget child,
  }) {
    return Container(
      height: height,
      decoration: BoxDecoration(
        color: color,
        border: const Border(
          right: BorderSide(color: Colors.black12),
          bottom: BorderSide(color: Colors.black12),
        ),
      ),
      alignment: Alignment.center,
      child: child,
    );
  }

  Widget _buildSaveButton(BuildContext context, Game game) {
    return SizedBox(
      width: double.infinity,
      child: FilledButton.icon(
        onPressed: () => _saveGame(context, game),
        icon: const Icon(Icons.check_circle_outline),
        label: const Text('Save Game', style: TextStyle(fontSize: 16)),
      ),
    );
  }

  Future<void> _saveGame(BuildContext context, Game game) async {
    // Sync controllers → current state one last time
    for (int p = 0; p < game.numPlayers; p++) {
      for (int c = 0; c < kNumCategories; c++) {
        final v = int.tryParse(_controllers[p][c].text) ?? 0;
        ref.read(currentGameProvider.notifier).updateScore(p, c, v);
      }
    }

    final finalGame = ref.read(currentGameProvider);
    if (finalGame == null) return;
    ref.read(gamesProvider.notifier).saveGame(finalGame);
    ref.read(currentGameProvider.notifier).clear();

    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Game saved!'),
          backgroundColor: kHeaderGreen,
        ),
      );
      Navigator.of(context).popUntil((r) => r.isFirst);
    }
  }

  Future<void> _confirmLeave(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Leave game?'),
        content: const Text('Progress will be lost if you leave without saving.'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Stay')),
          TextButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: const Text('Leave', style: TextStyle(color: Colors.red))),
        ],
      ),
    );
    if (confirmed == true && context.mounted) {
      ref.read(currentGameProvider.notifier).clear();
      Navigator.pop(context);
    }
  }
}

class _ScoreField extends StatelessWidget {
  final TextEditingController controller;
  final bool dark;
  final ValueChanged<String> onChanged;

  const _ScoreField({
    required this.controller,
    required this.dark,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      keyboardType: TextInputType.number,
      textAlign: TextAlign.center,
      style: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: dark ? Colors.white : Colors.black87,
      ),
      decoration: InputDecoration(
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(6),
          borderSide: BorderSide(
            color: dark ? Colors.white24 : Colors.black12,
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(6),
          borderSide: BorderSide(
            color: dark ? Colors.white24 : Colors.black12,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(6),
          borderSide: const BorderSide(color: kHeaderGreen, width: 2),
        ),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 4, vertical: 6),
        filled: true,
        fillColor: dark ? Colors.white10 : Colors.white60,
      ),
      onChanged: onChanged,
      onTap: () {
        controller.selection = TextSelection(
          baseOffset: 0,
          extentOffset: controller.text.length,
        );
      },
    );
  }
}
