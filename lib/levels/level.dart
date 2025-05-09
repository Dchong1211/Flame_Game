import 'dart:async';
import 'package:final_project/levels/collisions.dart';
import 'package:final_project/player.dart';
import 'package:flame/components.dart';
import 'package:flame_tiled/flame_tiled.dart';

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
            player = Player(position: Vector2(spawnPoint.x, spawnPoint.y));
            add(player!);
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
