import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../models/player.dart';
import '../models/game.dart';
import '../providers/players_provider.dart';
import '../providers/current_game_provider.dart';
import '../widgets/player_avatar.dart';
import '../models/score_categories.dart';
import 'scoring_screen.dart';
import 'players_screen.dart';

const _uuid = Uuid();

class NewGameScreen extends ConsumerStatefulWidget {
  const NewGameScreen({super.key});

  @override
  ConsumerState<NewGameScreen> createState() => _NewGameScreenState();
}

class _NewGameScreenState extends ConsumerState<NewGameScreen> {
  final _nameCtrl = TextEditingController();
  final _notesCtrl = TextEditingController();
  final _selectedIds = <String>{};
  DateTime _date = DateTime.now();

  @override
  void dispose() {
    _nameCtrl.dispose();
    _notesCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final players = ref.watch(playersProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('New Game')),
      body: players.isEmpty
          ? _noPlayersView(context)
          : _buildForm(context, players),
    );
  }

  Widget _noPlayersView(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.people_outline, size: 72, color: Colors.grey),
          const SizedBox(height: 16),
          const Text('Add players first',
              style: TextStyle(fontSize: 18, color: Colors.grey)),
          const SizedBox(height: 24),
          FilledButton.icon(
            onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const PlayersScreen())),
            icon: const Icon(Icons.person_add),
            label: const Text('Go to Players'),
          ),
        ],
      ),
    );
  }

  Widget _buildForm(BuildContext context, List<Player> players) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Game details card
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Game Details',
                      style: TextStyle(
                          fontSize: 16, fontWeight: FontWeight.w700)),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _nameCtrl,
                    textCapitalization: TextCapitalization.sentences,
                    decoration: const InputDecoration(
                      labelText: 'Game name (optional)',
                      prefixIcon: Icon(Icons.sports_esports_outlined),
                    ),
                  ),
                  const SizedBox(height: 12),
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: const Icon(Icons.calendar_today_outlined),
                    title: Text(_formatDate(_date)),
                    subtitle: const Text('Date'),
                    onTap: _pickDate,
                    trailing: const Icon(Icons.chevron_right),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8)),
                    tileColor: Theme.of(context)
                        .colorScheme
                        .surfaceContainerHighest
                        .withValues(alpha: 0.3),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _notesCtrl,
                    maxLines: 2,
                    textCapitalization: TextCapitalization.sentences,
                    decoration: const InputDecoration(
                      labelText: 'Notes (optional)',
                      prefixIcon: Icon(Icons.notes_outlined),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),
          // Player selection
          Row(
            children: [
              const Text('Select Players',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
              const SizedBox(width: 8),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: kHeaderGreen,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '${_selectedIds.length}/5',
                  style: const TextStyle(color: Colors.white, fontSize: 12),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          const Text('Choose 2–5 players',
              style: TextStyle(color: Colors.grey, fontSize: 13)),
          const SizedBox(height: 12),
          ...players.map((p) => _PlayerSelectTile(
                player: p,
                selected: _selectedIds.contains(p.id),
                onToggle: () => _togglePlayer(p.id),
              )),
          const SizedBox(height: 32),
          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              onPressed: _canStart ? _startGame : null,
              icon: const Icon(Icons.play_arrow_rounded),
              label: const Text('Start Scoring',
                  style: TextStyle(fontSize: 16)),
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  bool get _canStart =>
      _selectedIds.length >= 2 && _selectedIds.length <= 5;

  void _togglePlayer(String id) {
    setState(() {
      if (_selectedIds.contains(id)) {
        _selectedIds.remove(id);
      } else if (_selectedIds.length < 5) {
        _selectedIds.add(id);
      }
    });
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _date,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );
    if (picked != null) setState(() => _date = picked);
  }

  String _formatDate(DateTime d) =>
      '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

  void _startGame() {
    final players = ref.read(playersProvider);
    final selectedPlayers = players
        .where((p) => _selectedIds.contains(p.id))
        .toList();

    final game = Game.empty(
      id: _uuid.v4(),
      playerNames: selectedPlayers.map((p) => p.name).toList(),
      playerColorIndexes:
          selectedPlayers.map((p) => p.colorIndex).toList(),
      name: _nameCtrl.text.trim().isEmpty ? null : _nameCtrl.text.trim(),
      date: _date,
      notes: _notesCtrl.text.trim().isEmpty ? null : _notesCtrl.text.trim(),
    );

    ref.read(currentGameProvider.notifier).startGame(game);

    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const ScoringScreen()),
    );
  }
}

class _PlayerSelectTile extends StatelessWidget {
  final Player player;
  final bool selected;
  final VoidCallback onToggle;

  const _PlayerSelectTile({
    required this.player,
    required this.selected,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      color: selected
          ? Color(player.colorValue).withValues(alpha: 0.12)
          : null,
      child: ListTile(
        leading: PlayerAvatar(player: player, radius: 20),
        title: Text(player.name,
            style: const TextStyle(fontWeight: FontWeight.w600)),
        trailing: Checkbox(
          value: selected,
          onChanged: (_) => onToggle(),
          activeColor: Color(player.colorValue),
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(4)),
        ),
        onTap: onToggle,
      ),
    );
  }
}
