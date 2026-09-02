package;

import flixel.util.FlxTimer;
import flixel.tweens.FlxEase;
import flash.text.TextField;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.addons.display.FlxGridOverlay;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.math.FlxMath;
import flixel.text.FlxText;
import flixel.util.FlxColor;
import flixel.tweens.FlxTween;
import flixel.util.FlxStringUtil;
import lime.utils.Assets;
#if desktop
import Discord.DiscordClient;
#end
using StringTools;

class FreeplayState extends MusicBeatState
{
	var songs:Array<SongMetadata> = [];

	var selector:FlxText;
	var curSelected:Int = 0;
	var curDifficulty:Int = 1;

	var bg:FlxSprite = new FlxSprite().loadGraphic(Paths.image('backgrounds/SUSSUS AMOGUS'));

	var scoreText:FlxText;
	var diffText:FlxText;
	var lerpScore:Int = 0;
	var intendedScore:Int = 0;

	private var grpSongs:FlxTypedGroup<Alphabet>;
	private var curPlaying:Bool = false;
	private var curChar:String = "unknown";

	private var InMainFreeplayState:Bool = false;

	private var CurrentSongIcon:FlxSprite;

	private var AllPossibleSongs:Array<String> = ["Toass","Joke","Extra"];

	private var CurrentPack:Int = 0;

	private var packColors:Array<FlxColor> = [
		0xFF9300FF, // Toass
		0xFF008CFF, // Joke
		0xFFFF0000, // Extra
	];

	var loadingPack:Bool = false;

	var songColors:Array<FlxColor> = [
        0xFFca1f6f, // GF
        0xFFc885e5, // DAD
        0xFFf9a326, // SPOOKY
        0xFFceec75, // PICO
        0xFFec7aac, // MOM
        0xFFffffff, // PARENTS-CHRISTMAS
        0xFFffaa6f, // SENPAI
		0xFF7F00FF, // TOASS
		0xFFFF0000, // GEORGE
		0xFF00FFFF, //SPLIT THE THONNNNN
		0xFF9966FF // JOKE


    ];

	private var iconArray:Array<HealthIcon> = [];

	override function create()
	{

		/* 
			if (FlxG.sound.music != null)
			{
				if (!FlxG.sound.music.playing)
					FlxG.sound.playMusic(Paths.music('freakyMenu'));
			}
		 */
		#if desktop
		DiscordClient.changePresence("In the Freeplay Menu", null);
		#end
		
		var isDebug:Bool = false;

		#if debug
		isDebug = true;
		#end



		// LOAD MUSIC

		// LOAD CHARACTERS

		bg.loadGraphic(MainMenuState.randomizeBG());
		bg.color = packColors[CurrentPack];
		add(bg);

		CurrentSongIcon = new FlxSprite(0,0).loadGraphic(Paths.image('week_icons_' + (AllPossibleSongs[CurrentPack].toLowerCase())));

		CurrentSongIcon.centerOffsets(false);
		CurrentSongIcon.x = (FlxG.width / 2) - (CurrentSongIcon.width / 2);
		CurrentSongIcon.y = (FlxG.height / 2) - (CurrentSongIcon.height / 2);
		CurrentSongIcon.antialiasing = true;

		Highscore.load();

		add(CurrentSongIcon);

		super.create();
	}

