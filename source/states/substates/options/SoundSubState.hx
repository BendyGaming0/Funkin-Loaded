package states.substates.options;

import flixel.util.FlxColor;
import flixel.text.FlxText;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.FlxSprite;

class SoundSubState extends MusicBeatSubstate
{
    var textMenuItems:Array<String> = ['Back', 'Menus', 'SFX', 'Miss', 'Dialouge'];

	var selector:FlxSprite;
	var curSelected:Int = 0;

	var grpOptionsTexts:FlxTypedGroup<FlxText>;

	public function new()
	{
		super();

        bgColor = 0x80000000;

		grpOptionsTexts = new FlxTypedGroup<FlxText>();
		add(grpOptionsTexts);

		selector = new FlxSprite(10, 20).makeGraphic(4, 32, FlxColor.BLUE);
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
        selector.color = switch (textMenuItems[curSelected])
        {
            case "Back": FlxColor.RED;
            case "Menus": FlxG.save.data.sounds.menu_muted ? FlxColor.RED : FlxColor.BLUE;
            case "SFX": FlxG.save.data.sounds.sfx_muted ? FlxColor.RED : FlxColor.BLUE;
            case "Miss": FlxG.save.data.sounds.miss_muted ? FlxColor.RED : FlxColor.BLUE;
            case "Dialouge": FlxG.save.data.sounds.dialouge_muted ? FlxColor.RED : FlxColor.BLUE;
            default: FlxColor.BLUE;
        }

        if (controls.ACCEPT)
        {
            switch (textMenuItems[curSelected])
            {
                case "Back": close();
                case "Menus": FlxG.save.data.sounds.menu_muted = !FlxG.save.data.sounds.menu_muted;
                case "SFX": FlxG.save.data.sounds.sfx_muted = !FlxG.save.data.sounds.sfx_muted;
                case "Miss": FlxG.save.data.sounds.miss_muted = !FlxG.save.data.sounds.miss_muted;
                case "Dialouge": FlxG.save.data.sounds.dialouge_muted = !FlxG.save.data.sounds.dialouge_muted;
            }
        }
    }
}