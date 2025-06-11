import 'dart:async';
import 'package:final_project/knight.dart';
import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flame/text.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../Player/player.dart';

class WhiteBackgroundTextBox extends TextBoxComponent {
  WhiteBackgroundTextBox({
    required super.text,
    required super.textRenderer,
    required super.boxConfig,
    required super.position,
    super.anchor = Anchor.topLeft,
  });

  @override
  void render(Canvas canvas) {
    final backgroundPaint = Paint()..color = const Color(0xFFFFFFFF);

    final rrect = RRect.fromRectAndRadius(
      size.toRect(),
      const Radius.circular(8),
    );

    canvas.drawRRect(rrect, backgroundPaint);
    super.render(canvas);
  }

}

class Wizard extends SpriteAnimationComponent
    with HasGameReference<Knight>, CollisionCallbacks {
  late final TextBoxComponent dialogBox;
  bool dialogShown = false;

  Wizard({
    super.position,
    super.size,
  });

  @override
  FutureOr<void> onLoad() async {
    await super.onLoad();
    // debugMode = true;
    add(RectangleHitbox(
      position: Vector2(-16, 0),
      size: Vector2(64, 32),
      collisionType: CollisionType.passive,
    ));

    animation = SpriteAnimation.fromFrameData(
      game.images.fromCache('Character/Wizard.png'),
      SpriteAnimationData.sequenced(
        amount: 9,
        stepTime: 0.08,
        textureSize: Vector2.all(64),
      ),
    );

    dialogBox = WhiteBackgroundTextBox(
      text: 'Cảm ơn bạn',
      textRenderer: TextPaint(
        style: GoogleFonts.vt323(
          textStyle: const TextStyle(
            fontSize: 10,
            color: Colors.black,
          ),
        ),
      ),
      boxConfig: TextBoxConfig(
        timePerChar: 0.05,
        dismissDelay: 2.0,
        maxWidth: 100,
        growingBox: true,
      ),
      position: Vector2(0, 0),
    )..anchor = Anchor.bottomCenter;
  }

  @override
  void onCollisionStart(Set<Vector2> intersectionPoints, PositionComponent other) {
    super.onCollisionStart(intersectionPoints, other);
    if (!dialogShown && other is Player) {
      dialogShown = true;
      add(dialogBox);
    }
  }
}
