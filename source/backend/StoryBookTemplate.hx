package backend;

import states.StoryMenuState;
import flixel.util.FlxStringUtil;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.graphics.FlxGraphic;
import backend.DifficultyStars.StarType;
import states.MainMenuState;

import flixel.addons.transition.TransitionData;

typedef CoordinateEntry = {
	?x:Float,
	?y:Float,
	?width:Float,
	?height:Float,
	?centerX:Float,
	?centerY:Float,
}

typedef StoryBookData = {
	var page1:CoordinateEntry;
	var page2:CoordinateEntry;
	var description:CoordinateEntry;
	var icon:CoordinateEntry;
}

typedef MenuSelection = {
	var curSelectedLevel:Int;
	var curSelectedDifficulty:Int;
	var lastDifficultyName:String;
}

class StoryBookTemplate<T> extends MusicBeatState
{
	public static var lastPresence:Map<String, MenuSelection> = [];
	private var presenceName:String;

	private var levelsLoaded:Array<T> = [];
	private var stunned:Bool = false;

	private var score:Float = 0;
	private var lerpScore:Float = 0;
	private var accuracy:Float = 0;
	private var lerpAccuracy:Float = 0;

	private var storyBook:FlxSprite;
	private var iconSprite:FlxSprite;
	private var songNameSprite:FlxSprite;
	private var scoreTXT:FlxText;
	private var accTXT:FlxText;
	private var description:FlxText;

	private var missingText:FlxText;
	private var missingTextBG:FlxSprite;

	private var menuAssetFolder:String = "freeplay";

	/**
		Current name of the icon that's used!
	**/
	private var iconName(default, set):String;
	private var iconTween:FlxTween;

	/**
		Size of the icon.
	**/
	private static final iconRatio:Float = 415;

	/**
		Coordinates data for the menu
	**/
	private final bookData:StoryBookData = {
		page1: calculateData(157, 68, 466, 584),
		page2: calculateData(640, 68, 488, 584),
		description: calculateData(157, 253, 466, 160),
		icon: calculateData(674, 156, iconRatio)
	}

	@:noCompletion
	private function set_iconName(value:String):String
	{
		getIconSprite();
	
		var graphic = Paths.image('$menuAssetFolder/icons/$value');

		// Null safety check
		if (graphic != null)
		{
			iconSprite.loadGraphic(graphic);
			iconSprite.setGraphicSize(iconRatio);
			iconSprite.updateHitbox();

			iconSprite.offset.set(iconSprite.frameWidth * .5, iconSprite.frameHeight * .5);

			iconSprite.alpha = 0;
			iconTween?.cancel();
			iconTween = FlxTween.tween(iconSprite, {alpha: 1}, 0.3, {ease: FlxEase.sineInOut});
		}

		return iconName = value;
	}

	/**
		Function that creates a new icon sprite if we didn't have
		an already existing one.
	**/
	private function getIconSprite():FlxSprite
	{
		if (iconSprite == null)
		{
			var point = bookData.icon;
			iconSprite = new FlxSprite(point.centerX, point.centerY);
			iconSprite.antialiasing = ClientPrefs.data.antialiasing;
		}

		return iconSprite;
	}

	/**
		Helper function to calculate important Menu positions.
	**/
	private static function calculateData(x:Float = 0, y:Float = 0, width:Float = 0, height:Float = 0):CoordinateEntry
	{
		if (width > 0 && height == 0)
			height = width;
		else if (height > 0 && width == 0)
			width = height;

		return {
			x: x,
			y: y,
			width: width,
			height: height,
			centerX: (x + width * .5),
			centerY: (y + height * .5)
		}
	}

	private function getDefaultPresence():MenuSelection {
		trace('Creating default presence for ... $presenceName');
		return {
			curSelectedLevel: curSelectedLevel,
			curSelectedDifficulty: curSelectedDifficulty,
			lastDifficultyName: Difficulty.getDefault()
		};
	}

	private function updatePresenceData(?update:Bool = true):MenuSelection
	{
		var presence:MenuSelection = lastPresence.get(presenceName) ?? getDefaultPresence();

		if (update)
		{
			presence.curSelectedLevel = curSelectedLevel;
			presence.curSelectedDifficulty = curSelectedDifficulty;
			presence.lastDifficultyName = lastDifficultyName;
		}

		lastPresence.set(presenceName, presence);
		return presence;
	}

	public function new(name:String, ?TransIn:TransitionData, ?TransOut:TransitionData)
	{
		presenceName = name;

		var presence = updatePresenceData(false);

		curSelectedLevel = presence.curSelectedLevel;
		curSelectedDifficulty = presence.curSelectedDifficulty;
		lastDifficultyName = presence.lastDifficultyName;

		super(TransIn, TransOut);
	}

