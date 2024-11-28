var antialiasing:Bool = ClientPrefs.data.antialiasing;

var bg:FlxSprite = new FlxSprite(50, 170, Paths.image("concurrenceog/Stage"));
bg.antialiasing = antialiasing;
bg.blend = "shader";

bg.scrollFactor.set(0.95, 0.95);
bg.scale.set(1.25, 1.25);
bg.updateHitbox();

var bgNight:FlxSprite = new FlxSprite(50, 170, Paths.image("concurrenceog/slowStage"));
bgNight.antialiasing = antialiasing;

bgNight.scrollFactor.set(0.95, 0.95);
bgNight.scale.set(1.25, 1.25);
bgNight.updateHitbox();
bgNight.kill();

var flora:FlxSprite = new FlxSprite(720, 480);
flora.antialiasing = antialiasing;

flora.frames = Paths.getSparrowAtlas("concurrenceog/flora");
flora.animation.addByIndices("danceLeft", "New", [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16], '', 24, false);
flora.animation.addByIndices("danceRight", "New", [17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29], '', 24, false);

flora.scale.set(0.56, 0.56);
flora.updateHitbox();

var cynchNight:Character;

addBehindGF(bgNight);
addBehindGF(bg);
addBehindGF(flora);

var danceAnims:Array<String> = ["danceLeft", "danceRight"];
var danceLength:Int = danceAnims.length;

function floraDance(incr:Int)
{
	flora.animation.play(danceAnims[incr % danceLength], true);
}

function onCreatePost()
{
	cynchNight = new Character(game.dad.positionArray[0], game.dad.positionArray[1], "cynch-og-sans");
	cynchNight.kill();
	game.dadGroup.insert(0, cynchNight);
}

function onEvent(n:String, v1:String)
{
	if (n == "turnballs")
	{
		var isDay:Bool = (v1.toLowerCase() == "true");

		var duration:Float = 0.6;
		var ease = FlxEase.sineInOut;

		var fromColor:Int;
		var toColor:Int;
		var charAlpha:Float;

		if (!isDay)
		{
			bgNight.revive();
			FlxTween.tween(bg, {alpha: 0}, duration, {ease: ease});

			fromColor = FlxColor.WHITE;
			toColor = 0xFF444444;

			charAlpha = 0;
		}
		else
		{
			FlxTween.tween(bg, {alpha: 1}, duration, {
				ease: ease,
				onComplete: (_) -> bgNight.kill()
			});

			fromColor = 0xFF444444;
			toColor = FlxColor.WHITE;

			charAlpha = 1;
		}

		FlxTween.color(game.boyfriend, duration, fromColor, toColor, {ease: ease});
		FlxTween.color(game.gf, duration, fromColor, toColor, {ease: ease});
		FlxTween.color(flora, duration, fromColor, toColor, {ease: ease});

		cynchNight.revive();
		game.dad.revive();

		FlxTween.tween(game.dad, {alpha: charAlpha}, duration, {
			ease: ease,
			onComplete: (_) -> {
				if (charAlpha == 1)
					cynchNight.kill();
				else
					game.dad.kill();
			}
		});
	}
}

function onCountdownTick(type, t:Int)
	floraDance(t);

function onBeatHit()
	floraDance(curBeat);

var daNotes:Array<String> = ["singLEFT", "singDOWN", "singUP", "singRIGHT"];
function opponentNoteHit(note:Note)
{
	if (cynchNight.alive)
	{
		cynchNight.playAnim(daNotes	[note.noteData % 4], true);
		cynchNight.animation.curAnim.curFrame = game.dad.animation.curAnim.curFrame;
	}
}