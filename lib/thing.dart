import 'package:flame/components.dart';
import 'package:flame/geometry.dart';
import 'pumpkinsoup.dart';

class Thing extends SpriteComponent
    with HasGameRef<PumpkinSoup>, Hitbox, Collidable {
  late String spriteName;
  bool isEdible;

  Thing(this.isEdible) {
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

  void move(Vector2 delta) {
    position.add(delta);
  }
}
