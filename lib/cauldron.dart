import 'package:flame/input.dart';
import 'package:flame/components.dart';
import 'package:flame/geometry.dart';
import 'pumpkinsoup.dart';
import 'thing.dart';

class Cauldron extends SpriteComponent
    with HasGameRef<PumpkinSoup>, Hitbox, Collidable {
  final JoystickComponent joystick;
  late Vector2 _lastDelta;
  bool _isWallHit = false;

  Cauldron(this.joystick);

  Future<void> onLoad() async {
    await super.onLoad();
    sprite = await gameRef.loadSprite("cauldron.png");
    position = gameRef.size / 2;
    width = 200;
    height = 200;
    _lastDelta = Vector2.zero();
    anchor = Anchor.center;
    addHitbox(HitboxCircle());
  }

  @override
  void update(double dt) {
    super.update(dt);
    if (_isWallHit) {
      _isWallHit = false;
      position.add(-_lastDelta);
      return;
    }

    if (!joystick.delta.isZero()) {
      double maxSpeed = 200;
      _lastDelta = joystick.relativeDelta * maxSpeed * dt;
      position.add(_lastDelta);
      angle = joystick.delta.screenAngle();
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
      } else {
        gameRef.points -= 10;
      }
      gameRef.updateHud();
      gameRef.remove(other);
    }
  }
}
