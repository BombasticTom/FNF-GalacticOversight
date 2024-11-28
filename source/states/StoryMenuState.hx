package states;

import backend.Song;
import backend.Highscore;
import backend.WeekData;
import backend.StoryBookTemplate;

import flixel.addons.transition.TransitionData;

class StoryMenuState extends StoryBookTemplate<WeekData>
{
	public static var weekCompleted:Map<String, Bool> = new Map<String, Bool>();

	public function new(?TransIn:TransitionData, ?TransOut:TransitionData)
	{
		super("storymode", TransIn, TransOut);
	}

	override function create()
	{
		super.create();
		accTXT.text = "?";
	}

	override function changeLevel(increment:Int = 0)
	{
		super.changeLevel(increment);

		var week:WeekData = getCurrentLevel();
		var weekName:String = week.weekName.toLowerCase();

		WeekData.setDirectoryFromWeek(week);

		PlayState.storyWeek = curSelectedLevel;
		Difficulty.loadFromWeek();

		var defaultDiff:Int = Difficulty.defaultList.indexOf(Difficulty.getDefault());
		var defaultIDX:Int = Math.round(Math.max(0, defaultDiff));
		var newIDX:Int = Difficulty.list.indexOf(lastDifficultyName);

		curSelectedDifficulty = (newIDX > -1) ? newIDX : defaultIDX;

		iconName = weekName;
		
		description.text = week.storyName;
		description.offset.y = description.height * .5;

		songNameSprite.loadGraphic(Paths.image('storymenu/$weekName'));
		songNameSprite.scale.set(0.5, 0.5);
		songNameSprite.updateHitbox();
		songNameSprite.offset.x = songNameSprite.frameWidth * .5;
		songNameSprite.offset.y = songNameSprite.frameHeight * .5;

		resetTweenSequence();

		changeDiff();
	}

	override function onLevelSelected()
	{
		stunned = true;

		// We can't use Dynamic Array .copy() because that crashes HTML5, here's a workaround.

		var songArray:Array<String> = [];
		var leWeek:Array<Dynamic> = getCurrentLevel().songs;

		for (i in 0...leWeek.length) {
			songArray.push(leWeek[i][0]);
		}

		PlayState.storyPlaylist = songArray;
		PlayState.isStoryMode = true;

		var diffic = Difficulty.getFilePath(curSelectedDifficulty);
		if(diffic == null) diffic = '';

		PlayState.storyDifficulty = curSelectedDifficulty;

		PlayState.SONG = Song.loadFromJson(PlayState.storyPlaylist[0].toLowerCase() + diffic, PlayState.storyPlaylist[0].toLowerCase());
		PlayState.campaignScore = 0;
		PlayState.campaignMisses = 0;

		FlxG.sound.play(Paths.sound('confirmMenu'));

		new FlxTimer().start(1, function(tmr:FlxTimer)
		{
			LoadingState.loadAndSwitchState(new PlayState(), true);
			FreeplayState.destroyFreeplayVocals();
		});
	}

	override function reloadLevelData()
	{
		menuAssetFolder = "storymenu";

		PlayState.isStoryMode = true;
		super.reloadLevelData();

		for (i => weekName in WeekData.weeksList)
		{
			var weekFile:WeekData = WeekData.weeksLoaded.get(weekName);
			var isLocked:Bool = weekIsLocked(weekFile);

			if(!isLocked || !weekFile.hiddenUntilUnlocked)
			{
				levelsLoaded.push(weekFile);
			}
		}

		WeekData.setDirectoryFromWeek(getCurrentLevel());
	}

	override function updateScoreData()
	{
		score = Highscore.getWeekScore(getCurrentLevel().fileName, curSelectedDifficulty);
	}
}