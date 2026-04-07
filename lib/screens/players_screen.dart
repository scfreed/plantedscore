import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/player.dart';
import '../providers/players_provider.dart';
import '../widgets/player_avatar.dart';
import '../models/score_categories.dart';

class PlayersScreen extends ConsumerWidget {
  const PlayersScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final players = ref.watch(playersProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Players')),
      body: players.isEmpty
          ? _emptyState(context)
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: players.length,
              itemBuilder: (context, i) =>
                  _PlayerTile(player: players[i]),
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showPlayerDialog(context, ref, null),
        backgroundColor: kHeaderGreen,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.person_add),
        label: const Text('Add Player'),
      ),
    );
  }

  Widget _emptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.people_outline,
              size: 72, color: Colors.grey.withValues(alpha: 0.4)),
          const SizedBox(height: 16),
          const Text('No players yet',
              style: TextStyle(fontSize: 18, color: Colors.grey)),
          const SizedBox(height: 8),
          const Text('Add players to get started',
              style: TextStyle(color: Colors.grey)),
        ],
      ),
    );
  }
}

class _PlayerTile extends ConsumerWidget {
  final Player player;
  const _PlayerTile({required this.player});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: PlayerAvatar(player: player, radius: 22),
        title: Text(player.name,
            style: const TextStyle(fontWeight: FontWeight.w600)),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.edit_outlined),
              onPressed: () => _showPlayerDialog(context, ref, player),
            ),
            IconButton(
              icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
              onPressed: () => _confirmDelete(context, ref, player),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _confirmDelete(
      BuildContext context, WidgetRef ref, Player player) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Player'),
        content: Text('Remove ${player.name}?'),
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
      ref.read(playersProvider.notifier).deletePlayer(player.id);
    }
  }
}

Future<void> _showPlayerDialog(
    BuildContext context, WidgetRef ref, Player? existing) async {
  final nameCtrl = TextEditingController(text: existing?.name ?? '');
  int selectedColor = existing?.colorIndex ?? 0;

  await showDialog(
    context: context,
    builder: (ctx) => StatefulBuilder(
      builder: (ctx, setState) => AlertDialog(
        title: Text(existing == null ? 'Add Player' : 'Edit Player'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameCtrl,
              autofocus: true,
              textCapitalization: TextCapitalization.words,
              decoration: const InputDecoration(
                labelText: 'Player name',
                prefixIcon: Icon(Icons.person),
              ),
            ),
            const SizedBox(height: 20),
            const Text('Color', style: TextStyle(fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(kPlayerColorValues.length, (i) {
                return GestureDetector(
                  onTap: () => setState(() => selectedColor = i),
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 6),
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: Color(kPlayerColorValues[i]),
                      shape: BoxShape.circle,
                      border: selectedColor == i
                          ? Border.all(color: Colors.black, width: 3)
                          : null,
                    ),
                    child: selectedColor == i
                        ? const Icon(Icons.check,
                            color: Colors.white, size: 20)
                        : null,
                  ),
                );
              }),
            ),
          ],
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancel')),
          FilledButton(
            onPressed: () {
              final name = nameCtrl.text.trim();
              if (name.isEmpty) return;
              if (existing == null) {
                ref
                    .read(playersProvider.notifier)
                    .addPlayer(name, selectedColor);
              } else {
                ref
                    .read(playersProvider.notifier)
                    .updatePlayer(existing.id, name, selectedColor);
              }
              Navigator.pop(ctx);
            },
            child: Text(existing == null ? 'Add' : 'Save'),
          ),
        ],
      ),
    ),
  );
}
