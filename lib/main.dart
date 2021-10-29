import 'package:flame/input.dart';
import 'package:flame/palette.dart';
import 'package:flutter/material.dart' hide Draggable;
import 'package:flame/game.dart';
import 'package:flame/components.dart';
import 'package:flame/geometry.dart';
/*
Halloween
With a twist
Rediculously happy and colorful
No Collision detection
*/

class Player extends SpriteComponent
    with HasGameRef<SpaceShooterGame>, Draggable, Hitbox, Collidable {
  final Set<Collidable> _activeCollisions = {};
  final JoystickComponent joystick;

  Player(this.joystick);

  @override
  bool onDragUpdate(int pointerId, DragUpdateInfo info) {
    position += info.delta.game;
    return true;
  }

  Future<void> onLoad() async {
    await super.onLoad();
    sprite = await gameRef.loadSprite("flame.png");
    position = gameRef.size / 2;
    width = 200;
    height = 200;
    anchor = Anchor.center;
    addHitbox(HitboxRectangle());
  }

  void move(Vector2 delta) {
    position.add(delta);
  }

  @override
  void onCollision(Set<Vector2> intersectionPoints, Collidable other) {
    print("onCollision");
    final isNew = _activeCollisions.add(other);
    if (isNew) {
      print("Collided!!!! ");
      print(isNew);
    }
  }
}

class Thing extends SpriteComponent
    with HasGameRef<SpaceShooterGame>, Draggable, Hitbox, Collidable {
  Future<void> onLoad() async {
    await super.onLoad();
    sprite = await gameRef.loadSprite("flame.png");
    width = 100;
    height = 100;
    anchor = Anchor.center;
    addHitbox(HitboxCircle());
  }

  void move(Vector2 delta) {
    position.add(delta);
  }
}

JoystickComponent getJoystick() {
  return JoystickComponent(
      knob: Circle(radius: 30)
          .toComponent(paint: BasicPalette.blue.withAlpha(200).paint()),
      background: Circle(radius: 100)
          .toComponent(paint: BasicPalette.blue.withAlpha(100).paint()),
      margin: const EdgeInsets.only(left: 40, bottom: 40));
}

class SpaceShooterGame extends FlameGame
    with HasCollidables, HasDraggableComponents {
  late final Player player;
  late final JoystickComponent joystick;
  @override
  Future<void> onLoad() async {
    await super.onLoad();
    debugMode = true;
    JoystickComponent joystick = getJoystick();
    player = Player(joystick);
    Thing thing1 = Thing()..position = Vector2(100, 100);
    Thing thing2 = Thing()..position = Vector2(100, 800);
    add(player);
    add(thing1);
    add(thing2);
    add(joystick);
  }
}

void main() {
  runApp(GameWidget(game: SpaceShooterGame()));
}
