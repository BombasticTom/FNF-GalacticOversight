package states.stages;

import flixel.FlxSprite;

class Rooftop extends BaseStage
{
	var roof:FlxSprite;
	override function create()
	{
		// var stage:FlxSprite = new FlxSprite(-250, -110, Paths.image("genocide/background"));
		// stage.setGraphicSize(Std.int(stage.width * 1.1));
		// stage.updateHitbox();
		// add(stage);

		var goon:FlxSprite = new FlxSprite(0, -648, Paths.image("genocide/moonnumbertenthousandfourhundredandtwenty"));
		goon.scrollFactor.set(0.1, 0.1);
		goon.screenCenter(X);
		add(goon);

		roof = new FlxSprite(goon.getGraphicMidpoint().x, 626.4, Paths.image("genocide/roof"));
		roof.scrollFactor.set(0.93, 0.93);
		roof.x -= roof.width / 2;
		add(roof);
	}

	override function createPost()
	{

		final distance:Float = (boyfriend.getGraphicMidpoint().x + dad.getGraphicMidpoint().x) / 2;
		final camOff:Float = 300;

		game.triggerEvent("Camera Follow Pos", distance, camFollow.y - camOff);
		FlxG.camera.snapToTarget();
		camFollow.y += camOff; // Cool cam effect at start 😎

		defaultCamZoom = 0.6;

		// boyfriend.x = roof.getGraphicMidpoint().x + roof.width / 4 - boyfriend.width;
		// dad.x = roof.getGraphicMidpoint().x - roof.width / 4;
		// gf.x = (boyfriend.getGraphicMidpoint().x + dad.getGraphicMidpoint().x - gf.width) / 2;

		// trace(boyfriend);
		// trace(dad);

	}
}