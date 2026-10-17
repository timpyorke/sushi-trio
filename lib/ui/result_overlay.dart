import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/game_engine.dart';
import '../game/sushi_game.dart';
import '../services/wallet.dart';
import 'customer_order.dart';
import 'game_dialog.dart';
import 'l10n.dart';
import 'lives_ui.dart';
import 'ui_art.dart';

class ResultOverlay extends ConsumerWidget {
  const ResultOverlay(
      {super.key, required this.game, this.onNext, required this.onLevels});
  final SushiGame game;

  /// Null when there is no next level.
  final VoidCallback? onNext;
  final VoidCallback onLevels;

  /// Replaying costs a life only when the last run was lost, but starting
  /// any run needs one in the bank.
  Future<void> _again(BuildContext context, WidgetRef ref) async {
    if (await ensureLife(context, ref)) game.restart();
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final wallet = ref.watch(walletProvider);
    return ValueListenableBuilder<HudState>(
      valueListenable: game.hud,
      builder: (context, s, _) {
        if (s.status == GameStatus.playing) return const SizedBox.shrink();
        final won = s.status == GameStatus.won;
        final customer = Customer.forLevel(game.level.id);
        return ColoredBox(
          color: Colors.black38,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: Center(
              child: Container(
                width: 360,
                padding:
                    const EdgeInsets.symmetric(horizontal: 36, vertical: 32),
                decoration: UiArt.panelDecoration(),
                child: DefaultTextStyle.merge(
                  style: const TextStyle(color: UiArt.ink),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Keep actions visible when the board area is short or
                      // accessibility text makes the result taller.
                      Flexible(
                        child: SingleChildScrollView(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              OutlinedTitle(L10n.t(won ? 'win' : 'lose'),
                                  style: Theme.of(context)
                                      .textTheme
                                      .headlineSmall),
                              if (won) ...[
                                const SizedBox(height: 6),
                                Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    for (var i = 0; i < 3; i++)
                                      Padding(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 2),
                                        child: StarIcon(
                                            size: 36, lit: i < s.stars),
                                      ),
                                  ],
                                ),
                              ],
                              const SizedBox(height: 6),
                              CustomerSprite(
                                customer: customer,
                                anim:
                                    won ? CustomerAnim.happy : CustomerAnim.sad,
                                intro: won &&
                                        customer.signature?.cue ==
                                            SignatureCue.served
                                    ? CustomerAnim.signature
                                    : null,
                                introLoops: 1,
                                size: 88,
                              ),
                              Text(
                                L10n.t(won ? 'custWin' : 'custLose',
                                    {'name': customer.name}),
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 10),
                              Text(L10n.t('scoreN', {'n': s.score}),
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold)),
                              if (won && s.reward > 0)
                                Text(L10n.t('reward', {'n': s.reward}),
                                    textAlign: TextAlign.center),
                              if (s.eventGain > 0)
                                Text(L10n.t('eventGain', {'n': s.eventGain}),
                                    textAlign: TextAlign.center),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      if (!won) ...[
                        GameDialogButton(
                          primary: true,
                          onPressed: wallet.canUse(Booster.extraMoves)
                              ? game.buyExtraMoves
                              : null,
                          label: L10n.t('extraMoves', {
                            'm': Wallet.extraMovesAmount,
                            'n': wallet.count(Booster.extraMoves) > 0
                                ? 0
                                : Wallet.cost[Booster.extraMoves]!,
                          }),
                        ),
                        const SizedBox(height: 8),
                      ],
                      if (won && onNext != null) ...[
                        GameDialogButton(
                            primary: true,
                            onPressed: onNext,
                            label: L10n.t('nextLevel')),
                        const SizedBox(height: 8),
                      ],
                      GameDialogButton(
                          primary: !won || onNext == null,
                          onPressed: () => _again(context, ref),
                          label: L10n.t(won ? 'playAgain' : 'retry')),
                      const SizedBox(height: 8),
                      GameDialogButton(
                          onPressed: onLevels, label: L10n.t('levelSelect')),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
