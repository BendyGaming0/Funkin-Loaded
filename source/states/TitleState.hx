package states;

import flixel.input.keyboard.FlxKey;
import sys.FileSystem;
import openfl.Assets;
import openfl.net.SharedObject;

import flixel.input.actions.FlxAction.FlxActionDigital;
import flixel.addons.transition.FlxTransitionableState;
import flixel.addons.transition.TransitionData;
import flixel.math.FlxPoint;
import flixel.math.FlxRect;

import flixel.input.gamepad.FlxGamepad;
import flixel.group.FlxGroup;
import flixel.util.FlxColor;
import flixel.util.FlxTimer;
import flixel.FlxSprite;
import flixel.FlxG;

import objects.Alphabet;
import utilities.Conductor;
import utilities.PlayerSettings;
import utilities.Highscore;

#if desktop
import utilities.Discord.DiscordClient;
import lime.app.Application;
#end

using StringTools;

/**
 *	The first thing you see.
 *	The game's Title screen, checks version upon leaving
 */
class TitleState extends MusicBeatState
{
	/**
	 *	Whether or not this is the first time the title screen has been opened
	 */
	public static var initialized(default, null):Bool = false;

	/**
	 *	When HaxeFlixel initialized, including current date and time (incase they go past 12AM)
	 */
	public static var sessionStart(default, null):Date;

	public static var isOutdated(default, null):Bool = false;

	var blackScreen:FlxSprite;
	var credGroup:FlxGroup;
	var newgroundsLogo:FlxSprite;

	var logoBl:FlxSprite;
	var gfDance:FlxSprite;
	var titleText:FlxSprite;

	var danceLeft:Bool = false;
	//if the game's version has been checked yet
	var versionChecked:Bool = false;
	//if the intro has played yet
	var skippedIntro:Bool = false;

	/**
	 *	Currently selected intro text from `assets/data/introText.txt`
	 */
	var curIntroText:Array<String> = [];

	var enterControl:FlxActionDigital;

