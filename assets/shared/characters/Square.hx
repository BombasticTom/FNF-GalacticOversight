var x:Float = 1100;
var y:Float = -200;

var simX:Float;
var simY:Float;

var t:Float = 0;
var moveVal:Float = 160;

var followChar:Bool = false;

var camPoint:{x:Float, y:Float} = {
	x: game.dad.getMidpoint().x + game.dad.cameraPosition[0] + game.opponentCameraOffset[0] + 150,
	y: game.dad.getMidpoint().y + game.dad.cameraPosition[1] + game.opponentCameraOffset[1] - 100
};

function onUpdate(elapsed:Float)
{
	t += elapsed;

	var coolLerp:Float = 5 / (60 * elapsed);

	// Sorry for this basic ass circle animation I just started learning trigonometry in my school :(
	// Update: Haven't learned anything better 💀

	simX = x + FlxMath.fastCos(t) * 80;
	simY = y + FlxMath.fastSin(t) * 80;

	game.dad.x += (simX - game.dad.x) / coolLerp;
	game.dad.y += (simY - game.dad.y) / coolLerp;

	if (followChar && !mustHitSection)
		game.camFollow.setPosition(game.dad.getMidpoint().x + 230, game.dad.getMidpoint().y + 230);
}

var photosensitive:Bool = ClientPrefs.data.flashing;

function opponentNoteHit(note:Note)
{
	if (photosensitive)
	{
		var moveOffset = {x: 0.0, y: 0.0}

		switch (note.noteData)
		{
			case 0:
				moveOffset.x = -moveVal;
			case 1:
				moveOffset.y = moveVal;
			case 2:
				moveOffset.y = -moveVal;
			case 3:
				moveOffset.x = moveVal;
		}

		game.dad.x += moveOffset.x;
		game.dad.y += moveOffset.y;
	}

	return Function_Continue;
}


function onSectionHit()
{
	if (!followChar && !mustHitSection)
		game.camFollow.setPosition(camPoint.x, camPoint.y);
}

function onEvent(n:String, v1:String)
{
	if (n == "Change Control")
		followChar = (v1 == "true");

	return Function_Continue;
}