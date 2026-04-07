import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/game.dart';
import '../models/score_categories.dart';

class CurrentGameNotifier extends Notifier<Game?> {
  @override
  Game? build() => null;

  void startGame(Game game) {
    state = game;
  }

  void updateScore(int playerIdx, int categoryIdx, int value) {
    final current = state;
    if (current == null) return;
    state = current.withScore(playerIdx, categoryIdx, value);
  }

  void clear() {
    state = null;
  }

  int getScore(int playerIdx, int categoryIdx) {
    final current = state;
    if (current == null) return 0;
    if (playerIdx >= current.scores.length) return 0;
    if (categoryIdx >= kNumCategories) return 0;
    return current.scores[playerIdx][categoryIdx];
  }

  int getTotal(int playerIdx) {
    return state?.totalForPlayer(playerIdx) ?? 0;
  }
}

final currentGameProvider = NotifierProvider<CurrentGameNotifier, Game?>(
  CurrentGameNotifier.new,
);
