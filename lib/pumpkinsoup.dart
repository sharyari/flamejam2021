import 'dart:html';

import 'package:flame/input.dart';
import 'package:flame/palette.dart';
import 'package:flame/components.dart';
import 'package:flame/geometry.dart';
import 'package:flame/game.dart';
import 'package:flutter/material.dart' hide Draggable;
import 'package:flame/parallax.dart';
import 'package:flame_audio/flame_audio.dart';

import 'dart:math';

import 'cauldron.dart';
import 'thing.dart';

class GameTime extends TimerComponent with HasGameRef<PumpkinSoup> {
  bool finished = false;
  final TextPaint textPaint = TextPaint(
    config: const TextPaintConfig(
      color: Color(0xFFFFFFFF),
    ),
  );

  GameTime(Timer timer) : super(timer);
  @override
  void onRemove() {
    super.onRemove();
    print("ASD");
  }

  @override
  bool get shouldRemove => finished;

  @override
  void render(Canvas canvas) {
    super.render(canvas);
    textPaint.render(canvas, 'Time: ${timer.current.toInt()}',
        Vector2(gameRef.size.x - 150, 30));
  }
}

TextComponent getHud() {
  final _regularTextConfig = TextPaintConfig(color: BasicPalette.red.color);
  final textConfig = TextPaint(config: _regularTextConfig.withFontSize(36.0));

  return TextComponent("Points: 0",
      priority: 1, position: Vector2(20, 20), textRenderer: textConfig);
}

class PumpkinSoup extends FlameGame
    with HasCollidables, HasDraggableComponents, HasTappableComponents {
  late TextComponent hud;
  late Random rng = Random();
  late JoystickComponent joystick;
  Cauldron? cauldron;
  GameTime? gametime;
  late final HudButtonComponent startbutton;
  double timeSinceLastSpawned = 0.0;
  int points = 0;
  bool started = false;
  bool shouldReset = false;

  final _imageNames = [
    ParallaxImageData('parallax-forest-back-trees.png'),
    ParallaxImageData('parallax-forest-front-trees.png'),
    ParallaxImageData('parallax-forest-lights.png'),
    ParallaxImageData('parallax-forest-middle-trees.png'),
  ];

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    //debugMode = true;
    joystick = await getJoystick();
    startbutton = getStartButton();
    hud = getHud();
    final parallax = await loadParallaxComponent(
      _imageNames,
      priority: 0,
      baseVelocity: Vector2(10, 0),
      velocityMultiplierDelta: Vector2(1.8, 1.0),
    );

    add(joystick);
    add(ScreenCollidable());
    add(hud);
    add(getRestartButton());
    add(parallax);
    add(startbutton);
  }

  @override
  void update(double dt) {
    super.update(dt);
    if (!started) {
      return;
    }

    timeSinceLastSpawned += dt;
    _maybeAddThing();
    if (shouldReset) {
      setNewGame();
      shouldReset = false;
    }
  }

  Future<JoystickComponent> getJoystick() async {
    final image = await images.load('44.png');
    final image2 = await images.load('42.png');

    return JoystickComponent(
        knob: SpriteComponent(
          sprite: Sprite(image2),
          size: Vector2.all(70),
        ),
        background: SpriteComponent(
          sprite: Sprite(image),
          size: Vector2.all(150),
        ),
        margin: const EdgeInsets.only(left: 40, bottom: 40));
  }

  void _maybeAddThing() {
    // Initially spawn one per second, increase to 2 per seconds gradually
    double spawnRate = 1.0 - (gametime!.timer.current / 100.0);

    if (timeSinceLastSpawned < max(spawnRate, 0.5)) {
      return;
    }
    Vector2 startVelocity;
    Vector2 startPos;
    int sign = 1;
    if (!rng.nextBool()) {
      sign = -1;
      startPos = Vector2(size.x + 200, size.y);
    } else {
      startPos = Vector2(-200, size.y);
    }
    startVelocity = Vector2(0.0, -(200 + rng.nextDouble() * 300))
      ..rotate(sign * rng.nextDouble() * pi / 2);

    bool isEdible = rng.nextBool();
    bool twist = rng.nextDouble() > 0.7;
    Thing thing = Thing(isEdible: isEdible, twist: twist)
      ..position = startPos
      ..velocity.setFrom(startVelocity);
    add(thing);
    timeSinceLastSpawned = 0.0;
  }

  void setNewGame() {
    // Remove cauldron, things and timer and add new
    print(gametime);
    gametime?.finished = true;
    cauldron?.removeFromParent();
    gametime?.removeFromParent();
    children.whereType<Thing>().forEach(remove);
    cauldron = Cauldron(joystick);
    gametime = GameTime(Timer(double.infinity)..start());
    add(cauldron!);
    add(gametime!);
    remove(startbutton);
    points = 0;
    updateHud();
    if (!FlameAudio.bgm.isPlaying) {
      FlameAudio.bgm.play('GucciGhost.mp3');
    }
    started = true;
  }

  void updateHud() {
    hud.text = "Points: $points";
  }

  HudButtonComponent getRestartButton() {
    final Paint buttonPaint = Paint()..color = Colors.deepOrangeAccent;
    HudButtonComponent hbc = HudButtonComponent(
        button:
            Rectangle(size: Vector2(150, 60)).toComponent(paint: buttonPaint),
        buttonDown: Rectangle(size: Vector2(150, 60))
            .toComponent(paint: BasicPalette.blue.paint()),
        margin: const EdgeInsets.only(
          right: 85,
          bottom: 150,
        ),
        onPressed: () => shouldReset = true);
    hbc.add(TextComponent("Restart", priority: 3, position: hbc.size / 2)
      ..anchor = Anchor.center);

    return hbc;
  }

  HudButtonComponent getStartButton() {
    final Paint buttonPaint = Paint()..color = Colors.deepOrangeAccent;

    HudButtonComponent hbc = HudButtonComponent(
        button:
            Rectangle(size: Vector2(150, 60)).toComponent(paint: buttonPaint),
        buttonDown: Rectangle(size: Vector2(150, 60))
            .toComponent(paint: BasicPalette.blue.paint()),
        position: size / 2,
        onPressed: setNewGame);

    hbc.add(TextComponent("Start", priority: 3, position: hbc.size / 2)
      ..anchor = Anchor.center);
    return hbc;
  }
}
