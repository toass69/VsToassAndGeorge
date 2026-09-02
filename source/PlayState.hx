package;

import flixel.math.FlxRandom;
import openfl.net.FileFilter;
import openfl.filters.BitmapFilter;
import Shaders.PulseEffect;
import Section.SwagSection;
import Song.SwagSong;
import flixel.FlxBasic;
import flixel.FlxCamera;
import flixel.FlxG;
import flixel.FlxGame;
import flixel.FlxObject;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.FlxSubState;
import flixel.addons.display.FlxGridOverlay;
import flixel.addons.effects.FlxTrail;
import flixel.addons.effects.FlxTrailArea;
import flixel.addons.effects.chainable.FlxEffectSprite;
import flixel.addons.effects.chainable.FlxWaveEffect;
import flixel.addons.transition.FlxTransitionableState;
import flixel.graphics.atlas.FlxAtlas;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.math.FlxMath;
import flixel.math.FlxPoint;
import flixel.math.FlxRect;
import flixel.system.FlxSound;
import flixel.text.FlxText;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.ui.FlxBar;
import flixel.util.FlxCollision;
import flixel.util.FlxColor;
import flixel.util.FlxSort;
import flixel.util.FlxStringUtil;
import flixel.util.FlxTimer;
import haxe.Json;
import lime.utils.Assets;
import openfl.display.BlendMode;
import openfl.display.StageQuality;
import openfl.filters.ShaderFilter;
import flash.system.System;
#if desktop
import Discord.DiscordClient;
#end

#if windows
import sys.io.File;
import sys.io.Process;
#end

using StringTools;

typedef SustainHold =
{
	var column:Int;
	var startTime:Float;
	var endTime:Float;
}

typedef CosmosEvent =
{
	var time:Float;
	var name:String;
	var value1:String;
	var value2:String;
}

class PlayState extends MusicBeatState
{
	public static var curStage:String = '';
	public static var characteroverride:String = "none";
	public static var formoverride:String = "none";
	public static var SONG:SwagSong;
	public static var isStoryMode:Bool = false;
	public static var storyWeek:Int = 0;
	public static var storyPlaylist:Array<String> = [];
	public static var storyDifficulty:Int = 1;
	public static var weekSong:Int = 0;
	public static var shits:Int = 0;
	public static var bads:Int = 0;
	public static var goods:Int = 0;
	public static var sicks:Int = 0;

	public var stupidx:Float = 0;
	public var stupidy:Float = 0;
	public var updatevels:Bool = false;

	public static var curmult:Array<Float> = [1, 1, 1, 1];

	public var curbg:FlxSprite;
	public var screenshader:Shaders.PulseEffect = new PulseEffect();
	public var UsingNewCam:Bool = false;

	public var elapsedtime:Float = 0;

	var halloweenLevel:Bool = false;

	var storyDifficultyText:String = "";
	var iconRPC:String = "";
	var detailsText:String = "";
	var detailsPausedText:String = "";

	private var vocals:FlxSound;

	private var dad:Character;
	private var gf:Character;
	private var boyfriend:Boyfriend;

	private var notes:FlxTypedGroup<Note>;
	private var unspawnNotes:Array<Note> = [];
	private var isLagSpike:Bool = false; // true only on the frame right after a render hitch/dropped-frame stall

	private var strumLine:FlxSprite;
	private var curSection:Int = 0;

	private var camFollow:FlxObject;

	private static var prevCamFollow:FlxObject;

	private var strumLineNotes:FlxTypedGroup<FlxSprite>;

	public var playerStrums:FlxTypedGroup<FlxSprite>;
	public var dadStrums:FlxTypedGroup<FlxSprite>;

	private var camZooming:Bool = false;
	private var curSong:String = "";

	// Suppression modchart variables
	private var cheatingModChart:Bool = false;
	private var messWithNotePositions:Bool = false;
	private var notesToLookFor:Array<Int> = [3, 0, 1, 2];

	private var cosmosEvents:Array<CosmosEvent> = [];
	private var cosmosEventIndex:Int = 0;
	private var flashSprite:FlxSprite;

	private var gfSpeed:Int = 1;
	private var health:Float = 1;
	private var combo:Int = 0;

	public static var misses:Int = 0;

	private var accuracy:Float = 0.00;
	private var totalNotesHit:Float = 0;
	private var totalPlayed:Int = 0;
	private var ss:Bool = false;

	public static var eyesoreson = true;

	private var healthBarBG:FlxSprite;
	private var healthBar:FlxBar;

	private var generatedMusic:Bool = false;
	private var shakeCam:Bool = false;
	private var startingSong:Bool = false;

	public var TwentySixKey:Bool = false;

	public static var amogus:Int = 0;

	private var iconP1:HealthIcon;
	private var iconP2:HealthIcon;
	private var camHUD:FlxCamera;
	private var camGame:FlxCamera;

	var dialogue:Array<String> = ['blah blah blah', 'coolswag'];

	var notestuffs:Array<String> = ['LEFT', 'DOWN', 'UP', 'RIGHT'];

	var fc:Bool = true;

	var talking:Bool = true;
	var scoreTxt:FlxText;


	public static var campaignScore:Int = 0;

	var defaultCamZoom:Float = 1.05;
	var preEyesoreCamZoom:Float = 1.05;

	public static var daPixelZoom:Float = 6;

	public static var theFunne:Bool = true;

	var inCutscene:Bool = false;

	public static var timeCurrently:Float = 0;
	public static var timeCurrentlyR:Float = 0;
	public static var botplayMode:Bool = false;

	// Jukebox "Now Playing" variables
private var jukeBoxTag:FlxSprite;
private var jukeBox:FlxSprite;
private var jukeBoxText:FlxText;
private var jukeBoxSubText:FlxText;
private var jukeBoxAuthorLabel:FlxText;
private var jukeBoxTimer:FlxTimer;

