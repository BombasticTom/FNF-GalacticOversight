package states.stages.objects;

class MoonObj extends FlxSprite
{
	public var deltaVar:Float = 0;

	override public function new(x:Float, y:Float, scrollX:Null<Float>, scrollY:Null<Float>)
	{
		super(x, y);
		loadGraphic(Paths.image("Moon/moon"));

		scale.set(1.5, 1.5);
		scrollFactor.set(scrollX, scrollY);
		moves = false; // Setting this to false since there's already calculated movement inside of stages.objects.Moon.hx
	}

	override function update(elapsed:Float)
	{
		y += deltaVar * elapsed / 500;
		super.update(elapsed);
	}
}