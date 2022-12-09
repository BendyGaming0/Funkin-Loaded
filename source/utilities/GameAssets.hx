package utilities;

import openfl.utils.AssetLibrary;
import flixel.system.FlxSound;
import openfl.utils.Future;
import flixel.FlxG;
import flixel.graphics.frames.FlxAtlasFrames;
import openfl.utils.AssetType;
import openfl.utils.Assets as OpenFlAssets;
import lime.utils.Assets as LimeAssets;

using StringTools;

/**
 * Loads files synchronously/asynchronously from the file system, may use partial paths
 * for handling asynch loading refer to https://lime.openfl.org/api/lime/app/Future.html
 */
class GameAssets
{
    /**
     * [Description]
     * loads an instrumental synchronously using a full/partial path in `songs`
     * partial paths should be the song name
     * @param path  the folder/path of the song inst e.g. `assets/songs/name/Inst.(ext)` or `name`
     * @return a FlxSound
     */
    public static function getSongInst(path:String):FlxSound {
        if (path.startsWith('C:\\')) 
            throw 'Cannot load external audio files';

        if (!path.startsWith('songs:') && path.startsWith('assets/songs'))
            path = 'songs:' + path;

        if (!path.startsWith('songs:assets/songs'))
            path = Paths.inst(path);

        return new FlxSound().loadEmbedded(path);
    }

    /**
     * [Description]
     * loads an instrumental asynchronously using a full/partial path in `songs`
     * partial paths should be the song name
     * @param path  the folder/path of the song inst e.g. `assets/songs/name/Inst.(ext)` or `name`
     * @return a Future FlxSound (refer to `openfl.utils.Future`)
     */
    public static function loadSongInst(path:String):Future<FlxSound> {
        return new Future<FlxSound>(function () {
            return getSongInst(path);
        }, true);
    }

    /**
     * [Description]
     * loads an instrumental synchronously using a full/partial path in `songs`
     * partial paths should be the song name
     * @param path  the folder/path of the song voices e.g. `assets/songs/name/Voices.(ext)` or `name`
     * @return a FlxSound
     */
    public static function getSongVoices(path:String):FlxSound {
        if (path.startsWith('C:\\')) 
            throw 'Cannot load external audio files';

        if (!path.startsWith('songs:') && path.startsWith('assets/songs'))
            path = 'songs:' + path;

        if (!path.startsWith('songs:assets/songs'))
            path = Paths.voices(path);

        return new FlxSound().loadEmbedded(path);
    }

    /**
     * [Description]
     * loads an instrumental asynchronously using a full/partial path in `songs`
     * partial paths should be the song name
     * @param path  the folder/path of the song voices e.g. `assets/songs/name/Voices.(ext)` or `name`
     * @return a Future FlxSound (refer to `openfl.utils.Future`)
     */
    public static function loadSongVoices(path:String):Future<FlxSound> {
        return new Future<FlxSound>(function () {
            return getSongVoices(path);
        }, true);
    }

    /**
     * [Description]
     * loads an instrumental synchronously using a full/partial path in `music`
     * partial paths should be the song name
     * @param path  the folder/path of the song e.g. `assets/music/file.(ext)` or `file`
     * @return a FlxSound
     */
    public static function getMusic(path:String, looped:Bool = false):FlxSound {
        if (path.startsWith('C:\\')) 
            throw 'Cannot load external audio files';

        if (!path.startsWith('assets/music'))
            path = Paths.music(path);

        return new FlxSound().loadEmbedded(path, looped);
    }

    /**
     * [Description]
     * loads an instrumental asynchronously using a full/partial path in `music`
     * partial paths should be the song name
     * @param path  the folder/path of the song e.g. `assets/music/file.(ext)` or `file`
     * @return a Future FlxSound (refer to `openfl.utils.Future`)
     */
    public static function loadMusic(path:String, looped:Bool):Future<FlxSound> {
        return new Future<FlxSound>(function () {
            return getMusic(path, looped);
        }, true);
    }

    /**
     * [Description]
     * loads an instrumental synchronously using a full/partial path in `sounds`
     * partial paths should be the song name
     * @param path  the folder/path of the sound e.g. `assets/sounds/file.(ext)` or `file`
     * @return a FlxSound
     */
    public static function getSound(path:String, looped:Bool = false):FlxSound {
        if (path.startsWith('C:\\')) 
            throw 'Cannot load external audio files';

        if (!path.startsWith('assets/sounds'))
            path = Paths.sound(path);

        return new FlxSound().loadEmbedded(path, looped);
    }

    /**
     * [Description]
     * loads an instrumental asynchronously using a full/partial path in `sounds`
     * partial paths should be the song name
     * @param path  the folder/path of the sound e.g. `assets/sounds/file.(ext)` or `file`
     * @return a Future FlxSound (refer to `openfl.utils.Future`)
     */
    public static function loadSound(path:String, looped:Bool):Future<FlxSound> {
        return new Future<FlxSound>(function () {
            return getSound(path, looped);
        }, true);
    }

    /**
     * [Description]
     * loads an instrumental synchronously using a full path
     * partial paths should be the song name
     * @param path  the path of the audio
     * @return a FlxSound
     */
    public static function getAudio(path:String, looped:Bool = false):FlxSound {
        if (path.startsWith('C:\\')) 
            throw 'Cannot load external audio files';

        return new FlxSound().loadEmbedded(path, looped);
    }

    /**
     * [Description]
     * loads an instrumental asynchronously using a full path
     * partial paths should be the song name
     * @param path  the path of the audio 
     * @return a Future FlxSound (refer to `openfl.utils.Future`)
     */
    public static function loadAudio(path:String, looped:Bool):Future<FlxSound> {
        return new Future<FlxSound>(function () {
            return getSound(path, looped);
        }, true);
    }

    /**
     * [Description]
     * adds a library to the cache
     */
    public static function addLibrary(library:String) {
        trace(OpenFlAssets.hasLibrary(library));

		if (OpenFlAssets.getLibrary(library) == null)
		{
			@:privateAccess
			if (!LimeAssets.libraryPaths.exists(library)) {
				trace('library "$library" doesn\'t exist');
                return;
            }
			
			OpenFlAssets.loadLibrary(library).ready();
		}
    }

    /**
     * [Description]
     * adds a library to the cache and returns a future
     */
    public static function loadLibrary(library:String):Future<AssetLibrary> {
        trace(OpenFlAssets.hasLibrary(library));
		if (OpenFlAssets.getLibrary(library) == null)
		{
			@:privateAccess
			if (!LimeAssets.libraryPaths.exists(library)) 
				throw 'library "$library" doesn\'t exist';
			
			return OpenFlAssets.loadLibrary(library);
		}
        return Future.withValue(null);
    }
}