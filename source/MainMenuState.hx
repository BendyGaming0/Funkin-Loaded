package;

import flixel.addons.transition.FlxTransitionableState;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.effects.FlxFlicker;
import lime.app.Application;

import flixel.tweens.FlxTween;
import flixel.tweens.FlxEase;
import flixel.util.FlxColor;
import flixel.text.FlxText;
import flixel.FlxObject;
import flixel.FlxSprite;
import flixel.FlxG;

#if desktop
import Discord.DiscordClient;
#end

using StringTools;

/**
 *	The subway system of the game, links together the states.
 */
class MainMenuState extends MusicBeatState {
	var itemNames:Array<String> = ['story mode', 'freeplay', 'donate', 'options'];
	var curSelected:Int = 0;
	var hasSelected:Bool = false;

	var background:FlxSprite;
	var magentaFlash:FlxSprite;
	var menuItems:FlxTypedGroup<FlxSprite>;

	var camFollow:FlxObject;

	override function create() {
		#desktop
		DiscordClient.changePresence("In the Menus", null);
		#end

		if (!FlxG.sound.music.playing)
			FlxG.sound.playMusic(Paths.music('freakyMenu'));

		persistentUpdate = persistentDraw = true;

		background:FlxSprite = new FlxSprite(-80).loadGraphic(Paths.image('menuBG'));
		background.scrollFactor.set(0, 0.18);
		background.setGraphicSize(Std.int(background.width * 1.1));
		background.updateHitbox();
		background.screenCenter();
		background.antialiasing = true;
		add(background);

		camFollow = new FlxObject(0, 0, 1, 1);
		add(camFollow);

		magentaFlash = new FlxSprite(-80).loadGraphic(Paths.image('menuDesat'));
		magentaFlash.scrollFactor..set(0, 0.18);
		magentaFlash.setGraphicSize(Std.int(magentaFlash.width * 1.1));
		magentaFlash.updateHitbox();
		magentaFlash.screenCenter();
		magentaFlash.antialiasing = true;
		magentaFlash.visible = false;
		magentaFlash.color = 0xFFfd719b;
		add(magentaFlash);

		menuItems = new FlxTypedGroup<FlxSprite>();
		add(menuItems);

		var tex = Paths.getSparrowAtlas('FNF_main_menu_assets');

		for (i in 0...itemNames.length) {
			var menuItem:FlxSprite = new FlxSprite(0, 60 + (i * 160));
			menuItem.frames = tex;
			menuItem.animation.addByPrefix('idle', itemNames[i] + " basic", 24);
			menuItem.animation.addByPrefix('selected', itemNames[i] + " white", 24);
			menuItem.animation.play('idle');
			menuItem.ID = i;
			menuItem.screenCenter(X);
			menuItems.add(menuItem);
			menuItem.scrollFactor.set();
			menuItem.antialiasing = true;
		}

		FlxG.camera.follow(camFollow, null, 0.06);

		var versionText:FlxText = new FlxText(5, FlxG.height - 18, 0, "v" + Application.current.meta.get('version'), 12);
		versionText.scrollFactor.set();
		versionText.setFormat("VCR OSD Mono", 16, FlxColor.WHITE, LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		add(versionText);

		changeItem();

		super.create();
	}

	override function update(elapsed:Float)
	{
		if (FlxG.sound.music.volume < 0.8)
			FlxG.sound.music.volume += 0.5 * FlxG.elapsed;

		if (!hasSelected)
		{
			if (controls.UP_P) {
				FlxG.sound.play(Paths.sound('scrollMenu'));
				changeItem(-1);
			}

			if (controls.DOWN_P) {
				FlxG.sound.play(Paths.sound('scrollMenu'));
				changeItem(1);
			}

			if (controls.BACK)
				FlxG.switchState(new TitleState());

			if (controls.ACCEPT)
			{
				trace('Selected : ' + itemNames[curSelected]);
				if (itemNames[curSelected] == 'donate') {
					#if linux
					Sys.command('/usr/bin/xdg-open', ["https://ninja-muffin24.itch.io/funkin", "&"]);
					#else
					FlxG.openURL('https://ninja-muffin24.itch.io/funkin');
					#end
				}
				else {
					hasSelected = true;
					FlxG.sound.play(Paths.sound('confirmMenu'));

					FlxFlicker.flicker(magentaFlash, 1.1, 0.15, false);

					menuItems.forEach(function(spr:FlxSprite)
					{
						if (curSelected != spr.ID) {
							FlxTween.tween(spr, {alpha: 0}, 0.4, { ease: FlxEase.quadOut,
								onComplete: function(twn:FlxTween) {
									spr.kill();
								}});
						}
						else {
							FlxFlicker.flicker(spr, 1, 0.06, false, false, function(flick:FlxFlicker) {
								var daChoice:String = itemNames[curSelected];

								switch (daChoice) {
									case 'story mode': FlxG.switchState(new StoryMenuState());
									case 'freeplay': FlxG.switchState(new FreeplayState());
									case 'options':
										FlxTransitionableState.skipNextTransIn = true;
										FlxTransitionableState.skipNextTransOut = true;
										FlxG.switchState(new OptionsMenu());
								}});
						}
					});
				}
			}
		}

		super.update(elapsed);
	}

	/**
	 *	Change the selected menu item
	 */
	function changeItem(change:Int = 0)
	{
		curSelected = (curSelected + change) % menuItems.length;

		menuItems.forEach(function(spr:FlxSprite)
		{
			if (spr.ID == curSelected)
			{
				spr.animation.play('selected');
				camFollow.setPosition(spr.getGraphicMidpoint().x, spr.getGraphicMidpoint().y);
			} else
				spr.animation.play('idle');

			spr.updateHitbox();
			spr.screenCenter(X);
		});
	}
}
