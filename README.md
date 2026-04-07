# PlantedScore

A digital scoresheet for the [Planted](https://boardgamegeek.com/boardgame/375568/planted-a-game-of-nature-nurture) board game, built with Flutter.

Track scores across all 8 categories, view game history, and see player statistics — all stored locally on your device.

---

## Features

- **Scoring screen** — Color-coded table matching the physical scoresheet, with live running totals as you type
- **8 score categories** — Plant 1–6, Propagation, and Decorations
- **2–5 players** per game, each with a color-coded avatar
- **Game history** — Browse and review all past games
- **Statistics** — Overall stats (games played, average score, high score), player leaderboard (wins, win %, average and best score), and per-category averages
- **Player management** — Create reusable player profiles to quickly start new games
- **Dark mode** — Full light/dark theme support
- **Offline & private** — All data stored locally using Hive; no account or internet required

---

## Screenshots

> _Coming soon_

---

## Getting Started

### Prerequisites

- [Flutter SDK](https://docs.flutter.dev/get-started/install) ≥ 3.11
- Dart SDK ≥ 3.11 (bundled with Flutter)

### Run locally

```bash
git clone https://github.com/scfreed/plantedscore.git
cd plantedscore
flutter pub get
flutter run
```

Supported targets: Android, iOS, Web, Windows, macOS, Linux.

---

## Project Structure

```
lib/
├── main.dart                        # App entry point, Hive init, theme setup
├── models/
│   ├── game.dart                    # Game data model + Hive adapter
│   ├── player.dart                  # Player data model + Hive adapter
│   └── score_categories.dart        # Category labels, keys, and row colors
├── providers/
│   ├── current_game_provider.dart   # In-progress game state (Riverpod)
│   ├── games_provider.dart          # Saved games list (Riverpod + Hive)
│   └── players_provider.dart        # Player roster (Riverpod + Hive)
├── screens/
│   ├── home_screen.dart             # Dashboard + bottom nav host
│   ├── new_game_screen.dart         # Game setup (player selection, date, notes)
│   ├── scoring_screen.dart          # Live scoring table
│   ├── game_detail_screen.dart      # Read-only view of a saved game
│   ├── history_screen.dart          # List of past games
│   ├── stats_screen.dart            # Aggregate statistics
│   └── players_screen.dart          # Player profile management
├── theme/
│   └── app_theme.dart               # Light/dark MaterialTheme config
└── widgets/
    ├── planted_header.dart          # Branded app bar widget
    ├── player_avatar.dart           # Color-coded circular avatar
    └── scoresheet_table.dart        # Reusable score grid widget
```

---

## Scoring Categories

| Category | Color | Description |
|---|---|---|
| Plant 1–6 | Green | Points from each plant card played |
| Propagation | Yellow | Bonus points from propagation actions |
| Decorations | Lavender | Points from decoration tiles |
| **Total** | Peach | Sum of all categories |

---

## Tech Stack

| | |
|---|---|
| Framework | [Flutter](https://flutter.dev) |
| State management | [Riverpod](https://riverpod.dev) |
| Local storage | [Hive](https://docs.hivedb.dev) |
| Unique IDs | [uuid](https://pub.dev/packages/uuid) |
| Date formatting | [intl](https://pub.dev/packages/intl) |

---

## Building

**Android APK**
```bash
flutter build apk --release
```

**iOS**
```bash
flutter build ios --release
```

**Web**
```bash
flutter build web --release
```

**Windows**
```bash
flutter build windows --release
```

---

## License

MIT
