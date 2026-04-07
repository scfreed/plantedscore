import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/game.dart';

class GamesNotifier extends Notifier<List<Game>> {
  late Box<Game> _box;

  @override
  List<Game> build() {
    _box = Hive.box<Game>('games');
    final games = _box.values.toList();
    games.sort((a, b) => b.date.compareTo(a.date));
    return games;
  }

  void saveGame(Game game) {
    _box.put(game.id, game);
    final games = _box.values.toList();
    games.sort((a, b) => b.date.compareTo(a.date));
    state = games;
  }

  void deleteGame(String id) {
    _box.delete(id);
    final games = _box.values.toList();
    games.sort((a, b) => b.date.compareTo(a.date));
    state = games;
  }

  Game? getGame(String id) => _box.get(id);
}

final gamesProvider = NotifierProvider<GamesNotifier, List<Game>>(
  GamesNotifier.new,
);
