import 'package:flutter/material.dart';

import '../game/sushi_game.dart';
import 'l10n.dart';
import 'ui_art.dart';

/// Moves left plus the score as a bar that fills toward the third star, with
/// each star sitting at the score that earns it.
class HudBar extends StatelessWidget {
  const HudBar({super.key, required this.game});
  final SushiGame game;

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<HudState>(
      valueListenable: game.hud,
      builder: (context, s, _) => SizedBox(
        height: 68,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SizedBox(
                width: 68,
                child: _Chip(label: L10n.t('moves'), value: '${s.movesLeft}')),
            const SizedBox(width: 6),
            Expanded(
                child:
                    _ScoreStars(score: s.score, thresholds: game.level.stars)),
          ],
        ),
      ),
    );
  }
}

class _ScoreStars extends StatelessWidget {
  const _ScoreStars({required this.score, required this.thresholds});
  final int score;
  final List<int> thresholds;

  static const _star = 22.0;

  /// Stars sit at evenly spaced slots, so the bar is piecewise linear between
  /// the score thresholds instead of proportional to the raw score.
  static double _fillFor(int score, List<int> th) {
    if (th.isEmpty) return 0;
    var lo = 0;
    for (var i = 0; i < th.length; i++) {
      if (score < th[i]) {
        final span = th[i] - lo;
        final part = span <= 0 ? 0.0 : (score - lo) / span;
        return (i + part) / th.length;
      }
      lo = th[i];
    }
    return 1;
  }

  @override
  Widget build(BuildContext context) {
    final fill = _fillFor(score, thresholds);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: UiArt.plankDecoration(),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Flexible(
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: Text('${L10n.t('score')} $score',
                  maxLines: 1,
                  style: const TextStyle(
                      fontSize: 20,
                      height: 1.1,
                      fontWeight: FontWeight.bold,
                      color: UiArt.ink)),
            ),
          ),
          const SizedBox(height: 2),
          LayoutBuilder(builder: (context, box) {
            final w = box.maxWidth - _star;
            return SizedBox(
              height: _star,
              child: Stack(
                alignment: Alignment.centerLeft,
                children: [
                  Positioned(
                    left: _star / 2,
                    right: _star / 2,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(6),
                      child: LinearProgressIndicator(
                        value: fill,
                        minHeight: 7,
                        backgroundColor: Colors.black26,
                        color: const Color(0xFFFFB300),
                      ),
                    ),
                  ),
                  for (var i = 0; i < thresholds.length; i++)
                    Positioned(
                      left: w * (i + 1) / thresholds.length,
                      child: StarIcon(size: _star, lit: score >= thresholds[i]),
                    ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }
}

class _Chip extends StatelessWidget {
  const _Chip({required this.label, required this.value});
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 8),
      decoration: UiArt.plankDecoration(),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Flexible(
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(label,
                  maxLines: 1,
                  style: const TextStyle(fontSize: 11, color: UiArt.ink)),
            ),
          ),
          Flexible(
            flex: 2,
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(value,
                  maxLines: 1,
                  style: const TextStyle(
                      fontSize: 24,
                      height: 1.1,
                      fontWeight: FontWeight.bold,
                      color: UiArt.ink)),
            ),
          ),
        ],
      ),
    );
  }
}

/// Chef's cheer that pops in over the board after a combo and fades out.
class PraiseBanner extends StatelessWidget {
  const PraiseBanner({super.key, required this.game});
  final SushiGame game;

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: ValueListenableBuilder<({String text, int n})?>(
        valueListenable: game.praise,
        builder: (context, p, _) {
          if (p == null) return const SizedBox.shrink();
          return Center(
            child: TweenAnimationBuilder<double>(
              key: ValueKey(p.n),
              tween: Tween(begin: 0, end: 1),
              duration: const Duration(milliseconds: 1100),
              builder: (context, t, child) => Opacity(
                opacity: t < 0.7 ? 1 : (1 - t) / 0.3,
                child: Transform.scale(
                  scale: 0.6 +
                      0.6 * Curves.easeOutBack.transform((t * 3).clamp(0, 1)),
                  child: child,
                ),
              ),
              child: Text(
                p.text,
                style: Theme.of(context).textTheme.displaySmall?.copyWith(
                  fontWeight: FontWeight.w900,
                  color: Colors.white,
                  shadows: const [
                    Shadow(color: UiArt.ink, blurRadius: 6),
                    Shadow(color: UiArt.ink, offset: Offset(2, 2)),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
