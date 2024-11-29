import flixel.graphics.FlxGraphic;

var graphic:FlxGraphic = Paths.image("notes/starNote");
var sound:FlxSound = FlxG.sound.load(Paths.sound("heal"), 0.5);
var dumTween:FlxTween;

var healthDrain:Bool = PlayState.storyDifficulty > 0;
var drainAmount:Float = (PlayState.storyDifficulty > 1) ? 0.04 : 0.03;

function putTheFriesInTheBag()
{
	if (dumTween != null)
		dumTween.cancel();
}

if (graphic != null)
{
	for (note in game.unspawnNotes)
	{
		note.hitHealth = 0;
		note.missHealth = 0.15;

		if (note.noteType != "Star Note" || note.isSustainNote)
			continue;

		note.loadGraphic(graphic);
		note.updateHitbox();

		note.ignoreNote = true;

		note.copyAngle = false;
		note.moves = true;
		note.angularVelocity = -200;
	}
}

game.health = 2;

function goodNoteHit(note:Note)
{
	if (note.noteType != "Star Note")
		return;

	putTheFriesInTheBag();

	dumTween = FlxTween.tween(game, {health: 2}, sound.length / 1000, {ease: FlxEase.bounceOut});

	sound.play(true);
}

function noteMiss(note:Note)
{
	putTheFriesInTheBag();
}

function onUpdate(elapsed:Float)
{
	// Reason we pick camZooming is to know when dad starts singing
	if (!game.endingSong && healthDrain && game.camZooming)
		game.health -= drainAmount * elapsed;
}