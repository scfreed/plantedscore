import 'package:hive/hive.dart';
import 'score_categories.dart';

class Game {
  final String id;
  final String? name;
  final DateTime date;
  final String? notes;
  final List<String> playerNames;
  final List<int> playerColorIndexes;
  // scores[playerIndex][categoryIndex]
  final List<List<int>> scores;

  const Game({
    required this.id,
    this.name,
    required this.date,
    this.notes,
    required this.playerNames,
    required this.playerColorIndexes,
    required this.scores,
  });

  int totalForPlayer(int playerIndex) {
    if (playerIndex >= scores.length) return 0;
    return scores[playerIndex].fold(0, (sum, s) => sum + s);
  }

  int? winnerIndex() {
    if (playerNames.isEmpty) return null;
    int best = -1;
    int bestScore = -1;
    for (int i = 0; i < playerNames.length; i++) {
      final t = totalForPlayer(i);
      if (t > bestScore) {
        bestScore = t;
        best = i;
      }
    }
    return best;
  }

  String? winnerName() {
    final idx = winnerIndex();
    if (idx == null || idx < 0) return null;
    return playerNames[idx];
  }

  int get numPlayers => playerNames.length;

  static Game empty({
    required String id,
    required List<String> playerNames,
    required List<int> playerColorIndexes,
    String? name,
    DateTime? date,
    String? notes,
  }) {
    return Game(
      id: id,
      name: name,
      date: date ?? DateTime.now(),
      notes: notes,
      playerNames: playerNames,
      playerColorIndexes: playerColorIndexes,
      scores: List.generate(
        playerNames.length,
        (_) => List.filled(kNumCategories, 0),
      ),
    );
  }

  Game withScore(int playerIdx, int categoryIdx, int value) {
    final newScores = scores.map((row) => List<int>.from(row)).toList();
    newScores[playerIdx][categoryIdx] = value;
    return Game(
      id: id,
      name: name,
      date: date,
      notes: notes,
      playerNames: playerNames,
      playerColorIndexes: playerColorIndexes,
      scores: newScores,
    );
  }
}

class GameAdapter extends TypeAdapter<Game> {
  @override
  final int typeId = 1;

  @override
  Game read(BinaryReader reader) {
    final id = reader.readString();
    final hasName = reader.readBool();
    final name = hasName ? reader.readString() : null;
    final dateMs = reader.readInt();
    final hasNotes = reader.readBool();
    final notes = hasNotes ? reader.readString() : null;
    final playerNames = reader.readStringList();
    final playerColorIndexes = reader.readIntList();
    final numPlayers = reader.readInt();
    final scores = List.generate(numPlayers, (_) => reader.readIntList());
    return Game(
      id: id,
      name: name,
      date: DateTime.fromMillisecondsSinceEpoch(dateMs),
      notes: notes,
      playerNames: playerNames,
      playerColorIndexes: playerColorIndexes,
      scores: scores,
    );
  }

  @override
  void write(BinaryWriter writer, Game obj) {
    writer.writeString(obj.id);
    writer.writeBool(obj.name != null);
    if (obj.name != null) writer.writeString(obj.name!);
    writer.writeInt(obj.date.millisecondsSinceEpoch);
    writer.writeBool(obj.notes != null);
    if (obj.notes != null) writer.writeString(obj.notes!);
    writer.writeStringList(obj.playerNames);
    writer.writeIntList(obj.playerColorIndexes);
    writer.writeInt(obj.scores.length);
    for (final row in obj.scores) {
      writer.writeIntList(row);
    }
  }
}
