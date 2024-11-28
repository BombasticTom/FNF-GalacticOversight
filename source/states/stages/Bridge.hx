package states.stages;

import substates.GameOverSubstate;
import openfl.filters.ShaderFilter;
import shaders.Glitch;
import flixel.FlxSprite;

class Bridge extends BaseStage
{
	var sky:FlxSprite;
	var bridge:FlxSprite;
	var foreground:FlxSprite;
	var background:FlxSprite;

	var glitch:Glitch;
	var filter:ShaderFilter;

	// Add sprites, fix layering issues.
	override function create()
	{
		glitch = new Glitch();
		filter = new ShaderFilter(glitch.shader);

		game.camGame.filters = [filter];

		sky = new FlxSprite(0, 0, Paths.image("bethere/sky"));
		sky.scale.set(1.2, 1.2);
		sky.updateHitbox();
		sky.scrollFactor.set(0.2, 0.2);
		sky.shader = glitch.shader;
		add(sky);

		bridge = new FlxSprite(0, sky.y + 89, Paths.image("bethere/bridge"));

		foreground = new FlxSprite(0, sky.y + 126, Paths.image("bethere/foreground"));
		foreground.scrollFactor.set(1.15, 1.15);

		background = new FlxSprite(0, 0, Paths.image("bethere/background"));
		background.screenCenter();
		background.scrollFactor.set(0.2, 0.2);

		Paths.image("bethere/skyGlitched");

		GameOverSubstate.characterName = "cynch-bethere-dead";
	}

	override function createPost()
	{
		// boyfriend.setPosition(690, 380);
		// dad.setPosition(1100, -160);

		dad.scrollFactor.set(0.9, 0.9);

		addBehindBF(bridge);

		add(foreground);
		add(background);

		sky.screenCenter();
		// game.moveCamera(true);
	}

	override public function eventCalled(eventName:String, value1:String, value2:String, flValue1:Null<Float>, flValue2:Null<Float>, strumTime:Float)
	{
		switch (eventName)
		{
			case "Be There Glitch":
				var time:Float = (48 * (Conductor.crochet*4) - Conductor.songPosition) / 1000;

				game.camZooming = false;
				camFollow.setPosition(boyfriend.getGraphicMidpoint().x, boyfriend.y);
				FlxTween.tween(FlxG.camera, {zoom: 1.2}, time - 0.3, {ease: FlxEase.cubeOut});

				FlxTween.num(0.0, 1.0, time,
					{
						ease: FlxEase.backIn,
						onComplete: (twn:FlxTween) -> {
							sky.loadGraphic(Paths.image("bethere/skyGlitched"));
							sky.scale.set(1.2, 1.2);
							sky.updateHitbox();

							FlxTween.num(1.0, 0.0, 1.0,
								{
									startDelay: 0.15,
									onComplete: (twn:FlxTween) -> {
										game.camGame.filters = [];
										glitch.AMT = 0.6;
										glitch.SPEED = 0.4;
									}
								},
								(val:Float) -> {
									glitch.AMT = val;
									glitch.SPEED = val;
								}
							);

							game.camZooming = true;
						}
					},
					(val:Float) -> {
						glitch.AMT = val;
						glitch.SPEED = val;
					}
				);
		}
	}

	override function update(elapsed:Float)
	{
		super.update(elapsed);
		glitch.update(elapsed);
	}
}