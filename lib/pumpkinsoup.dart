import 'package:flame/palette.dart';
import 'package:flame/components.dart';
import 'package:flame/geometry.dart';
import 'package:flame/game.dart';
import 'package:flutter/material.dart' hide Draggable;
import 'dart:math';

import 'cauldron.dart';
import 'thing.dart';

class GameTime extends TimerComponent with HasGameRef<PumpkinSoup> {
  final TextPaint textPaint = TextPaint(
    config: const TextPaintConfig(
      color: Color(0xFFFFFFFF),
    ),
  );

  GameTime(Timer timer) : super(timer);

  @override
  void render(Canvas canvas) {
    super.render(canvas);
    textPaint.render(canvas, 'Time: ${timer.current.toInt()}',
        Vector2(gameRef.size.x - 150, 30));
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

TextComponent getHud() {
  final _regularTextConfig = TextPaintConfig(color: BasicPalette.red.color);
  final textConfig = TextPaint(config: _regularTextConfig.withFontSize(36.0));

  TextComponent hud = TextComponent("Points: 0",
      priority: 1, position: Vector2(20, 20), textRenderer: textConfig);
  return hud;
}

class PumpkinSoup extends FlameGame
    with HasCollidables, HasDraggableComponents {
  late final Cauldron cauldron;
  late final JoystickComponent joystick;
  double timeSinceLastSpawned = 0.0;
  int points = 0;
  late TextComponent hud;
  late Random rng;

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    rng = Random();
    debugMode = true;
    JoystickComponent joystick = getJoystick();
    hud = getHud();
    cauldron = Cauldron(joystick);

    add(cauldron);
    add(joystick);
    add(ScreenCollidable());
    add(GameTime(Timer(double.infinity)..start()));
    add(hud);
  }

  @override
  void update(double dt) {
    super.update(dt);
    timeSinceLastSpawned += dt;
    _maybeAddThing();
  }

  void _maybeAddThing() {
    if (timeSinceLastSpawned > 1.0) {
      bool isEdible = rng.nextBool();
      Vector2 startVelocity;
      Vector2 startPos;
      if (rng.nextBool()) {
        startPos = Vector2(-100, size.y);
        startVelocity = Vector2(0.0, -(200 + rng.nextDouble() * 300))
          ..rotate(rng.nextDouble() * pi / 4);
      } else {
        startPos = Vector2(size.x + 100, size.y);
        startVelocity = Vector2(0.0, -(200 + rng.nextDouble() * 300))
          ..rotate(-rng.nextDouble() * pi / 4);
      }
      Thing thing = Thing(isEdible: isEdible)
        ..position = startPos
        ..velocity.setFrom(startVelocity);
      add(thing);
      timeSinceLastSpawned = 0.0;
    }
  }

  void updateHud() {
    hud.text = "Points: $points";
  }
}
