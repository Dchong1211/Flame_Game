import 'package:flame_audio/flame_audio.dart';

class SoundManager {
  static final SoundManager _instance = SoundManager._internal();
  factory SoundManager() => _instance;
  SoundManager._internal();

  AudioPool? coin;
  AudioPool? jump;
  AudioPool? attack;
  AudioPool? hit;
  AudioPool? death;
  AudioPool? heart;
  AudioPool? checkpoint;
  bool _isInitialized = false;

  Future<void> init() async {
    if (_isInitialized) return;
    _isInitialized = true;

    coin = await FlameAudio.createPool('coin.wav', maxPlayers: 5);
    jump = await FlameAudio.createPool('jump.wav', maxPlayers: 5);
    attack = await FlameAudio.createPool('attack.wav', maxPlayers: 5);
    hit = await FlameAudio.createPool('hit.wav', maxPlayers: 5);
    death = await FlameAudio.createPool('death.wav', maxPlayers: 5);
    heart = await FlameAudio.createPool('heart.wav', maxPlayers: 5);
    checkpoint = await FlameAudio.createPool('heart.wav', maxPlayers: 5);

  }

  void playCoin() {
    coin?.start();
  }

  void playJump() {
    jump?.start();
  }
  void playAttack() {
    attack?.start();
  }

  void playHit() {
    hit?.start();
  }
  void playDeath() {
    death?.start();
  }
  void playHeart() {
    heart?.start();
  }
  void playCheckpoint() {
    checkpoint?.start();
  }
}
