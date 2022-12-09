package states.substates;

import flixel.addons.transition.FlxTransitionableState;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.text.FlxText;
import flixel.util.FlxColor;

import states.substates.options.*;

class OptionsSubState extends MusicBeatSubstate
{
	var textMenuItems:Array<String> = ['Back', 'Master Volume', 'Sound Volume', 'Controls', 'Mods'];

	var selector:FlxSprite;
	var curSelected:Int = 0;

	var grpOptionsTexts:FlxTypedGroup<FlxText>;

	public function new()
	{
		super();

		grpOptionsTexts = new FlxTypedGroup<FlxText>();
		add(grpOptionsTexts);

		selector = new FlxSprite(10, 20).makeGraphic(4, 32, FlxColor.YELLOW);
		add(selector);

		for (i in 0...textMenuItems.length)
		{
			var optionText:FlxText = new FlxText(20, 20 + (i * 50), 0, textMenuItems[i], 32);
			optionText.ID = i;
			grpOptionsTexts.add(optionText);
		}
	}

	override function update(elapsed:Float)
	{
		super.update(elapsed);

		if (controls.UP_P)
			curSelected -= 1;

		if (controls.DOWN_P)
			curSelected += 1;

		if (curSelected < 0)
			curSelected = textMenuItems.length - 1;

		if (curSelected >= textMenuItems.length)
			curSelected = 0;

		grpOptionsTexts.forEach(function(txt:FlxText)
		{
			txt.color = FlxColor.WHITE;

			if (txt.ID == curSelected)
				txt.color = FlxColor.YELLOW;
		});

        selector.y = 20 + (curSelected * 50);

		if (controls.ACCEPT)
		{
			switch (textMenuItems[curSelected])
			{
                case "Back": 
					close();
					if (FlxG.state is states.OptionsMenu) {
						FlxTransitionableState.skipNextTransIn = true;
						FlxTransitionableState.skipNextTransOut = true;
						FlxG.switchState(new MainMenuState());
					}
				case "Master Volume": FlxG.sound.muted = !FlxG.sound.muted;
				case "Sound Volume": openSubState(new SoundSubState());
				case "Controls": openSubState(new ControlsSubState());
			}
		}
	}
}
