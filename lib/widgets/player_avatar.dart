import 'package:flutter/material.dart';
import '../models/player.dart';

class PlayerAvatar extends StatelessWidget {
  final Player player;
  final double radius;

  const PlayerAvatar({super.key, required this.player, this.radius = 20});

  @override
  Widget build(BuildContext context) {
    return CircleAvatar(
      radius: radius,
      backgroundColor: Color(player.colorValue),
      child: Text(
        player.name.isNotEmpty ? player.name[0].toUpperCase() : '?',
        style: TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
          fontSize: radius * 0.9,
        ),
      ),
    );
  }
}

class PlayerInitial extends StatelessWidget {
  final String name;
  final int colorIndex;
  final double radius;

  const PlayerInitial({
    super.key,
    required this.name,
    required this.colorIndex,
    this.radius = 20,
  });

  @override
  Widget build(BuildContext context) {
    final colorValue = kPlayerColorValues[colorIndex % kPlayerColorValues.length];
    return CircleAvatar(
      radius: radius,
      backgroundColor: Color(colorValue),
      child: Text(
        name.isNotEmpty ? name[0].toUpperCase() : '?',
        style: TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
          fontSize: radius * 0.9,
        ),
      ),
    );
  }
}
