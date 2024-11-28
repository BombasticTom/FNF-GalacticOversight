package states;

import flixel.util.FlxStringUtil;
import backend.GradientText;
import backend.GradientText.TextPreset;
import flixel.graphics.frames.FlxAtlasFrames;
import backend.Song;
import backend.Highscore;
import backend.DifficultyStars;
import flixel.graphics.FlxGraphic;
import backend.WeekData;
import backend.StoryBookTemplate;

import openfl.utils.Assets as OpenFlAssets;

// TODO: Move into own class for modularity

class FreeplayState extends StoryBookTemplate
{
	var stunned:Bool = false;

	var songNameSprite:FlxSprite;

	var difficultySprite:DifficultyStars;

	var scoreTXT:FlxText;
	var accTXT:FlxText;
	var description:FlxText; // Song description

	var missingText:FlxText;
	var missingTextBG:FlxSprite;

	var songs:Array<SongMetadata> = [];

	var score:Float = 0;
	var lerpScore:Float = 0;
	var accuracy:Float = 0;
	var lerpAccuracy:Float = 0;

	// To avoid errors lmao

	public static var vocals:FlxSound = null;
	public static function destroyFreeplayVocals() {}

	static var curSelectedDifficulty:Int = 0;
	static var lastDifficultyName:String = Difficulty.getDefault();
	static final STAR_ORDER:Array<StarType> = [WHITE, BLUE, LIT];

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
		score = Highscore.getScore(songs[curSelectedSong].songName, curSelectedDifficulty);
		accuracy = Highscore.getRating(songs[curSelectedSong].songName, curSelectedDifficulty);
		#end

		difficultySprite.setStarOrder(STAR_ORDER, curSelectedDifficulty);

		// KILL 'EM ALL
		// Those who know: 🤓
		// Those who nose: 👃

		missingText.kill();
		missingTextBG.kill();

