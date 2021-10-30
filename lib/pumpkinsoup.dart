import 'package:flame/input.dart';
import 'package:flame/palette.dart';
import 'package:flame/components.dart';
import 'package:flame/geometry.dart';
import 'package:flame/game.dart';
import 'package:flutter/material.dart' hide Draggable;

import 'cauldron.dart';
import 'thing.dart';

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
  int points = 0;
  late TextComponent hud;
  @override
  Future<void> onLoad() async {
    await super.onLoad();
    debugMode = true;
    JoystickComponent joystick = getJoystick();
    hud = getHud();
    cauldron = Cauldron(joystick);
    Thing thing1 = Thing(true)..position = Vector2(100, 100);
    Thing thing2 = Thing(false)..position = Vector2(100, 800);

    add(cauldron);
    add(thing1);
    add(thing2);
    add(joystick);
    add(ScreenCollidable());
    add(hud);
  }

  void updateHud() {
    hud.text = "Points: $points";
  }
}
