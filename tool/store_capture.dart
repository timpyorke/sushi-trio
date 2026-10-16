// Emulator-only entry point for store photography. Uses the real product
// screens with an in-memory, progressed save; never opens the player's Hive.
// flutter run -t tool/store_capture.dart --dart-define=DETERMINISTIC_SEED=true
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../lib/core/piece.dart';
import '../lib/core/settings.dart';
import '../lib/game/piece_painter.dart';
import '../lib/gen/fonts.gen.dart';
import '../lib/main.dart' show SushiTrioApp;
import '../lib/services/event_config.dart';
import '../lib/services/restaurant.dart';
import '../lib/services/store.dart';
import '../lib/services/wallet.dart';
import '../lib/ui/game_screen.dart';
import '../lib/ui/level_select_screen.dart';
import '../lib/ui/restaurant_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  await SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
  await PiecePainter.loadSprites();
  final now = DateTime.now();
  final schedule = await AssetEventSource().load();
  final event = schedule.activeAt(now);
  final store = MemoryStore({
    'language': 'en',
    'sound_volume': 0.0,
    'music_volume': 0.0,
    'cleared_level': 205,
    'coins': 690,
    'daily_last': DateTime(now.year, now.month, now.day).toIso8601String(),
    'daily_day': 3,
    'tips_seen': [
      'conveyor',
      'ice',
      'deliver',
      'mat',
      'fire',
      'cat',
      'key',
      'bomb',
      'portal',
      'gravity',
      'bag'
    ],
    'restaurant_owned': [for (final f in Restaurant.furniture) f.id],
    'restaurant_shelf': ['salmon', 'maguro', 'tamago', 'ikura', 'kappa', 'ebi'],
    'restaurant_since': now.millisecondsSinceEpoch,
    'restaurant_banked': 84,
    for (var n = 1; n <= 205; n++) 'stars_$n': n % 4 == 0 ? 2 : 3,
    for (final kind in PieceKind.values) 'sushi_${kind.name}': 8,
    for (final booster in Booster.values) 'booster_${booster.name}': 3,
    if (event != null) ...{
      'event_id': event.id,
      'event_seen': event.id,
      'event_collected': 235,
      'event_claimed': <String>['0'],
    },
  });
  final container = ProviderContainer(overrides: [
    storeProvider.overrideWithValue(store),
    eventScheduleProvider.overrideWithValue(schedule),
  ]);
  container.read(settingsProvider);
  runApp(UncontrolledProviderScope(
    container: container,
    child: MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorSchemeSeed: const Color(0xFFB71C2C),
        useMaterial3: true,
        fontFamily: FontFamily.mali,
      ),
      home: const _CaptureMenu(),
    ),
  ));
}

class _CaptureMenu extends StatelessWidget {
  const _CaptureMenu();

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(title: const Text('Store capture · memory save')),
        body: ListView(children: [
          for (final entry in <String, Widget>{
            '01 · Match sushi (level 9)': const GameScreen(levelNumber: 9),
            '02 · Explore Japan': const LevelSelectScreen(),
            '03 · Your restaurant': const RestaurantScreen(),
            '04 · Fresh challenges (level 205)':
                const GameScreen(levelNumber: 205),
            '05 · Home / weekly event': const SushiTrioApp(showSplash: false),
          }.entries)
            ListTile(
              title: Text(entry.key),
              onTap: () => Navigator.of(context)
                  .push(MaterialPageRoute<void>(builder: (_) => entry.value)),
            ),
        ]),
      );
}
