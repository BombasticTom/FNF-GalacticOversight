import shaders.AdjustColor;

game.cpuControlled = true;
var stupidShader:AdjustColor = new AdjustColor();

function onCreatePost()
{
	game.dad.shader = stupidShader.shader;
	game.addCharacterToList("cynch-spooky", 1);
}

var coolTween1:FlxTween;
var coolTween2:FlxTween;

function doTheThing(charName:String)
{
	if (coolTween1 != null)
		coolTween1.cancel();
	if (coolTween2 != null)
		coolTween2.cancel();

	stupidShader.brightness = 0;

	coolTween2 = FlxTween.tween(stupidShader, {brightness: 0}, 1, {ease: FlxEase.sineOut});

	coolTween1 = FlxTween.tween(stupidShader, {brightness: 256}, 1, {ease: FlxEase.backIn,
		onComplete: (_) -> {
			var prevShader = game.dad.shader;
			game.dad.shader = null;

			game.triggerEvent("Change Character", "dad", charName);
			game.dad.shader = prevShader;
		}
	}).then(coolTween2);
}

function onUpdate()
{
	if (FlxG.keys.justPressed.P)
		doTheThing(game.dad.curCharacter == "cynch-new-shade" ? "cynch-spooky" : "cynch-new-shade");
}