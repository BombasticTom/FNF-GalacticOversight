package backend;

import cpp.Object;
import backend.GradientText.TextPreset;
import lime.utils.Assets;
import openfl.utils.Assets as OpenFlAssets;
import haxe.Json;

typedef WeekFile =
{
	// JSON variables
	var songs:Array<Dynamic>;
	var weekCharacters:Array<String>;
	var weekBackground:String;
	var weekBefore:String;
	var storyName:String;
	var weekName:String;
	var freeplayColor:Array<Int>;
	var startUnlocked:Bool;
	var hiddenUntilUnlocked:Bool;
	var hideStoryMode:Bool;
	var hideFreeplay:Bool;
	var difficulties:String;

	@:optional var presetData:Array<TextPreset>;
	@:optional var songPresets:Array<Array<String>>;
}

class WeekData {
	public static var weeksLoaded:Map<String, WeekData> = new Map<String, WeekData>();
	public static var weeksList:Array<String> = [];
	public var folder:String = '';
	
	// JSON variables
	public var songs:Array<Dynamic>;
	public var weekCharacters:Array<String>;
	public var weekBackground:String;
	public var weekBefore:String;
	public var storyName:String;
	public var weekName:String;
	public var freeplayColor:Array<Int>;
	public var startUnlocked:Bool;
	public var hiddenUntilUnlocked:Bool;
	public var hideStoryMode:Bool;
	public var hideFreeplay:Bool;
	public var difficulties:String;

	public var presetData:Array<TextPreset>;

	public var fileName:String;

	public static function createWeekFile():WeekFile {
		var weekFile:WeekFile = {
			songs: [["Bopeebo", "dad", [146, 113, 253]], ["Fresh", "dad", [146, 113, 253]], ["Dad Battle", "dad", [146, 113, 253]]],
			weekCharacters: ['dad', 'bf', 'gf'],
			weekBackground: 'stage',
			weekBefore: 'tutorial',
			storyName: 'Your New Week',
			weekName: 'Custom Week',
			freeplayColor: [146, 113, 253],
			startUnlocked: true,
			hiddenUntilUnlocked: false,
			hideStoryMode: false,
			hideFreeplay: false,
			difficulties: ''
		};
		return weekFile;
	}

	// HELP: Is there any way to convert a WeekFile to WeekData without having to put all variables there manually? I'm kind of a noob in haxe lmao
	public function new(weekFile:WeekFile, fileName:String) {
		// here ya go - MiguelItsOut
		for (field in Reflect.fields(weekFile))
			if(Reflect.fields(this).contains(field)) // Reflect.hasField() won't fucking work :/
				Reflect.setProperty(this, field, Reflect.getProperty(weekFile, field));

		this.presetData = weekFile.presetData;

		this.fileName = fileName;
	}

