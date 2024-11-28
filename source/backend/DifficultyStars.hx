package backend;

import objects.SpriteTracker;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.graphics.FlxGraphic;

enum StarType
{
	EMPTY;
	WHITE;
	BLUE;
	LIT;
}

class DifficultyStar extends SpriteTracker
{
	public var type(default, set):StarType;

	public function set_type(value:StarType):StarType
	{
		if (type == value)
			return value;

		alpha = 1;
		trackedSprite?.kill();

		switch (value)
		{
			case WHITE:
				animation.play("white");
			case BLUE:
				animation.play("blue");
			case LIT:
				animation.play("blue");
				trackedSprite?.revive();
				trackedSprite?.animation.play("start");
				FlxG.sound.play(Paths.sound("starIgnite"));
			default:
				animation.play("none");
				alpha = 0.5;
		}

		return type = value;
	}
}

class DifficultyStars extends FlxSpriteGroup
{
	public var stars:Array<DifficultyStar> = [];
	var flames:Array<FlxSprite> = [];

	static final flameOffset:FlxPoint = new FlxPoint(31, 120);

	static final distance:Float = 70;

	public function new(x:Float, y:Float, length:Int = 3)
	{
		Paths.sound("starIgnite");

		var starGraphic:FlxGraphic = Paths.image("freeplay/difficultyStar");
		var flameGraphic:FlxAtlasFrames = Paths.getSparrowAtlas("freeplay/freeplayFlame");

		var prevRandomFpsStart:Int = 0;
		var prevRandomFpsLoop:Int = 0;

		var halfLength:Float = (1 - length) / 2;

		super(x, y, length * 2);

		for (i in 0...length)
		{
			var randomFpsStart = FlxG.random.int(18, 30, [prevRandomFpsStart]);
			var randomFpsLoop = FlxG.random.int(22, 26, [prevRandomFpsLoop]);

			prevRandomFpsStart = randomFpsStart;
			prevRandomFpsLoop = randomFpsLoop;

			var star:DifficultyStar = new DifficultyStar(distance * (i + halfLength));
			star.loadGraphic(starGraphic, true);
			star.offset.x = star.width * .5;

			star.animation.add("white", [0], 0);
			star.animation.add("blue", [1], 0);
			star.animation.add("none", [2], 0);

			star.antialiasing = ClientPrefs.data.antialiasing;

			var flame:FlxSprite = new FlxSprite();
			flame.frames = flameGraphic;
			flame.animation.addByIndices("start", "fire loop full instance 1", [0, 1], "", randomFpsStart, false);
			flame.animation.addByIndices("loop", "fire loop full instance 1", [2, 3, 4, 5, 6, 7, 8, 9], "", randomFpsLoop, true);

			flame.antialiasing = ClientPrefs.data.antialiasing;

			flame.animation.finishCallback = (name:String) -> {
				if(name == "start")
					flame.animation.play("loop");
			}

			flameOffset.copyTo(flame.offset);
			star.assignSprite(flame);

			flames.push(flame);
			stars.push(star);

			add(flame);
			add(star);
		}
	}

	public function setStarOrder(?starOrder:Array<StarType>, ?max:Int)
	{
		max = max ?? starOrder.length;

		for (i => star in stars)
		{
			var prevType = star.type;
			var type = (starOrder == null || i > max) ? EMPTY : (starOrder[i] ?? EMPTY);
			
			star.type = type;

			if (prevType != type)
			{
				FlxTween.cancelTweensOf(star.scale);
				star.scale.set(2, 2);
				FlxTween.tween(star.scale, {x: 1, y: 1}, 0.25, {ease: FlxEase.quartOut});
			}
		}
	}
}