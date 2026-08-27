package;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.group.FlxSpriteGroup;
import flixel.math.FlxMath;
import flixel.math.FlxPoint;
import flixel.util.FlxTimer;

using StringTools;

enum Alignment
{
	LEFT;
	CENTERED;
	RIGHT;
}

class Alphabet extends FlxSpriteGroup
{
	public var delay:Float = 0.05;
	public var paused:Bool = false;

	// for menu shit
	public var targetY:Float = 0;
	public var isMenuItem:Bool = false;
	public var changeX:Bool = true;
	public var changeY:Bool = true;

	public var text:String = "";
	public var bold:Bool = false;

	public var distancePerItem:FlxPoint = new FlxPoint(20, 120);
	public var startPosition:FlxPoint = new FlxPoint(0, 0);

	public var SwitchXandY:Bool = false;
	public var widthOfWords:Float = FlxG.width;

	var _finalText:String = "";
	var yMulti:Float = 1;
	var lastSprite:AlphaCharacter;
	var xPosResetted:Bool = false;
	var lastWasSpace:Bool = false;
	var splitWords:Array<String> = [];
	var isBold:Bool = false;

	public var letters:Array<AlphaCharacter> = [];
	public var rows:Int = 0;
	private var rowWidths:Map<Int, Float> = new Map();
	public var alignment(default, set):Alignment = LEFT;

	public function new(x:Float, y:Float, text:String = "", ?bold:Bool = false, ?typed:Bool = false)
	{
		super(x, y);

		this.startPosition.x = x;
		this.startPosition.y = y;

		_finalText = text;
		this.text = text;
		isBold = bold;
		this.bold = bold;

		if (text != "")
		{
			if (typed)
				startTypedText();
			else
				addText();
		}
	}

	public function setAlignmentFromString(align:String)
	{
		switch (align.toLowerCase().trim())
		{
			case 'right':
				alignment = RIGHT;
			case 'center' | 'centered':
				alignment = CENTERED;
			default:
				alignment = LEFT;
		}
	}

	private function set_alignment(align:Alignment)
	{
		alignment = align;
		updateAlignment();
		return align;
	}

	private function updateAlignment()
	{
		for (letter in letters)
		{
			var rw:Float = rowWidths.exists(letter.row) ? rowWidths.get(letter.row) : 0;
			var newOffset:Float = switch (alignment)
			{
				case CENTERED: rw / 2;
				case RIGHT: rw;
				default: 0;
			};
			letter.offset.x -= letter.alignOffset;
			letter.alignOffset = newOffset * scale.x;
			letter.offset.x += letter.alignOffset;
		}
	}

	public function addText()
	{
		clearLetters();
		doSplitWords();

		var xPos:Float = 0;
		var curRow:Int = 0;
		lastSprite = null;
		lastWasSpace = false;

		for (character in splitWords)
		{
			// handle newline
			if (character == "\n")
			{
				rowWidths.set(curRow, xPos);
				yMulti += 1;
				xPosResetted = true;
				xPos = 0;
				curRow += 1;
				lastSprite = null;
				continue;
			}

			if (character == " " || character == "-")
			{
				lastWasSpace = true;
				continue;
			}

			if (!AlphaCharacter.allLetters.exists(character.toLowerCase()))
				continue;

			// spacing from last sprite
			if (lastSprite != null)
			{
				lastSprite.updateHitbox();
				xPos = lastSprite.x + lastSprite.width + 3;
			}
			else
			{
				xPos = xPosResetted ? 0 : xPos;
				xPosResetted = false;
			}

			if (lastWasSpace)
			{
				xPos += 40;
				lastWasSpace = false;
			}

			var letter:AlphaCharacter = new AlphaCharacter(xPos, 0);
			letter.row = curRow;
			letter.createCharacter(character, isBold);

			add(letter);
			letters.push(letter);
			lastSprite = letter;

			rowWidths.set(curRow, xPos + letter.width);
		}

		if (lastSprite != null)
			rowWidths.set(curRow, lastSprite.x + lastSprite.width);

		rows = curRow + 1;
		updateAlignment();
	}

	public function clearLetters()
	{
		var i:Int = letters.length;
		while (i > 0)
		{
			--i;
			var letter:AlphaCharacter = letters[i];
			if (letter != null)
			{
				letter.kill();
				letters.remove(letter);
				remove(letter);
			}
		}
		letters = [];
		rowWidths = new Map();
		rows = 0;
		yMulti = 1;
		lastSprite = null;
		lastWasSpace = false;
		xPosResetted = false;
	}

