import 'dart:math';

import 'package:flame/input.dart';
import 'package:flame/components.dart';
import 'package:flame/palette.dart';
import 'package:flame/geometry.dart';
//import 'package:flame_audio/flame_audio.dart';
import 'package:flame_audio/audio_pool.dart';

import 'pumpkinsoup.dart';
import 'thing.dart';

class Cauldron extends SpriteComponent
    with HasGameRef<PumpkinSoup>, Hitbox, Collidable {
  final JoystickComponent joystick;
  late Vector2 _lastDelta;
  bool _isWallHit = false;
  bool reverse = false;
  double reverseTime = 0.0;
  TextComponent? reverseHud;
  late AudioPool happyPlayer;
  late AudioPool sadPlayer;

  Cauldron(this.joystick);

  Future<void> onLoad() async {
    await super.onLoad();
    sprite = await gameRef.loadSprite("cauldron.png");
    position = gameRef.size / 2;
    size = Vector2(200, 200);
    _lastDelta = Vector2.zero();
    anchor = Anchor.center;
    happyPlayer = await AudioPool.create('happy2.mp3');
    sadPlayer = await AudioPool.create('sad.mp3');

    addHitbox(HitboxCircle());
  }

  @override
  void onRemove() {
    super.onRemove();
    reverseHud?.removeFromParent();
  }

  @override
  void update(double dt) {
    super.update(dt);
    if (_isWallHit) {
      _isWallHit = false;
      if (reverse) {
        reverseTime += dt;
        position.add(_lastDelta);
      } else {
        position.add(-_lastDelta);
      }
      return;
    }

    if (!joystick.delta.isZero()) {
      double maxSpeed = 400;
      _lastDelta = joystick.relativeDelta * maxSpeed * dt;
      if (reverse) {
        position.add(-_lastDelta);
        angle = joystick.delta.screenAngle() + pi;
        reverseTime += dt;
      } else {
        position.add(_lastDelta);
        angle = joystick.delta.screenAngle();
      }
    }
    if (reverseTime > 5.0) {
      position.add(_lastDelta);
      reverse = false;
      reverseTime = 0.0;
      reverseHud!.removeFromParent();
    }
  }

  void move(Vector2 delta) {
    position.add(delta);
  }

  @override
  void onCollision(Set<Vector2> intersectionPoints, Collidable other) {
    if (other is ScreenCollidable) {
      _isWallHit = true;
      return;
    }
    if (other is Thing) {
      if (other.isEdible) {
        gameRef.points += 10;
        happyPlayer.start();

        if (other.twist) {
          reverse = true;
          position.add(-_lastDelta * 2);

          if (reverseHud != null) {
            reverseHud!.removeFromParent();
          }
          reverseHud = getReverseHud();
          gameRef.add(reverseHud!);
        }
      } else {
        sadPlayer.start();

        gameRef.points -= 10;
      }
      gameRef.updateHud();
      other.die();
    }
  }

  TextComponent getReverseHud() {
    final _regularTextConfig = TextPaintConfig(color: BasicPalette.red.color);
    final textConfig = TextPaint(config: _regularTextConfig.withFontSize(86.0));

    return TextComponent("Reverse!",
        priority: 10,
        position: Vector2(gameRef.size.x / 2, 100),
        textRenderer: textConfig)
      ..anchor = Anchor.center;
  }
}
