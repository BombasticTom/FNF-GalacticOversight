package states.stages;

import objects.Note.EventNote;
import shaders.AdjustColor;
import flixel.FlxSprite;

class Beach extends BaseStage
{
	private var flora:FlxSprite;
	private var bg:BGSprite;

	var bgShader:AdjustColor;
	var effectShader:AdjustColor;

	var fadeOutTween:FlxTween;
	var fadeInTween:FlxTween;
	var bgTween:FlxTween;

	function changeCharacterEffect(charName:String, startTime:Float)
	{
		if (effectShader == null)
		{
			trace("EFFECT shader was not initialized!! Dummy!");
			return;
		}

		fadeInTween?.cancel();
		fadeOutTween?.cancel();

		fadeOutTween = FlxTween.tween(effectShader, {brightness: 0}, 1, {ease: FlxEase.sineOut});

		fadeInTween = FlxTween.tween(effectShader, {brightness: 256}, startTime, {ease: FlxEase.backIn,
			onComplete: (_) -> {
				var prevShader:AdjustColorShader = game.dad.shader;
				dad.shader = null;

				game.triggerEvent("Change Character", "dad", charName);
				dad.shader = prevShader;
			}
		}).then(fadeOutTween);
	}

	override function create()
	{
		
		bg = new BGSprite('Stage', 50, 170, 0.95, 0.95);

		bg.scale.set(1.25, 1.25); // bg.setGraphicSize(Std.int(bg.width * 1.25));
		bg.updateHitbox();
		add(bg);

		flora = new FlxSprite(0, 0);

		flora.frames = Paths.getSparrowAtlas("flora_assets");
		flora.animation.addByIndices("danceLEFT", "flora_dance", [30,0,1,2,3,4,5,6,7,8,9,10,11,12,13,14], '', 24, false);
		flora.animation.addByIndices("danceRIGHT", "flora_dance", [15,16,17,18,19,20,21,22,23,24,25,26,27,28,29], '', 24, false);
		flora.animation.addByPrefix("miss", "flora_miss_note", 24, false);

		flora.scrollFactor.set(0.993, 0.993);

		flora.scale.set(0.75, 0.75); // flora.setGraphicSize(Std.int(flora.width * 0.75));
		flora.updateHitbox();
	}

	override function eventPushed(event:EventNote)
	{
		if (event.event == "Concurrence Event")
		{
			// Creates the shader if the event is used
			effectShader = new AdjustColor();
			bgShader = new AdjustColor();

			bg.shader = bgShader.shader;

			dad.shader = effectShader.shader;
			boyfriend.shader = bgShader.shader;
			gf.shader = bgShader.shader;
			flora.shader = bgShader.shader;
		}
	}

	override function eventPushedUnique(event:EventNote)
	{
		if (event.event == "Concurrence Event")
			// Preloads character for a smooth transition
			game.addCharacterToList(event.value1, 1);
	}

	override function eventCalled(eventName:String, value1:String, value2:String, flValue1:Null<Float>, flValue2:Null<Float>, strumTime:Float)
	{
		if (eventName == "Concurrence Event")
		{
			var t:Float = flValue2 / 1000;
			var isReverse:Bool = !(value1 == "cynch-spooky");

			var tweenData = !isReverse ?
				{hue: -45, saturation: -60, brightness: -40} :
				{hue: 0, saturation: 0, brightness: 0}

			changeCharacterEffect(value1, t);

			bgTween?.cancel();
			bgTween = FlxTween.tween(bgShader, tweenData, t, {ease: isReverse ? FlxEase.circIn : FlxEase.circOut});
		}
	}

	override function createPost()
	{
		flora.setPosition(gf.x + 461, gf.y + 132);
		insert(game.members.indexOf(gfGroup) + 1, flora);
	}

	override function beatHit()
	{
		flora.animation.play(curBeat%2 > 0 ? "danceRIGHT" : "danceLEFT", true);
	}

	override function countdownTick(count:Countdown, num:Int)
	{
		flora.animation.play(num%2 > 0 ? "danceRIGHT" : "danceLEFT", true);
	}
}