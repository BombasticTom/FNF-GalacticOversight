package objects;

class SpriteTracker extends FlxSprite
{
	public var trackedSprite(default, null):FlxSprite;
	public var spriteExists(get, never):Bool;

	public function assignSprite(spr:FlxSprite)
	{
		trackedSprite = spr;

		setPosition(x, y);
		angle = angle;
		alpha = alpha;
		visible = visible;
	}

	public var angleAdd:Float = 0;
	public var alphaMult:Float = 1;

	public var copyAngle:Bool = true;
	public var copyAlpha:Bool = true;
	public var copyVisible:Bool = false;

	@:noCompletion
	public function get_spriteExists():Bool
	{
		return (trackedSprite != null);
	}

	override function set_x(value:Float):Float
	{
		if (spriteExists)
			trackedSprite.x = x - offset.x;
		return x = value;
	}

	override function set_y(value:Float):Float
	{
		if (spriteExists)
			trackedSprite.y = y - offset.y;
		return y = value;
	}

	override function set_angle(value:Float):Float
	{
		if (spriteExists && copyAngle)
			trackedSprite.angle = value + angleAdd;
		return angle = value;
	}
	
	override function set_alpha(Alpha:Float):Float
	{
		if (spriteExists && copyAlpha)
			trackedSprite.alpha = Alpha * alphaMult;
		return super.set_alpha(Alpha);
	}

	override function set_visible(Value:Bool):Bool
	{
		if (spriteExists && copyVisible)
			trackedSprite.visible = Value;
		return visible = Value;
	}

	override function update(elapsed:Float)
	{
		super.update(elapsed);

		if (spriteExists)
			scrollFactor.copyTo(trackedSprite.scrollFactor);
	}
}
