package;

import flixel.addons.effects.chainable.FlxEffectSprite;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.animation.FlxBaseAnimation;
import flixel.graphics.frames.FlxAtlasFrames;

using StringTools;

class Character extends FlxSprite
{
	public var animOffsets:Map<String, Array<Dynamic>>;
	public var debugMode:Bool = false;

	public var isPlayer:Bool = false;
	public var curCharacter:String = 'bf';

	public var holdTimer:Float = 0;
	public var furiosityScale:Float = 1.02;
	public var canDance:Bool = true;

	public var nativelyPlayable:Bool = false;

	public var globaloffset:Array<Float> = [0,0];

	public function new(x:Float, y:Float, ?character:String = "bf", ?isPlayer:Bool = false)
	{
		super(x, y);

		animOffsets = new Map<String, Array<Dynamic>>();
		curCharacter = character;
		this.isPlayer = isPlayer;

		var tex:FlxAtlasFrames;
		antialiasing = true;

		switch (curCharacter)
		{
			case 'gf':
				// GIRLFRIEND CODE
				tex = Paths.getSparrowAtlas('characters/GF_assets');
				frames = tex;
				animation.addByPrefix('cheer', 'GF Cheer', 24, false);
				animation.addByPrefix('singLEFT', 'GF left note', 24, false);
				animation.addByPrefix('singRIGHT', 'GF Right Note', 24, false);
				animation.addByPrefix('singUP', 'GF Up Note', 24, false);
				animation.addByPrefix('singDOWN', 'GF Down Note', 24, false);
				animation.addByIndices('sad', 'gf sad', [0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12], "", 24, false);
				animation.addByIndices('danceLeft', 'GF Dancing Beat', [30, 0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14], "", 24, false);
				animation.addByIndices('danceRight', 'GF Dancing Beat', [15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29], "", 24, false);
				animation.addByIndices('hairBlow', "GF Dancing Beat Hair blowing", [0, 1, 2, 3], "", 24);
				animation.addByIndices('hairFall', "GF Dancing Beat Hair Landing", [0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11], "", 24, false);
				animation.addByPrefix('scared', 'GF FEAR', 24);

				addOffset('cheer');
				addOffset('sad', -2, -2);
				addOffset('danceLeft', 0, -9);
				addOffset('danceRight', 0, -9);

				addOffset("singUP", 0, 4);
				addOffset("singRIGHT", 0, -20);
				addOffset("singLEFT", 0, -19);
				addOffset("singDOWN", 0, -20);
				addOffset('hairBlow', 45, -8);
				addOffset('hairFall', 0, -9);

				addOffset('scared', -2, -17);

				playAnim('danceRight');

			case 'gf-pixel':
				tex = Paths.getSparrowAtlas('characters/gfPixel');
				frames = tex;
				animation.addByIndices('singUP', 'GF IDLE', [2], "", 24, false);
				animation.addByIndices('danceLeft', 'GF IDLE', [30, 0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14], "", 24, false);
				animation.addByIndices('danceRight', 'GF IDLE', [15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29], "", 24, false);

				if (!PlayState.curStage.startsWith('school'))
				{
					globaloffset[0] = -200;
					globaloffset[1] = -175;
				}
				
				addOffset('danceLeft', 0);
				addOffset('danceRight', 0);

				playAnim('danceRight');

				setGraphicSize(Std.int(width * PlayState.daPixelZoom));
				updateHitbox();
				antialiasing = false;

			case 'toass':
				// TOASS ANIMATION LOADING CODE (ported from toass.json)
				tex = Paths.getSparrowAtlas('characters/Toass');
				frames = tex;
				animation.addByPrefix('idle', 'idle', 24, false);
				animation.addByPrefix('singLEFT', 'left', 24, false);
				animation.addByPrefix('singDOWN', 'down', 24, false);
				animation.addByPrefix('singUP', 'up', 24, false);
				animation.addByPrefix('singRIGHT', 'right', 24, false);
				animation.addByPrefix('hey', 'like', 24, false);

				addOffset('idle', 0, 0);
				addOffset('singLEFT', 1, 3);
				addOffset('singDOWN', 10, -20);
				addOffset('singUP', 5, 25);
				addOffset('singRIGHT', -10, 4);
				addOffset('hey', 12, 4);

				setGraphicSize(Std.int(width * 1.3));
				updateHitbox();

				playAnim('idle');

			case 'betatoass':
				// TOASS ANIMATION LOADING CODE (ported from toass.json)
				tex = Paths.getSparrowAtlas('characters/toassassets');
				frames = tex;
                animation.addByPrefix('idle', 'MARCELLO idle dance', 24, false);
				animation.addByPrefix('singUP', 'MARCELLO NOTE UP0', 24, false);
				animation.addByPrefix('singLEFT', 'MARCELLO NOTE LEFT0', 24, false);
				animation.addByPrefix('singRIGHT', 'MARCELLO NOTE RIGHT0', 24, false);
				animation.addByPrefix('singDOWN', 'MARCELLO NOTE DOWN0', 24, false);

				addOffset('idle');
				addOffset("singUP", -16, 3);
				addOffset("singRIGHT", 0, -4);
				addOffset("singLEFT", -10, -2);
				addOffset("singDOWN", -10, -17);

				setGraphicSize(Std.int(width * 1));
				updateHitbox();

				playAnim('idle');

				flipX = true;

			case 'george-player':
				// TOASS ANIMATION LOADING CODE (ported from toass.json)
				tex = Paths.getSparrowAtlas('characters/George');
				frames = tex;
                animation.addByPrefix('idle', 'george idle', 12, false);
				animation.addByPrefix('singUP', 'george up', 12, false);
				animation.addByPrefix('singRIGHT', 'george right', 12, false);
				animation.addByPrefix('singLEFT', 'george left', 12, false);
				animation.addByPrefix('singDOWN', 'george down', 12, false);

				addOffset('idle');
				addOffset("singUP", 0, 0);
				addOffset("singRIGHT", 0, 0);
				addOffset("singLEFT", 0, 0);
				addOffset("singDOWN", 0, 0);

				setGraphicSize(Std.int(width * 1.4));
				updateHitbox();

				playAnim('idle');

				flipX = true;

			case 'george':
				// TOASS ANIMATION LOADING CODE (ported from toass.json)
				tex = Paths.getSparrowAtlas('characters/George');
				frames = tex;
                animation.addByPrefix('idle', 'george idle', 12, false);
				animation.addByPrefix('singUP', 'george up', 12, false);
				animation.addByPrefix('singRIGHT', 'george right', 12, false);
				animation.addByPrefix('singLEFT', 'george left', 12, false);
				animation.addByPrefix('singDOWN', 'george down', 12, false);

				addOffset('idle');
				addOffset("singUP", 0, 0);
				addOffset("singRIGHT", 0, 0);
				addOffset("singLEFT", 0, 0);
				addOffset("singDOWN", 0, 0);

				setGraphicSize(Std.int(width * 1.4));
				updateHitbox();

				playAnim('idle');

				flipX = true;

			case 'REDACTOASS':
				// TOASS ANIMATION LOADING CODE (ported from toass.json)
				tex = Paths.getSparrowAtlas('characters/REDACTOASS');
				frames = tex;
				animation.addByPrefix('idle', 'REDACTOASS Idle', 24, true);
				animation.addByPrefix('singLEFT', 'REDACTOASS Left', 24, false);
				animation.addByPrefix('singDOWN', 'REDACTOASS Down', 24, false);
				animation.addByPrefix('singUP', 'REDACTOASS Up', 24, false);
				animation.addByPrefix('singRIGHT', 'REDACTOASS Right', 24, false);

				addOffset('idle', -320, 0);
				addOffset('singLEFT', -320, 0);
				addOffset('singDOWN', -320, 0);
				addOffset('singUP', -320, 0);
				addOffset('singRIGHT', -320, 0);

				setGraphicSize(Std.int(width * 1.3));
				updateHitbox();
				antialiasing = false;

				playAnim('idle');

			case 'toass-3d-angey':
				// TOASS ANIMATION LOADING CODE (ported from toass.json)
				tex = Paths.getSparrowAtlas('characters/3dtoass');
				frames = tex;
				animation.addByPrefix('idle', 'idle', 24, false);
				animation.addByPrefix('singLEFT', 'left', 24, false);
				animation.addByPrefix('singDOWN', 'down', 24, false);
				animation.addByPrefix('singUP', 'up', 24, false);
				animation.addByPrefix('singRIGHT', 'right', 24, false);

				addOffset('idle', 0, 0);
				addOffset('singLEFT', 0, 0);
				addOffset('singDOWN', 0, 0);
				addOffset('singUP', 0, 0);
				addOffset('singRIGHT', 0, 0);

				setGraphicSize(Std.int(width * 1));
				updateHitbox();
				antialiasing = false;

				playAnim('idle');

			case 'marcello-toass':
				// TOASS ANIMATION LOADING CODE (ported from toass.json)
				tex = Paths.getSparrowAtlas('characters/BlueToass');
				frames = tex;
				animation.addByPrefix('idle', 'idle', 24, true);
				animation.addByPrefix('singLEFT', 'left', 24, false);
				animation.addByPrefix('singDOWN', 'down', 24, false);
				animation.addByPrefix('singUP', 'up', 24, false);
				animation.addByPrefix('singRIGHT', 'right', 24, false);

				addOffset('idle', 0, 0);
				addOffset('singLEFT', 68, 3);
				addOffset('singDOWN', 26, -20);
				addOffset('singUP', 5, 64);
				addOffset('singRIGHT', -10, 4);

				setGraphicSize(Std.int(width * 1.3));
				updateHitbox();

				playAnim('idle');

case 'toass-angry':
    // TOASS ANIMATION LOADING CODE (ported from toass.json)
    tex = Paths.getSparrowAtlas('characters/RedToass');
    frames = tex;
    animation.addByPrefix('idle', 'idle', 24, false);
    animation.addByPrefix('singLEFT', 'left', 24, false);
    animation.addByPrefix('singDOWN', 'down', 24, false);
    animation.addByPrefix('singUP', 'up', 24, false);
    animation.addByPrefix('singRIGHT', 'right', 24, false);
    animation.addByIndices('idle-loop', 'idle', [10, 11, 12, 13], "", 24, true);
    animation.addByIndices('singLEFT-loop', 'left', [10, 11, 12, 13], "", 24, true);
    animation.addByIndices('singDOWN-loop', 'down', [10, 11, 12, 13], "", 24, true);
    animation.addByIndices('singUP-loop', 'up', [10, 11, 12, 13], "", 24, true);
    animation.addByIndices('singRIGHT-loop', 'right', [10, 11, 12, 13], "", 24, true);

    addOffset('idle', 0, 0);
    addOffset('singLEFT', 4, 3);
    addOffset('singDOWN', -10, -20);
    addOffset('singUP', -8, 25);
    addOffset('singRIGHT', -4, 4);
    addOffset('idle-loop', 0, 0);
    addOffset('singLEFT-loop', 4, 3);
    addOffset('singDOWN-loop', -10, -20);
    addOffset('singUP-loop', -8, 25);
    addOffset('singRIGHT-loop', -4, 4);

    setGraphicSize(Std.int(width * 1.3));
    updateHitbox();

    playAnim('idle');

			case 'bf':
				var tex = Paths.getSparrowAtlas('characters/BOYFRIEND');
				frames = tex;
				animation.addByPrefix('idle', 'BF idle dance', 24, false);
				animation.addByPrefix('singUP', 'BF NOTE UP0', 24, false);
				animation.addByPrefix('singLEFT', 'BF NOTE LEFT0', 24, false);
				animation.addByPrefix('singRIGHT', 'BF NOTE RIGHT0', 24, false);
				animation.addByPrefix('singDOWN', 'BF NOTE DOWN0', 24, false);
				animation.addByPrefix('singUPmiss', 'BF NOTE UP MISS', 24, false);
				animation.addByPrefix('singLEFTmiss', 'BF NOTE LEFT MISS', 24, false);
				animation.addByPrefix('singRIGHTmiss', 'BF NOTE RIGHT MISS', 24, false);
				animation.addByPrefix('singDOWNmiss', 'BF NOTE DOWN MISS', 24, false);
				animation.addByPrefix('hey', 'BF HEY', 24, false);

				animation.addByPrefix('firstDeath', "BF dies", 24, false);
				animation.addByPrefix('deathLoop', "BF Dead Loop", 24, true);
				animation.addByPrefix('deathConfirm', "BF Dead confirm", 24, false);
				animation.addByPrefix('dodge', "boyfriend dodge", 24, false);
				animation.addByPrefix('scared', 'BF idle shaking', 24);
				animation.addByPrefix('hit', 'BF hit', 24, false);

				addOffset('idle', -5);
				addOffset("singUP", -29, 27);
				addOffset("singRIGHT", -38, -7);
				addOffset("singLEFT", 12, -6);
				addOffset("singDOWN", -10, -50);
				addOffset("singUPmiss", -29, 27);
				addOffset("singRIGHTmiss", -30, 21);
				addOffset("singLEFTmiss", 12, 24);
				addOffset("singDOWNmiss", -11, -19);
				addOffset("hey", 7, 4);
				addOffset('firstDeath', 37, 11);
				addOffset('deathLoop', 37, 5);
				addOffset('deathConfirm', 37, 69);
				addOffset('scared', -4);

				playAnim('idle');

				nativelyPlayable = true;

				flipX = true;
				
			case 'bf-pixel':
				frames = Paths.getSparrowAtlas('characters/bfPixel');
				animation.addByPrefix('idle', 'BF IDLE', 24, false);
				animation.addByPrefix('singUP', 'BF UP NOTE', 24, false);
				animation.addByPrefix('singLEFT', 'BF LEFT NOTE', 24, false);
				animation.addByPrefix('singRIGHT', 'BF RIGHT NOTE', 24, false);
				animation.addByPrefix('singDOWN', 'BF DOWN NOTE', 24, false);
				animation.addByPrefix('singUPmiss', 'BF UP MISS', 24, false);
				animation.addByPrefix('singLEFTmiss', 'BF LEFT MISS', 24, false);
				animation.addByPrefix('singRIGHTmiss', 'BF RIGHT MISS', 24, false);
				animation.addByPrefix('singDOWNmiss', 'BF DOWN MISS', 24, false);

				addOffset('idle');
				addOffset("singUP");
				addOffset("singRIGHT");
				addOffset("singLEFT");
				addOffset("singDOWN");
				addOffset("singUPmiss");
				addOffset("singRIGHTmiss");
				addOffset("singLEFTmiss");
				addOffset("singDOWNmiss");
				if (!PlayState.curStage.startsWith('school'))
				{
					globaloffset[0] = -200;
					globaloffset[1] = -175;
				}
				setGraphicSize(Std.int(width * 6));
				updateHitbox();

				playAnim('idle');

				width -= 100;
				height -= 100;

				antialiasing = false;

				nativelyPlayable = true;

				flipX = true;
				
			case 'bf-pixel-dead':
				frames = Paths.getSparrowAtlas('characters/bfPixelsDEAD');
				animation.addByPrefix('singUP', "BF Dies pixel", 24, false);
				animation.addByPrefix('firstDeath', "BF Dies pixel", 24, false);
				animation.addByPrefix('deathLoop', "Retry Loop", 24, true);
				animation.addByPrefix('deathConfirm', "RETRY CONFIRM", 24, false);
				animation.play('firstDeath');

				addOffset('firstDeath');
				addOffset('deathLoop', -37);
				addOffset('deathConfirm', -37);
				playAnim('firstDeath');
				// pixel bullshit
				setGraphicSize(Std.int(width * 6));
				updateHitbox();
				antialiasing = false;
				nativelyPlayable = true;
				flipX = true;
		}
		dance();

		if(isPlayer)
		{
			flipX = !flipX;
		}
	}

