import 'dart:async';
import 'package:final_project/Items/heart_counter.dart';
import 'package:final_project/Button/attack_button.dart';
import 'package:final_project/Button/jump_button.dart';
import 'package:final_project/Player/player.dart';
import 'package:final_project/levels/level.dart';
import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame/game.dart';
import 'package:flame/parallax.dart';
import 'package:flame_audio/flame_audio.dart';
import 'package:flutter/material.dart';
import 'Items/coin_counter.dart';
import 'Sound/sound_manager.dart';

class Knight extends FlameGame
    with HasKeyboardHandlerComponents, DragCallbacks, HasCollisionDetection {
  late CameraComponent cam;
  late JoystickComponent joyStick;
  late Player player;
  int coinCount = 0;
  int heartCount = 0;
  final jumpButton = JumpButton();
  final attackButton = AttackButton();
  List<String> levelNames = ['level_01', 'level_02', 'level_03', 'level_04'];
  int currentLevelIndex = 0;

  ParallaxComponent? parallaxBackground;

  bool playSounds = true;
  double soundVolume = 0.2;

  late final RectangleComponent blackOverlay;

  @override
  FutureOr<void> onLoad() async {
    await images.loadAllImages();
    await SoundManager().init();
    if (!FlameAudio.bgm.isPlaying) {
      await FlameAudio.bgm.play('background_music.ogg', volume: soundVolume);
    }

    await loadLevel();

    blackOverlay = RectangleComponent(
      size: size,
      position: Vector2.zero(),
      paint: Paint()..color = Colors.black.withAlpha(0),
      priority: 999,
    );
    add(blackOverlay);

    return super.onLoad();
  }


  @override
  void update(double dt) {
    heartCount = player.heartCount;
    updateJoystick();

    if (parallaxBackground?.parallax != null) {
      parallaxBackground!.parallax!.baseVelocity =
          Vector2(player.velocity.x * 0.3, 0);
    }
    super.update(dt);
  }

  void addJoyStick() {
    joyStick = JoystickComponent(
      knob: SpriteComponent(
        sprite: Sprite(images.fromCache('UI/Knob.png')),
        size: Vector2(64, 64),
      ),
      background: SpriteComponent(
        sprite: Sprite(images.fromCache('UI/Joystick.png')),
        size: Vector2(128, 128),
      ),
      margin: const EdgeInsets.only(left: 64, bottom: 32),
    );
    cam.viewport.add(joyStick);
  }

  void updateJoystick() {
    switch (joyStick.direction) {
      case JoystickDirection.left:
      case JoystickDirection.upLeft:
      case JoystickDirection.downLeft:
        player.horizontal = -1;
        break;
      case JoystickDirection.right:
      case JoystickDirection.upRight:
      case JoystickDirection.downRight:
        player.horizontal = 1;
        break;
      default:
        player.horizontal = 0;
        break;
    }
  }

  Future<void> loadNextLevel() async {
    children.whereType<Level>().forEach(remove);
    if (currentLevelIndex < levelNames.length - 1) {
      currentLevelIndex++;
    } else {
      currentLevelIndex = 0;
    }
    await loadLevel();
  }

  Future<void> loadLevel() async {
    Level world = Level(
      levelName: levelNames[currentLevelIndex],
      collisionBlocks: [],
    );
    await add(world);

    player = world.player!;
    player.collisionBlocks = world.collisionBlocks;
    cam = CameraComponent(world: world);
    cam.viewfinder.anchor = Anchor.center;
    cam.follow(player);
    cam.viewfinder.zoom = 5.0;
    add(cam);

    parallaxBackground?.removeFromParent();

    Map<String, List<ParallaxImageData>?> levelBackgrounds = {
      'level_01': [
        ParallaxImageData('Backgrounds/Level_1/BG1.png'),
        ParallaxImageData('Backgrounds/Level_1/BG2.png'),
        ParallaxImageData('Backgrounds/Level_1/BG3.png'),
      ],
      'level_02': [
        ParallaxImageData('Backgrounds/Level_2/BG3.png'),
        ParallaxImageData('Backgrounds/Level_2/BG2.png'),
        ParallaxImageData('Backgrounds/Level_2/BG1.png'),
      ],
      'level_03': null,
      'level_04': null,
    };

    var bgImages = levelBackgrounds[levelNames[currentLevelIndex]];
    if (bgImages != null) {
      parallaxBackground = await loadParallaxComponent(
        bgImages,
        baseVelocity: Vector2.zero(),
        velocityMultiplierDelta: Vector2(1.5, 0),
      );
      add(parallaxBackground!);
    } else {
      parallaxBackground = null;
    }

    addJoyStick();
    cam.viewport.add(jumpButton);
    cam.viewport.add(attackButton);
    cam.viewport.add(CoinCounter());
    cam.viewport.add(HeartCounter());
  }

  Future<void> fadeToBlack() async {

    final overlay = RectangleComponent(
      position: Vector2.zero(),
      size: size.clone(),
      paint: Paint()..color = Colors.black.withAlpha(0),
      priority: 1000,
    );

    cam.viewport.add(overlay);

    double elapsed = 0;
    const fadeDuration = 2.0;

    while (elapsed < fadeDuration) {
      await Future.delayed(const Duration(milliseconds: 16));
      elapsed += 0.016;
      double opacity = (elapsed / fadeDuration).clamp(0.0, 1.0);
      overlay.paint.color = const Color(0xFF000000).withAlpha((opacity * 255).toInt());
    }

    overlay.paint.color = const Color(0xFF000000).withAlpha(255);
  }
  Future<void> goToThanksScene() async {
    removeAll(children.toList());

    add(
      TextComponent(
        text: 'Các thành viên tham gia\n'
            'Võ Đình Trọng\n'
            'Hàng Minh Châu\n'
            'Nguyễn Minh Hùng\n'
            'Nguyễn Trọng Thời',
        position: size / 2,
        anchor: Anchor.center,
        textRenderer: TextPaint(
          style: TextStyle(fontSize: 32, color: Colors.white)
        ),
      )
    );
  }
}
