// GET A LOAD OF THIS!

import openfl.filters.ColorMatrixFilter;

// idx 6 - gamma
// idx 9 - brightness

var filterMatrix:Array<Float> = [
	1, 0, 0, 0, 0,
	0, 1, 0, 0, 0,
	0, 0, 1, 0, 0,
	0, 0, 0, 1, 0
];

var filter:ColorMatrixFilter = new ColorMatrixFilter(filterMatrix);

function updateFilter(r:Float, g:Float, b:Float, ?a:Float, ?brightness:Float)
{
	a = a ?? 1;
	brightness = brightness ?? 0;

	var matrix:Array<Float> = filter.matrix;

	matrix[0] = r;
	matrix[6] = g;
	matrix[9] = brightness;
	matrix[12] = b;
	matrix[18] = a;
}

updateFilter(1, 1, 1);
game.camGame.filters = [filter];

function onEvent(n:String, v1:String)
{
	if (n == "E-102 Gamma")
	{
		var rgb:Array<String> = v1.split(',');

		var r:Float = Std.parseFloat(rgb[0] ?? "1");
		var g:Float = Std.parseFloat(rgb[1] ?? "1");
		var b:Float = Std.parseFloat(rgb[2] ?? "1");

		updateFilter(r, g, b);
		FlxG.camera.flash(FlxColor.LIME, 0.7);
	}
}