	override function create()
	{
		trace("STATE RESET");

		// Save data
		final antialiasing:Bool = ClientPrefs.data.antialiasing;

		// Points shortcuts
		final p1Point = bookData.page1;
		final p2Point = bookData.page2;
		final descPoint = bookData.description;
		final iconPoint = bookData.icon;

		// Score text offsets based on already precalcuated values
		final txtWidth:Int = 73;
		final txtY:Int = 207;

		bgColor = FlxColor.WHITE;
		persistentUpdate = true;

		#if DISCORD_ALLOWED
		// Updating Discord Rich Presence
		DiscordClient.changePresence("In the Menus", null);
		#end

		reloadLevelData();

		Mods.loadTopMod();
		WeekData.setDirectoryFromWeek();

		songNameSprite = new FlxSprite(p1Point.centerX, p1Point.y + p1Point.height * .1);
		songNameSprite.antialiasing = antialiasing;

		difficultySprite = new DifficultyStars(p1Point.centerX, p1Point.y + p1Point.height * .75);

		var miniArrowGraphic:FlxGraphic = Paths.image("freeplay/miniArrow");
		var arrowFrames:FlxAtlasFrames = Paths.getSparrowAtlas("freeplay/freeplaySelector");
		
		var miniArrowX:Float = p2Point.centerX - miniArrowGraphic.height * .5;
		var bigArrowY:Float = difficultySprite.stars[0].y + difficultySprite.stars[0].height * .5;

		var miniArrowUp:FlxSprite = new FlxSprite(miniArrowX, iconPoint.y - miniArrowGraphic.width - 35, miniArrowGraphic);
		var miniArrowDown:FlxSprite = new FlxSprite(miniArrowX, iconPoint.y + iconPoint.height + 30, miniArrowGraphic);
		miniArrowUp.angle = -90;
		miniArrowDown.angle = 90;
		
		leftArrow = new FlxSprite(difficultySprite.stars[0].x - 50, bigArrowY);
		leftArrow.frames = arrowFrames;
		leftArrow.antialiasing = antialiasing;
		leftArrow.animation.addByPrefix("idle", "arrow pointer loop", 24, true);
		leftArrow.x -= leftArrow.width;
		leftArrow.y -= leftArrow.height * .5;
		leftArrow.animation.play("idle");

		rightArrow = new FlxSprite(difficultySprite.stars[difficultySprite.stars.length - 1].x + 50, bigArrowY);
		rightArrow.frames = arrowFrames;
		rightArrow.antialiasing = antialiasing;
		rightArrow.animation.addByPrefix("idle", "arrow pointer loop", 24, true, true);
		rightArrow.y -= rightArrow.height * .5;
		rightArrow.animation.play("idle");

		scoreTXT = new FlxText(p1Point.centerX - txtWidth, txtY, 100, "0");
		scoreTXT.setFormat(Paths.font("pixel.otf"), 14, FlxColor.WHITE, CENTER);
		scoreTXT.antialiasing = false;
		scoreTXT.x -= scoreTXT.fieldWidth * .5;
		scoreTXT.y -= scoreTXT.height * .5;
		
		accTXT = new FlxText(p1Point.centerX + txtWidth, txtY, 67, '0%');
		accTXT.setFormat(Paths.font("pixel.otf"), 14, 0xFFFFD700, CENTER);
		accTXT.antialiasing = false;
		accTXT.x -= accTXT.fieldWidth * .5;
		accTXT.y -= accTXT.height * .5;

		description = new FlxText(descPoint.centerX, descPoint.centerY, p1Point.width - 15);
		description.setFormat(Paths.font("FacultyGlyphic-Regular.ttf"), 18, FlxColor.WHITE, CENTER);
		description.x -= description.fieldWidth * .5;
		description.antialiasing = antialiasing;

		missingTextBG = new FlxSprite().makeGraphic(FlxG.width, FlxG.height, FlxColor.BLACK);
		missingTextBG.alpha = 0.6;
		
		missingText = new FlxText(50, 0, FlxG.width - 100, '', 24);
		missingText.setFormat(Paths.font("vcr.ttf"), 24, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		missingText.scrollFactor.set();
	
		storyBook = new FlxSprite(0, 0, Paths.image("freeplay/freeplaymenu"));

		changeLevel();
		changeDiff();

		add(getIconSprite());
		add(storyBook);

		add(songNameSprite);

		add(scoreTXT);
		add(accTXT);
		add(description);

		add(leftArrow);
		add(rightArrow);
		add(difficultySprite);

		add(miniArrowUp);
		add(miniArrowDown);

		add(missingTextBG);
		add(missingText);

		super.create();

		FlxG.sound.playMusic(Paths.music('library'));
	}

	private var leftArrow:FlxSprite;
	private var rightArrow:FlxSprite;

	private var curSelectedDifficulty:Int = 0;
	private var lastDifficultyName:String = Difficulty.getDefault();
	
	private var difficultySprite:DifficultyStars;
	private static final STAR_ORDER:Array<StarType> = [WHITE, BLUE, LIT];

	public function changeDiff(increment:Int = 0)
	{
		// There can be only 3 difficulties max
		var diffLimit:Int = Std.int(Math.min(3, Difficulty.list.length));

		if (diffLimit == 1)
		{
			leftArrow.kill();
			rightArrow.kill();
		}
		else
		{
			leftArrow.revive();
			rightArrow.revive();
		}

		curSelectedDifficulty = (curSelectedDifficulty + increment + diffLimit) % diffLimit;
		lastDifficultyName = Difficulty.getString(curSelectedDifficulty);

		#if !switch
		updateScoreData();
		#end

		difficultySprite.setStarOrder(STAR_ORDER, curSelectedDifficulty);

		// KILL 'EM ALL
		// Those who know: 🤓
		// Those who nose: 👃

		missingText.kill();
		missingTextBG.kill();
	}

	private var curSelectedLevel:Int = 0;

	private function getCurrentLevel():Null<T>
	{
		return levelsLoaded[curSelectedLevel];
	}

	public function changeLevel(increment:Int = 0)
	{
		if(increment != 0)
			FlxG.sound.play(Paths.sound('scrollMenu'), 0.4);

		curSelectedLevel = (curSelectedLevel + increment + levelsLoaded.length) % levelsLoaded.length;
	}

	var tweenSequence:FlxTween;
	var descriptionTween:FlxTween;

	private function resetTweenSequence():Void
	{
		tweenSequence?.cancel();
		descriptionTween?.cancel();

		songNameSprite.alpha = 0;
		description.alpha = 0;
		songNameSprite.y = bookData.page1.y + bookData.page1.height * .1 - 20;

		descriptionTween = FlxTween.tween(description, {alpha: 1}, 0.3, {ease: FlxEase.sineOut, startDelay: 0.1});
		tweenSequence = FlxTween.tween(songNameSprite, {alpha: 1, y: songNameSprite.y + 20}, 0.3, {ease:FlxEase.quartOut}).then(descriptionTween);
	}

	private function updateScoreData():Void
	{
		score = 0;
		accuracy = 0;
	}

	private function reloadLevelData():Void { WeekData.reloadWeekFiles(false); }

	private function onLevelSelected():Void { stunned = false; }

	private function weekIsLocked(week:WeekData):Bool {
		return (!week.startUnlocked && StoryMenuState.weekCompleted.get(week.weekBefore) == false);
	}

	override function update(elapsed:Float)
	{
		if (score != lerpScore)
		{
			lerpScore = FlxMath.lerp(score, lerpScore, Math.exp(-elapsed * 24));

			if (Math.abs(lerpScore - score) <= 10)
				lerpScore = score;

			scoreTXT.text = '${FlxStringUtil.formatMoney(Math.floor(lerpScore), false, false)}';
		}

		if (accuracy != lerpAccuracy)
		{
			lerpAccuracy = FlxMath.lerp(accuracy, lerpAccuracy, Math.exp(-elapsed * 12));

			if (Math.abs(lerpAccuracy - accuracy) <= 0.01)
				lerpAccuracy = accuracy;

			accTXT.text = '${Math.floor(lerpAccuracy * 100)}%';
		}

		if (!stunned)
		{
			if (controls.UI_UP_P)
				changeLevel(-1);
			if (controls.UI_DOWN_P)
				changeLevel(1);
			if (controls.UI_LEFT_P)
				changeDiff(-1);
			if (controls.UI_RIGHT_P)
				changeDiff(1);

			if (controls.BACK)
			{
				stunned = true;
				MusicBeatState.switchState(new MainMenuState());
				FlxG.sound.play(Paths.sound("cancelMenu"));
			}

			if (controls.ACCEPT)
			{
				stunned = true;
				persistentUpdate = false;

				try
				{
					onLevelSelected();
				}
				catch (e:Dynamic)
				{
					stunned = false;

					var errorStr:String = e.toString();

					if(errorStr.startsWith('[file_contents,assets/data/')) // Missing chart
						errorStr = 'Missing file: ' + errorStr.substring(34, errorStr.length - 1);

					trace('ERROR! $errorStr');

					missingText.text = 'ERROR WHILE LOADING CHART:\n$errorStr';
					missingText.screenCenter(Y);
					missingText.revive();
					missingTextBG.revive();

					FlxG.sound.play(Paths.sound('cancelMenu'));

					super.update(elapsed);
					return;
				}

				// destroyFreeplayVocals(); - MIGHT reuse later
			}
		}

		super.update(elapsed);
	}

	override function destroy()
	{
		updatePresenceData();
		bgColor = FlxColor.BLACK;
		super.destroy();

		FlxG.sound.playMusic(Paths.music('freakyMenu'));
	}
}