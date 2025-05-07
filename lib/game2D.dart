import 'dart:async';

import 'package:final_project/levels/jump_button.dart';
import 'package:final_project/levels/level.dart'; // Import lớp Level
import 'package:final_project/player.dart';
import 'package:flame/camera.dart';
import 'package:flame/components.dart'; // Chứa ParallaxComponent và ParallaxImageData
import 'package:flame/events.dart';
import 'package:flame/game.dart';
import 'package:flame/parallax.dart';
import 'package:flutter/cupertino.dart';

class Game2D extends FlameGame with HasKeyboardHandlerComponents, DragCallbacks {
  late final CameraComponent cam;
  late JoystickComponent joyStick;
  late Player player;
  final jumpButton = JumpButton();
  // Khai báo parallaxBackground component
  late ParallaxComponent parallaxBackground;

  @override
  FutureOr<void> onLoad() async {
    await images.loadAllImages();

    final world = Level(levelName: 'level_01', collisionBlocks: []);
    await add(world);

    player = world.player!;
    player.collisionBlocks = world.collisionBlocks;

    cam = CameraComponent(world: world);
    cam.follow(player);
    add(cam);
    cam.viewfinder.zoom = 2.0;

    parallaxBackground = await loadParallaxComponent([
        ParallaxImageData('BG1.png'),
        ParallaxImageData('BG2.png'),
        ParallaxImageData('BG3.png'),
      ], baseVelocity: Vector2.zero(),
          velocityMultiplierDelta: Vector2(1.5, 0));

      add(parallaxBackground);
    addJoyStick();
    cam.viewport.add(jumpButton);
    return super.onLoad();
  }

  @override
  void update(double dt) {
    updateJoystick();
    if (parallaxBackground.parallax != null) {
      parallaxBackground.parallax!.baseVelocity = Vector2(player.velocity.x * 0.3, 0);
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
}