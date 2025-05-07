import 'package:final_project/game2D.dart';
import 'package:flame/flame.dart';
import 'package:flame/game.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';

void main() async {
  Game2D game = Game2D();
  WidgetsFlutterBinding.ensureInitialized();
  await Flame.device.fullScreen();
  await Flame.device.setLandscape();
  runApp(GameWidget(game: kDebugMode ? Game2D(): game));
}