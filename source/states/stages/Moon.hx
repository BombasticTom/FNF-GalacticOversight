package states.stages;

import objects.Note;
import states.stages.objects.MoonObj;
import states.stages.objects.MoonStar;
import objects.AttachedSprite;

class Moon extends BaseStage
{
	// Basic variables we'll need to make cool effects.
	private var dadRotate:Float = 40;
	private var rotationRateMult:Float = 1.2;
	private var moonVelocityY:Float = 0;

	// Variables that contain objects.
	private var moon:MoonObj;
	private var rock:AttachedSprite;

	private var starParticles:Array<MoonStar> = [];
	private var frontParticles:FlxTypedGroup<MoonStar>;
	private var backParticles:FlxTypedGroup<MoonStar>;

	private var BF_Y:Float;

	// Adding new objects.
	override function create()
	{
		// Random generator for how many stars will appear in the background.
		var starCount:Int = FlxG.random.int(25, 40);

		// Limit to how many stars appear in the back
		var backLimit:Int = FlxG.random.int(10, 15);

		// Initializing a FlxTypedGroup for stars.

		frontParticles = new FlxTypedGroup<MoonStar>(starCount - backLimit);
		backParticles = new FlxTypedGroup<MoonStar>(backLimit);

		for (i in 0...starCount)
		{
			var inFront:Bool = !(i < backLimit);
			var particleGroup:FlxTypedGroup<MoonStar> = inFront ? frontParticles : backParticles;

			var x:Float = -1000 + ((FlxG.width + 1600) / starCount * i) + FlxG.random.float(-20, 20);
			var y:Float = FlxG.random.float(-250, FlxG.height + 200);

			var bounds:{x:Float, y:Float};

			if (inFront)
				bounds = {x: 0.25, y: 0.4};
			else
				bounds = {x: 0.1, y: 0.24};

			var star:MoonStar = new MoonStar(x, y);

			var starScale:Float = FlxG.random.float(bounds.x, bounds.y);
			star.scale.set(starScale, starScale);
			star.updatePosition();

			particleGroup.add(star);
			starParticles.push(star);
		}

		frontParticles.active = false;
		backParticles.active = false;

		var bg:FlxSprite = new FlxSprite(-920, -650, Paths.image("Moon/bgalt"));
		bg.scrollFactor.set(0.2, 0.2);
		bg.scale.set(1.7, 1.7);
		bg.updateHitbox();

		// Moon.
		moon = new MoonObj(FlxG.width - 300, 500, 0.2, 0.2);

		// Creating a rock on which bf is standing.
		rock = new AttachedSprite('Moon/BloodmoonPlatform');
		rock.copyAngle = false;
		rock.copyAlpha = false;

		// Adding sprites
		add(bg);
		add(backParticles);
		add(moon);
		add(frontParticles);
	}

	// Fixing layering issues.
	override function createPost()
	{
		rock.sprTracker = boyfriend;
		rock.xAdd = -boyfriend.width / 4 + 30;
		rock.yAdd = boyfriend.height - rock.height * .25;

		// Fix layering issues
		remove(dadGroup);
		addBehindBF(dadGroup);
		addBehindBF(rock);

		boyfriend.cameraPosition[1] = boyfriend.height * .2;
		BF_Y = boyfriend.y;

		#if STAGE
		game.cpuControlled = true;
		#end
	}

	// Camera zooms out in order to see the dad (Cynch in this case).
	override public function sectionHit()
	{
		defaultCamZoom = mustHitSection ? 0.85 : 0.7;
	}

	// A LOT OF MATH 💀

	var dadShiftX:Float = 0;
	var dadShiftY:Float = 0;

	var dadSimX:Float = 0;
	var dadSimY:Float = 0;

	final dadMoveVal:Float = 300;
	final shiftDecay:Int = 100;

	// Math stuff.
	override public function update(elapsed:Float)
	{
		// Dad shit

		var rotRateDad:Float = curDecStep / 9.5 * rotationRateMult;
		var moonDelta:Float = moonVelocityY * elapsed;

		dadShiftX += (0 - dadShiftX) / (shiftDecay);
		dadShiftY += (0 - dadShiftY) / (shiftDecay);

		dadSimX += (-150 - FlxMath.fastCos(rotRateDad) * dadRotate - dadSimX) / 12;
		dadSimY += (-FlxMath.fastSin(rotRateDad * 2) * dadRotate * 0.45 - dadSimY) / 12;

		game.dad.x += (dadSimX - dadShiftX - game.dad.x) * elapsed;
		game.dad.y += (dadSimY - dadShiftY - game.dad.y) * elapsed;

		// BF coords

		boyfriend.y += ((BF_Y - FlxMath.fastSin(curDecStep / 11.5) * 25 * rotationRateMult) - boyfriend.y) / 12;

		// Camera code

		game.moveCamera(!mustHitSection);
		// 	camFollow.setPosition(bfMidpoint.x - 120, bfMidpoint.y - 125);

		// Star code

		for (obj in starParticles)
		{
			if (!obj.alive)
				continue;

			obj.y += (moonDelta * (obj.scale.x / 0.45));
			
			if (obj.y >= FlxG.height + 270)
			{
				obj.setPosition(FlxG.random.float(-1000, FlxG.width + 1600), FlxG.random.float(-330, -370));
			}
		}
	}

	// Events which change some values (for cooler effects).
	override public function eventCalled(eventName:String, value1:String, value2:String, flValue1:Null<Float>, flValue2:Null<Float>, strumTime:Float)
	{
		switch (eventName)
		{
			case 'Change Bloodmoon Speed':
				FlxTween.num(moonVelocityY, flValue1, 1.55,
					{
						ease: FlxEase.expoOut,
						type: ONESHOT,
					},
					(num:Float) -> {moonVelocityY = num; moon.deltaVar=num;}
				);
			case 'Update Dad Rotation':
				FlxTween.num(dadRotate, flValue1, 1.55,
					{
						ease: FlxEase.backInOut,
						type: ONESHOT
					}, 
					(num:Float) -> {dadRotate = num;}
				);

				rotationRateMult = flValue2;
				if (Math.isNaN(rotationRateMult)) rotationRateMult = 1;
		}
	}

	override function opponentNoteHit(note:Note)
	{
		switch (note.noteData)
		{
			case 0:
				dadShiftX = dadMoveVal;
			case 1:
				dadShiftY = -dadMoveVal;
			case 2:
				dadShiftY = dadMoveVal;
			case 3:
				dadShiftX = -dadMoveVal;
		}
	}
}

/**
	OLD TRIG CODE

	dad.x += (-150 - FlxMath.fastCos(rotRateDad) * dadRotate - dad.x) / 12;
	dad.y += (-FlxMath.fastSin(rotRateDad * 2) * dadRotate * 0.45 - dad.y) / 12;
**/