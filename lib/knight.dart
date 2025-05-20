import 'dart:async';
import 'package:final_project/Items/heart_counter.dart';
import 'package:final_project/Player/attack_button.dart';
import 'package:final_project/Player/jump_button.dart';
import 'package:final_project/Player/player.dart';
import 'package:final_project/levels/level.dart';
import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame/game.dart';
import 'package:flame/parallax.dart';
import 'package:flutter/cupertino.dart';

import 'Items/coin_counter.dart';

class Knight extends FlameGame with HasKeyboardHandlerComponents, DragCallbacks, HasCollisionDetection {
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
  double soundVolume = 1.0;

  @override
  FutureOr<void> onLoad() async {
    await images.loadAllImages();
    await loadLevel();
    return super.onLoad();
  }

  @override
  void update(double dt) {
    heartCount = player.heartCount;
    updateJoystick();

    if (parallaxBackground?.parallax != null) {
      parallaxBackground!.parallax!.baseVelocity = Vector2(player.velocity.x * 0.3, 0);
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
    Level world = Level(levelName: levelNames[currentLevelIndex], collisionBlocks: []);
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
      'level_02': null,
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
}
