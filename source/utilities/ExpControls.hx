package utilities;

import haxe.Json;
import openfl.Assets;
import flixel.input.gamepad.FlxGamepadInputID;
import flixel.util.FlxSignal.FlxTypedSignal;
import flixel.input.keyboard.FlxKey;
import openfl.events.KeyboardEvent;

class ExpControls
{
    public var keys:Map<FlxKey, DigButton> = [];
    public var keyToBind:Map<FlxKey, String> = [];
    public var bindToKey:Map<String, FlxKey> = [];

    public var eventBinds:Map<String, KeyEventData> = [];

    var _justkeys:Array<DigButton> = [];

    public function new()
    {
		FlxG.stage.addEventListener(KeyboardEvent.KEY_DOWN, onKeyDown);
		FlxG.stage.addEventListener(KeyboardEvent.KEY_UP, onKeyUp);
        FlxG.signals.postUpdate.add(update);

        var jsonRaw = Assets.getText(Paths.json('controls'));
        var json:BindsFile = Json.parse(jsonRaw);
        setBindings(json.binds);
        trace('binds file : ' + json.binds);
    }

    function update()
    {
        for (i in _justkeys)
        {
            _justkeys.remove(i);
            i.justPressed = false;
            i.justReleased = false;
        }
    }

    function onKeyDown(event:KeyboardEvent):Void {
        //trace('key pressed');
        var code:FlxKey = event.keyCode;
        
        var button = getKeyButton(code);

        button.pressed = true;
        button.justPressed = true;
        button.released = false;

        button.justPressedEvn.dispatch();

        _justkeys.push(button);

        for (evn in eventBinds) 
            if (evn.keys.contains(code)) {evn.pressed(code);}
    }

    function onKeyUp(event:KeyboardEvent):Void {
        var code:FlxKey = event.keyCode;
        
        var button = getKeyButton(code);

        button.pressed = false;
        button.justReleased = true;
        button.released = true;

        button.justReleasedEvn.dispatch();

        _justkeys.push(button);

        for (evn in eventBinds) 
            if (evn.keys.contains(code)) evn.released(code);
    }

    public function getKeyButton(key:FlxKey):DigButton {
        if (!keys.exists(key))
            keys.set(key, new DigButton());

        return keys.get(key);
    }

    public function getMergedKeysButton(keys:Array<FlxKey>):DigButton {
        var merged = new DigButton();
        merged.released = false;
        for (key in keys) {
            var button = getKeyButton(key);
            if (button.justPressed) merged.justPressed = true;
            if (button.pressed) {merged.pressed = true; merged.justReleased = false;}
            if (button.justReleased && !merged.pressed) merged.justReleased = true;
        }
        if (!merged.pressed) merged.released = true;
        return merged;
    }

    public function setBindings(binds:Array<Binding>) {
        keyToBind.clear();
        bindToKey.clear();
        for (bind in binds) {
            bindToKey.set(bind.name, bind.main);
            bindToKey.set(bind.name + '_alt', bind.alt);
            keyToBind.set(bind.main, bind.name);
            keyToBind.set(bind.alt, bind.name + '_alt');
            //trace('set binding :' + bind.name + ' to ' + bind.main);
        }
    }

    public function changeBinding(bind:Binding) {
        bindToKey.set(bind.name, bind.main);
        bindToKey.set(bind.name + '_alt', bind.alt);
        keyToBind.set(bind.main, bind.name);
        keyToBind.set(bind.alt, bind.name + '_alt');
    }

    public function getAllBindKeys(bindName:String):Array<FlxKey> {
        //trace(bindToKey.get(bindName) + ' | ' + bindToKey.get(bindName+'_alt'));
        return [bindToKey.get(bindName), bindToKey.get(bindName+'_alt')];
    }

    public function getEveryBindsKeys(bindNames:Array<String>) {
        var keys:Array<FlxKey> = [];
        for (bind in bindNames) keys = keys.concat(getAllBindKeys(bind));
        //trace('all keys : '+keys);
        return keys;
    }
}

class DigButton
{
    public function new() {}

    public var justPressed:Bool = false;
    public var pressed:Bool = false;
    public var justReleased:Bool = false;
    public var released:Bool = true;

    public var justPressedEvn:FlxTypedSignal<() -> Void> = new FlxTypedSignal<() -> Void>();
    public var justReleasedEvn:FlxTypedSignal<() -> Void> = new FlxTypedSignal<() -> Void>();
}

typedef BindsFile = {
    var binds:Array<Binding>;
}

typedef Binding = {
    var name:String;
    var main:FlxKey;
    var alt:FlxKey;
    var ?gamepad:FlxGamepadInputID;
}

typedef KeyEventData = {
    var keys:Array<FlxKey>;
    var pressed:(FlxKey) -> Void;
    var released:(FlxKey) -> Void;
}