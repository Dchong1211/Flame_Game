import 'dart:async';
import 'package:final_project/Enemy/enemy.dart';
import 'package:final_project/Items/checkpoint.dart';
import 'package:final_project/Items/coins.dart';
import 'package:final_project/Collisions/collisions.dart';
import 'package:final_project/Items/heart.dart';
import 'package:final_project/Items/wizard.dart';
import 'package:final_project/Player/player.dart';
import 'package:final_project/Traps/shuriken.dart';
import 'package:flame/components.dart';
import 'package:flame_tiled/flame_tiled.dart';
import '../Traps/bridge.dart';
import '../Traps/damaged_area.dart';

class Level extends World {
  List<CollisionBlock> collisionBlocks = [];
  final String levelName;
  Player? player;
  Level({required this.levelName, required this.collisionBlocks});
  late TiledComponent level;
  @override
  FutureOr<void> onLoad() async {
    level = await TiledComponent.load('$levelName.tmx', Vector2.all(16));
    add(level);

    final spawnPointsLayer = level.tileMap.getLayer<ObjectGroup>('SpawnPoints');
    if(spawnPointsLayer != null){
      for (final spawnPoint in spawnPointsLayer.objects) {
        switch (spawnPoint.class_) {
          case 'Player':
            player = Player(position: Vector2(spawnPoint.x + 16, spawnPoint.y + 16));
            add(player!);
            break;
          case 'Coins':
            final coins = Coins(
              coin: spawnPoint.name,
              position: Vector2(spawnPoint.x, spawnPoint.y),
              size: Vector2(spawnPoint.width, spawnPoint.height),
            );
            level.add(coins);
            break;
          case 'Heart':
            final hearts = Heart(
              heart: spawnPoint.name,
              position: Vector2(spawnPoint.x, spawnPoint.y),
              size: Vector2(spawnPoint.width, spawnPoint.height),
            );
            level.add(hearts);
            break;
          case 'Shuriken':
            final isVertical = spawnPoint.properties.getValue('isVertical');
            final offNeg = spawnPoint.properties.getValue('offNeg');
            final offPos = spawnPoint.properties.getValue('offPos');
            final shuriken = Shuriken(
              isVertical: isVertical,
              offNeg: offNeg,
              offPos: offPos,
              position: Vector2(spawnPoint.x, spawnPoint.y),
              size: Vector2(spawnPoint.width, spawnPoint.height),
            );
            level.add(shuriken);
            break;
          case 'Checkpoint':
            final checkpoint = Checkpoint(
              position: Vector2(spawnPoint.x, spawnPoint.y),
              size: Vector2(spawnPoint.width, spawnPoint.height),
            );
            level.add(checkpoint);
            break;
          case 'Wizard':
            final wizard = Wizard(
              position: Vector2(spawnPoint.x, spawnPoint.y),
              size: Vector2(spawnPoint.width, spawnPoint.height),
            );
            level.add(wizard);
            break;
          case 'DamagedArea': // Thêm trường hợp này
            final damagedArea = DamagedArea(
              position: Vector2(spawnPoint.x, spawnPoint.y),
              size: Vector2(spawnPoint.width, spawnPoint.height),
            );
            add(damagedArea);
            break;
          case 'Enemy':
            final offNeg = spawnPoint.properties.getValue('offNeg');
            final offPos = spawnPoint.properties.getValue('offPos');
            final enemy = Enemy(
              offNeg: offNeg,
              offPos: offPos,
              position: Vector2(spawnPoint.x + spawnPoint.width / 2,
                spawnPoint.y + spawnPoint.height / 2,),
              size: Vector2(spawnPoint.width, spawnPoint.height),
            );
            add(enemy);
            break;
          case 'Bridge':
            final bridge = Bridge(
              position: Vector2(spawnPoint.x, spawnPoint.y),
              size: Vector2(spawnPoint.width, spawnPoint.height),
            );
            add(bridge);
            break;
          default:
        }
      }
    }
    final collisionsLayer = level.tileMap.getLayer<ObjectGroup>('Collisions');
    if(collisionsLayer != null){
      for (final collision in collisionsLayer.objects){
        switch(collision.class_){
          case 'Platform':
            final platform = CollisionBlock(
              position: Vector2(collision.x, collision.y),
              size: Vector2(collision.width, collision.height),
              isPlatform: true,
            );
            collisionBlocks.add(platform);
            add(platform);
            break;
          default:
            final block = CollisionBlock(
              position: Vector2(collision.x, collision.y),
              size: Vector2(collision.width, collision.height,),
            );
            collisionBlocks.add(block);
            add(block);
            break;
        }
      }
    }
    player?.collisionBlocks = collisionBlocks;
    return super.onLoad();
  }
}