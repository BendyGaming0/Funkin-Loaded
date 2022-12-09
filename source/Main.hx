package;

import openfl.Lib;
import openfl.display.Sprite;
import openfl.events.Event;

import flixel.FlxGame;
import flixel.FlxState;

import utilities.FPS_Mem;
import states.TitleState;

/**
 * Starts the game system. Best left alone
 */
class Main extends Sprite
{
	// Width of the game in pixels.
	var gameWidth:Int = 1280; 
	// Height of the game in pixels.
	var gameHeight:Int = 720; 
	// The FlxState the game starts with.
	var initialState:Class<FlxState> = TitleState; 
	// If -1, zoom is automatically calculated to fit the window dimensions.
	var zoom:Float = -1; 
	// How many frames per second the game should run at.
	var framerate:Int = 60; 
	// Whether to skip the flixel splash screen that appears in release mode.
	var skipSplash:Bool = false; 
	// Whether to start the game in fullscreen on desktop targets
	var startFullscreen:Bool = false; 

	// You can pretty much ignore everything from here on - your code should go in your states.

	public static function main():Void
	{
		Lib.current.addChild(new Main());
	}

	public function new()
	{
		super();

		if (stage != null)
		{
			init();
		}
		else
		{
			addEventListener(Event.ADDED_TO_STAGE, init);
		}
	}

	private function init(?E:Event):Void
	{
		if (hasEventListener(Event.ADDED_TO_STAGE))
		{
			removeEventListener(Event.ADDED_TO_STAGE, init);
		}

		setupGame();
	}

	private function setupGame():Void
	{
		var stageWidth:Int = Lib.current.stage.stageWidth;
		var stageHeight:Int = Lib.current.stage.stageHeight;

		if (zoom == -1)
		{
			var ratioX:Float = stageWidth / gameWidth;
			var ratioY:Float = stageHeight / gameHeight;
			zoom = Math.min(ratioX, ratioY);
			gameWidth = Math.ceil(stageWidth / zoom);
			gameHeight = Math.ceil(stageHeight / zoom);
		}

		#if !debug
		initialState = TitleState;
		#end

		addChild(new FlxGame(gameWidth, gameHeight, initialState, zoom, framerate, framerate, skipSplash, startFullscreen));

		#if !mobile
		addChild(new FPS_Mem(10, 4, 0xFFFFFF));
		#end
	}
}