	public function LoadProperPack()
	{
		if (AllPossibleSongs[CurrentPack].toLowerCase() == 'toass')
		{
			addWeek(['Toass', 'Persistence Of Cosmos', 'Suppression'], 7, ['toass', 'toass', 'toass-3d-angey']);
			addWeek(['Bailing','Cader','Hills',], 8, ['george']);
			addWeek(['Splitathon'],9,['the-duo']);
		}
		else if (AllPossibleSongs[CurrentPack].toLowerCase() == 'joke')
		{
			addWeek(['Daybreak', 'Singing-Birds'], 10, ['mr-toass']);
			if (FlxG.save.data.cheatingFound)
			{
				addWeek(['Cheating'], 10, ['bambi-3d']);
			}
		}
		else if (AllPossibleSongs[CurrentPack].toLowerCase() == 'extra')
		{
			addWeek(['8 28 63'], 8, ['george']);
            addWeek(['Old Toass'], 7, ['toass']);
            addWeek(['Thunderstorm'], 7, ['toass']);
            addWeek(['Old Times'], 7, ['toass']);
			if (FlxG.save.data.doneForeverFound)
			{
				addWeek(['Done Forever'], 7, ['REDACTOASS']);
			}
		}
	}


	public function GoToActualFreeplay()
	{
		grpSongs = new FlxTypedGroup<Alphabet>();
		add(grpSongs);

		for (i in 0...songs.length)
		{
			var songText:Alphabet = new Alphabet(0, (70 * i) + 30, songs[i].songName, true, false);
			songText.isMenuItem = true;
			songText.targetY = i;
			grpSongs.add(songText);

			var icon:HealthIcon = new HealthIcon(songs[i].songCharacter);
			icon.sprTracker = songText;

			// using a FlxGroup is too much fuss!
			iconArray.push(icon);
			add(icon);

			// songText.x += 40;
			// DONT PUT X IN THE FIRST PARAMETER OF new ALPHABET() !!
			// songText.screenCenter(X);
		}

		scoreText = new FlxText(FlxG.width * 0.7, 5, 0, "", 32);
		// scoreText.autoSize = false;
		scoreText.setFormat(Paths.font("vcr.ttf"), 32, FlxColor.WHITE, RIGHT);
		// scoreText.alignment = RIGHT;

		var scoreBG:FlxSprite = new FlxSprite(scoreText.x - 6, 0).makeGraphic(Std.int(FlxG.width * 0.35), 66, 0xFF000000);
		scoreBG.alpha = 0.6;
		add(scoreBG);

		diffText = new FlxText(scoreText.x, scoreText.y + 36, 0, "", 24);
		diffText.font = scoreText.font;
		add(diffText);

		add(scoreText);

		changeSelection();
		changeDiff();

		// FlxG.sound.playMusic(Paths.music('title'), 0);
		// FlxG.sound.music.fadeIn(2, 0, 0.8);
		selector = new FlxText();

		selector.size = 40;
		selector.text = ">";
		// add(selector);

		var swag:Alphabet = new Alphabet(1, 0, "swag");

		// JUST DOIN THIS SHIT FOR TESTING!!!
		/* 
			var md:String = Markdown.markdownToHtml(Assets.getText('CHANGELOG.md'));

			var texFel:TextField = new TextField();
			texFel.width = FlxG.width;
			texFel.height = FlxG.height;
			// texFel.
			texFel.htmlText = md;

			FlxG.stage.addChild(texFel);

			// scoreText.textField.htmlText = md;

			trace(md);
		 */
	}

	public function addSong(songName:String, weekNum:Int, songCharacter:String)
	{
		songs.push(new SongMetadata(songName, weekNum, songCharacter));
	}

	public function UpdatePackSelection(change:Int)
	{
		CurrentPack += change;
		if (CurrentPack == -1)
		{
			CurrentPack = AllPossibleSongs.length - 1;
		}
		if (CurrentPack == AllPossibleSongs.length)
		{
			CurrentPack = 0;
		}
		CurrentSongIcon.loadGraphic(Paths.image('week_icons_' + (AllPossibleSongs[CurrentPack].toLowerCase())));
		CurrentSongIcon.centerOffsets(false);
		CurrentSongIcon.x = (FlxG.width / 2) - (CurrentSongIcon.width / 2);
		CurrentSongIcon.y = (FlxG.height / 2) - (CurrentSongIcon.height / 2);
		FlxTween.color(bg, 0.3, bg.color, packColors[CurrentPack]);
	}

