package states.stages;

import shaders.AdjustColor;

class AlsoBridgeIDK extends BaseStage
{
	var lighteffect:FlxSprite;
	var lighteffect2:FlxSprite; // NO FUCKING WAY THEY MADE A SEQUEL..

	var streetlight:FlxSprite;

	var bfShader:AdjustColor;
	var dadShader:AdjustColor;

	override function create()
	{
		var sky:FlxSprite = new FlxSprite(-640, -100, Paths.image("starshot/sky"));
		sky.color = sky.color.getDarkened(0.4);
		sky.scale.set(1.2, 1.2);
		sky.scrollFactor.set(0.6, 0.4);

		var fence:FlxSprite = new FlxSprite(-293, 361, Paths.image("starshot/fence"));
		fence.scale.set(1.25, 1.2);
		fence.scrollFactor.set(0.83, 0.83);

		var sidebuildings:FlxSprite = new FlxSprite(-640, -100, Paths.image("starshot/sidebuildings"));
		sidebuildings.scale.set(1.2, 1.2);
		sidebuildings.scrollFactor.set(0.9, 0.9);

		var ground:FlxSprite = new FlxSprite(-640, 634, Paths.image("starshot/ground"));
		ground.scale.set(1.2, 1.2);

		streetlight = new FlxSprite(-29, -29, Paths.image("starshot/streetlight"));
		streetlight.scale.set(1.2, 1.2);

		lighteffect = new FlxSprite(-740, 230, Paths.image("starshot/lighteffect"));
		lighteffect.x = streetlight.x - lighteffect.width * 0.71;
		lighteffect.scale.set(1.2, 1.2);

		lighteffect2 = new FlxSprite(344, 230, Paths.image("starshot/lighteffect"));
		lighteffect2.scale.set(1.2, 1.2);
		lighteffect2.flipX = true;

		bfShader = new AdjustColor();
		dadShader = new AdjustColor();

		add(sky);
		add(fence);
		add(sidebuildings);
		add(ground);
		add(streetlight);

		add(lighteffect);
		add(lighteffect2);

		coolLightEffect(false, true);

		super.create();
	}

	var activeLightTwn:FlxTween;
	var activeShaderTwn:FlxTween;

	var passiveLightTwn:FlxTween;
	var passiveShaderTwn:FlxTween;

	function coolTweens(activeLight:FlxSprite, activeShader:AdjustColor, passiveLight:FlxSprite, passiveShader:AdjustColor) {
		if (activeLightTwn != null)
		{
			activeLightTwn.cancel();
			activeShaderTwn.cancel();

			passiveLightTwn.cancel();
			passiveShaderTwn.cancel();
		}

		activeLightTwn = FlxTween.tween(activeLight, {alpha: 1}, 0.3, {ease: FlxEase.expoIn});
		activeShaderTwn = FlxTween.tween(activeShader, {hue: 12, saturation: 0, brightness: 0, contrast: 7}, 0.3, {ease: FlxEase.expoIn});

		passiveLightTwn = FlxTween.tween(passiveLight, {alpha: 0}, 1.2, {ease: FlxEase.bounceOut});
		passiveShaderTwn = FlxTween.tween(passiveShader, {hue: -10, saturation: -25, brightness: -30, contrast: 12}, 1.2, {ease: FlxEase.bounceOut});
	}

	var previousEffect:Bool;

	function coolLightEffect(isPlayer:Bool = false, forceEffect:Bool = false)
	{
		if (!forceEffect && previousEffect == isPlayer)
			return;

		if (isPlayer)
			coolTweens(lighteffect2, bfShader, lighteffect, dadShader);
		else
			coolTweens(lighteffect, dadShader, lighteffect2, bfShader);

		previousEffect = isPlayer;
	}

	override function createPost()
	{
		boyfriend.shader = bfShader.shader;
		dad.shader = dadShader.shader;

		super.createPost();
	}

	override function sectionHit()
	{
		coolLightEffect(mustHitSection);
		super.sectionHit();
	}
}