import 'package:final_project/Player/player.dart';
import 'package:flame/components.dart';
import '../knight.dart';

class HeartCounter extends PositionComponent with HasGameReference<Knight> {
  final List<SpriteComponent> hearts = [];
  late Sprite heartSprite;
  Player? player;

  int _lastHeartCount = -1;

  @override
  Future<void> onLoad() async {
    position = Vector2(50, 20);
    heartSprite = Sprite(game.images.fromCache('Items/HeartCount.png'));
    _updateHearts();
  }

  @override
  void update(double dt) {
    super.update(dt);

    if (_lastHeartCount != game.heartCount) {
      _updateHearts();
    }
  }

  void _updateHearts() {
    _lastHeartCount = game.heartCount;

    removeAll(hearts);
    hearts.clear();

    for (int i = 0; i < game.heartCount; i++) {
      final heart = SpriteComponent(
        sprite: heartSprite,
        size: Vector2(32, 32),
        position: Vector2(i * 36.0, 0),
      );
      hearts.add(heart);
    }

    addAll(hearts);
  }
}