	function doSplitWords():Void
	{
		splitWords = _finalText.split("");
	}

	public var personTalking:String = 'gf';

	public function startTypedText():Void
	{
		_finalText = text;
		doSplitWords();

		var loopNum:Int = 0;
		var xPos:Float = 0;
		var curRow:Int = 0;

		lastSprite = null;
		lastWasSpace = false;
		xPosResetted = false;

		new FlxTimer().start(0.05, function(tmr:FlxTimer)
		{
			if (_finalText.fastCodeAt(loopNum) == "\n".code)
			{
				yMulti += 1;
				xPosResetted = true;
				xPos = 0;
				curRow += 1;
			}

			if (splitWords[loopNum] == " ")
				lastWasSpace = true;

			if (AlphaCharacter.allLetters.exists(splitWords[loopNum].toLowerCase()))
			{
				if (lastSprite != null && !xPosResetted)
				{
					lastSprite.updateHitbox();
					xPos += lastSprite.width + 3;
				}
				else
				{
					xPosResetted = false;
				}

				if (lastWasSpace)
				{
					xPos += 20;
					lastWasSpace = false;
				}

				var letter:AlphaCharacter = new AlphaCharacter(xPos, 55 * yMulti);
				letter.row = curRow;
				letter.createCharacter(splitWords[loopNum], isBold);

				if (FlxG.random.bool(40))
					FlxG.sound.play(Paths.soundRandom('GF_', 1, 4));

				add(letter);
				letters.push(letter);
				lastSprite = letter;
			}

			loopNum += 1;
			tmr.time = FlxG.random.float(0.04, 0.09);

		}, splitWords.length);
	}

	override function update(elapsed:Float)
	{
		if (isMenuItem)
		{
			if (SwitchXandY)
			{
				var scaledX = FlxMath.remapToRange(targetY, 0, 1, 0, 1.3);
				x = FlxMath.lerp(x, (scaledX * 120) + (text.length * 30), 0.16);
			}
			else
			{
				var scaledY = FlxMath.remapToRange(targetY, 0, 1, 0, 1.3);
				y = FlxMath.lerp(y, (scaledY * 120) + (FlxG.height * 0.48), 0.16);
				x = FlxMath.lerp(x, (targetY * 20) + 90, 0.16);
			}
		}

		super.update(elapsed);
	}

	public function snapToPosition()
	{
		if (isMenuItem)
		{
			if (changeX)
				x = (targetY * distancePerItem.x) + startPosition.x;
			if (changeY)
				y = (targetY * 1.3 * distancePerItem.y) + startPosition.y;
		}
	}
}

///////////////////////////////////////////
// ALPHABET LETTERS, SYMBOLS AND NUMBERS //
///////////////////////////////////////////

typedef Letter =
{
	?anim:Null<String>,
	?offsets:Array<Float>,
	?offsetsBold:Array<Float>
}

class AlphaCharacter extends FlxSprite
{
	public static var allLetters:Map<String, Null<Letter>>;

	// all allowed characters from Psych Engine
	private static var ALLOWED:String = "abcdefghijklmnopqrstuvwxyz0123456789áéíóúàèìòùâêîôûãëïõüäöåøæñçšžýÿß&()[]*+-<>'\"!?.❝❞_#$%:;@^,\\/|~¡¿{}•";

