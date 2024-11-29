package states;

import flixel.graphics.FlxGraphic;
import backend.GradientText;
import backend.GradientText.TextPreset;
import backend.Song;
import backend.Highscore;
import backend.WeekData;
import backend.StoryBookTemplate;

import flixel.addons.transition.TransitionData;

class FreeplayState extends StoryBookTemplate<SongMetadata>
{
	// To avoid errors lmao
	public static var vocals:FlxSound = null;
	public static function destroyFreeplayVocals() {}

	final UNKNOWN_GRAPHIC:FlxGraphic = Paths.image("freeplay/unknown");

	inline private function _updateSongLastDifficulty()
	{
		getCurrentLevel().lastDifficulty = Difficulty.getString(curSelectedDifficulty);
	}

	override function changeDiff(increment:Int = 0)
	{
		super.changeDiff(increment);
		_updateSongLastDifficulty();
	}

	override function changeLevel(increment:Int = 0)
	{
		_updateSongLastDifficulty();

		var lastList:Array<String> = Difficulty.list;

		super.changeLevel(increment);

		var song:SongMetadata = getCurrentLevel();

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

		iconName = Paths.formatToSongPath(song.songName);
		
		description.text = song.description;
		description.offset.y = description.height * .5;

		gradientText(song);
		resetTweenSequence();

		changeDiff();
	}

	public function addSong(songName:String, weekNum:Int, songCharacter:String, ?description:String):SongMetadata {
		var song = new SongMetadata(songName, weekNum, songCharacter, 0, description);
		levelsLoaded.push(song);
		return song;
	}

	private function gradientText(song:SongMetadata, ?preset:TextPreset)
	{
		if (song.playedSong)
		{
			var scale:Array<Int> = preset?.scale ?? [1, 1];

			var graphic = GradientText.getGradient(song.songName);
			songNameSprite.loadGraphic(graphic);
			
			songNameSprite.scale.set(scale[0], scale[1]);
		}
		else
			songNameSprite.loadGraphic(UNKNOWN_GRAPHIC);

		songNameSprite.updateHitbox();
		songNameSprite.offset.x = songNameSprite.frameWidth * .5;
		songNameSprite.offset.y = songNameSprite.frameHeight * .5;
	}

	override function onLevelSelected()
	{
		var songPath:String = Paths.formatToSongPath(getCurrentLevel().songName);
		var songFile:String = Highscore.formatSong(songPath, curSelectedDifficulty);
		trace(songFile);

		PlayState.SONG = Song.loadFromJson(songFile, songPath);
		PlayState.isStoryMode = false;
		PlayState.storyDifficulty = curSelectedDifficulty;

		trace('CURRENT WEEK: ' + WeekData.getWeekFileName());

		FlxG.sound.music.volume = 0;
		LoadingState.loadAndSwitchState(new PlayState());
	}

	override function reloadLevelData()
	{
		PlayState.isStoryMode = false;
		super.reloadLevelData();

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
				var songData = addSong(song[0], i, song[1], song[3]);
				Paths.image('freeplay/icons/${Paths.formatToSongPath(songData.songName)}');

				// If we didn't play the song yet we don't wanna generate a graphic for it
				// Cuz it's supposed to be unknown and it's up to the player to discover it
				// Smart optimization 😎

				if (songData.playedSong)
					GradientText.getGradient(songData.songName, presets.get(song[4]));
			}
		}
	}

	override function updateScoreData()
	{
		var songName:String = getCurrentLevel().songName;
		score = Highscore.getScore(songName, curSelectedDifficulty);
		accuracy = Highscore.getRating(songName, curSelectedDifficulty);
	}

	public function new(?TransIn:TransitionData, ?TransOut:TransitionData)
	{
		super("freeplay", TransIn, TransOut);
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

	public var playedSong:Bool;

	public function new(song:String, week:Int, songCharacter:String, color:Int, description = "")
	{
		this.songName = song;
		this.week = week;
		this.songCharacter = songCharacter;
		this.color = color;
		this.folder = Mods.currentModDirectory;
		this.description = description;

		playedSong = Highscore.hasPlayedSong(this);

		if(this.folder == null) this.folder = '';
	}
}