var underlay:FlxSprite;
var midX:Float = 0;

function positionStrum(spr:StrumNote, pos:Float)
{
	spr.x = pos - spr.width / 2 + (160 * spr.scale.x * (spr.noteData - 1.5));
	spr.y -= 35;
}

function fixSF(spr:FlxSprite)
{
	spr.scrollFactor.set(0.6, 0.1);
}

function onCreatePost()
{
	midX = (game.boyfriend.getGraphicMidpoint().x + game.dad.getGraphicMidpoint().x) / 2;

	underlay = new FlxSprite(midX).makeGraphic(4.25 * 160 * 0.7, FlxG.height, FlxColor.BLACK);
	underlay.x -= underlay.width / 2;

	underlay.scale.y = 1 / game.defaultCamZoom;
	underlay.scrollFactor.set(0.6, 0);
	underlay.alpha = 0.3;
	underlay.kill();

	remove(game.noteGroup);
	game.noteGroup.camera = game.camGame;

	for (note in game.unspawnNotes)
	{
		if (!note.mustPress)
			note.visible = false;
		else
			fixSF(note);
	}

	for (strum in game.opponentStrums.members)
	{
		strum.active = false;
		strum.visible = false;
	}

	for (strum in game.playerStrums.members)
	{
		strum.camera = game.camGame;
		fixSF(strum);
		positionStrum(strum, midX);
	}

	// Fixes scroll on splashes
	for (splash in game.grpNoteSplashes)
		fixSF(splash);

	// In case a new splash gets added, we fix it's scroll too
	game.grpNoteSplashes.memberAdded.add((splash) -> {
		fixSF(splash);
	});

	insert(1, underlay);
	insert(game.members.length, game.noteGroup);
}

function onEvent(n:String)
{
	if (n == "Change Character")
		underlay.revive();

	return Function_Continue;
}