	public static function reloadWeekFiles(isStoryMode:Bool = false)
	{
		weeksList = [];
		weeksLoaded.clear();

		#if MODS_ALLOWED
		final base_directories:Array<String> = [Paths.mods(), Paths.getSharedPath()];
		var mod_directories:Array<String> = [for (mod in Mods.parseList().enabled) Paths.mods('$mod/')];
		var global_mods:Array<String> = [for (mod in Mods.getGlobalMods()) Paths.mods('$mod/')];
		#else
		final base_directories:Array<String> = [Paths.getSharedPath()];
		final mod_directories:Array<String> = [];
		final global_mods:Array<String> = [];
		#end

		// Prioritize mod folders over base game folders
		// Or if mods are disabled, just preview base folders
		var directories:Array<String> = mod_directories.concat(base_directories);

		// First check weeks in the shared list
		var sharedWeekList:Array<String> = CoolUtil.coolTextFile(Paths.getSharedPath('weeks/weekList.txt'));

		for (week in sharedWeekList)
		{
			for (directory in directories)
			{
				// Try to find if some mods have overwritten this week

				var path:String = '${directory}weeks/$week.json';
				var isModDirectory:Bool = !base_directories.contains(directory);
				var substrPrefix:String = #if MODS_ALLOWED isModDirectory ? Paths.mods() : #end "";

				// If it's not a global mod, don't overwrite anything!!
				if (isModDirectory && !global_mods.contains(directory))
					continue;

				// Check if the mod has an overwriten json
				if(FileSystem.exists(path))
				{
					addWeek(week, path, directory, substrPrefix);
					break;
				}
			}
		}

		for (directory in directories) {
			var directoryPath:String = '${directory}weeks/';

			if(!FileSystem.exists(directoryPath))
				continue;

			var isModDirectory:Bool = !base_directories.contains(directory);
			var substrPrefix:String = #if MODS_ALLOWED isModDirectory ? Paths.mods() : #end "";

			// A text file displaying all ordered weeks inside of one week directory (if provided)
			var listOfWeeks:Array<String> = CoolUtil.coolTextFile(directoryPath + 'weekList.txt');

			// Locate all files inside of weeks folder of our chosen directory
			var weekFiles:Array<String> = FileSystem.readDirectory(directoryPath);

			for (week in listOfWeeks)
			{
				if (weeksLoaded.exists(week))
					continue;

				var path:String = '$directoryPath$week.json';

				// Check if the mod has an overwriten json
				if(FileSystem.exists(path))
				{
					addWeek(week, path, directory, substrPrefix);
					weekFiles.remove('$week.json');
				}
			}

			// Lets sweep through weeks we have left off
			for (file in weekFiles)
			{
				if (!file.endsWith('.json'))
					continue;

				var fileName:String = file.substr(0, file.length - 5);
				var path:String = haxe.io.Path.join([directoryPath, file]);

				if (!FileSystem.isDirectory(path))
					addWeek(fileName, path, directory, substrPrefix);
			}
		}
	}

	private static function addWeek(weekToCheck:String, path:String, directory:String, substrPrefix:String = "")
	{
		if(weeksLoaded.exists(weekToCheck))
			return;

		var week:WeekFile = getWeekFile(path);

		if(week != null)
		{
			var weekFile:WeekData = new WeekData(week, weekToCheck);

			#if MODS_ALLOWED
			// Subtract path prefix to get the folder name
			if(substrPrefix.length > 0 && directory.startsWith(substrPrefix))
				weekFile.folder = directory.substr(substrPrefix.length);
			#end

			if((PlayState.isStoryMode && !weekFile.hideStoryMode) || (!PlayState.isStoryMode && !weekFile.hideFreeplay))
			{
				weeksLoaded.set(weekToCheck, weekFile);
				weeksList.push(weekToCheck);
			}
		}
	}

	private static function getWeekFile(path:String):WeekFile {
		var rawJson:String = null;
		#if MODS_ALLOWED
		if(FileSystem.exists(path)) {
			rawJson = File.getContent(path);
		}
		#else
		if(OpenFlAssets.exists(path)) {
			rawJson = Assets.getText(path);
		}
		#end

		if(rawJson != null && rawJson.length > 0) {
			return cast tjson.TJSON.parse(rawJson);
		}
		return null;
	}

	//   FUNCTIONS YOU WILL PROBABLY NEVER NEED TO USE

	//To use on PlayState.hx or Highscore stuff
	public static function getWeekFileName():String {
		return weeksList[PlayState.storyWeek];
	}

	//Used on LoadingState, nothing really too relevant
	public static function getCurrentWeek():WeekData {
		return weeksLoaded.get(weeksList[PlayState.storyWeek]);
	}

	public static function setDirectoryFromWeek(?data:WeekData = null) {
		Mods.currentModDirectory = '';
		if(data != null && data.folder != null && data.folder.length > 0) {
			Mods.currentModDirectory = data.folder;
		}
	}
}
