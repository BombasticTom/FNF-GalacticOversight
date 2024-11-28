var dumTween:FlxTween;

var sound:FlxSound = FlxG.sound.load(Paths.sound("flash"), 0.5);
var t:Float = (sound.length / 1000);

var frameTime:Float = (20 / 30);

function onEvent(n:String, v1:String)
{
	if (n == "Heal Flash Mechanic")
	{
		var drain:Float = Std.parseFloat((v1.length == 0) ? "0.1" : v1);
		var lowHealth:Float = (2 * drain);

		game.dad.playAnim("attack", true);
		game.dad.specialAnim = true;

		new FlxTimer().start(frameTime, (tmr) -> {
			if (dumTween != null)
				dumTween.cancel();

			dumTween = FlxTween.tween(game, {health: lowHealth}, t, {ease: FlxEase.sineInOut});

			game.camOther.flash(FlxColor.WHITE, t);
			sound.play(true);
		});
	}
}

function eventEarlyTrigger(n:String)
{
	if (n == "Heal Flash Mechanic")
		return frameTime * 1000;
}