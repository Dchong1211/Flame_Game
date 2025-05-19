import 'package:flame/components.dart';
import 'package:flame/palette.dart';
import 'package:flutter/painting.dart';

class HealthBar extends PositionComponent {
  final int maxHealth;
  int currentHealth;

  HealthBar({
    required this.maxHealth,
    required this.currentHealth,
    required Vector2 size,
  }) : super(size: size);

  @override
  void render(Canvas canvas) {
    final paintBg = BasicPalette.black.paint()..style = PaintingStyle.fill;
    final paintFg = BasicPalette.red.paint()..style = PaintingStyle.fill;

    // Draw background
    canvas.drawRect(size.toRect(), paintBg);

    // Draw foreground (current health)
    final healthWidth = size.x * (currentHealth / maxHealth);
    canvas.drawRect(Rect.fromLTWH(0, 0, healthWidth, size.y), paintFg);
  }

  void updateHealth(int health) {
    currentHealth = health;

  }


}
