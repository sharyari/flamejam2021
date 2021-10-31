import 'package:flame/components.dart';
import 'package:flame/geometry.dart';
import 'package:flame/effects.dart';
import 'package:flutter/material.dart';

import 'pumpkinsoup.dart';

class Thing extends SpriteComponent
    with HasGameRef<PumpkinSoup>, Hitbox, Collidable {
  late String spriteName;
  bool isEdible;
  bool twist;
  Vector2 velocity = Vector2.zero();
  HitboxShape hitbox = HitboxCircle();
  bool isDead = false;

  Thing({this.isEdible = false, this.twist = false}) {
    collidableType = CollidableType.passive;
    if (isEdible) {
      if (twist) {
        spriteName = "hatpumpkin.png";
      } else {
        spriteName = "pumpkin.png";
      }
    } else {
      spriteName = "poison.png";
    }
  }

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    sprite = await gameRef.loadSprite(spriteName);
    size = Vector2(75.0, 75.0);
    anchor = Anchor.center;
    addHitbox(hitbox);
  }

  @override
  void update(double dt) {
    super.update(dt);
    _maybeDie();
    if (!isDead) {
      position += velocity * dt;
    }
    velocity += Vector2(0, (25 * dt));
    angle = velocity.screenAngle();
  }

  void _maybeDie() {
    Vector2 gameCenter = gameRef.size / 2;
    Vector2 distance = position - gameCenter;
    distance.absolute();
    if (distance.length2 > ((gameRef.size * 0.8) + Vector2(250, 250)).length2) {
      removeFromParent();
    }
  }

  void die() {
    isDead = true;
    add(SizeEffect(
        size: Vector2.all(0),
        speed: 100.0,
        curve: Curves.bounceInOut,
        onComplete: () => removeFromParent()));
    removeHitbox(hitbox);
  }

  void move(Vector2 delta) {
    position.add(delta);
  }
}
