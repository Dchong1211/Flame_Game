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
  // Khai báo parallaxBackground component
  late ParallaxComponent parallaxBackground;

  @override
  FutureOr<void> onLoad() async {
    await images.loadAllImages();

    // Load the world first
    final world = Level(levelName: 'level_01', collisionBlocks: []);
    await add(world); // Add world to the game

    player = world.player!;
    player.collisionBlocks = world.collisionBlocks;

    // Create camera and set its world to the Level instance
    cam = CameraComponent.withFixedResolution(world: world, width: 480, height: 270); // Sử dụng instance 'world'
    cam.follow(player); // Theo dõi player
    add(cam); // Thêm camera vào game
      parallaxBackground = await loadParallaxComponent([
        ParallaxImageData('BG1.png'), // Lớp gần nhất
        ParallaxImageData('BG2.png'), // Lớp giữa
        ParallaxImageData('BG3.png'), // Lớp xa nhất
      ], baseVelocity: Vector2.zero(), // Bắt đầu với vận tốc bằng 0
          velocityMultiplierDelta: Vector2(1.8, 1.0)); // Điều chỉnh hệ số nhân vận tốc

      add(parallaxBackground); // Thêm parallax vào viewport
    addJoyStick();
    add(JumpButton());
    return super.onLoad();
  }

  @override
  void update(double dt) {
    updateJoystick();
    
    super.update(dt);
  }

  void addJoyStick() {
    joyStick = JoystickComponent(
      knob: SpriteComponent(
        sprite: Sprite(images.fromCache('UI/Knob.png')),
        size: Vector2(32, 32),
      ),
      background: SpriteComponent(
        sprite: Sprite(images.fromCache('UI/Joystick.png')),
        size: Vector2(64, 64),
      ),
      margin: const EdgeInsets.only(left: 32, bottom: 16),
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