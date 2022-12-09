package states;

import utilities.ExpControls;
import utilities.Conductor;
import flixel.addons.ui.FlxUIState;

import utilities.Conductor.BPMChangeEvent;
import utilities.Controls;
import utilities.PlayerSettings;

class MusicBeatState extends FlxUIState
{
	private var lastBeat:Float = 0;
	private var lastStep:Float = 0;

	var curStep:Int = 0;
	var curBeat:Int = 0;

	public var controls(get, never):Controls;

	inline function get_controls():Controls
		return PlayerSettings.player1.controls;

	public var exp_controls(get, never):ExpControls;

	inline function get_exp_controls():ExpControls
		return PlayerSettings.player1.expControls;

	override function create()
	{
		#if debug
		if (transIn != null)
			trace('Transition region : ' + transIn.region);
		#end

		super.create();
	}

	override function update(elapsed:Float)
	{
		var oldStep:Int = curStep;

		updateCurStep();
		curBeat = Math.floor(curStep / 4);

		if (oldStep != curStep && curStep > 0)
			stepHit();

		super.update(elapsed);
	}

	/**
	 * Calculates the current step (fourth of a beat)
	 */
	private function updateCurStep():Void
	{
		var lastChange:BPMChangeEvent = { stepTime: 0,
			songTime: 0, bpm: 0 };
		
		for (i in 0...Conductor.bpmChangeMap.length)
		{
			if (Conductor.songPosition >= Conductor.bpmChangeMap[i].songTime)
				lastChange = Conductor.bpmChangeMap[i];
		}

		curStep = lastChange.stepTime + Math.floor((Conductor.songPosition - lastChange.songTime) / Conductor.stepCrochet);
	}

	/**
	 * Ran 4 times in a beat if a song is playing
	 */
	public function stepHit():Void
	{
		if (curStep % 4 == 0)
			beatHit();
	}

	/**
	 * Ran when the song reaches a new beat if a song is playing
	 */
	public function beatHit():Void { }
}