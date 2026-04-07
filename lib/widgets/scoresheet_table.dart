import 'package:flutter/material.dart';
import '../models/game.dart';
import '../models/player.dart';
import '../models/score_categories.dart';

/// Read-only scoresheet used in game detail / history view.
class ScoresheetTable extends StatelessWidget {
  final Game game;

  const ScoresheetTable({super.key, required this.game});

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    return _ScoreTableLayout(
      playerNames: game.playerNames,
      playerColorIndexes: game.playerColorIndexes,
      numPlayers: game.numPlayers,
      getScore: (p, c) => game.scores[p][c],
      getTotal: game.totalForPlayer,
      readOnly: true,
      dark: dark,
    );
  }
}

/// Editable scoresheet used during live scoring.
class EditableScoresheetTable extends StatefulWidget {
  final List<String> playerNames;
  final List<int> playerColorIndexes;
  final List<List<int>> scores;
  final void Function(int playerIdx, int categoryIdx, int value) onScoreChanged;

  const EditableScoresheetTable({
    super.key,
    required this.playerNames,
    required this.playerColorIndexes,
    required this.scores,
    required this.onScoreChanged,
  });

  @override
  State<EditableScoresheetTable> createState() =>
      _EditableScoresheetTableState();
}

class _EditableScoresheetTableState extends State<EditableScoresheetTable> {
  // Controllers indexed [playerIdx][categoryIdx]
  late List<List<TextEditingController>> _controllers;
  late List<List<FocusNode>> _focusNodes;

  @override
  void initState() {
    super.initState();
    _buildControllers();
  }

  void _buildControllers() {
    _controllers = List.generate(
      widget.playerNames.length,
      (p) => List.generate(
        kNumCategories,
        (c) {
          final val = widget.scores[p][c];
          return TextEditingController(text: val == 0 ? '' : val.toString());
        },
      ),
    );
    _focusNodes = List.generate(
      widget.playerNames.length,
      (_) => List.generate(kNumCategories, (_) => FocusNode()),
    );
  }

  @override
  void didUpdateWidget(EditableScoresheetTable oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.playerNames.length != widget.playerNames.length) {
      _disposeControllers();
      _buildControllers();
    }
  }

  void _disposeControllers() {
    for (final row in _controllers) {
      for (final c in row) {
        c.dispose();
      }
    }
    for (final row in _focusNodes) {
      for (final f in row) {
        f.dispose();
      }
    }
  }

  @override
  void dispose() {
    _disposeControllers();
    super.dispose();
  }

  int _getTotal(int playerIdx) =>
      widget.scores[playerIdx].fold(0, (s, v) => s + v);

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    return _ScoreTableLayout(
      playerNames: widget.playerNames,
      playerColorIndexes: widget.playerColorIndexes,
      numPlayers: widget.playerNames.length,
      getScore: (p, c) => widget.scores[p][c],
      getTotal: _getTotal,
      readOnly: false,
      dark: dark,
      controllers: _controllers,
      focusNodes: _focusNodes,
      onScoreChanged: widget.onScoreChanged,
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Core layout widget (shared by read-only and editable)
// ─────────────────────────────────────────────────────────────────────────────

class _ScoreTableLayout extends StatelessWidget {
  final List<String> playerNames;
  final List<int> playerColorIndexes;
  final int numPlayers;
  final int Function(int playerIdx, int categoryIdx) getScore;
  final int Function(int playerIdx) getTotal;
  final bool readOnly;
  final bool dark;
  final List<List<TextEditingController>>? controllers;
  final List<List<FocusNode>>? focusNodes;
  final void Function(int playerIdx, int categoryIdx, int value)?
      onScoreChanged;

  const _ScoreTableLayout({
    required this.playerNames,
    required this.playerColorIndexes,
    required this.numPlayers,
    required this.getScore,
    required this.getTotal,
    required this.readOnly,
    required this.dark,
    this.controllers,
    this.focusNodes,
    this.onScoreChanged,
  });

  static const double _labelW = 110.0;
  static const double _cellW = 68.0;
  static const double _rowH = 46.0;
  static const double _headerH = 44.0;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(
            color: dark ? Colors.white12 : Colors.black12,
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildPlayerHeaderRow(context),
            ...List.generate(kNumCategories, (c) => _buildCategoryRow(context, c)),
            _buildTotalRow(context),
          ],
        ),
      ),
    );
  }

  Widget _buildPlayerHeaderRow(BuildContext context) {
    final bg = dark ? kPlayerHeaderBgDark : kPlayerHeaderBg;
    return SizedBox(
      height: _headerH,
      child: Row(
        children: [
          // "Player" label cell
          _LabelCell(
            width: _labelW,
            height: _headerH,
            color: bg,
            child: Text(
              'Player',
              style: TextStyle(
                fontStyle: FontStyle.italic,
                fontWeight: FontWeight.w700,
                fontSize: 13,
                color: dark ? Colors.white70 : Colors.black54,
              ),
            ),
          ),
          // Player name cells
          ...List.generate(numPlayers, (p) {
            final colorVal = kPlayerColorValues[
                playerColorIndexes[p] % kPlayerColorValues.length];
            return _PlayerHeaderCell(
              width: _cellW,
              height: _headerH,
              name: playerNames[p],
              colorValue: colorVal,
              bg: bg,
              dark: dark,
            );
          }),
        ],
      ),
    );
  }

  Widget _buildCategoryRow(BuildContext context, int categoryIdx) {
    final bg = rowColorForCategory(categoryIdx, dark: dark);
    return SizedBox(
      height: _rowH,
      child: Row(
        children: [
          _LabelCell(
            width: _labelW,
            height: _rowH,
            color: bg,
            child: Text(
              kCategoryLabels[categoryIdx],
              style: const TextStyle(
                fontStyle: FontStyle.italic,
                fontWeight: FontWeight.w600,
                fontSize: 13,
              ),
            ),
          ),
          ...List.generate(numPlayers, (p) {
            if (readOnly) {
              return _ReadOnlyCell(
                width: _cellW,
                height: _rowH,
                color: bg,
                value: getScore(p, categoryIdx),
                dark: dark,
              );
            } else {
              return _EditableCell(
                width: _cellW,
                height: _rowH,
                color: bg,
                controller: controllers![p][categoryIdx],
                focusNode: focusNodes![p][categoryIdx],
                dark: dark,
                onChanged: (v) {
                  final parsed = int.tryParse(v) ?? 0;
                  onScoreChanged!(p, categoryIdx, parsed);
                },
              );
            }
          }),
        ],
      ),
    );
  }

  Widget _buildTotalRow(BuildContext context) {
    final bg = dark ? const Color(0xFF3A2820) : kTotalPeach;
    return SizedBox(
      height: _rowH,
      child: Row(
        children: [
          _LabelCell(
            width: _labelW,
            height: _rowH,
            color: bg,
            child: const Text(
              'Total',
              style: TextStyle(
                fontStyle: FontStyle.italic,
                fontWeight: FontWeight.w800,
                fontSize: 14,
              ),
            ),
          ),
          ...List.generate(numPlayers, (p) {
            return _ReadOnlyCell(
              width: _cellW,
              height: _rowH,
              color: bg,
              value: getTotal(p),
              dark: dark,
              bold: true,
            );
          }),
        ],
      ),
    );
  }
}