	override function beatHit()
	{
		super.beatHit();
		FlxTween.tween(FlxG.camera, {zoom:1.05}, 0.3, {ease: FlxEase.quadOut, type: BACKWARD});
	}

	public function addWeek(songs:Array<String>, weekNum:Int, ?songCharacters:Array<String>)
	{
		if (songCharacters == null)
			songCharacters = ['bf'];

		var num:Int = 0;
		for (song in songs)
		{
			addSong(song, weekNum, songCharacters[num]);

			if (songCharacters.length != 1)
				num++;
		}
	}

	override function update(elapsed:Float)
	{
		super.update(elapsed);


		if (!InMainFreeplayState) 
		{
			if (controls.LEFT_P)
			{
				UpdatePackSelection(-1);
			}
			if (controls.RIGHT_P)
			{
				UpdatePackSelection(1);
			}
			if (controls.ACCEPT && !loadingPack)
			{
				loadingPack = true;
				LoadProperPack();
				FlxTween.tween(CurrentSongIcon, {alpha: 0}, 0.3);
				new FlxTimer().start(0.5, function(Dumbshit:FlxTimer)
				{
					CurrentSongIcon.visible = false;
					GoToActualFreeplay();
					InMainFreeplayState = true;
					loadingPack = false;
				});
			}
			if (controls.BACK)
			{
				FlxG.switchState(new MainMenuState());
			}	
		
			return;
		}

		if (FlxG.sound.music.volume < 0.7)
		{
			FlxG.sound.music.volume += 0.5 * FlxG.elapsed;
		}

		lerpScore = Math.floor(FlxMath.lerp(lerpScore, intendedScore, 0.4));

		if (Math.abs(lerpScore - intendedScore) <= 10)
			lerpScore = intendedScore;

		scoreText.text = "PERSONAL BEST:" + lerpScore;

		var upP = controls.UP_P;
		var downP = controls.DOWN_P;
		var accepted = controls.ACCEPT;

		if (upP)
		{
			changeSelection(-1);
		}
		if (downP)
		{
			changeSelection(1);
		}
		
		// Check if current pack is Joke or Extra - if so, don't allow difficulty change
		var isJokeOrExtra:Bool = (AllPossibleSongs[CurrentPack].toLowerCase() == 'joke' || 
		                          AllPossibleSongs[CurrentPack].toLowerCase() == 'extra');
		
		if (!isJokeOrExtra)
		{
			if (controls.LEFT_P)
				changeDiff(-1);
			if (controls.RIGHT_P)
				changeDiff(1);
		}

		if (controls.BACK)
		{
			FlxG.switchState(new FreeplayState());
		}

		if (accepted)
		{
			var poop:String = Highscore.formatSong(songs[curSelected].songName.toLowerCase(), curDifficulty);

			trace(poop);

			PlayState.SONG = Song.loadFromJson(poop, songs[curSelected].songName.toLowerCase());
			PlayState.isStoryMode = false;
			PlayState.storyDifficulty = curDifficulty;

			PlayState.storyWeek = songs[curSelected].week;
			trace('CUR WEEK' + PlayState.storyWeek);

			if (songs[curSelected].songName.toLowerCase() == '8 28 63')
			{
				PlayState.characteroverride = "none";
				PlayState.formoverride = "none";
				LoadingState.loadAndSwitchState(new PlayState());
			}
			else
			{
				LoadingState.loadAndSwitchState(new CharacterSelectState());
			}
		}
	}