		_updateSongLastDifficulty();
	}

	inline private function _updateSongLastDifficulty()
	{
		songs[curSelectedSong].lastDifficulty = Difficulty.getString(curSelectedDifficulty);
	}

	static var curSelectedSong:Int = 0;

	public function changeSong(increment:Int = 0)
	{
		_updateSongLastDifficulty();

		if(increment != 0)
			FlxG.sound.play(Paths.sound('scrollMenu'), 0.4);

		var lastList:Array<String> = Difficulty.list;

		curSelectedSong = (curSelectedSong + increment + songs.length) % songs.length;

		var song:SongMetadata = songs[curSelectedSong];

		iconName = Paths.formatToSongPath(song.songName);
		
		description.text = song.description;
		description.offset.y = description.height * .5;

		Mods.currentModDirectory = song.folder;
		PlayState.storyWeek = song.week;
		Difficulty.loadFromWeek();

		var savedDiff:String = song.lastDifficulty;
		var defaultDiff:String = Difficulty.getDefault();

		var savedIDX:Int = Difficulty.list.indexOf(savedDiff);
		var lastIDX:Int = Difficulty.list.indexOf(lastDifficultyName);		
		var defaultIDX:Int = Difficulty.list.indexOf(defaultDiff);

		if(savedIDX > -1 && !lastList.contains(savedDiff))
			curSelectedDifficulty = savedIDX;
		else if (lastIDX > -1)
			curSelectedDifficulty = lastIDX;
		else if (defaultIDX > - 1 && Difficulty.list.contains(defaultDiff))
			curSelectedDifficulty = defaultIDX;
		else
			curSelectedDifficulty = 0;

		gradientText(song.songName);
		resetTweenSequence();

		changeDiff();
	}

	public function addSong(songName:String, weekNum:Int, songCharacter:String, ?description:String) {
		songs.push(new SongMetadata(songName, weekNum, songCharacter, 0, description));
	}

	private function weekIsLocked(week:WeekData):Bool {
		return (!week.startUnlocked && StoryMenuState.weekCompleted.get(week.weekBefore) == false);
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

	var leftArrow:FlxSprite;
	var rightArrow:FlxSprite;

	override function create()
	{
		persistentUpdate = true;

		PlayState.isStoryMode = false;
		WeekData.reloadWeekFiles(false);

		#if DISCORD_ALLOWED
		// Updating Discord Rich Presence
		DiscordClient.changePresence("In the Menus", null);
		#end

		trace("STATE RESET");

		for (i => weekName in WeekData.weeksList)
		{
			var week:WeekData = WeekData.weeksLoaded.get(weekName);

			if (weekIsLocked(week))
				continue;

			WeekData.setDirectoryFromWeek(week);

			var presets:Map<String, TextPreset> = [];

			for (preset in (week.presetData ?? []))
				presets.set(preset.name, preset);

			for (song in week.songs)
			{
				addSong(song[0], i, song[1], song[3]);
				Paths.image('freeplay/icons/${Paths.formatToSongPath(song[0])}');
				GradientText.getGradient(song[0], presets.get(song[4]));
			}
		}

		Mods.loadTopMod();
		WeekData.setDirectoryFromWeek();

		var antialiasing:Bool = ClientPrefs.data.antialiasing;

		var p1Point = bookData.page1;
		var p2Point = bookData.page2;
		var descPoint = bookData.description;
		var iconPoint = bookData.icon;

		songNameSprite = new FlxSprite(p1Point.centerX, p1Point.y + p1Point.height * .1);
		songNameSprite.antialiasing = antialiasing;

		difficultySprite = new DifficultyStars(p1Point.centerX, p1Point.y + p1Point.height * .75);

		var miniArrowGraphic:FlxGraphic = Paths.image("freeplay/miniArrow");
		var miniArrowX:Float = p2Point.centerX - miniArrowGraphic.height * .5;
		var miniArrowUp:FlxSprite = new FlxSprite(miniArrowX, iconPoint.y - miniArrowGraphic.width - 35, miniArrowGraphic);
		var miniArrowDown:FlxSprite = new FlxSprite(miniArrowX, iconPoint.y + iconPoint.height + 30, miniArrowGraphic);
		miniArrowUp.angle = -90;
		miniArrowDown.angle = 90;

		var arrowFrames:FlxAtlasFrames = Paths.getSparrowAtlas("freeplay/freeplaySelector");
		var arrowY:Float = difficultySprite.stars[0].y + difficultySprite.stars[0].height * .5;
		
		leftArrow = new FlxSprite(difficultySprite.stars[0].x - 50, arrowY);
		leftArrow.frames = arrowFrames;
		leftArrow.antialiasing = antialiasing;
		leftArrow.animation.addByPrefix("idle", "arrow pointer loop", 24, true);
		leftArrow.x -= leftArrow.width;
		leftArrow.y -= leftArrow.height * .5;
		leftArrow.animation.play("idle");

		rightArrow = new FlxSprite(difficultySprite.stars[difficultySprite.stars.length - 1].x + 50, arrowY);
		rightArrow.frames = arrowFrames;
		rightArrow.antialiasing = antialiasing;
		rightArrow.animation.addByPrefix("idle", "arrow pointer loop", 24, true, true);
		rightArrow.y -= rightArrow.height * .5;
		rightArrow.animation.play("idle");

		var txtWidth:Int = 73; // Text offset based on width of black rectangle (292 / 4)
		var txtY:Int = 207;

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
	
		changeSong();
		changeDiff();

		super.create();

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
	}

	private function gradientText(txt:String, ?preset:TextPreset)
	{
		var scale:Array<Int> = preset?.scale ?? [1, 1];

		var graphic = GradientText.getGradient(txt);
		songNameSprite.loadGraphic(graphic);
		
		songNameSprite.scale.set(scale[0], scale[1]);
		songNameSprite.updateHitbox();
		songNameSprite.offset.x = songNameSprite.frameWidth * .5;
		songNameSprite.offset.y = songNameSprite.frameHeight * .5;
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
				changeSong(-1);
			if (controls.UI_DOWN_P)
				changeSong(1);
			if (controls.UI_LEFT_P)
				changeDiff(-1);
			if (controls.UI_RIGHT_P)
				changeDiff(1);

			if (FlxG.keys.justPressed.R)
			{
				stunned = true;
				MusicBeatState.resetState();
			}

			if (controls.ACCEPT)
			{
				stunned = true;

				persistentUpdate = false;
				var songPath:String = Paths.formatToSongPath(songs[curSelectedSong].songName);
				var songFile:String = Highscore.formatSong(songPath, curSelectedDifficulty);
				trace(songFile);

				try
				{
					PlayState.SONG = Song.loadFromJson(songFile, songPath);
					PlayState.isStoryMode = false;
					PlayState.storyDifficulty = curSelectedDifficulty;

					trace('CURRENT WEEK: ' + WeekData.getWeekFileName());
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

				LoadingState.loadAndSwitchState(new PlayState());

				FlxG.sound.music.volume = 0;
						
				// destroyFreeplayVocals(); - MIGHT reuse later
			}
		}

		super.update(elapsed);
	}

	override function destroy()
	{
		super.destroy();
	}
}

class SongMetadata
{
	public var songName:String = "";
	public var week:Int = 0;
	public var songCharacter:String = "";
	public var color:Int = -7179779;
	public var folder:String = "";
	public var lastDifficulty:String = null;
	public var description:String = "";

	public function new(song:String, week:Int, songCharacter:String, color:Int, description = "")
	{
		this.songName = song;
		this.week = week;
		this.songCharacter = songCharacter;
		this.color = color;
		this.folder = Mods.currentModDirectory;
		this.description = description;

		if(this.folder == null) this.folder = '';
	}
}