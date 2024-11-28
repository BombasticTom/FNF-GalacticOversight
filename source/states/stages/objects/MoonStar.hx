package states.stages.objects;

class MoonStar extends FlxSprite
{
	override public function new(x:Float, y:Float)
	{
		super(x, y);

		loadGraphic(Paths.image('Moon/star'));

		moves = false; // Setting this to false since there's already calculated movement inside of stages.objects.Moon.hx
		active = false;
	}

	public function updatePosition():Void
	{
		updateHitbox();

		var xFactor:Float = (0.325 - scale.x);
		scrollFactor.set(0.4 - xFactor, 0.6 - xFactor);
	}
}