package backend;

import flixel.system.FlxAssets;
import flixel.system.FlxAssets.FlxGraphicSource;
import openfl.display.BitmapDataChannel;
import openfl.geom.Point;
import openfl.geom.Rectangle;
import flixel.util.FlxGradient;
import flixel.graphics.FlxGraphic;
import openfl.display.BitmapData;

typedef TextPreset = {
	/**
	 * Name - Name of the preset we're using.
	 */
	var name:String;

	/**
	 * Gradient - The gradient colors.
	 */
	@:optional var gradient:Array<String>;

	/**
	 * Preset font - The text font this preset uses. Default is VCR OSD Mono.
	 */
	@:optional var font:String;

	/**
	 * Font Size - Default is 52.
	 */
	@:optional var fontSize:Int;

	/**
	 * Sprite scale - Default is 1/1.
	 */
	@:optional var scale:Array<Int>;
}

class GradientText
{
	public static final DEFAULT_PRESET:TextPreset = {name: "Default"};

	// A bit faster FlxSpriteUtil.alphaMask call
	private static function alphaMask(?source:BitmapData, ?mask:FlxGraphic):BitmapData
	{
		if (source == null || mask == null)
			return null;

		source.copyChannel(mask.bitmap, new Rectangle(0, 0, source.width, source.height), new Point(), BitmapDataChannel.ALPHA, BitmapDataChannel.ALPHA);
		mask.destroy();
		return source;
	}

	private static var gradientData:Map<String, String> = []; // A map that leads to bitmap keys of each text

	private static function generateGradient(txt:String, preset:TextPreset):FlxGraphic
	{
		var graphicBitmap:BitmapData;
		var graphicData:FlxGraphic;

		var _dummyTXT:FlxText = new FlxText();
		var font:String = (preset.font) ?? "BOOKUS.ttf";
		var size:Int = (preset.fontSize) ?? 52;
		var gradient:Array<String> = (preset.gradient) ?? ["#000000"];
		var colorData:Array<FlxColor> = gradient.map(color -> FlxColor.fromString(color)); // Convert String to FlxColor.

		// Custom bitmap key for our bitmap.
		var bmpKey:String;

		_dummyTXT.text = txt;
		_dummyTXT.setFormat(Paths.font(font), size);

		if (colorData.length > 1)
		{
			// Let's make sure there's more than one color.

			bmpKey = 'gosfp/$txt';

			_dummyTXT.drawFrame();

			graphicBitmap = FlxGradient.createGradientBitmapData(_dummyTXT.frameWidth, _dummyTXT.frameHeight, colorData, 1, 0);
			alphaMask(graphicBitmap, _dummyTXT.graphic);
		}
		else
		{
			// In case there's one color, it's just a simple render, to make it less redundant.

			_dummyTXT.color = colorData[0];
			_dummyTXT.drawFrame();

			graphicBitmap = _dummyTXT.graphic.bitmap;
			bmpKey = FlxG.bitmap.findKeyForBitmap(graphicBitmap);
		}

		graphicData = FlxG.bitmap.add(graphicBitmap, false, bmpKey);
		graphicData.persist = true;
		graphicData.destroyOnNoUse = false;
		gradientData.set(txt, bmpKey);

		Paths.currentTrackedAssets.set(bmpKey, graphicData);
		Paths.localTrackedAssets.push(bmpKey);

		_dummyTXT.destroy();

		return null;
	}

	public static function getGradient(txt:String, ?preset:TextPreset, overwrite:Bool = false):FlxGraphic
	{
		if (txt.length == 0)
		{
			trace("You haven't added any text DUMBASS");
			return null;
		}

		var graphicData:FlxGraphic;

		if (gradientData.exists(txt))
		{
			// Looks in the game's custom currentTrackedAssets pool
			graphicData = Paths.currentTrackedAssets.get(gradientData.get(txt));

			if (graphicData == null) {
				trace('Graphic data for $txt not found.. (possibly deleted) Generating new one.');
				gradientData.remove(txt);
			}
			else if (overwrite) {
				// Make sure to free memory when we're overwriting.
				gradientData.remove(txt);
				graphicData.destroy();
				graphicData = null;
			}
			else {
				return graphicData;
			}
		}

		if (preset == null)
		{
			preset = DEFAULT_PRESET;
			trace('Preset for $txt wasn\'t provided.. Resorting to default.');
		}

		return generateGradient(txt, preset);
	}
}