	// ── stub so Main.hx / TitleState.hx don't crash ──────────────────────────
	public static function loadAlphabetData(request:String = 'alphabet')
	{
		allLetters = new Map<String, Null<Letter>>();

		// 1. Register every allowed character
		for (i in 0...ALLOWED.length)
		{
			var char:String = ALLOWED.charAt(i);
			if (char == ' ')
				continue;
			allLetters.set(char.toLowerCase(), null);
		}

		// 2. Apply special animation names / offsets
		inline function setChar(char:String, ?anim:String, ?normal:Array<Float>, ?bold:Array<Float>)
		{
			var character:String = char.toLowerCase().substr(0, 1);
			if (allLetters.exists(character))
				allLetters.set(character, {anim: anim, offsets: normal, offsetsBold: bold});
		}

		setChar("ç", null, null, [0, -11]);
		setChar("&", null, null, [0, 2]);
		setChar("]", null, null, [0, -1]);
		setChar("*", null, [0, 28], [0, 40]);
		setChar("+", null, [0, 7], [0, 12]);
		setChar("-", null, [0, 16], [0, 16]);
		setChar("<", null, null, [0, -2]);
		setChar(">", null, null, [0, -2]);
		setChar("'", "apostrophe", [0, 32], [0, 40]);
		setChar("\"", "quote", [0, 32], [0, 40]);
		setChar("!", "exclamation");
		setChar("?", "question");
		setChar(".", "period");
		setChar("❝", "start quote", [0, 24], [0, 40]);
		setChar("❞", "end quote", [0, 24], [0, 40]);
		setChar(":", null, [0, 2], [0, 8]);
		setChar(";", null, [0, -2], [0, 4]);
		setChar("^", null, [0, 28], [0, 38]);
		setChar(",", "comma", [0, -6], [0, -4]);
		setChar("\\", "back slash");
		setChar("/", "forward slash");
		setChar("~", null, [0, 16], [0, 20]);
		setChar("¡", "inverted exclamation", [0, -20], [0, -20]);
		setChar("¿", "inverted question", [0, -20], [0, -20]);
		setChar("•", "bullet", [0, 18], [0, 20]);

		if (!allLetters.exists('?'))
			allLetters.set('?', {anim: 'question'});
	}
	// ─────────────────────────────────────────────────────────────────────────

	public var alignOffset:Float = 0;
	public var letterOffset:Array<Float> = [0, 0];
	public var row:Int = 0;
	public var rowWidth:Float = 0;
	public var character:String = '?';
	public var curLetter:Letter = null;

	public function new(x:Float, y:Float)
	{
		super(x, y);
		frames = Paths.getSparrowAtlas('alphabet');
		antialiasing = true;
	}

	public static function isTypeAlphabet(c:String):Bool
	{
		var ascii = StringTools.fastCodeAt(c, 0);
		return (ascii >= 65 && ascii <= 90)
			|| (ascii >= 97 && ascii <= 122)
			|| (ascii >= 192 && ascii <= 214)
			|| (ascii >= 216 && ascii <= 246)
			|| (ascii >= 248 && ascii <= 255);
	}

	public function createCharacter(char:String, bold:Bool)
	{
		this.character = char;
		curLetter = null;

		// reset letterOffset every time - THIS is what fixes the spacing bug!
		letterOffset = [0, 0];

		var lowercase:String = char.toLowerCase();
		if (allLetters.exists(lowercase))
			curLetter = allLetters.get(lowercase);
		else
			curLetter = allLetters.get('?');

		var postfix:String = '';
		if (!bold)
		{
			if (isTypeAlphabet(lowercase))
			{
				if (lowercase != char)
					postfix = ' uppercase';
				else
					postfix = ' lowercase';
			}
			else
				postfix = ' normal';
		}
		else
			postfix = ' bold';

		var alphaAnim:String = lowercase;
		if (curLetter != null && curLetter.anim != null)
			alphaAnim = curLetter.anim;

		var anim:String = alphaAnim + postfix;
		animation.addByPrefix(anim, anim, 24);
		animation.play(anim, true);

		if (animation.curAnim == null)
		{
			if (postfix != ' bold')
				postfix = ' normal';
			anim = 'question' + postfix;
			animation.addByPrefix(anim, anim, 24);
			animation.play(anim, true);
		}

		updateHitbox();
	}

	public function updateLetterOffset()
	{
		if (animation.curAnim == null)
		{
			trace(character);
			return;
		}

		// reset offset first to avoid recycling/reuse bugs
		letterOffset = [0, 0];

		var add:Float = 110;
		if (animation.curAnim.name.endsWith('bold'))
		{
			if (curLetter != null && curLetter.offsetsBold != null)
			{
				letterOffset[0] = curLetter.offsetsBold[0];
				letterOffset[1] = curLetter.offsetsBold[1];
			}
			add = 70;
		}
		else
		{
			if (curLetter != null && curLetter.offsets != null)
			{
				letterOffset[0] = curLetter.offsets[0];
				letterOffset[1] = curLetter.offsets[1];
			}
		}

		add *= scale.y;
		offset.x += letterOffset[0] * scale.x;
		offset.y += letterOffset[1] * scale.y - (add - height);
	}

	override public function updateHitbox()
	{
		super.updateHitbox();
		updateLetterOffset();
	}
}