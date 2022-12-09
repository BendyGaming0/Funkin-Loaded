package states.substates.options;

import flixel.FlxSprite;
import flixel.FlxSubState;

class ControlsSubState extends FlxSubState
{
	public function new()
	{
		super();
	}

	override function create()
	{
		super.create();
		close();
	}
}
