import 'package:flame/components.dart';
import 'package:flame/geometry.dart';
import 'pumpkinsoup.dart';

class Thing extends SpriteComponent
    with HasGameRef<PumpkinSoup>, Hitbox, Collidable {
  late String spriteName;
  bool isEdible;
  Vector2 velocity = Vector2.zero();

  Thing({this.isEdible = false}) {
    collidableType = CollidableType.passive;
    if (isEdible) {
      spriteName = "pumpkin.png";
    } else {
      spriteName = "poison.png";
    }
  }

  Future<void> onLoad() async {
    await super.onLoad();
    sprite = await gameRef.loadSprite(this.spriteName);
    width = 100;
    height = 100;
    anchor = Anchor.center;
    addHitbox(HitboxCircle());
  }

  @override
  void update(double dt) {
    super.update(dt);
    _maybeDie();
    position += velocity * dt;
    velocity += Vector2(0, (25 * dt));
    angle = velocity.screenAngle();
  }

  void _maybeDie() {
    Vector2 gameCenter = size / 2;
    Vector2 distance = position - size;
    distance.absolute();
    if (distance.length2 > ((gameRef.size / 2) + Vector2(150, 150)).length2) {
      print("Killed");
      removeFromParent();
    }
  }

  void move(Vector2 delta) {
    position.add(delta);
  }
}