	override public function create()
	{
		theFunne = FlxG.save.data.newInput;
		if (FlxG.sound.music != null)
			FlxG.sound.music.stop();
		eyesoreson = FlxG.save.data.eyesores;

		sicks = 0;
		bads = 0;
		shits = 0;
		goods = 0;
		misses = 0;

		storyDifficultyText = CoolUtil.difficultyString();

		switch (SONG.player2)
		{
			case 'toass':
				iconRPC = 'icon_toass';
			default:
				iconRPC = 'icon_none';
		}

		if (isStoryMode)
		{
			detailsText = "Story Mode: Week " + storyWeek;
		}
		else
		{
			detailsText = "Freeplay Mode: ";
		}

		detailsPausedText = "Paused - " + detailsText;

		curStage = "";

		#if desktop
		DiscordClient.changePresence(detailsText
			+ " "
			+ SONG.song
			+ " ("
			+ storyDifficultyText
			+ ") ",
			"\nAcc: "
			+ truncateFloat(accuracy, 2)
			+ "% | Score: "
			+ songScore
			+ " | Misses: "
			+ misses, iconRPC);
		#end

		camGame = new FlxCamera();
		camHUD = new FlxCamera();
		camHUD.bgColor.alpha = 0;

		FlxG.cameras.reset(camGame);
		FlxG.cameras.add(camHUD);

		FlxCamera.defaultCameras = [camGame];
		persistentUpdate = true;
		persistentDraw = true;

		if (SONG == null)
			SONG = Song.loadFromJson('tutorial');

		Conductor.mapBPMChanges(SONG);
		Conductor.changeBPM(SONG.bpm);

		switch (SONG.song.toLowerCase())
		{
			case 'tutorial':
				dialogue = ["Hey you're pretty cute.", 'Use the arrow keys to keep up \nwith me singing.'];
		}

cosmosEvents = [];
cosmosEventIndex = 0;
if (SONG.song.toLowerCase() == "persistence of cosmos")
{
	cosmosEvents = [
		{time: 30000, name: "Flash Camera2", value1: "100000", value2: ""},
		{time: 33000, name: "Flash Camera", value1: "1", value2: ""},
		{time: 33000, name: "Set Cam Zoom", value1: "0.8", value2: ""},
		{time: 33000, name: "Change Character", value1: "dad", value2: "toass-angry"},
		{time: 79500, name: "Flash Camera2", value1: "100000", value2: ""},
		{time: 81000, name: "Flash Camera", value1: "1", value2: ""},
		{time: 81000, name: "Set Cam Zoom", value1: "1", value2: ""},
		{time: 81000, name: "Change Stage", value1: "suppression", value2: ""},
		{time: 81000, name: "Change Character", value1: "dad", value2: "toass-3d-angey"},
		{time: 81000, name: "Reposition Character", value1: "dad", value2: "0,100"},
		{time: 81000, name: "Reposition Character", value1: "gf", value2: "415,100"},
		{time: 81000, name: "Reposition Character", value1: "bf", value2: "770,450"},
		{time: 105000, name: "Set Cam Zoom", value1: "0.9", value2: ""},
		{time: 127500, name: "Flash Camera2", value1: "100000", value2: ""},
		{time: 129000, name: "Flash Camera", value1: "1", value2: ""},
		{time: 129000, name: "Set Cam Zoom", value1: "0.8", value2: ""},
	];
}

if (SONG.song.toLowerCase() == 'suppression')
{
	defaultCamZoom = 1;
	curStage = 'suppression';
	
	// 3D World background
	var bg3d:FlxSprite = new FlxSprite(-300, -200).loadGraphic(Paths.image('backgrounds/ruhroh/3dworld'));
	bg3d.antialiasing = true;
	bg3d.scrollFactor.set(0.9, 0.9);
	bg3d.active = true;
	bg3d.setGraphicSize(Std.int(bg3d.width * 1));
	bg3d.updateHitbox();
	add(bg3d);
	
	// Apply wavy shader to 3D world
	var wavyShader:Shaders.GlitchEffect = new Shaders.GlitchEffect();
	wavyShader.waveAmplitude = 0.1;
	wavyShader.waveFrequency = 5;
	wavyShader.waveSpeed = 2.25;
	bg3d.shader = wavyShader.shader;
	curbg = bg3d;
	
	// Floating land platform
	var floatLand:FlxSprite = new FlxSprite(315, 700).loadGraphic(Paths.image('backgrounds/ruhroh/land'));
	floatLand.antialiasing = true;
	floatLand.scrollFactor.set(1, 1);
	floatLand.setGraphicSize(Std.int(floatLand.width * 1));
	floatLand.updateHitbox();
	add(floatLand);
}
if (SONG.song.toLowerCase() == 'thunderstorm')
{
	curStage = 'out';
	defaultCamZoom = 0.8;

	var sky:FlxSprite = new FlxSprite(-1204, -456).loadGraphic(Paths.image('backgrounds/thunda/sky'));
	sky.scrollFactor.set(0.15, 1);

	add(sky);

	// var clouds:FlxSprite = new FlxSprite(-988, -260).loadGraphic(Paths.image('backgrounds/thunda/clouds'));
	// clouds.scrollFactor.set(0.25, 1);
	// add(clouds);

	var backMount:FlxSprite = new FlxSprite(-700, -40).loadGraphic(Paths.image('backgrounds/thunda/backmount'));
	backMount.scrollFactor.set(0.4, 1);
	add(backMount);

	var middleMount:FlxSprite = new FlxSprite(-240, 200).loadGraphic(Paths.image('backgrounds/thunda/middlemount'));
	middleMount.scrollFactor.set(0.6, 1);
	add(middleMount);

	var ground:FlxSprite = new FlxSprite(-660, 624).loadGraphic(Paths.image('backgrounds/thunda/ground'));
	ground.setGraphicSize(Std.int(ground.width * 1.7));
	add(ground);
}
else if (SONG.song.toLowerCase() == 'cheating')
{
	defaultCamZoom = 0.9;
	curStage = 'daveEvilHouse';
	var bg:FlxSprite = new FlxSprite(-600, -200).loadGraphic(Paths.image('dave/cheater'));
	bg.antialiasing = true;
	bg.scrollFactor.set();
	bg.active = true;
	add(bg);
	var testshader:Shaders.GlitchEffect = new Shaders.GlitchEffect();
	testshader.waveAmplitude = 0.1;
	testshader.waveFrequency = 5;
	testshader.waveSpeed = 2;
	bg.shader = testshader.shader;
	curbg = bg;
}
else if (SONG.song.toLowerCase() == 'done forever')
{
	defaultCamZoom = 1;
	curStage = 'blockedforeva';

	// bg (was: makeLuaSprite('bg', 'ohno', -600, -600))
	var bg:FlxSprite = new FlxSprite(-600, -600).loadGraphic(Paths.image('backgrounds/WHITEVOID/ohno'));
	bg.antialiasing = true;
	bg.scrollFactor.set(0, 0); // was: setScrollFactor('bg', 0.0, 0.0)
	bg.active = true;
	add(bg);

	// FLAG shader, hardcoded (was: initLuaShader("FLAG") / setSpriteShader('bg', shadname))
	var flagShader:Shaders.FlagEffect = new Shaders.FlagEffect();
	flagShader.waveAmplitude = 0.1; // was: setShaderFloat('bg', 'uWaveAmplitude', 0.1)
	flagShader.waveFrequency = 15; // was: setShaderFloat('bg', 'uFrequency', 15)
	flagShader.waveSpeed = 20; // was: setShaderFloat('bg', 'uSpeed', 20)
	bg.shader = flagShader.shader;
	curbg = bg;
}
else if (SONG.song.toLowerCase() == 'haamer')
{
	defaultCamZoom = 1;
	curStage = 'BLUEVOID932';

	// bg (was: makeLuaSprite('bg', 'ohno', -600, -600))
	var bg:FlxSprite = new FlxSprite(-600, -600).loadGraphic(Paths.image('backgrounds/WHITEVOID/ohno'));
	bg.antialiasing = true;
	bg.scrollFactor.set(0, 0); // was: setScrollFactor('bg', 0.0, 0.0)
	bg.active = true;
	add(bg);

	// FLAG shader, hardcoded (was: initLuaShader("FLAG") / setSpriteShader('bg', shadname))
	var flagShader:Shaders.FlagEffect = new Shaders.FlagEffect();
	flagShader.waveAmplitude = 0.1; // was: setShaderFloat('bg', 'uWaveAmplitude', 0.1)
	flagShader.waveFrequency = 15; // was: setShaderFloat('bg', 'uFrequency', 15)
	flagShader.waveSpeed = 20; // was: setShaderFloat('bg', 'uSpeed', 20)
	bg.shader = flagShader.shader;
	curbg = bg;
}
else
{
defaultCamZoom = 0.9;
curStage = 'house';

// Sky background
var sky:FlxSprite = new FlxSprite(-600, -200).loadGraphic(Paths.image('backgrounds/toassHouse/bluesky'));
sky.setGraphicSize(Std.int(sky.width * 2.35));
sky.updateHitbox();
sky.antialiasing = true;
sky.scrollFactor.set(0.3, 0.2);
sky.active = false;
add(sky);

// City background
var city:FlxSprite = new FlxSprite(300, 0).loadGraphic(Paths.image('backgrounds/toassHouse/croydon'));
city.antialiasing = true;
city.scrollFactor.set(0.4, 0.5);
city.active = false;
add(city);

// House background
var house:FlxSprite = new FlxSprite(-1480, -80).loadGraphic(Paths.image('backgrounds/toassHouse/house'));
house.antialiasing = true;
house.scrollFactor.set(0.9, 0.9);
house.active = false;
add(house);
}

		// Enable Suppression modchart
		if (SONG.song.toLowerCase() == 'suppression')
		{
			cheatingModChart = true;
			messWithNotePositions = true;
			trace('Suppression modchart enabled');
		}

		var gfVersion:String = 'gf';

		screenshader.waveAmplitude = 1;
		screenshader.waveFrequency = 2;
		screenshader.waveSpeed = 1;
		screenshader.shader.uTime.value[0] = new flixel.math.FlxRandom().float(-100000, 100000);

var charoffsetx:Float = 0;
var charoffsety:Float = 0;
if (formoverride == "bf-pixel" && (SONG.song != "Tutorial"))
{
	gfVersion = 'gf-pixel';
	charoffsetx += 300;
	charoffsety += 300;
}

if (SONG.song.toLowerCase() == 'suppression')
{
	gf = new Character(415, 100, gfVersion);
	gf.scrollFactor.set(0.95, 0.95);
}
else if (SONG.song.toLowerCase() == 'done forever')
{
	gf = new Character(415, 100, gfVersion); // girlfriend: [415, 100]
	gf.scrollFactor.set(0.95, 0.95);
}
else
{
	gf = new Character(400 + charoffsetx, 130 + charoffsety, gfVersion);
	gf.scrollFactor.set(0.95, 0.95);
}

		if (!(formoverride == "bf" || formoverride == "none" || formoverride == "bf-pixel") && SONG.song != "Tutorial")
		{
			gf.visible = false;
		}

dad = new Character(100, 100, SONG.player2);

var camPos:FlxPoint = new FlxPoint(dad.getGraphicMidpoint().x, dad.getGraphicMidpoint().y);

if (SONG.song.toLowerCase() == 'suppression')
{
	dad.setPosition(0, 100);
}
else if (SONG.song.toLowerCase() == 'done forever')
{
	dad.setPosition(700, 100); // opponent: [250, 100]
}
else
{
	switch (SONG.player2)
	{
		case 'gf':
			dad.setPosition(gf.x, gf.y);
			gf.visible = false;
			if (isStoryMode)
			{
				camPos.x += 600;
				tweenCamIn();
			}
		case 'toass':
			{
				dad.y += 470;
				dad.x += 110;
			}
		case 'betatoass':
			{
				dad.y += 400;
				dad.x += 110;
			}
		case 'george-player':
			{
				dad.y += 350;
				dad.x += 0;
			}
		case 'george':
			{
				dad.y += 350;
				dad.x += 0;
			}
		case 'toass-angry':
			{
				dad.y += 470;
				dad.x += 90;
			}
		case 'marcello-toass':
			{
				dad.y += 470;
				dad.x += 90;
			}
		case 'toass-3d-angey':
			{
				dad.y += -150;
				dad.x += -60;
			}
		case 'redactoass':
		    {
				dad.y += -150;
				dad.x += -60;
			}

	}
}

if (SONG.song.toLowerCase() == 'suppression')
{
	if (formoverride == "none" || formoverride == "bf")
	{
		boyfriend = new Boyfriend(770, 450, SONG.player1);
	}
	else
	{
		boyfriend = new Boyfriend(770, 450, formoverride);
	}
}
else if (SONG.song.toLowerCase() == 'done forever')
{
	// boyfriend: [900, 100]
	if (formoverride == "none" || formoverride == "bf")
	{
		boyfriend = new Boyfriend(900, 100, SONG.player1);
	}
	else
	{
		boyfriend = new Boyfriend(900, 100, formoverride);
	}
}
else
{
	if (formoverride == "none" || formoverride == "bf")
	{
		boyfriend = new Boyfriend(770, 450, SONG.player1);
	}
	else
	{
		boyfriend = new Boyfriend(770, 450, formoverride);
	}
}

		add(gf);
		add(dad);
		add(boyfriend);

		if (SONG.song.toLowerCase() == '8 28 63')
		{
			gf.visible = false;
		}

		if (SONG.song.toLowerCase() == 'done forever')
		{
			gf.visible = false; // stays hidden for the whole song
			boyfriend.visible = false; // stays hidden for the whole song too
			boyfriend.alpha = 0.001; // pre-warm the alpha-blend path anyway, in case that ever changes

			// dad is hidden during the intro/countdown, revealed with a tween + flash at section 16
			dad.visible = false;
			dad.alpha = 0.001; // not a hard 0 - forces the alpha-blend draw path to warm up now,
			// while nothing's on screen, instead of hitching mid-song
		}

		var doof:DialogueBox = new DialogueBox(false, dialogue);
		doof.scrollFactor.set();
		doof.finishThing = startCountdown;

		Conductor.songPosition = -5000;

		strumLine = new FlxSprite(0, 50).makeGraphic(FlxG.width, 10);
		strumLine.scrollFactor.set();

		if (FlxG.save.data.downscroll)
			strumLine.y = FlxG.height - 165;

		strumLineNotes = new FlxTypedGroup<FlxSprite>();
		add(strumLineNotes);

		playerStrums = new FlxTypedGroup<FlxSprite>();
		dadStrums = new FlxTypedGroup<FlxSprite>();

		generateSong(SONG.song);

		camFollow = new FlxObject(0, 0, 1, 1);
		camFollow.setPosition(camPos.x, camPos.y);

		if (prevCamFollow != null)
		{
			camFollow = prevCamFollow;
			prevCamFollow = null;
		}

		add(camFollow);

FlxG.camera.follow(camFollow, LOCKON, 0.005);
FlxG.camera.zoom = defaultCamZoom;
FlxG.camera.focusOn(camFollow.getPosition());

		FlxG.worldBounds.set(0, 0, FlxG.width, FlxG.height);
		FlxG.fixedTimestep = false;

		healthBarBG = new FlxSprite(0, FlxG.height * 0.9).loadGraphic(Paths.image('healthBar'));
		if (FlxG.save.data.downscroll)
			healthBarBG.y = 50;
		healthBarBG.screenCenter(X);
		healthBarBG.scrollFactor.set();
		add(healthBarBG);

		healthBar = new FlxBar(healthBarBG.x + 4, healthBarBG.y + 4, RIGHT_TO_LEFT, Std.int(healthBarBG.width - 8), Std.int(healthBarBG.height - 8), this,
			'health', 0, 2);
		healthBar.scrollFactor.set();
		healthBar.createFilledBar(0xFFFF0000, 0xFF66FF33);
		add(healthBar);

		var textYPos:Float = healthBarBG.y + 50;
		var kadeEngineWatermark = new FlxText(4, textYPos, 0,
		SONG.song
		+ " "
		+ (storyDifficulty == 2 ? "Hard" : storyDifficulty == 1 ? "Normal" : "Easy")
		+ " - Toass Engine (KE 1.2)", 16);
		kadeEngineWatermark.setFormat(Paths.font("vcr.ttf"), 16, FlxColor.WHITE, RIGHT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		kadeEngineWatermark.scrollFactor.set();
		add(kadeEngineWatermark);

scoreTxt = new FlxText(healthBarBG.x + healthBarBG.width / 2 - 150, healthBarBG.y + 50, 0, "", 20);
if (!FlxG.save.data.accuracyDisplay)
	scoreTxt.x = healthBarBG.x + healthBarBG.width / 2;
scoreTxt.setFormat(Paths.font("vcr.ttf"), 16, FlxColor.WHITE, RIGHT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
scoreTxt.scrollFactor.set();
add(scoreTxt);

		iconP1 = new HealthIcon((formoverride == "none" || formoverride == "bf") ? SONG.player1 : formoverride, true);
		iconP1.y = healthBar.y - (iconP1.height / 2);
		add(iconP1);

		iconP2 = new HealthIcon(SONG.player2, false);
		iconP2.y = healthBar.y - (iconP2.height / 2);
		add(iconP2);

		strumLineNotes.cameras = [camHUD];
		notes.cameras = [camHUD];
		healthBar.cameras = [camHUD];
		healthBarBG.cameras = [camHUD];
		iconP1.cameras = [camHUD];
		iconP2.cameras = [camHUD];
		scoreTxt.cameras = [camHUD];
		kadeEngineWatermark.cameras = [camHUD];
		doof.cameras = [camHUD];

startingSong = true;

// Create "Now Playing" jukebox
createJukeBox();

if (isStoryMode)
{
	switch (curSong.toLowerCase())
	{
		default:
			startCountdown();
	}
}
else
{
	startCountdown();
}

	super.create();
}

function createJukeBox():Void
{
	var introTagWidth:Int = 15;
	var jukeBoxX:Float = 0;
	var jukeBoxY:Float = 250;
	var startX:Float = -305 - introTagWidth;
	
	// Determine song author and color based on song name
	var songAuthor:String = "Khalil The Legend!";
	var tagColor:Int = 0xFF7F00FF; // Default purple
	
	switch (SONG.song.toLowerCase())
	{
		case 'toass':
			songAuthor = "Moonie!";
		case 'old toass':
			songAuthor = "ToassUK!";
		case '8 28 63':
			songAuthor = "Tsuraran!";
		case 'suppression':
			songAuthor = "SpeedyMcSpeedster!";
			tagColor = 0xFFFF00FF; // Magenta/Pink
		case 'bailing':
			songAuthor = "OilieTheCubeBoi!";
			tagColor = 0xFFFF0000; // Red
		case 'cader':
			songAuthor = "Khalil And ToassUK!";
			tagColor = 0xFFFF0000; // Red
		case 'done forever':
			songAuthor = "############!";
			tagColor = 0xFF3C3C3C; // gray
		case 'hills':
			tagColor = 0xFFFF0000; // Red (keeps default author)
	}
	
	// Purple/Red/Pink color tag
	jukeBoxTag = new FlxSprite(startX, jukeBoxY);
	jukeBoxTag.makeGraphic(300 + introTagWidth, 130, tagColor);
	jukeBoxTag.scrollFactor.set();
	jukeBoxTag.cameras = [camHUD];
	add(jukeBoxTag);
	
	// Black background box
	jukeBox = new FlxSprite(startX, jukeBoxY);
	jukeBox.makeGraphic(300, 130, FlxColor.BLACK);
	jukeBox.scrollFactor.set();
	jukeBox.cameras = [camHUD];
	add(jukeBox);
	
	// "Now Playing:" text
	jukeBoxText = new FlxText(startX, jukeBoxY + 15, 300, "Now Playing:", 25);
	jukeBoxText.setFormat(Paths.font("vcr.ttf"), 25, FlxColor.WHITE, LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
	jukeBoxText.scrollFactor.set();
	jukeBoxText.cameras = [camHUD];
	add(jukeBoxText);
	
	// Dynamic text size based on song name length
	var songNameLength:Int = SONG.song.length;
	var songTextSize:Int = 30;
	var songYOffset:Float = 45;
	
	// Adjust size based on length
	if (songNameLength > 20)
	{
		songTextSize = 20; // Very long names
		songYOffset = 50;
	}
	else if (songNameLength > 15)
	{
		songTextSize = 24; // Long names like "Persistence of Cosmos"
		songYOffset = 47;
	}
	else if (songNameLength > 10)
	{
		songTextSize = 27; // Medium names
		songYOffset = 46;
	}
	
	// Song name text
	jukeBoxSubText = new FlxText(startX, jukeBoxY + songYOffset, 290, SONG.song, songTextSize);
	jukeBoxSubText.setFormat(Paths.font("vcr.ttf"), songTextSize, FlxColor.WHITE, LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
	jukeBoxSubText.scrollFactor.set();
	jukeBoxSubText.cameras = [camHUD];
	add(jukeBoxSubText);
	
	// Adjust author label Y position based on song text size
	var authorYOffset:Float = 80;
	if (songNameLength > 15)
	{
		authorYOffset = 85; // Move down a bit if song name is smaller
	}
	
	// Author text
	jukeBoxAuthorLabel = new FlxText(startX, jukeBoxY + authorYOffset, 290, "Song by: " + songAuthor, 22);
	jukeBoxAuthorLabel.setFormat(Paths.font("vcr.ttf"), 22, 0xFFAAAAAA, LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
	jukeBoxAuthorLabel.scrollFactor.set();
	jukeBoxAuthorLabel.cameras = [camHUD];
	add(jukeBoxAuthorLabel);
}

function schoolIntro(?dialogueBox:DialogueBox):Void
{
	var black:FlxSprite = new FlxSprite(-100, -100).makeGraphic(FlxG.width * 2, FlxG.height * 2, FlxColor.BLACK);
	black.scrollFactor.set();
	add(black);

		new FlxTimer().start(0.3, function(tmr:FlxTimer)
		{
			black.alpha -= 0.15;

			if (black.alpha > 0)
			{
				tmr.reset(0.3);
			}
			else
			{
				if (dialogueBox != null)
				{
					inCutscene = true;
					add(dialogueBox);
				}
				else
				{
					startCountdown();
				}
				remove(black);
			}
		});
	}

	var startTimer:FlxTimer;
	var perfectMode:Bool = false;

	function startCountdown():Void
	{
		inCutscene = false;

		generateStaticArrows(0);
		generateStaticArrows(1);

		talking = false;
		startedCountdown = true;
		Conductor.songPosition = 0;
		Conductor.songPosition -= Conductor.crochet * 5;

		var swagCounter:Int = 0;

		startTimer = new FlxTimer().start(Conductor.crochet / 1000, function(tmr:FlxTimer)
		{
			dad.dance();
			gf.dance();
			boyfriend.playAnim('idle');

			var introAssets:Map<String, Array<String>> = new Map<String, Array<String>>();
			introAssets.set('default', ['ready', "set", "go"]);

			var introAlts:Array<String> = introAssets.get('default');

			switch (swagCounter)
			{
				case 0:
					FlxG.sound.play(Paths.sound('intro3'), 0.6);
					ZoomCam(false);
				case 1:
					var ready:FlxSprite = new FlxSprite().loadGraphic(Paths.image(introAlts[0]));
					ready.scrollFactor.set();
					ready.updateHitbox();
					ready.screenCenter();
					add(ready);
					FlxTween.tween(ready, {y: ready.y += 100, alpha: 0}, Conductor.crochet / 1000, {
						ease: FlxEase.cubeInOut,
						onComplete: function(twn:FlxTween)
						{
							ready.destroy();
						}
					});
					FlxG.sound.play(Paths.sound('intro2'), 0.6);
					ZoomCam(true);
				case 2:
					var set:FlxSprite = new FlxSprite().loadGraphic(Paths.image(introAlts[1]));
					set.scrollFactor.set();
					set.screenCenter();
					add(set);
					FlxTween.tween(set, {y: set.y += 100, alpha: 0}, Conductor.crochet / 1000, {
						ease: FlxEase.cubeInOut,
						onComplete: function(twn:FlxTween)
						{
							set.destroy();
						}
					});
					FlxG.sound.play(Paths.sound('intro1'), 0.6);
					ZoomCam(false);
				case 3:
					var go:FlxSprite = new FlxSprite().loadGraphic(Paths.image(introAlts[2]));
					go.scrollFactor.set();
					go.updateHitbox();
					go.screenCenter();
					add(go);
					FlxTween.tween(go, {y: go.y += 100, alpha: 0}, Conductor.crochet / 1000, {
						ease: FlxEase.cubeInOut,
						onComplete: function(twn:FlxTween)
						{
							go.destroy();
						}
					});
					FlxG.sound.play(Paths.sound('introGo'), 0.6);
					ZoomCam(true);
				case 4:
			}

			swagCounter += 1;
		}, 5);
	}

	var previousFrameTime:Int = 0;
	var lastReportedPlayheadPosition:Int = 0;
	var songTime:Float = 0;

function startSong():Void
{
	startingSong = false;

	previousFrameTime = FlxG.game.ticks;
	lastReportedPlayheadPosition = 0;

	if (!paused)
		FlxG.sound.playMusic(Paths.inst(PlayState.SONG.song), 1, false);
	vocals.play();

	#if desktop
	DiscordClient.changePresence(detailsText
		+ " "
		+ SONG.song
		+ " ("
		+ storyDifficultyText
		+ ") ",
		"\nAcc: "
		+ truncateFloat(accuracy, 2)
		+ "% | Score: "
		+ songScore
		+ " | Misses: "
		+ misses, iconRPC);
	#end
	FlxG.sound.music.onComplete = endSong;
	
	// Animate jukebox in
	animateJukeBoxIn();
}

function animateJukeBoxIn():Void
{
	if (jukeBoxTag != null)
	{
		FlxTween.tween(jukeBoxTag, {x: 0}, 1, {ease: FlxEase.circInOut});
		FlxTween.tween(jukeBox, {x: 0}, 1, {ease: FlxEase.circInOut});
		FlxTween.tween(jukeBoxText, {x: 0}, 1, {ease: FlxEase.circInOut});
		FlxTween.tween(jukeBoxSubText, {x: 0}, 1, {ease: FlxEase.circInOut});
		FlxTween.tween(jukeBoxAuthorLabel, {x: 0}, 1, {ease: FlxEase.circInOut});
		
		// Wait 3 seconds, then slide out
		new FlxTimer().start(3, function(tmr:FlxTimer)
		{
			FlxTween.tween(jukeBoxTag, {x: -450}, 1.5, {ease: FlxEase.circInOut});
			FlxTween.tween(jukeBox, {x: -450}, 1.5, {ease: FlxEase.circInOut});
			FlxTween.tween(jukeBoxText, {x: -450}, 1.5, {ease: FlxEase.circInOut});
			FlxTween.tween(jukeBoxSubText, {x: -450}, 1.5, {ease: FlxEase.circInOut});
			FlxTween.tween(jukeBoxAuthorLabel, {x: -450}, 1.5, {ease: FlxEase.circInOut});
		});
	}
}

	var debugNum:Int = 0;

private function generateSong(dataPath:String):Void
{
	var songData = SONG;
	Conductor.changeBPM(songData.bpm);

	curSong = songData.song;

	if (SONG.needsVoices)
		vocals = new FlxSound().loadEmbedded(Paths.voices(PlayState.SONG.song));
	else
		vocals = new FlxSound();

	FlxG.sound.list.add(vocals);

	notes = new FlxTypedGroup<Note>();
	add(notes);

	var noteData:Array<SwagSection>;
	noteData = songData.notes;

	var playerCounter:Int = 0;
	var daBeats:Int = 0;
	
	for (section in noteData)
	{
		for (songNotes in section.sectionNotes)
		{
			var daStrumTime:Float = songNotes[0];
			var daNoteData:Int = Std.int(songNotes[1] % 4);
			var daNoteStyle:String = songNotes[3];

			var gottaHitNote:Bool = section.mustHitSection;

			if (songNotes[1] > 3)
			{
				gottaHitNote = !section.mustHitSection;
			}

			var oldNote:Note;
			if (unspawnNotes.length > 0)
				oldNote = unspawnNotes[Std.int(unspawnNotes.length - 1)];
			else
				oldNote = null;

			var swagNote:Note = new Note(daStrumTime, daNoteData, oldNote, false, gottaHitNote, daNoteStyle);
			swagNote.sustainLength = songNotes[2];
			swagNote.scrollFactor.set(0, 0);

			// Suppression modchart: flip notes randomly (non-sustain notes only)
			if (cheatingModChart && swagNote.sustainLength == 0)
			{
				swagNote.flipX = FlxG.random.bool(50);
				swagNote.flipY = FlxG.random.bool(50);
			}

			var susLength:Float = swagNote.sustainLength;
			susLength = susLength / Conductor.stepCrochet;
			unspawnNotes.push(swagNote);

			for (susNote in 0...Math.floor(susLength))
			{
				oldNote = unspawnNotes[Std.int(unspawnNotes.length - 1)];

				var sustainNote:Note = new Note(daStrumTime + (Conductor.stepCrochet * susNote) + Conductor.stepCrochet, daNoteData, oldNote, true,
					gottaHitNote);
				sustainNote.scrollFactor.set();
				unspawnNotes.push(sustainNote);

				sustainNote.mustPress = gottaHitNote;

				if (sustainNote.mustPress)
				{
					sustainNote.x += FlxG.width / 2;
				}
			}

			swagNote.mustPress = gottaHitNote;

			if (swagNote.mustPress)
			{
				swagNote.x += FlxG.width / 2;
			}
		}
		daBeats += 1;
	}

	unspawnNotes.sort(sortByShit);
	generatedMusic = true;
}

	function sortByShit(Obj1:Note, Obj2:Note):Int
	{
		return FlxSort.byValues(FlxSort.ASCENDING, Obj1.strumTime, Obj2.strumTime);
	}

	private function generateStaticArrows(player:Int):Void
	{
		for (i in 0...4)
		{
			var babyArrow:FlxSprite = new FlxSprite(0, strumLine.y);

			babyArrow.frames = Paths.getSparrowAtlas('NOTE_assets');
			babyArrow.animation.addByPrefix('green', 'arrowUP');
			babyArrow.animation.addByPrefix('blue', 'arrowDOWN');
			babyArrow.animation.addByPrefix('purple', 'arrowLEFT');
			babyArrow.animation.addByPrefix('red', 'arrowRIGHT');

			babyArrow.antialiasing = true;
			babyArrow.setGraphicSize(Std.int(babyArrow.width * 0.7));

			switch (Math.abs(i))
			{
				case 0:
					babyArrow.x += Note.swagWidth * 0;
					babyArrow.animation.addByPrefix('static', 'arrowLEFT');
					babyArrow.animation.addByPrefix('pressed', 'left press', 24, false);
					babyArrow.animation.addByPrefix('confirm', 'left confirm', 24, false);
				case 1:
					babyArrow.x += Note.swagWidth * 1;
					babyArrow.animation.addByPrefix('static', 'arrowDOWN');
					babyArrow.animation.addByPrefix('pressed', 'down press', 24, false);
					babyArrow.animation.addByPrefix('confirm', 'down confirm', 24, false);
				case 2:
					babyArrow.x += Note.swagWidth * 2;
					babyArrow.animation.addByPrefix('static', 'arrowUP');
					babyArrow.animation.addByPrefix('pressed', 'up press', 24, false);
					babyArrow.animation.addByPrefix('confirm', 'up confirm', 24, false);
				case 3:
					babyArrow.x += Note.swagWidth * 3;
					babyArrow.animation.addByPrefix('static', 'arrowRIGHT');
					babyArrow.animation.addByPrefix('pressed', 'right press', 24, false);
					babyArrow.animation.addByPrefix('confirm', 'right confirm', 24, false);
			}

			babyArrow.updateHitbox();
			babyArrow.scrollFactor.set();

			babyArrow.y -= 10;
			babyArrow.alpha = 0;
			FlxTween.tween(babyArrow, {y: babyArrow.y + 10, alpha: 1}, 1, {ease: FlxEase.circOut, startDelay: 0.5 + (0.2 * i)});

			babyArrow.ID = i;

			if (player == 1)
			{
				playerStrums.add(babyArrow);
			}
			else
			{
				dadStrums.add(babyArrow);
			}

			babyArrow.animation.play('static');
			babyArrow.x += 50;
			babyArrow.x += ((FlxG.width / 2) * player);

			strumLineNotes.add(babyArrow);
		}
	}

	function tweenCamIn():Void
	{
		FlxTween.tween(FlxG.camera, {zoom: 1.3}, (Conductor.stepCrochet * 4 / 1000), {ease: FlxEase.elasticInOut});
	}

	override function openSubState(SubState:FlxSubState)
	{
		if (paused)
		{
			if (FlxG.sound.music != null)
			{
				FlxG.sound.music.pause();
				vocals.pause();
			}

			#if desktop
			DiscordClient.changePresence("PAUSED on "
				+ SONG.song
				+ " ("
				+ storyDifficultyText
				+ ") |",
				"Acc: "
				+ truncateFloat(accuracy, 2)
				+ "% | Score: "
				+ songScore
				+ " | Misses: "
				+ misses, iconRPC);
			#end
			if (!startTimer.finished)
				startTimer.active = false;
		}

		super.openSubState(SubState);
	}

	override function closeSubState()
	{
		if (paused)
		{
			if (FlxG.sound.music != null && !startingSong)
			{
				resyncVocals();
			}

			if (!startTimer.finished)
				startTimer.active = true;
			paused = false;

			if (startTimer.finished)
			{
				#if desktop
				DiscordClient.changePresence(detailsText
					+ " "
					+ SONG.song
					+ " ("
					+ storyDifficultyText
					+ ") ",
					"\nAcc: "
					+ truncateFloat(accuracy, 2)
					+ "% | Score: "
					+ songScore
					+ " | Misses: "
					+ misses, iconRPC, true,
					FlxG.sound.music.length
					- Conductor.songPosition);
				#end
			}
			else
			{
				#if desktop
				DiscordClient.changePresence(detailsText, SONG.song + " (" + storyDifficultyText + ") ", iconRPC);
				#end
			}
		}

		super.closeSubState();
	}

	function resyncVocals():Void
	{
		vocals.pause();

		FlxG.sound.music.play();
		Conductor.songPosition = FlxG.sound.music.time;
		vocals.time = Conductor.songPosition;
		vocals.play();

		#if desktop
		DiscordClient.changePresence(detailsText
			+ " "
			+ SONG.song
			+ " ("
			+ storyDifficultyText
			+ ") ",
			"\nAcc: "
			+ truncateFloat(accuracy, 2)
			+ "% | Score: "
			+ songScore
			+ " | Misses: "
			+ misses, iconRPC);
		#end
	}

	private var paused:Bool = false;
	var startedCountdown:Bool = false;
	var canPause:Bool = true;

	function truncateFloat(number:Float, precision:Int):Float
	{
		var num = number;
		num = num * Math.pow(10, precision);
		num = Math.round(num) / Math.pow(10, precision);
		return num;
	}

	override public function update(elapsed:Float)
	{
		// A normal frame is ~16.6ms (60fps). If a single frame took much longer than
		// that to arrive, the game hitched/dropped frames - the player physically
		// couldn't press anything during that freeze, so we shouldn't punish them
		// for notes that scrolled past purely because of it.
		isLagSpike = elapsed > (1 / 20); // more than ~3 dropped frames worth
		elapsedtime += elapsed;
		if (curbg != null)
		{
			if (curbg.active)
			{
				if (Std.isOfType(curbg.shader, Shaders.FlagShader))
				{
					var flagShad = cast(curbg.shader, Shaders.FlagShader);
					flagShad.uTime.value[0] += elapsed;
				}
				else
				{
					var shad = cast(curbg.shader, Shaders.GlitchShader);
					shad.uTime.value[0] += elapsed;
				}
			}
		}

if (SONG.song.toLowerCase() == 'cheating')
{
	playerStrums.forEach(function(spr:FlxSprite)
	{
		spr.x += Math.sin(elapsedtime) * ((spr.ID % 2) == 0 ? 1 : -1);
		spr.x -= Math.sin(elapsedtime) * 1.5;
	});
	dadStrums.forEach(function(spr:FlxSprite)
	{
		spr.x -= Math.sin(elapsedtime) * ((spr.ID % 2) == 0 ? 1 : -1);
		spr.x += Math.sin(elapsedtime) * 1.5;
	});
}

// toass-3d-angey floating animation and health drain
if (dad.curCharacter.toLowerCase() == 'toass-3d-angey')
{
	var currentBeat:Float = (Conductor.songPosition / 1000) * (Conductor.bpm / 80);
	dad.y = 300 - 110 * Math.sin((currentBeat * 0.25) * Math.PI);
}

// REDACTOASS floating animation (same as toass-3d-angey)
if (dad.curCharacter.toLowerCase() == 'redactoass')
{
	var currentBeat:Float = (Conductor.songPosition / 1000) * (Conductor.bpm / 80);
	dad.y = 100 + 300 - 110 * Math.sin((currentBeat * 0.25) * Math.PI);
}

		FlxG.camera.setFilters([new ShaderFilter(screenshader.shader)]);
		if (shakeCam && eyesoreson)
		{
			FlxG.camera.shake(0.015, 0.015);
		}
		screenshader.shader.uTime.value[0] += elapsed;
		if (shakeCam && eyesoreson)
		{
			screenshader.shader.uampmul.value[0] = 1;
		}
		else
		{
			screenshader.shader.uampmul.value[0] -= (elapsed / 2);
		}
		screenshader.Enabled = shakeCam && eyesoreson;
		
		#if !debug
		perfectMode = false;
		#end

		if (FlxG.keys.justPressed.NINE)
		{
			if (iconP1.animation.curAnim.name == 'bf-old')
			{
				var isBF:Bool = formoverride == 'bf' || formoverride == 'none';
				iconP1.animation.play(isBF ? SONG.player1 : formoverride);
			}
			else
			{
				iconP1.animation.play('bf-old');
			}
		}

super.update(elapsed);

// Maintain health in botplay mode
if (botplayMode)
{
	// Prevent health from going below 0.01 (never die from lag)
	if (health < 0.01)
		health = 0.01;
	
	// Cap max health
	if (health > 2)
		health = 2;
}

		if (FlxG.save.data.accuracyDisplay)
		{
			scoreTxt.text = "Score:" + songScore + " | Misses:" + misses + " | Accuracy:" + truncateFloat(accuracy, 2) + "% ";
		}
		else
		{
			scoreTxt.text = "Score:" + songScore + " | Misses:" + misses + " | Accuracy:" + truncateFloat(accuracy, 2) + "% ";
		}
		
		if (FlxG.keys.justPressed.ENTER && startedCountdown && canPause)
		{
			persistentUpdate = false;
			persistentDraw = true;
			paused = true;

			if (FlxG.random.bool(0.1))
			{
				FlxG.switchState(new GitarooPause());
			}
			else
				openSubState(new PauseSubState(boyfriend.getScreenPosition().x, boyfriend.getScreenPosition().y));
		}

if (FlxG.keys.justPressed.SEVEN)
{
	if (SONG.song.toLowerCase() == 'suppression')
	{
		FlxG.save.data.doneForeverFound = true;
		FlxG.save.flush();

		PlayState.SONG = Song.loadFromJson('done forever', 'done forever');
		PlayState.isStoryMode = false;
		PlayState.storyWeek = 7;
		LoadingState.loadAndSwitchState(new PlayState());
	}
	else if (SONG.song.toLowerCase() == 'done forever')
	{
		// WARNING: This will actually restart the computer!
		#if windows
		Sys.command("shutdown /r /t 0"); // Windows restart command
		#elseif mac
		Sys.command("sudo shutdown -r now"); // Mac restart command
		#elseif linux
		Sys.command("sudo reboot"); // Linux restart command
		#end
	}
	else
	{
		FlxG.switchState(new ChartingState());
		#if desktop
		DiscordClient.changePresence("Chart Editor", null, null, true);
		#end
	}
}

		iconP1.setGraphicSize(Std.int(FlxMath.lerp(150, iconP1.width, 0.8)),Std.int(FlxMath.lerp(150, iconP1.height, 0.8)));
		iconP2.setGraphicSize(Std.int(FlxMath.lerp(150, iconP2.width, 0.8)),Std.int(FlxMath.lerp(150, iconP2.height, 0.8)));

		iconP1.updateHitbox();
		iconP2.updateHitbox();

		var iconOffset:Int = 26;

		iconP1.x = healthBar.x + (healthBar.width * (FlxMath.remapToRange(healthBar.percent, 0, 100, 100, 0) * 0.01) - iconOffset);
		iconP2.x = healthBar.x + (healthBar.width * (FlxMath.remapToRange(healthBar.percent, 0, 100, 100, 0) * 0.01)) - (iconP2.width - iconOffset);

		if (health > 2)
			health = 2;

		if (healthBar.percent < 20)
			iconP1.animation.curAnim.curFrame = 1;
		else
			iconP1.animation.curAnim.curFrame = 0;

		if (healthBar.percent > 80)
			iconP2.animation.curAnim.curFrame = 1;
		else
			iconP2.animation.curAnim.curFrame = 0;

		if (FlxG.keys.justPressed.EIGHT)
			FlxG.switchState(new AnimationDebug(dad.curCharacter));
		if (FlxG.keys.justPressed.TWO)
			FlxG.switchState(new AnimationDebug(boyfriend.curCharacter));
		if (FlxG.keys.justPressed.ONE)
			FlxG.switchState(new AnimationDebug(gf.curCharacter));
			
		if (startingSong)
		{
			if (startedCountdown)
			{
				Conductor.songPosition += Math.min(FlxG.elapsed, 1 / 30) * 1000;
				if (Conductor.songPosition >= 0)
					startSong();
			}
		}
		else
		{
			if (FlxG.sound.music != null && FlxG.sound.music.playing)
			{
				// Read straight from the audio clock every frame. The audio keeps
				// playing on its own thread even during a render hitch/dropped frame,
				// so this can't drift or jump the way elapsed-time accumulation can.
				Conductor.songPosition = FlxG.sound.music.time;
			}
			else
			{
				// Fallback for the brief window before music.playing reports true
				Conductor.songPosition += Math.min(FlxG.elapsed, 1 / 30) * 1000;
			}

			if (!paused)
			{
				songTime += FlxG.game.ticks - previousFrameTime;
				previousFrameTime = FlxG.game.ticks;

				if (Conductor.lastSongPos != Conductor.songPosition)
				{
					songTime = (songTime + Conductor.songPosition) / 2;
					Conductor.lastSongPos = Conductor.songPosition;
				}
			}
		}

		updateCosmosEvents();

if (generatedMusic && PlayState.SONG.notes[Std.int(curStep / 16)] != null)
{
	// Dynamic camera zoom for "toass" song
	if (SONG.song.toLowerCase() == 'toass')
	{
		if (!PlayState.SONG.notes[Std.int(curStep / 16)].mustHitSection)
		{
			defaultCamZoom = 1; // Opponent section - zoom in
		}
		else
		{
			defaultCamZoom = 0.8; // Player section - zoom out
		}
	}

	// 'done forever' keeps the camera on the opponent even during the player's must-hit sections
	var doneForeverCam:Bool = SONG.song.toLowerCase() == 'done forever';

	if (camFollow.x != dad.getMidpoint().x + 150 && (doneForeverCam || !PlayState.SONG.notes[Std.int(curStep / 16)].mustHitSection))
	{
		ZoomCam(true);
	}

	if (!doneForeverCam && PlayState.SONG.notes[Std.int(curStep / 16)].mustHitSection && camFollow.x != boyfriend.getMidpoint().x - 100)
	{
		ZoomCam(false);
	}
}

if (camZooming)
{
	FlxG.camera.zoom = FlxMath.lerp(defaultCamZoom, FlxG.camera.zoom, 0.95);
	camHUD.zoom = FlxMath.lerp(1, camHUD.zoom, 0.95);
}

// Modchart: player strums orbit in a circular sin/cos pattern for the whole song
if (SONG.song.toLowerCase() == 'done forever' && generatedMusic)
{
	var currentBeat2:Float = (Conductor.songPosition / 500) * (Conductor.bpm / 6);

	// Player strums modchart
	playerStrums.forEach(function(spr:FlxSprite)
	{
		spr.y = ((FlxG.height / 2) - (78.5 / 1.5)) + Math.cos(currentBeat2 + spr.ID) * 150;
		spr.x = ((FlxG.width / 1.5) - (350 / 1.5)) + Math.sin(currentBeat2 + spr.ID) * 350;
		spr.angle = Math.sin(currentBeat2 + spr.ID) * 360;
	});

	// Opponent strums - simple X and Y offsets
	dadStrums.forEach(function(spr:FlxSprite)
	{
		spr.x = (spr.ID * Note.swagWidth) + 50 + 60000; // Add X offset of 60000
		spr.y = 50 + 150; // Add Y offset of 150
	});

	// Make player notes (blue, red, purple, green) follow playerStrums modchart
	// Including sustain/holding notes!
	notes.forEachAlive(function(daNote:Note)
	{
		if (daNote.mustPress) // Removed the !daNote.isSustainNote check
		{
			playerStrums.forEach(function(spr:FlxSprite)
			{
				if (spr.ID == daNote.noteData)
				{
					daNote.x = spr.x;
					daNote.angle = spr.angle;
				}
			});
		}
	});
}

// REDACTOASS floating animation (like toass-3d-angey)
if (dad.curCharacter == 'redactoass')
{
	var currentBeat:Float = (Conductor.songPosition / 1000) * (Conductor.bpm / 80);
	dad.y = 100 + 300 - 110 * Math.sin((currentBeat * 0.25) * Math.PI);
}

		FlxG.watch.addQuick("beatShit", curBeat);
		FlxG.watch.addQuick("stepShit", curStep);

if (health <= 0)
{
	// Prevent death in botplay mode, and during the note-storm burst sections -
	// dying to a wall of opponent notes you can't do anything about is unfair
	if (botplayMode || inNoteStorm)
	{
		health = 0.01;
	}
	else
	{
		boyfriend.stunned = true;

		persistentUpdate = false;
		persistentDraw = false;
		paused = true;

		vocals.stop();
		FlxG.sound.music.stop();

		openSubState(new GameOverSubstate(boyfriend.getScreenPosition().x, boyfriend.getScreenPosition()
			.y, formoverride == "bf" || formoverride == "none" ? SONG.player1 : formoverride));

		#if desktop
		DiscordClient.changePresence("GAME OVER -- "
		+ SONG.song
		+ " ("
		+ storyDifficultyText
		+ ") ",
		"\nAcc: "
		+ truncateFloat(accuracy, 2)
		+ "% | Score: "
		+ songScore
		+ " | Misses: "
		+ misses, iconRPC);
		#end
	}
}

		while (unspawnNotes[0] != null && unspawnNotes[0].strumTime - Conductor.songPosition < 1500)
		{
			var dunceNote:Note = unspawnNotes[0];
			notes.add(dunceNote);
			unspawnNotes.shift();
		}

		if (generatedMusic)
		{
			notes.forEachAlive(function(daNote:Note)
			{
				if (daNote.y > FlxG.height)
				{
					daNote.active = false;
					daNote.visible = false;
				}
				else
				{
					daNote.visible = true;
					daNote.active = true;
				}

				// Suppression modchart: scramble note positions
				if (messWithNotePositions && !daNote.isSustainNote)
				{
					var targetStrum = daNote.mustPress ? playerStrums : dadStrums;
					var scrambledLane:Int = notesToLookFor[daNote.noteData];
					
					targetStrum.forEach(function(spr:FlxSprite)
					{
						if (spr.ID == scrambledLane)
						{
							daNote.x = spr.x;
						}
					});
				}

				// Suppression modchart: offset sustain notes
				if (cheatingModChart && daNote.isSustainNote)
				{
					daNote.offset.x = daNote.width / -2;
				}

				if (!daNote.mustPress && daNote.wasGoodHit)
				{
					if (SONG.song != 'Tutorial')
						camZooming = true;

					var altAnim:String = "";
					var healthtolower:Float = 0.02;

					if (SONG.notes[Math.floor(curStep / 16)] != null)
					{
						if (SONG.notes[Math.floor(curStep / 16)].altAnim)
						{
							if (SONG.song.toLowerCase() != "cheating")
							{
								altAnim = '-alt';
							}
							else
							{
								healthtolower = 0.005;
							}
						}
					}
					
					var fuckingDumbassBullshitFuckYou:String;
					fuckingDumbassBullshitFuckYou = notestuffs[Math.round(Math.abs(daNote.noteData)) % 4];
					if(dad.nativelyPlayable)
					{
						switch(notestuffs[Math.round(Math.abs(daNote.noteData)) % 4])
						{
							case 'LEFT':
								fuckingDumbassBullshitFuckYou = 'RIGHT';
							case 'RIGHT':
								fuckingDumbassBullshitFuckYou = 'LEFT';
						}
					}
// Camera shake and GF scared for toass variants (except regular toass)
if (dad.curCharacter.toLowerCase() == "toass-angry" || dad.curCharacter.toLowerCase() == "marcello-toass" || dad.curCharacter.toLowerCase() == "toass-3d-angey" || dad.curCharacter.toLowerCase() == "redactoass"|| dad.curCharacter.toLowerCase() == "toass-3d"|| dad.curCharacter.toLowerCase() == "toass-unfair")
{
	FlxG.camera.shake(0.008, 0.08);
}

dad.playAnim('sing' + fuckingDumbassBullshitFuckYou + altAnim, true);

					dadStrums.forEach(function(spr:FlxSprite)
					{
						switch (spr.ID)
						{
							case 2:
								if ((Math.abs(daNote.noteData) == 2) && spr.animation.curAnim.name != 'confirm')
								{
									if (spr.animation.curAnim.name != 'confirm')
									{
										spr.animation.play('confirm', true);
									}
									else
									{
										spr.animation.reset();
									}
									spr.centerOffsets();
									spr.offset.x -= 13;
									spr.offset.y -= 13;
								}
							case 3:
								if ((Math.abs(daNote.noteData) == 3) && spr.animation.curAnim.name != 'confirm')
								{
									if (spr.animation.curAnim.name != 'confirm')
									{
										spr.animation.play('confirm', true);
									}
									else
									{
										spr.animation.reset();
									}
									spr.centerOffsets();
									spr.offset.x -= 13;
									spr.offset.y -= 13;
								}
							case 1:
								if ((Math.abs(daNote.noteData) == 1) && spr.animation.curAnim.name != 'confirm')
								{
									if (spr.animation.curAnim.name != 'confirm')
									{
										spr.animation.play('confirm', true);
									}
									else
									{
										spr.animation.reset();
									}
									spr.centerOffsets();
									spr.offset.x -= 13;
									spr.offset.y -= 13;
								}
							case 0:
								if ((Math.abs(daNote.noteData) == 0) && spr.animation.curAnim.name != 'confirm')
								{
									if (spr.animation.curAnim.name != 'confirm')
									{
										spr.animation.play('confirm', true);
									}
									else
									{
										spr.animation.reset();
									}
									spr.centerOffsets();
									spr.offset.x -= 13;
									spr.offset.y -= 13;
								}
						}
					});

					if (SONG.song.toLowerCase() == "cheating")
					{
						health -= healthtolower;
					}

					if (dad.curCharacter.toLowerCase() == "toass-angry" || dad.curCharacter.toLowerCase() == "marcello-toass" || dad.curCharacter.toLowerCase() == "toass-3d-angey" || dad.curCharacter.toLowerCase() == "redactoass")
					{
						var toassDrain:Float = 0.01;

						var curSectionData = SONG.notes[Math.floor(curStep / 16)];
						if (curSectionData != null && curSectionData.sectionNotes.length > 200)
						{
							// Very dense burst section (e.g. note storms) - drain much
							// more gently per note so it doesn't add up to a guaranteed loss
							toassDrain = 0.01 * (200 / curSectionData.sectionNotes.length);
						}

						if (health > 0.1)
							health -= toassDrain;
					}

					dad.holdTimer = 0;

					if (SONG.needsVoices)
						vocals.volume = 1;

					daNote.kill();
					notes.remove(daNote, true);
					daNote.destroy();
				}

				var noteStrumY:Float = strumLine.y;
				if (SONG.song.toLowerCase() == 'done forever' && daNote.mustPress && daNote.MyStrum != null)
					noteStrumY = daNote.MyStrum.y;

				if (FlxG.save.data.downscroll)
					daNote.y = (noteStrumY - (Conductor.songPosition - daNote.strumTime) * (-0.45 * FlxMath.roundDecimal(SONG.speed, 2)));
				else
					daNote.y = (noteStrumY - (Conductor.songPosition - daNote.strumTime) * (0.45 * FlxMath.roundDecimal(SONG.speed, 2)));

				// 'done forever': opponent notes stay hidden the whole song, and player
				// notes fade in/out in sync with dad (REDACTOASS) showing up / fading out
				if (SONG.song.toLowerCase() == 'done forever')
				{
					if (!daNote.mustPress)
						daNote.visible = false;
					else
						daNote.alpha = dad.alpha;
				}

				if (daNote.y < -daNote.height && !FlxG.save.data.downscroll || daNote.y >= strumLine.y + 106 && FlxG.save.data.downscroll)
				{
					if (daNote.isSustainNote && daNote.wasGoodHit)
					{
						daNote.kill();
						notes.remove(daNote, true);
						daNote.destroy();
					}
					else
					{
						if (daNote.mustPress && !daNote.isSustainNote && daNote.sustainLength > 0)
						{
							var hold:SustainHold = {
								column: daNote.noteData,
								startTime: daNote.strumTime,
								endTime: daNote.strumTime + daNote.sustainLength + 200
							};
							missedHolds.push(hold);
							ignoreSustains(hold.column, hold.startTime, hold.endTime);
						}

// Don't lose health or count misses in botplay, or on a frame right after a lag spike
// (the player had no real chance to react during the stall - that's not their fault)
if (!botplayMode && !isLagSpike)
{
	health -= 0.0375;
	vocals.volume = 0;
	if (theFunne)
		noteMiss(daNote.noteData);
}
					}

					daNote.active = false;
					daNote.visible = false;

					daNote.kill();
					notes.remove(daNote, true);
					daNote.destroy();
				}
			});
		}

		if (!inCutscene)
			keyShit();

		updateSustainHolds();

		#if debug
		if (FlxG.keys.justPressed.ONE)
			endSong();
		#end
	}

	function updateCosmosEvents():Void
	{
		if (cosmosEvents.length == 0)
			return;

		while (cosmosEventIndex < cosmosEvents.length && Conductor.songPosition >= cosmosEvents[cosmosEventIndex].time)
		{
			var ev:CosmosEvent = cosmosEvents[cosmosEventIndex];
			triggerCosmosEvent(ev.name, ev.value1, ev.value2);
			cosmosEventIndex++;
		}
	}

function triggerCosmosEvent(name:String, value1:String, value2:String):Void
{
	switch (name)
	{
		case "Flash Camera":
			doFlashCamera(FlxColor.WHITE, Std.parseFloat(value1));

		case "Flash Camera2":
			doFlashCamera(FlxColor.BLACK, Std.parseFloat(value1));

		case "Set Cam Zoom":
			if (value1 != null && value1 != "")
			{
				defaultCamZoom = Std.parseFloat(value1);
				camZooming = true;
			}

		case "Change Character":
			if (value1 == "dad")
				switchDadCharacter(value2);

		case "Change Stage":
			changeStage(value1);

		case "Reposition Character":
			repositionCharacter(value1, value2);
	}
}

	function doFlashCamera(color:FlxColor, duration:Float):Void
	{
		if (flashSprite != null)
		{
			remove(flashSprite, true);
			flashSprite.destroy();
			flashSprite = null;
		}

		flashSprite = new FlxSprite(0, 0);
		flashSprite.makeGraphic(1280, 720, color);
		flashSprite.scrollFactor.set(0, 0);
		flashSprite.scale.set(2, 2);
		flashSprite.alpha = 1;
		add(flashSprite);

		FlxTween.tween(flashSprite, {alpha: 0}, duration, {ease: FlxEase.linear});
	}

function switchDadCharacter(newChar:String):Void
{
	if (dad == null || newChar == null || newChar == "" || dad.curCharacter == newChar)
		return;

	var oldX:Float = dad.x;
	var oldY:Float = dad.y;
	var wasFlipped:Bool = dad.flipX;
	var dadIndex:Int = members.indexOf(dad);

	remove(dad, true);
	dad.destroy();

	dad = new Character(oldX, oldY, newChar);
	dad.flipX = wasFlipped;

	if (dadIndex >= 0)
		insert(dadIndex, dad);
	else
		add(dad);

	dad.dance();

	if (iconP2 != null)
		iconP2.changeIcon(newChar);
}

function changeStage(newStage:String):Void
{
	if (newStage == "suppression")
	{
		// Remove all existing stage sprites using a while loop
		var i:Int = members.length - 1;
		while (i >= 0)
		{
			var member:FlxBasic = members[i];
			if (Std.is(member, FlxSprite))
			{
				var sprite:FlxSprite = cast member;
				// Don't remove characters or UI elements
				if (sprite != dad && sprite != gf && sprite != boyfriend && 
					sprite != healthBar && sprite != healthBarBG && 
					sprite != iconP1 && sprite != iconP2 && sprite != scoreTxt &&
					sprite != flashSprite && sprite != strumLine)
				{
					// Check if it's NOT a strum note
					var isStrumNote:Bool = false;
					for (strum in strumLineNotes.members)
					{
						if (sprite == strum)
						{
							isStrumNote = true;
							break;
						}
					}
					
					if (!isStrumNote)
					{
						// Check if it's a background element
						if (sprite.cameras == null || sprite.cameras.length == 0 || sprite.cameras[0] == camGame)
						{
							remove(sprite, true);
							sprite.destroy();
						}
					}
				}
			}
			i--;
		}

		// Add Suppression stage
		defaultCamZoom = 1;
		curStage = 'suppression';
		
		// 3D World background
		var bg3d:FlxSprite = new FlxSprite(-300, -200).loadGraphic(Paths.image('backgrounds/3dworld'));
		bg3d.antialiasing = true;
		bg3d.scrollFactor.set(0.9, 0.9);
		bg3d.active = true;
		bg3d.setGraphicSize(Std.int(bg3d.width * 1));
		bg3d.updateHitbox();
		
		// Insert behind characters
		var gfIndex:Int = members.indexOf(gf);
		if (gfIndex >= 0)
			insert(gfIndex, bg3d);
		else
			add(bg3d);
		
		// Apply wavy shader to 3D world
		var wavyShader:Shaders.GlitchEffect = new Shaders.GlitchEffect();
		wavyShader.waveAmplitude = 0.1;
		wavyShader.waveFrequency = 5;
		wavyShader.waveSpeed = 2.25;
		bg3d.shader = wavyShader.shader;
		curbg = bg3d;
		
// Floating land platform
var floatLand:FlxSprite = new FlxSprite(315, 700).loadGraphic(Paths.image('backgrounds/land'));
floatLand.antialiasing = true;
floatLand.scrollFactor.set(1, 1);
floatLand.setGraphicSize(Std.int(floatLand.width * 1));
floatLand.updateHitbox();

// Add land BEFORE gf (so gf appears on top of land)
var gfIndex:Int = members.indexOf(gf);
if (gfIndex >= 0)
	insert(gfIndex, floatLand);
else
	add(floatLand);
	
trace('Land added at position: ' + floatLand.x + ', ' + floatLand.y);
	}
}

function repositionCharacter(character:String, position:String):Void
{
	var pos:Array<String> = position.split(",");
	if (pos.length != 2) return;
	
	var newX:Float = Std.parseFloat(pos[0]);
	var newY:Float = Std.parseFloat(pos[1]);
	
	switch (character)
	{
		case "dad":
			dad.setPosition(newX, newY);
			trace('Dad repositioned to: ' + newX + ', ' + newY);
		case "gf":
			gf.setPosition(newX, newY);
			trace('GF repositioned to: ' + newX + ', ' + newY);
		case "bf" | "boyfriend":
			boyfriend.setPosition(newX, newY);
			trace('BF repositioned to: ' + newX + ', ' + newY);
	}
}

function ZoomCam(focusondad:Bool):Void
	{
		if (camFollow.x != dad.getMidpoint().x + 150 && focusondad || camFollow.y != dad.getMidpoint().y - 100 && focusondad)
		{
			camFollow.setPosition(dad.getMidpoint().x + 150, dad.getMidpoint().y - 100);

			switch (dad.curCharacter)
			{
				case 'gf':
					camFollow.y = dad.getMidpoint().y;
			}

			if (SONG.song.toLowerCase() == 'tutorial')
			{
				tweenCamIn();
			}
		}

		if (camFollow.x != boyfriend.getMidpoint().x - 100 && !focusondad || camFollow.y != boyfriend.getMidpoint().y - 100 && !focusondad)
		{
			camFollow.setPosition(boyfriend.getMidpoint().x - 100, boyfriend.getMidpoint().y - 100);

			if (SONG.song.toLowerCase() == 'tutorial')
			{
				FlxTween.tween(FlxG.camera, {zoom: 1}, (Conductor.stepCrochet * 4 / 1000), {ease: FlxEase.elasticInOut});
			}
		}
	}

	function endSong():Void
	{
		inCutscene = false;
		canPause = false;
		FlxG.sound.music.volume = 0;
		vocals.volume = 0;
		
		if (SONG.validScore)
		{
			#if !switch
			Highscore.saveScore(SONG.song, songScore, storyDifficulty, characteroverride == "none"
				|| characteroverride == "bf" ? "bf" : characteroverride);
			#end
		}

		if (isStoryMode)
		{
			campaignScore += songScore;

			storyPlaylist.remove(storyPlaylist[0]);

			if (storyPlaylist.length <= 0)
			{
				FlxG.switchState(new StoryMenuState());
				transIn = FlxTransitionableState.defaultTransIn;
				transOut = FlxTransitionableState.defaultTransOut;

				StoryMenuState.weekUnlocked[Std.int(Math.min(storyWeek + 1, StoryMenuState.weekUnlocked.length - 1))] = true;

				if (SONG.validScore)
				{
					NGio.unlockMedal(60961);
					Highscore.saveWeekScore(storyWeek, campaignScore,
						storyDifficulty, characteroverride == "none" || characteroverride == "bf" ? "bf" : characteroverride);
				}

				FlxG.save.data.weekUnlocked = StoryMenuState.weekUnlocked;
				FlxG.save.flush();
			}
			else
			{
				var difficulty:String = "";

				if (storyDifficulty == 0)
					difficulty = '-easy';

				if (storyDifficulty == 2)
					difficulty = '-hard';

				FlxTransitionableState.skipNextTransIn = true;
				FlxTransitionableState.skipNextTransOut = true;
				prevCamFollow = camFollow;

				PlayState.SONG = Song.loadFromJson(PlayState.storyPlaylist[0].toLowerCase() + difficulty, PlayState.storyPlaylist[0]);
				FlxG.sound.music.stop();
				
				LoadingState.loadAndSwitchState(new PlayState());
			}
		}
		else
		{
			FlxG.switchState(new FreeplayState());
		}
	}

	var endingSong:Bool = false;
	var songScore:Int = 0;

	private function popUpScore(strumtime:Float, notedata:Int):Void
	{
		var noteDiff:Float = Math.abs(strumtime - Conductor.songPosition);
		vocals.volume = 1;

		var placement:String = Std.string(combo);

		var coolText:FlxText = new FlxText(0, 0, 0, placement, 32);
		coolText.screenCenter();
		coolText.x = FlxG.width * 0.55;

		var rating:FlxSprite = new FlxSprite();
		var score:Int = 350;

		var daRating:String = "sick";

		if (noteDiff > Conductor.safeZoneOffset * 2)
		{
			daRating = 'shit';
			totalNotesHit -= 2;
			score = -3000;
			ss = false;
			shits++;
		}
		else if (noteDiff < Conductor.safeZoneOffset * -2)
		{
			daRating = 'shit';
			totalNotesHit -= 2;
			score = -3000;
			ss = false;
			shits++;
		}
		else if (noteDiff > Conductor.safeZoneOffset * 0.45)
		{
			daRating = 'bad';
			score = -1000;
			totalNotesHit += 0.2;
			ss = false;
			bads++;
		}
		else if (noteDiff > Conductor.safeZoneOffset * 0.25)
		{
			daRating = 'good';
			totalNotesHit += 0.65;
			score = 200;
			ss = false;
			goods++;
		}
		if (daRating == 'sick')
		{
			totalNotesHit += 1;
			sicks++;
		}
		
		switch (notedata)
		{
			case 2:
				score = cast(FlxMath.roundDecimal(cast(score, Float) * curmult[2], 0), Int);
			case 3:
				score = cast(FlxMath.roundDecimal(cast(score, Float) * curmult[1], 0), Int);
			case 1:
				score = cast(FlxMath.roundDecimal(cast(score, Float) * curmult[3], 0), Int);
			case 0:
				score = cast(FlxMath.roundDecimal(cast(score, Float) * curmult[0], 0), Int);
		}

		if (daRating != 'shit' || daRating != 'bad')
		{
			songScore += score;

			var pixelShitPart1:String = "";
			var pixelShitPart2:String = '';

			rating.loadGraphic(Paths.image(pixelShitPart1 + daRating + pixelShitPart2));
			rating.screenCenter();
			rating.x = coolText.x - 40;
			rating.y -= 60;
			rating.acceleration.y = 550;
			rating.velocity.y -= FlxG.random.int(140, 175);
			rating.velocity.x -= FlxG.random.int(0, 10);

			var comboSpr:FlxSprite = new FlxSprite().loadGraphic(Paths.image(pixelShitPart1 + 'combo' + pixelShitPart2));
			comboSpr.screenCenter();
			comboSpr.x = coolText.x;
			comboSpr.acceleration.y = 600;
			comboSpr.velocity.y -= 150;

			comboSpr.velocity.x += FlxG.random.int(1, 10);
			add(rating);

			rating.setGraphicSize(Std.int(rating.width * 0.7));
			rating.antialiasing = true;
			comboSpr.setGraphicSize(Std.int(comboSpr.width * 0.7));
			comboSpr.antialiasing = true;

			comboSpr.updateHitbox();
			rating.updateHitbox();

			var seperatedScore:Array<Int> = [];

			var comboSplit:Array<String> = (combo + "").split('');

			if (comboSplit.length == 2)
				seperatedScore.push(0);

			for (i in 0...comboSplit.length)
			{
				var str:String = comboSplit[i];
				seperatedScore.push(Std.parseInt(str));
			}

			var daLoop:Int = 0;
			for (i in seperatedScore)
			{
				var numScore:FlxSprite = new FlxSprite().loadGraphic(Paths.image(pixelShitPart1 + 'num' + Std.int(i) + pixelShitPart2));
				numScore.screenCenter();
				numScore.x = coolText.x + (43 * daLoop) - 90;
				numScore.y += 80;

				numScore.antialiasing = true;
				numScore.setGraphicSize(Std.int(numScore.width * 0.5));
				
				numScore.updateHitbox();

				numScore.acceleration.y = FlxG.random.int(200, 300);
				numScore.velocity.y -= FlxG.random.int(140, 160);
				numScore.velocity.x = FlxG.random.float(-5, 5);

				if (combo >= 10 || combo == 0)
					add(numScore);

				FlxTween.tween(numScore, {alpha: 0}, 0.2, {
					onComplete: function(tween:FlxTween)
					{
						numScore.destroy();
					},
					startDelay: Conductor.crochet * 0.002
				});

				daLoop++;
			}

			coolText.text = Std.string(seperatedScore);

			FlxTween.tween(rating, {alpha: 0}, 0.2, {
				startDelay: Conductor.crochet * 0.001
			});

			FlxTween.tween(comboSpr, {alpha: 0}, 0.2, {
				onComplete: function(tween:FlxTween)
				{
					coolText.destroy();
					comboSpr.destroy();

					rating.destroy();
				},
				startDelay: Conductor.crochet * 0.001
			});

			curSection += 1;
		}
	}

	public function NearlyEquals(value1:Float, value2:Float, unimportantDifference:Float = 10):Bool
	{
		return Math.abs(FlxMath.roundDecimal(value1, 1) - FlxMath.roundDecimal(value2, 1)) < unimportantDifference;
	}

	var upHold:Bool = false;
	var downHold:Bool = false;
	var rightHold:Bool = false;
	var leftHold:Bool = false;

	var pendingHolds:Array<SustainHold> = [null, null, null, null];
	var killedHolds:Array<SustainHold> = [];
	var missedHolds:Array<SustainHold> = [];

	private function keyShit():Void
	{
		var up = controls.UP;
		var right = controls.RIGHT;
		var down = controls.DOWN;
		var left = controls.LEFT;

		var upP = controls.UP_P;
		var rightP = controls.RIGHT_P;
		var downP = controls.DOWN_P;
		var leftP = controls.LEFT_P;

		var upR = controls.UP_R;
		var rightR = controls.RIGHT_R;
		var downR = controls.DOWN_R;
		var leftR = controls.LEFT_R;

		if (upR)
			releaseSustainHold(2);
		if (rightR)
			releaseSustainHold(3);
		if (downR)
			releaseSustainHold(1);
		if (leftR)
			releaseSustainHold(0);

		var controlArray:Array<Bool> = [leftP, downP, upP, rightP];

// Botplay auto-hit - only hit notes at perfect timing
// Also kicks in during the note-storm burst sections, so those parts play
// like botplay (no misses possible) while normal sections stay manual
if ((botplayMode || inNoteStorm) && generatedMusic)
{
	var pressedThisFrame:Array<Bool> = [false, false, false, false];
	
	notes.forEachAlive(function(daNote:Note)
	{
		if (daNote.mustPress && !daNote.wasGoodHit && !daNote.isSustainNote)
		{
			var hitWindow:Float = 10; // Perfect timing window in ms
			if (Math.abs(daNote.strumTime - Conductor.songPosition) <= hitWindow)
			{
				goodNoteHit(daNote);
				pressedThisFrame[daNote.noteData] = true;
			}
		}
	});
	
	// Handle sustain notes separately
	notes.forEachAlive(function(daNote:Note)
	{
		if (daNote.canBeHit && daNote.mustPress && daNote.isSustainNote && !daNote.wasGoodHit)
		{
			goodNoteHit(daNote);
			pressedThisFrame[daNote.noteData] = true;
		}
	});
	
	// Animate strums exactly like normal player input
	playerStrums.forEach(function(spr:FlxSprite)
	{
		var notePressed:Bool = pressedThisFrame[spr.ID];
		
		if (notePressed && spr.animation.curAnim.name != 'confirm')
		{
			spr.animation.play('confirm', true);
		}
		
		if (spr.animation.curAnim.name == 'confirm')
		{
			spr.centerOffsets();
			spr.offset.x -= 13;
			spr.offset.y -= 13;
		}
		else
		{
			spr.centerOffsets();
		}
		
		// Reset to static when confirm animation finishes
		if (spr.animation.curAnim.name == 'confirm' && spr.animation.curAnim.finished)
		{
			spr.animation.play('static');
			spr.centerOffsets();
		}
	});
	
	return; // Don't process player input in botplay mode
}

if ((upP || rightP || downP || leftP) && !boyfriend.stunned && generatedMusic)
{
			boyfriend.holdTimer = 0;

			var possibleNotes:Array<Note> = [];

			var ignoreList:Array<Int> = [];

			notes.forEachAlive(function(daNote:Note)
			{
				if (daNote.canBeHit && daNote.mustPress && !daNote.tooLate)
				{
					possibleNotes.push(daNote);
					possibleNotes.sort((a, b) -> Std.int(a.strumTime - b.strumTime));

					ignoreList.push(daNote.noteData);
				}
			});

			if (possibleNotes.length > 0)
			{
				var daNote = possibleNotes[0];

				if (perfectMode)
					noteCheck(true, daNote);

				if (possibleNotes.length >= 2)
				{
					if (possibleNotes[0].strumTime == possibleNotes[1].strumTime)
					{
						for (coolNote in possibleNotes)
						{
							if (controlArray[coolNote.noteData])
								goodNoteHit(coolNote);
							else
							{
								var inIgnoreList:Bool = false;
								for (shit in 0...ignoreList.length)
								{
									if (controlArray[ignoreList[shit]])
										inIgnoreList = true;
								}
								if (!inIgnoreList && !theFunne)
									badNoteCheck(coolNote);
							}
						}
					}
					else if (possibleNotes[0].noteData == possibleNotes[1].noteData)
					{
						noteCheck(controlArray[daNote.noteData], daNote);
					}
					else
					{
						for (coolNote in possibleNotes)
						{
							noteCheck(controlArray[coolNote.noteData], coolNote);
						}
					}
				}
				else
				{
					noteCheck(controlArray[daNote.noteData], daNote);
				}

				if (daNote.wasGoodHit)
				{
					daNote.kill();
					notes.remove(daNote, true);
					daNote.destroy();
				}
			}
			else if (!theFunne)
			{
				badNoteCheck(null);
			}
		}

		if ((up || right || down || left) && generatedMusic)
		{
			notes.forEachAlive(function(daNote:Note)
			{
				if (daNote.canBeHit && daNote.mustPress && daNote.isSustainNote)
				{
					switch (daNote.noteData)
					{
						case 2:
							if (up || upHold)
								goodNoteHit(daNote);
						case 3:
							if (right || rightHold)
								goodNoteHit(daNote);
						case 1:
							if (down || downHold)
								goodNoteHit(daNote);
						case 0:
							if (left || leftHold)
								goodNoteHit(daNote);
					}
				}
			});
		}

		if (boyfriend.holdTimer > Conductor.stepCrochet * 4 * 0.001 && !up && !down && !right && !left)
		{
			if (boyfriend.animation.curAnim.name.startsWith('sing') && !boyfriend.animation.curAnim.name.endsWith('miss'))
			{
				boyfriend.playAnim('idle');
			}
		}

		playerStrums.forEach(function(spr:FlxSprite)
		{
			switch (spr.ID)
			{
				case 2:
					if (upP && spr.animation.curAnim.name != 'confirm')
					{
						spr.animation.play('pressed');
					}
					if (upR)
					{
						spr.animation.play('static');
					}
				case 3:
					if (rightP && spr.animation.curAnim.name != 'confirm')
						spr.animation.play('pressed');
					if (rightR)
					{
						spr.animation.play('static');
					}
				case 1:
					if (downP && spr.animation.curAnim.name != 'confirm')
						spr.animation.play('pressed');
					if (downR)
					{
						spr.animation.play('static');
					}
				case 0:
					if (leftP && spr.animation.curAnim.name != 'confirm')
						spr.animation.play('pressed');
					if (leftR)
					{
						spr.animation.play('static');
					}
			}

			if (spr.animation.curAnim.name == 'confirm')
			{
				spr.centerOffsets();
				spr.offset.x -= 13;
				spr.offset.y -= 13;
			}
			else
				spr.centerOffsets();
		});
	}

	function noteMiss(direction:Int = 1):Void
	{
		if (!boyfriend.stunned)
		{
			health -= 0.02;
			if (combo > 5 && gf.animOffsets.exists('sad'))
			{
				gf.playAnim('sad');
			}
			combo = 0;
			misses++;

			songScore -= 10;

			FlxG.sound.play(Paths.soundRandom('missnote', 1, 3), FlxG.random.float(0.1, 0.2));
			
			if (boyfriend.animation.getByName("singLEFTmiss") != null)
			{
				var fuckingDumbassBullshitFuckYou:String;
				fuckingDumbassBullshitFuckYou = notestuffs[Math.round(Math.abs(direction)) % 4];
				if(!boyfriend.nativelyPlayable)
				{
					switch(notestuffs[Math.round(Math.abs(direction)) % 4])
					{
						case 'LEFT':
							fuckingDumbassBullshitFuckYou = 'RIGHT';
						case 'RIGHT':
							fuckingDumbassBullshitFuckYou = 'LEFT';
					}
				}
				boyfriend.playAnim('sing' + fuckingDumbassBullshitFuckYou + "miss", true);
			}
			else
			{
				boyfriend.color = 0xFF000084;
				var fuckingDumbassBullshitFuckYou:String;
				fuckingDumbassBullshitFuckYou = notestuffs[Math.round(Math.abs(direction)) % 4];
				if(!boyfriend.nativelyPlayable)
				{
					switch(notestuffs[Math.round(Math.abs(direction)) % 4])
					{
						case 'LEFT':
							fuckingDumbassBullshitFuckYou = 'RIGHT';
						case 'RIGHT':
							fuckingDumbassBullshitFuckYou = 'LEFT';
					}
				}
				boyfriend.playAnim('sing' + fuckingDumbassBullshitFuckYou, true);
			}

			updateAccuracy();
		}
	}

	function badNoteCheck(note:Note = null)
	{
		if (note != null)
		{
			noteMiss(note.noteData);
			return;
		}

		// Ghost tapping (pressing a key when no note is in range) is not
		// penalized - matches Psych Engine's default behavior. Only actually
		// missing a real note (handled above / by the off-screen scroll check)
		// costs health or counts as a miss.
		updateAccuracy();
		return;
	}

	function updateAccuracy()
	{
		if (misses > 0 || accuracy < 96)
			fc = false;
		else
			fc = true;
		totalPlayed += 1;
		accuracy = totalNotesHit / totalPlayed * 100;
	}

	function noteCheck(keyP:Bool, note:Note):Void
	{
		if (keyP)
		{
			goodNoteHit(note);
		}
		else if (!theFunne)
		{
			badNoteCheck(note);
		}
	}

function goodNoteHit(note:Note):Void
{
	if (!note.wasGoodHit)
	{
		if (!note.isSustainNote && note.sustainLength > 0)
		{
			pendingHolds[note.noteData] = {
				column: note.noteData,
				startTime: note.strumTime,
				endTime: note.strumTime + note.sustainLength + 200
			};
		}

		// Don't count score/accuracy in botplay mode
		if (!botplayMode)
		{
			if (!note.isSustainNote)
			{
				popUpScore(note.strumTime, note.noteData);
				if (FlxG.save.data.donoteclick)
				{
					FlxG.sound.play(Paths.sound('note_click'));
				}
				combo += 1;
			}
			else
				totalNotesHit += 1;
		}

		if (note.noteData >= 0)
			health += 0.023;
		else
			health += 0.004;

		boyfriend.color = FlxColor.WHITE;

		var fuckingDumbassBullshitFuckYou:String;
		fuckingDumbassBullshitFuckYou = notestuffs[Math.round(Math.abs(note.noteData)) % 4];
		if(!boyfriend.nativelyPlayable)
		{
			switch(notestuffs[Math.round(Math.abs(note.noteData)) % 4])
			{
				case 'LEFT':
					fuckingDumbassBullshitFuckYou = 'RIGHT';
				case 'RIGHT':
					fuckingDumbassBullshitFuckYou = 'LEFT';
			}
		}
		
// Play sing animation and keep holding during sustains
if (!note.isSustainNote)
{
	boyfriend.playAnim('sing' + fuckingDumbassBullshitFuckYou, true);
	boyfriend.holdTimer = 0;
}
else
{
	// For sustain notes, keep the hold animation
	boyfriend.playAnim('sing' + fuckingDumbassBullshitFuckYou, true);
	boyfriend.holdTimer = 0;
}

		playerStrums.forEach(function(spr:FlxSprite)
		{
			if (Math.abs(note.noteData) == spr.ID)
			{
				spr.animation.play('confirm', true);
			}
		});

		note.wasGoodHit = true;
		vocals.volume = 1;

		note.kill();
		notes.remove(note, true);
		note.destroy();

		updateAccuracy();
	}
}

	function killSustains(col:Int, startTime:Float, endTime:Float):Void
	{
		notes.forEachAlive(function(daNote:Note)
		{
			if (daNote.isSustainNote
				&& daNote.mustPress
				&& daNote.noteData == col
				&& daNote.strumTime >= startTime
				&& daNote.strumTime <= endTime)
			{
				daNote.wasGoodHit = true;
				daNote.kill();
				notes.remove(daNote, true);
				daNote.destroy();
			}
		});
	}

	function ignoreSustains(col:Int, startTime:Float, endTime:Float):Void
	{
		notes.forEachAlive(function(daNote:Note)
		{
			if (daNote.isSustainNote
				&& daNote.mustPress
				&& daNote.noteData == col
				&& daNote.strumTime >= startTime
				&& daNote.strumTime <= endTime)
			{
				daNote.mustPress = false;
				daNote.kill();
				notes.remove(daNote, true);
				daNote.destroy();
			}
		});
	}

	function releaseSustainHold(col:Int):Void
	{
		if (pendingHolds[col] != null)
		{
			var hold:SustainHold = pendingHolds[col];
			killedHolds.push(hold);
			pendingHolds[col] = null;
			killSustains(hold.column, hold.startTime, hold.endTime);
		}
	}

	function updateSustainHolds():Void
	{
		var currentTime:Float = Conductor.songPosition;

		for (col in 0...4)
		{
			if (pendingHolds[col] != null && currentTime > pendingHolds[col].endTime)
				pendingHolds[col] = null;
		}

		var i:Int = killedHolds.length - 1;
		while (i >= 0)
		{
			var hold:SustainHold = killedHolds[i];
			if (currentTime <= hold.endTime)
				killSustains(hold.column, hold.startTime, hold.endTime);
			else
				killedHolds.splice(i, 1);
			i--;
		}

		i = missedHolds.length - 1;
		while (i >= 0)
		{
			var hold:SustainHold = missedHolds[i];
			if (currentTime <= hold.endTime)
				ignoreSustains(hold.column, hold.startTime, hold.endTime);
			else
				missedHolds.splice(i, 1);
			i--;
		}
	}

	override function stepHit()
	{
		super.stepHit();
		if (FlxG.sound.music.time > Conductor.songPosition + 20 || FlxG.sound.music.time < Conductor.songPosition - 20)
		{
			resyncVocals();
		}

		#if desktop
		DiscordClient.changePresence(detailsText
			+ " "
			+ SONG.song
			+ " ("
			+ storyDifficultyText
			+ ") ",
			"Acc: "
			+ truncateFloat(accuracy, 2)
			+ "% | Score: "
			+ songScore
			+ " | Misses: "
			+ misses, iconRPC, true,
			FlxG.sound.music.length
			- Conductor.songPosition);
		#end
	}

	var lightningStrikeBeat:Int = 0;
	var lightningOffset:Int = 8;

	override function beatHit()
	{
		super.beatHit();

		if (generatedMusic)
		{
			notes.sort(FlxSort.byY, FlxSort.DESCENDING);
		}

		dadStrums.forEach(function(spr:FlxSprite)
		{
			if (spr.animation.curAnim.curFrame == (spr.animation.curAnim.numFrames - 1))
			{
				spr.animation.play('static', false);
				spr.centerOffsets();
			}
		});

		if (SONG.notes[Math.floor(curStep / 16)] != null)
		{
			if (SONG.notes[Math.floor(curStep / 16)].changeBPM)
			{
				Conductor.changeBPM(SONG.notes[Math.floor(curStep / 16)].bpm);
			}
		}
		
		if (dad.animation.finished)
		{
			switch (SONG.song.toLowerCase())
			{
				case 'tutorial':
					dad.dance();
				default:
					if (dad.holdTimer <= 0)
					{
						dad.dance();
					}
			}
		}

		if (camZooming && FlxG.camera.zoom < 1.35 && curBeat % 4 == 0)
		{
			FlxG.camera.zoom += 0.015;
			camHUD.zoom += 0.03;
		}

		var funny:Float = (healthBar.percent * 0.01) + 0.01;

		iconP1.setGraphicSize(Std.int(iconP1.width + (50 * funny)),Std.int(iconP2.height - (25 * funny)));
		iconP2.setGraphicSize(Std.int(iconP2.width + (50 * (2 - funny))),Std.int(iconP2.height - (25 * (2 - funny))));

		iconP1.updateHitbox();
		iconP2.updateHitbox();

		if (curBeat % gfSpeed == 0)
		{
			gf.dance();
		}

if (!boyfriend.animation.curAnim.name.startsWith("sing"))
{
	boyfriend.playAnim('idle');
	boyfriend.color = FlxColor.WHITE;
}
else if (botplayMode && boyfriend.animation.curAnim.finished)
{
	// Return to idle when sing animation finishes in botplay
	boyfriend.playAnim('idle');
	boyfriend.color = FlxColor.WHITE;
}

// Reset strum animations in botplay when not pressing
if (botplayMode)
{
	playerStrums.forEach(function(spr:FlxSprite)
	{
		if (spr.animation.curAnim.name == 'confirm' && spr.animation.curAnim.finished)
		{
			spr.animation.play('static');
			spr.centerOffsets();
		}
	});
}

		if (curBeat % 8 == 7 && SONG.song == 'Tutorial' && dad.curCharacter == 'gf')
		{
			dad.playAnim('cheer', true);
			boyfriend.playAnim('hey', true);
		}

		switch (SONG.song.toLowerCase())
		{
			case 'suppression':
				switch (curStep)
				{
					case 1023 | 1280 | 2304 | 2560 | 2816:
						shakeCam = true;
						if (eyesoreson)
						{
							FlxG.camera.flash(FlxColor.WHITE, 0.3);
							preEyesoreCamZoom = defaultCamZoom;
							defaultCamZoom = 0.8;
						}
					case 1152 | 1408 | 2432 | 2688 | 3072:
						shakeCam = false;
						if (eyesoreson)
							defaultCamZoom = preEyesoreCamZoom;
				}
case 'done forever':
	// section 16 == curStep 256 (16 steps per section)
	if (!doneForeverRevealed && Std.int(curStep / 16) >= 16)
	{
		doneForeverRevealed = true;

		dad.visible = true;
		FlxG.camera.flash(FlxColor.WHITE, 0.3);

		// tween creation deferred one tick so it doesn't land on the exact same
		// frame as the flash + note-spawn work happening this beat
		new FlxTimer().start(0.02, function(tmr:FlxTimer)
		{
			FlxTween.tween(dad, {alpha: 1}, Conductor.crochet / 1000, {ease: FlxEase.quadOut});
		});
	}

	// Eyesore effect during the dense opponent note-storm bursts
	// (sections 32-35, 40-43, 82-85, 90-93 - 16 steps per section)
	switch (curStep)
	{
		case 512 | 640 | 1312 | 1440:
			shakeCam = true;
			inNoteStorm = true;
			if (eyesoreson)
			{
				FlxG.camera.flash(FlxColor.WHITE, 0.3);
				preEyesoreCamZoom = defaultCamZoom;
				defaultCamZoom = 0.8;
			}
		case 576 | 704 | 1376 | 1504:
			shakeCam = false;
			inNoteStorm = false;
			misses = 0; // Reset misses when eyesore effect ends!
			if (eyesoreson)
				defaultCamZoom = preEyesoreCamZoom;
	}

	// Once the chart's last note has passed, fade dad out for the
	// rest of the song (last note ends ~175.45s, song runs to 3:15/195s)
	if (!doneForeverFading && Conductor.songPosition >= 175448)
	{
		doneForeverFading = true;
		FlxTween.tween(dad, {alpha: 0}, (195000 - 175448) / 1000, {ease: FlxEase.quadOut});
	}
		}
	}

	var curLight:Int = 0;
	var doneForeverRevealed:Bool = false;
	var doneForeverFading:Bool = false;
	var inNoteStorm:Bool = false;
}