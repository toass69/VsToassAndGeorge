package;

import flixel.FlxSprite;
import flixel.math.FlxMath;

class HealthIcon extends FlxSprite
{
	/**
	 * Used for FreeplayState! If you use it elsewhere, prob gonna annoying
	 */
	public var sprTracker:FlxSprite;

	public function new(char:String = 'bf', isPlayer:Bool = false)
	{
		super();
		loadGraphic(Paths.image('iconGrid'), true, 150, 150);

		antialiasing = true;
		animation.add('bf', [0, 1], 0, false, isPlayer);
		animation.add('bf-pixel', [21, 21], 0, false, isPlayer);
		animation.add('face', [10, 11], 0, false, isPlayer);
		animation.add('dad', [12, 13], 0, false, isPlayer);
		animation.add('gf', [16], 0, false, isPlayer);
		animation.add('gorgeein', [17, 18], 0, false, isPlayer);
		animation.add('toass', [24, 25], 0, false, isPlayer);
		animation.add('REDACTOASS', [8, 9], 0, false, isPlayer);
		animation.add('toass-angry', [2, 3], 0, false, isPlayer);
		animation.add('marcello-toass', [4, 5], 0, false, isPlayer);
		animation.add('toass-3d-angey', [26, 27], 0, false, isPlayer);
		animation.add('george', [28, 29], 0, false, isPlayer);
		animation.add('george-player', [28, 29], 0, false, isPlayer);
		animation.add('the-duo', [32, 33], 0, false, isPlayer);
		animation.add('mr-toass', [34, 35], 0, false, isPlayer);
		animation.add('betatoass', [34, 35], 0, false, isPlayer);
		animation.add('toass-3d', [36, 37], 0, false, isPlayer);
		scrollFactor.set();

		changeIcon(char);
	}

	/**
	 * Swaps the icon to `char`'s animation. If `char` has no icon frame set up,
	 * falls back to the generic 'face' icon instead of throwing/crashing.
	 */
	public function changeIcon(char:String):Void
	{
		var hasIcon:Bool = char != null && animation.getByName(char) != null;
		var iconAnim:String = hasIcon ? char : 'face';

		animation.play(iconAnim);

		antialiasing = !(hasIcon
			&& (char == 'toass-3d-angey' || char == 'toass-3d' || char == 'toass-unfair' || char == 'senpai' || char == 'bf-pixel' || char == 'spirit' || char == 'senpai-angry'));
	}

	override function update(elapsed:Float)
	{
		super.update(elapsed);
		offset.set(Std.int(FlxMath.bound(width - 150,0)),Std.int(FlxMath.bound(height - 150,0)));


		if (sprTracker != null)
			setPosition(sprTracker.x + sprTracker.width + 10, sprTracker.y - 30);
	}
}