	override function update(elapsed:Float)
	{
		if (animation == null)
		{
			super.update(elapsed);
			return;
		}
		else if (animation.curAnim == null)
		{
			super.update(elapsed);
			return;
		}
		if (!nativelyPlayable && !isPlayer)
		{
			if (animation.curAnim.name.startsWith('sing'))
			{
				holdTimer += elapsed;
			}

			var dadVar:Float = 4;

			if (curCharacter == 'dad')
				dadVar = 6.1;
			if (holdTimer >= Conductor.stepCrochet * dadVar * 0.001)
			{
				dance();
				holdTimer = 0;
			}
		}

		switch (curCharacter)
		{
			case 'gf':
				if (animation.curAnim.name == 'hairFall' && animation.curAnim.finished)
					playAnim('danceRight');
		}

		super.update(elapsed);
	}

	private var danced:Bool = false;

	/**
	 * FOR GF DANCING SHIT
	 */
	public function dance()
	{
		if (!debugMode && canDance)
		{
			switch (curCharacter)
			{
				case 'gf' | 'gf-pixel':
					if (!animation.curAnim.name.startsWith('hair'))
					{
						danced = !danced;

						if (danced)
							playAnim('danceRight');
						else
							playAnim('danceLeft');
					}
				default:
					playAnim('idle');
			}
		}
	}

	public function playAnim(AnimName:String, Force:Bool = false, Reversed:Bool = false, Frame:Int = 0):Void
	{
		if (animation.getByName(AnimName) == null)
		{
			return; //why wasn't this a thing in the first place
		}
		if(AnimName.toLowerCase() == 'idle' && !canDance)
		{
			return;
		}
		animation.play(AnimName, Force, Reversed, Frame);
	
		var daOffset = animOffsets.get(AnimName);
		if (animOffsets.exists(AnimName))
		{
			if (isPlayer)
			{
				offset.set(daOffset[0] + globaloffset[0], daOffset[1] + globaloffset[1]);
			}
			else
			{
				offset.set(daOffset[0], daOffset[1]);
			}
		}
		else
			offset.set(0, 0);
	
		if (curCharacter == 'gf')
		{
			if (AnimName == 'singLEFT')
			{
				danced = true;
			}
			else if (AnimName == 'singRIGHT')
			{
				danced = false;
			}
	
			if (AnimName == 'singUP' || AnimName == 'singDOWN')
			{
				danced = !danced;
			}
		}
	}

	public function addOffset(name:String, x:Float = 0, y:Float = 0)
	{
		animOffsets[name] = [x, y];
	}
}