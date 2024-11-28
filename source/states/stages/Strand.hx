package states.stages;

class Strand extends BaseStage
{	
	override function create()
	{
		// Swagshit moneymoney

		var bg:BGSprite = new BGSprite('staticstrand/stage', -600, -200, 0.9, 0.9);
		add(bg);
	}

	override function sectionHit() {
		moveCamera(true);
	}

	override function destroy()
	{
		super.destroy();
	}
}