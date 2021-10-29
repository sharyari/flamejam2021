import 'package:flame/input.dart';
import 'package:flutter/material.dart';
import 'package:flame/game.dart';
import 'package:flame/components.dart';

/*
Halloween
With a twist
Rediculously happy and colorful
No Collision detection
*/

class Player extends SpriteComponent with HasGameRef<SpaceShooterGame> {
  static final _paint = Paint()..color = Colors.white;

  Future<void> onLoad() async {
    await super.onLoad();
    sprite = await gameRef.loadSprite("flame.png");
    position = size / 2;
    width = 200;
    height = 200;
    anchor = Anchor.center;
  }

  void move(Vector2 delta) {
    position.add(delta);
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);
  }
}

class SpaceShooterGame extends FlameGame with PanDetector {
  late Player player;
  @override
  Future<void> onLoad() async {
    await super.onLoad();

    player = Player();

    add(player);
  }

  void onPanUpdate(DragUpdateInfo info) {
    player.move(info.delta.game);
  }
}

void main() {
  runApp(GameWidget(game: SpaceShooterGame()));
}
