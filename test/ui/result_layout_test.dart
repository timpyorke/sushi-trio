import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sushi_trio/core/game_engine.dart';
import 'package:sushi_trio/game/sushi_game.dart';
import 'package:sushi_trio/services/wallet.dart';
import 'package:sushi_trio/ui/hud.dart';
import 'package:sushi_trio/ui/l10n.dart';
import 'package:sushi_trio/ui/result_overlay.dart';

import '../core/helpers.dart';
import '../helpers/riverpod.dart';

void main() {
  for (final language in ['en', 'th']) {
    for (final won in [true, false]) {
      testWidgets(
          '$language result keeps actions usable in a short board area '
          'when ${won ? 'won' : 'lost'}', (tester) async {
        tester.view.physicalSize = const Size(320, 640);
        tester.view.devicePixelRatio = 1;
        addTearDown(tester.view.reset);
        final container = testContainer();
        L10n.language = language;
        addTearDown(() => L10n.language = 'en');
        final game = SushiGame(
            level: testLevel(),
            wallet: container.read(walletProvider.notifier));
        game.hud.value = HudState(
            movesLeft: 0,
            score: 14720,
            goals: game.hud.value.goals,
            status: won ? GameStatus.won : GameStatus.lost,
            stars: 2,
            reward: won ? 20 : 0,
            eventGain: 61);
        var next = 0;
        var levels = 0;
        await tester.pumpWidget(scope(
          container,
          MaterialApp(
            home: Scaffold(
                body: MediaQuery(
              data: const MediaQueryData(textScaler: TextScaler.linear(1.6)),
              child: Align(
                child: SizedBox(
                  width: 320,
                  height: 400,
                  child: ResultOverlay(
                    game: game,
                    onNext: () => next++,
                    onLevels: () => levels++,
                  ),
                ),
              ),
            )),
          ),
        ));
        await tester.pump();
        expect(tester.takeException(), isNull);
        expect(find.textContaining('restaurant'), findsNothing);
        if (won) {
          await tester.tap(find.text(L10n.t('nextLevel')));
          expect(next, 1);
        }
        await tester.tap(find.text(L10n.t('levelSelect')));
        expect(levels, 1);
        // Longer result content remains accessible without moving the actions.
        await tester.ensureVisible(find.text(L10n.t('eventGain', {'n': 61})));
        await tester.pump();
        final eventRect =
            tester.getRect(find.text(L10n.t('eventGain', {'n': 61})));
        final viewport = tester.getRect(find.byType(SingleChildScrollView));
        expect(viewport.contains(eventRect.center), isTrue);
        expect(find.text(L10n.t('levelSelect')).hitTestable(), findsOneWidget);
        expect(tester.takeException(), isNull);
      });
    }
    testWidgets('$language HUD fits a large score without growing taller',
        (tester) async {
      final container = testContainer();
      L10n.language = language;
      addTearDown(() => L10n.language = 'en');
      final game = SushiGame(
          level: testLevel(), wallet: container.read(walletProvider.notifier));
      game.hud.value = HudState(
          movesLeft: 123,
          score: 99999999,
          goals: game.hud.value.goals,
          status: GameStatus.playing,
          stars: 3);
      await tester.pumpWidget(MaterialApp(
        home: MediaQuery(
          data: const MediaQueryData(textScaler: TextScaler.linear(1.6)),
          child: Center(child: SizedBox(width: 184, child: HudBar(game: game))),
        ),
      ));
      expect(tester.getSize(find.byType(HudBar)).height, 68);
      expect(find.text('${L10n.t('score')} 99999999'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  }
}