	function changeDiff(change:Int = 0)
	{
		// Check if current pack is Joke or Extra
		var isJokeOrExtra:Bool = (AllPossibleSongs[CurrentPack].toLowerCase() == 'joke' || 
		                          AllPossibleSongs[CurrentPack].toLowerCase() == 'extra');
		
		// If it's Joke or Extra pack, lock to Normal difficulty
		if (isJokeOrExtra)
		{
			curDifficulty = 1; // Always Normal
		}
		else
		{
			curDifficulty += change;
			
			if (songs[curSelected].week != 7 || songs[curSelected].songName == 'Old-Insanity')
			{
				if (curDifficulty < 0)
					curDifficulty = 2;
				if (curDifficulty > 2)
					curDifficulty = 0;
			}
			else
			{
				if (curDifficulty < 0)
					curDifficulty = 3;
				if (curDifficulty > 3)
					curDifficulty = 0;
			}
			
			if (songs[curSelected].week == 9)
			{
				curDifficulty = 1;
			}
		}
		
		#if !switch
		intendedScore = Highscore.getScore(songs[curSelected].songName, curDifficulty);
		#end
		curChar = Highscore.getChar(songs[curSelected].songName, curDifficulty);
		updateDifficultyText();
		
	}

	function updateDifficultyText()
	{
		switch (songs[curSelected].week)
		{
			case 9:
				diffText.text = 'FINALE' + " - " + curChar.toUpperCase();
			default:
				switch (curDifficulty)
				{
					case 0:
						diffText.text = "EASY" + " - " + curChar.toUpperCase();
					case 1:
						diffText.text = 'NORMAL' + " - " + curChar.toUpperCase();
					case 2:
						diffText.text = "HARD" + " - " + curChar.toUpperCase();
				}
		}
	}

	function changeSelection(change:Int = 0)
	{
		FlxG.sound.play(Paths.sound('scrollMenu'), 0.4);
		curSelected += change;

		if (curSelected < 0)
			curSelected = songs.length - 1;
		if (curSelected >= songs.length)
			curSelected = 0;
		
		// Check if current pack is Joke or Extra
		var isJokeOrExtra:Bool = (AllPossibleSongs[CurrentPack].toLowerCase() == 'joke' || 
		                          AllPossibleSongs[CurrentPack].toLowerCase() == 'extra');
		
		if (isJokeOrExtra)
		{
			curDifficulty = 1; // Lock to Normal
		}
		else
		{
			if (songs[curSelected].week != 7 || songs[curSelected].songName == 'Old-Insanity')
			{
				if (curDifficulty < 0)
					curDifficulty = 2;
				if (curDifficulty > 2)
					curDifficulty = 0;
			}
			
			if (songs[curSelected].week == 9)
			{
				curDifficulty = 1;
			}
		}
		
		curChar = Highscore.getChar(songs[curSelected].songName, curDifficulty);
		updateDifficultyText();
		
		#if !switch
		intendedScore = Highscore.getScore(songs[curSelected].songName, curDifficulty);

		// lerpScore = 0;
		#end

		#if PRELOAD_ALL
		FlxG.sound.playMusic(Paths.inst(songs[curSelected].songName), 0);
		#end

		var bullShit:Int = 0;

		for (i in 0...iconArray.length)
		{
			iconArray[i].alpha = 0.6;
		}

		iconArray[curSelected].alpha = 1;

		for (item in grpSongs.members)
		{
			item.targetY = bullShit - curSelected;
			bullShit++;

			item.alpha = 0.6;
			// item.setGraphicSize(Std.int(item.width * 0.8));

			if (item.targetY == 0)
			{
				item.alpha = 1;
				// item.setGraphicSize(Std.int(item.width));
			}
		}
		FlxTween.color(bg, 0.1, bg.color, getSongColor(songs[curSelected]));
	}

	function getSongColor(song:SongMetadata):FlxColor
	{
		if (song.songName == 'Suppression')
			return 0xFFFF00FF;

		if (song.songName == 'Done Forever')
			return 0xFF3C3C3C;

		return songColors[song.week];
	}
}

class SongMetadata
{
	public var songName:String = "";
	public var week:Int = 0;
	public var songCharacter:String = "";

	public function new(song:String, week:Int, songCharacter:String)
	{
		this.songName = song;
		this.week = week;
		this.songCharacter = songCharacter;
	}
}