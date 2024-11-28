import psychlua.LuaUtils;

var canEnter:Bool = false;

var cynch:Character = new Character(0, 0, "cynch-bethere-dead");

cynch.alpha = 0;
cynch.flipX = false;

cynch.animation.addByIndices("glitchFrame", "Game_Over_Loop", [0], "", 24);
cynch.addOffset("glitchFrame", -258, -430);
cynch.playAnim("glitchFrame");

var cynchDummy:Character = new Character(0, 0, "cynch-bethere-dead");
cynchDummy.alpha = 0;
cynchDummy.flipX = false;

cynchDummy.animation.finishCallback = (name:String) -> {
	switch (name)
	{
		case "firstDeath":
		{
			add(cynch);

			FlxTween.tween(cynchDummy, {alpha: 0}, 25/24, {
				onComplete: (twn:FlxTween) -> {
					cynch.alpha = 1;
					cynch.playAnim("deathLoop");
					canEnter = true;
				},
				onUpdate: (twn:FlxTween) -> {
					cynch.alpha = twn.percent;
				}
			});
		}
	}
};

new FlxTimer().start(1, (tmr:FlxTimer) -> {
	add(cynchDummy);
	cynchDummy.animation.play("firstDeath");
	FlxTween.tween(cynchDummy, {alpha: 1}, 1);
	tmr.destroy();
});

function onStartCountdown()
{
	return LuaUtils.Function_Stop;
}

function onUpdate(elapsed:Float)
{
	if (canEnter && FlxG.keys.justPressed.ENTER)
	{
		cynch.playAnim("deathConfirm");
		return;
	}

	if (FlxG.keys.justPressed.O)
	{
		FlxG.resetState();
		return;
	}

	if (FlxG.keys.justPressed.P)
	{
		game.endSong();
		return;
	}
}