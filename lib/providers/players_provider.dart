import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:uuid/uuid.dart';
import '../models/player.dart';

const _uuid = Uuid();

class PlayersNotifier extends Notifier<List<Player>> {
  late Box<Player> _box;

  @override
  List<Player> build() {
    _box = Hive.box<Player>('players');
    return _box.values.toList();
  }

  void addPlayer(String name, int colorIndex) {
    final player = Player(
      id: _uuid.v4(),
      name: name,
      colorIndex: colorIndex,
    );
    _box.put(player.id, player);
    state = _box.values.toList();
  }

  void updatePlayer(String id, String name, int colorIndex) {
    final existing = _box.get(id);
    if (existing == null) return;
    final updated = existing.copyWith(name: name, colorIndex: colorIndex);
    _box.put(id, updated);
    state = _box.values.toList();
  }

  void deletePlayer(String id) {
    _box.delete(id);
    state = _box.values.toList();
  }
}

final playersProvider = NotifierProvider<PlayersNotifier, List<Player>>(
  PlayersNotifier.new,
);