	override public function create():Void
	{
		if (!initialized) {
			sessionStart = Date.now();
			GameAssets.addLibrary('preload');
		}

		PlayerSettings.init();

		curIntroText = FlxG.random.getObject(getAllIntroText());

		super.create();

		//woah cool
		#if sys
		if (!FileSystem.exists('saves') && !FileSystem.isDirectory('saves'))
			FileSystem.createDirectory('saves');
		#end

		FlxG.save.bind('default', #if sys Sys.getCwd() + 'saves' #else 'ninjamuffin' #end);

		#if sys
		@:privateAccess
		FlxG.save._sharedObject.pathType = SystemPath;
		#end

		Highscore.load();

		if (FlxG.save.data.weekUnlocked != null)
		{
			// FIX LATER!!!
			// WEEK UNLOCK PROGRESSION!!
			// StoryMenuState.weekUnlocked = FlxG.save.data.weekUnlocked;

			if (StoryMenuState.weekUnlocked.length < 4)
				StoryMenuState.weekUnlocked.insert(0, true);

			// QUICK PATCH OOPS!
			if (!StoryMenuState.weekUnlocked[0])
				StoryMenuState.weekUnlocked[0] = true;
		}

		new FlxTimer().start(1, function(tmr:FlxTimer)
		{
			startIntro();
		});

		#if desktop
		DiscordClient.initialize();
		
		Application.current.onExit.add (function (exitCode) {
			DiscordClient.shutdown();
			trace('HaxeFlixel application failed to run, exited with error code:' + exitCode);
		 });
		#end
	}

	/**
	 *	Plays music, adds sprites and initializes some game data
	 */
	function startIntro()
	{
		if (!initialized)
		{
			FlxTransitionableState.defaultTransIn = new TransitionData(FADE, FlxColor.BLACK, 1, new FlxPoint(0, -1),
				new FlxRect(-200, -200, FlxG.width * 1.4, FlxG.height * 1.4));
			FlxTransitionableState.defaultTransOut = new TransitionData(FADE, FlxColor.BLACK, 0.7, new FlxPoint(0, 1),
				new FlxRect(-200, -200, FlxG.width * 1.4, FlxG.height * 1.4));

			transIn = FlxTransitionableState.defaultTransIn;
			transOut = FlxTransitionableState.defaultTransOut;

			// HAD TO MODIFY SOME BACKEND SHIT
			// IF THIS PR IS HERE IF ITS ACCEPTED UR GOOD TO GO
			// https://github.com/HaxeFlixel/flixel-addons/pull/348

			FlxG.sound.playMusic(Paths.music('freakyMenu'), 0);

			FlxG.sound.music.fadeIn(4, 0, 0.7);
		}

		Conductor.changeBPM(102);
		persistentUpdate = true;

		gfDance = new FlxSprite(FlxG.width * 0.4, FlxG.height * 0.07);
		gfDance.frames = Paths.getSparrowAtlas('gfDanceTitle');
		gfDance.animation.addByIndices('danceLeft', 'gfDance', [30, 0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14], "", 24, false);
		gfDance.animation.addByIndices('danceRight', 'gfDance', [15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29], "", 24, false);
		gfDance.antialiasing = true;
		add(gfDance);

		logoBl = new FlxSprite(-150, -100);
		logoBl.frames = Paths.getSparrowAtlas('logoBumpin');
		logoBl.antialiasing = true;
		logoBl.animation.addByPrefix('bump', 'logo bumpin', 24);
		logoBl.animation.play('bump');
		logoBl.updateHitbox();
		add(logoBl);

		titleText = new FlxSprite(100, FlxG.height * 0.8);
		titleText.frames = Paths.getSparrowAtlas('titleEnter');
		titleText.animation.addByPrefix('idle', "Press Enter to Begin", 24);
		titleText.animation.addByPrefix('press', "ENTER PRESSED", 24);
		titleText.antialiasing = true;
		titleText.animation.play('idle');
		titleText.updateHitbox();
		add(titleText);

		blackScreen = new FlxSprite().makeGraphic(FlxG.width, FlxG.height, FlxColor.BLACK);
		add(blackScreen);

		credGroup = new FlxGroup();
		add(credGroup);

		newgroundsLogo = new FlxSprite(0, FlxG.height * 0.52).loadGraphic(Paths.image('newgrounds_logo'));
		newgroundsLogo.visible = false;
		newgroundsLogo.setGraphicSize(Std.int(newgroundsLogo.width * 0.8));
		newgroundsLogo.updateHitbox();
		newgroundsLogo.screenCenter(X);
		newgroundsLogo.antialiasing = true;
		add(newgroundsLogo);

		FlxG.mouse.visible = false;

		enterControl = new FlxActionDigital("titleScreenEnter", titleShoot);
		enterControl.addGamepad(START, JUST_PRESSED);
		enterControl.addGamepad(A, JUST_PRESSED);
		enterControl.addKey(SPACE, JUST_PRESSED);
		enterControl.addKey(ENTER, JUST_PRESSED);

		if (initialized)
			skipIntro();
		else
			initialized = true;
	}

	/**
	 *	Gets all intro text from `assets/data/introText.txt` and converts it to an array
	 *	@return intro text as an `Array<Array<String>>`
	 */
	function getAllIntroText():Array<Array<String>>
	{
		var fullText:String = Assets.getText(Paths.txt('introText'));

		var firstArray:Array<String> = fullText.split('\n');
		var swagGoodArray:Array<Array<String>> = [];

		for (i in firstArray)
		{
			swagGoodArray.push(i.split('--'));
		}

		return swagGoodArray;
	}

	//debugging/testing
	var timestampA:Float = 0;
	var timestampB:Float = 0;

	override function update(elapsed:Float)
	{
		if (FlxG.sound.music != null)
			Conductor.songPosition = FlxG.sound.music.time;

		if (FlxG.keys.justPressed.F11)
			FlxG.fullscreen = !FlxG.fullscreen;

		if (enterControl != null)
			enterControl.check();

		super.update(elapsed);
	}      

	/**
	 * [Description]
	 * Progresses the title screen (skips the intro if not skipped/ended yet)
	 */
	function titleShoot(_):Void
	{
		timestampA = Sys.cpuTime();

		if (!skippedIntro) {
			skipIntro();
		}
		else if (!versionChecked) {
			titleText.animation.play('press');

			FlxG.camera.flash(FlxColor.WHITE, 1);
			FlxG.sound.play(Paths.sound('confirmMenu'), 0.7);

			versionChecked = true;

			new FlxTimer().start(2, function(tmr:FlxTimer)
			{
				//Disabled for now
				// Check if version is outdated
				/*
				var version:String = "v" + Application.current.meta.get('version');

				if (version.trim() != NGio.GAME_VER_NUMS.trim() && !OutdatedSubState.leftState)
				{
					isOutdated = true;
					trace('Outdated! | app ver. : ' + version.trim()
						+ ' | cur ver : ' + idk.trim());
				}
				else
				{*/
					FlxG.switchState(new MainMenuState());
				//}
			});
		}
	}

	/**
	 *	Creates and places text on the screen from and Array of strings
	 */
	function createCoolText(textArray:Array<String>)
	{
		for (i in 0...textArray.length)
		{
			var money:Alphabet = new Alphabet(0, 0, textArray[i], true, false);
			money.screenCenter(X);
			money.y += (i * 60) + 200;
			credGroup.add(money);
		}
	}

	/**
	 *	Adds one line of text
	 */
	function addMoreText(text:String)
	{
		var coolText:Alphabet = new Alphabet(0, 0, text, true, false);
		coolText.screenCenter(X);
		coolText.y += (credGroup.length * 60) + 200;
		credGroup.add(coolText);
	}

	/**
	 *	Removes all text from the screen
	 */
	function deleteCoolText()
	{
		while (credGroup.members.length > 0)
		{
			credGroup.remove(credGroup.members[0], true);
		}
	}

	override function beatHit()
	{
		super.beatHit();

		logoBl.animation.play('bump');
		danceLeft = !danceLeft;

		if (danceLeft)
			gfDance.animation.play('danceRight');
		else
			gfDance.animation.play('danceLeft');

		FlxG.log.add(curBeat);

		switch (curBeat)
		{
			case 1: createCoolText(['ninjamuffin99', 'phantomArcade', 'kawaisprite', 'evilsk8er']);
			case 3: addMoreText('present');
			case 4: deleteCoolText();
			case 5: createCoolText(['In association', 'with']);
			case 7: addMoreText('newgrounds'); newgroundsLogo.visible = true;
			case 8: deleteCoolText(); newgroundsLogo.visible = false;
			case 9: createCoolText([curIntroText[0]]);
			case 11: addMoreText(curIntroText[1]);
			case 12: deleteCoolText();
			case 13: addMoreText('Friday');
			case 14: addMoreText('Night');
			case 15: addMoreText('Funkin'); 
			case 16: skipIntro();
		}
	}

	/**
	 *	Removes some elements revealing the main title screen
	 */
	function skipIntro():Void
	{
		if (!skippedIntro)
		{
			FlxG.camera.flash(FlxColor.WHITE, 4);
			remove(newgroundsLogo);
			remove(credGroup);
			remove(blackScreen);
			blackScreen.destroy();
			blackScreen = null;
			skippedIntro = true;
		}
	}

	override function destroy():Void
	{
		super.destroy();
		enterControl.destroy();
		enterControl = null;
	}
}