// ─── Sub-widgets ──────────────────────────────────────────────────────────────

class _LabelCell extends StatelessWidget {
  final double width;
  final double height;
  final Color color;
  final Widget child;

  const _LabelCell({
    required this.width,
    required this.height,
    required this.color,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
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
}

class _PlayerHeaderCell extends StatelessWidget {
  final double width;
  final double height;
  final String name;
  final int colorValue;
  final Color bg;
  final bool dark;

  const _PlayerHeaderCell({
    required this.width,
    required this.height,
    required this.name,
    required this.colorValue,
    required this.bg,
    required this.dark,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        height: height,
        decoration: BoxDecoration(
          color: bg,
          border: const Border(
            right: BorderSide(color: Colors.black12),
            bottom: BorderSide(color: Colors.black12),
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircleAvatar(
              radius: 10,
              backgroundColor: Color(colorValue),
              child: Text(
                name.isNotEmpty ? name[0].toUpperCase() : '?',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 2),
            Text(
              name,
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
  }
}

class _ReadOnlyCell extends StatelessWidget {
  final double width;
  final double height;
  final Color color;
  final int value;
  final bool dark;
  final bool bold;

  const _ReadOnlyCell({
    required this.width,
    required this.height,
    required this.color,
    required this.value,
    required this.dark,
    this.bold = false,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        height: height,
        decoration: BoxDecoration(
          color: color,
          border: const Border(
            right: BorderSide(color: Colors.black12),
            bottom: BorderSide(color: Colors.black12),
          ),
        ),
        alignment: Alignment.center,
        child: value == 0
            ? const SizedBox.shrink()
            : Text(
                '$value',
                style: TextStyle(
                  fontSize: bold ? 15 : 14,
                  fontWeight: bold ? FontWeight.w800 : FontWeight.w500,
                  color: dark ? Colors.white : Colors.black87,
                ),
              ),
      ),
    );
  }
}

class _EditableCell extends StatelessWidget {
  final double width;
  final double height;
  final Color color;
  final TextEditingController controller;
  final FocusNode focusNode;
  final bool dark;
  final ValueChanged<String> onChanged;

  const _EditableCell({
    required this.width,
    required this.height,
    required this.color,
    required this.controller,
    required this.focusNode,
    required this.dark,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        height: height,
        decoration: BoxDecoration(
          color: color,
          border: const Border(
            right: BorderSide(color: Colors.black12),
            bottom: BorderSide(color: Colors.black12),
          ),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
        child: TextField(
          controller: controller,
          focusNode: focusNode,
          keyboardType: TextInputType.number,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            color: dark ? Colors.white : Colors.black87,
          ),
          decoration: InputDecoration(
            border: InputBorder.none,
            contentPadding: EdgeInsets.zero,
            filled: true,
            fillColor: focusNode.hasFocus
                ? (dark ? Colors.white12 : Colors.white54)
                : Colors.transparent,
          ),
          onChanged: onChanged,
          onTap: () {
            controller.selection = TextSelection(
              baseOffset: 0,
              extentOffset: controller.text.length,
            );
          },
        ),
      ),
    );
  }
}
