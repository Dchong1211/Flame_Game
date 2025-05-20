import 'package:flame/components.dart';
import 'package:flame/palette.dart';
import 'package:flutter/cupertino.dart';

import '../knight.dart';

class CoinCounter extends PositionComponent with HasGameReference<Knight> {
  late final SpriteComponent coinIcon;
  late final TextComponent coinText;

  @override
  Future<void> onLoad() async {
    anchor = Anchor.topLeft;
    position = Vector2(50, 60);

    final sprite = Sprite(game.images.fromCache('Items/CoinCount.png'));
    coinIcon = SpriteComponent(
      sprite: sprite,
      size: Vector2(32, 32),
    );

    coinText = TextComponent(
      text: '${game.coinCount}',
      position: Vector2(40, 3),
      textRenderer: TextPaint(
        style: TextStyle(
          color: BasicPalette.white.color,
          fontSize: 23,
          fontWeight: FontWeight.bold,
        ),
      ),
    );

    addAll([coinIcon, coinText]);
  }

  @override
  void update(double dt) {
    coinText.text = '${game.coinCount}';
    super.update(dt);
  }
}
