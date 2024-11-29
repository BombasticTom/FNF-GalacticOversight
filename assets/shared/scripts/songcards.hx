if (!ClientPrefs.data.songCards)
	return Function_Continue;

var graphic = Paths.image("songcards/" + songName);

if (graphic == null)
	return Function_Continue;

var img:FlxSprite = new FlxSprite(0, 0, graphic);

img.camera = game.camOther;

img.x -= img.width;
img.kill();
add(img);

function onSongStart()
{
	img.revive();

	FlxTween.tween(img, {x: 0}, 1, {
		ease: FlxEase.sineOut,
		onComplete: (_) ->
		{
			FlxTween.tween(img, {x: -img.width}, 1, {
				ease: FlxEase.cubeIn,
				startDelay: Conductor.crochet / 125,
				onComplete: (_) -> {
					remove(img);
					img.destroy();
				}
			});
		}
	});
}