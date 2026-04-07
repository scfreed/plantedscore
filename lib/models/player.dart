import 'package:hive/hive.dart';

const List<int> kPlayerColorValues = [
  0xFF4CAF50, // green
  0xFF2196F3, // blue
  0xFFF44336, // red
  0xFFFF9800, // orange
  0xFF9C27B0, // purple
];

class Player {
  final String id;
  final String name;
  final int colorIndex;

  const Player({
    required this.id,
    required this.name,
    required this.colorIndex,
  });

  Player copyWith({String? name, int? colorIndex}) => Player(
        id: id,
        name: name ?? this.name,
        colorIndex: colorIndex ?? this.colorIndex,
      );

  int get colorValue => kPlayerColorValues[colorIndex % kPlayerColorValues.length];
}

class PlayerAdapter extends TypeAdapter<Player> {
  @override
  final int typeId = 0;

  @override
  Player read(BinaryReader reader) {
    return Player(
      id: reader.readString(),
      name: reader.readString(),
      colorIndex: reader.readInt(),
    );
  }

  @override
  void write(BinaryWriter writer, Player obj) {
    writer.writeString(obj.id);
    writer.writeString(obj.name);
    writer.writeInt(obj.colorIndex);
  }
}
