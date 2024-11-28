import psychlua.LuaUtils.getTweenEaseByString;

var zoomTwn:FlxTween;
var forceCamZoom:Bool = false;

function generateTween(data:{scale:Float, time:Float, ease:FlxEase, fixZoom:Bool}):FlxTween
{
	game.camZooming = false;
	forceCamZoom = true;

	return FlxTween.tween(FlxG.camera, {zoom: data.scale}, data.time, {
		ease: data.ease,
		onComplete: (twn:FlxTween) -> {
			forceCamZoom = !data.fixZoom;
		}
	});
}

function onEvent(n:String, v1:String, v2:String)
{
	if (n == "Camera Zoom")
	{
		var v1Split:Array<String> = StringTools.replace(v1, " ", "").split(",");

		if (zoomTwn != null)
			zoomTwn.cancel();

		zoomTwn = generateTween({
			scale: Std.parseFloat(v1Split[0]),
			time: Std.parseFloat(v1Split[1]),
			ease: getTweenEaseByString(v1Split[2]),
			fixZoom: (v2 == "true")
		});
	}
}

function opponentNoteHit(note:Note)
{
	if (forceCamZoom)
		game.camZooming = false;
}