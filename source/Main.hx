package;

import config.Config;
import extensions.openfl.display.FPSExt;
import flixel.FlxG;
import flixel.FlxGame;
import flixel.FlxSprite;
import flixel.system.debug.log.LogStyle;
import graphics.VideoHandler;
import modding.PolymodHandler;
import openfl.Lib;
import openfl.display.InteractiveObject;
import openfl.display.Sprite;
#if android
import androidmanager.callback.Callback;
import androidmanager.view.Window;
#end
#if mobile
import mobile.MobileInput;
import mobile.StorageUtil;
#end

class Main extends Sprite
{

	public static var fpsDisplay:InteractiveObject;

	public static var launchArguments:LaunchArguments = {
		no_vid: false,
		flippy_mode: false,
		no_mods: false,
	}

	public function new()
	{
		super();

		#if mobile
		StorageUtil.init();
		#end

		#if sys
		launchArguments.no_vid = Sys.args().contains("-no_vid");
		launchArguments.flippy_mode = Sys.args().contains("-flippy_mode");
		launchArguments.no_mods = Sys.args().contains("-no_mods") || #if MOD_SUPPORT false #else true #end;
		#end

		PolymodHandler.init();
		#if (desktop || android)
		hxvlc.util.Handle.init([]); // initializes LibVLC
		#end
		FlxSprite.defaultAntialiasing = true;

		#if !debug
		LogStyle.ERROR.openConsole = false;
		LogStyle.ERROR.errorSound = null;
		#end

		LogStyle.WARNING.openConsole = false;
		LogStyle.WARNING.errorSound = null;

		SaveManager.global();

		fpsDisplay = new FPSExt(3, 3, 0xFFFFFF);
		fpsDisplay.visible = true;
		fpsDisplay.alpha = 1;

		var game:FlxGame = new FlxGame(1280, 720, Startup, 60, 60, true);

		untyped FlxG.cameras = new extensions.flixel.system.frondEnds.CameraFrontEndExt();
		untyped FlxG.sound = new extensions.flixel.system.frondEnds.SoundFrontEndExt();

		@:privateAccess
		game._customSoundTray = ui.FunkinSoundTray;

		addChild(game);
		addChild(fpsDisplay);

		#if mobile
		FlxG.signals.gameResized.add(function(width:Int, height:Int) updateFPSDisplay());
		updateFPSDisplay();
		#end

		#if web
		VideoHandler.MAX_FPS = 30;
		#end

		#if mobile
		FlxG.mouse.visible = false;
		MobileInput.init();
		#end

		#if android
		FlxG.android.preventDefaultKeys = [BACK];
		Window.keepScreenOn = true;
		Window.immersive = true;
		Callback.init();
		Callback.onPause.add(onAppPause);
		#end

		#if sys
		Lib.current.stage.window.onClose.add(function(){
			if(Config.initialized){ Config.write(); }
			#if (desktop || android)
			hxvlc.util.Handle.dispose();
			#end
			Sys.exit(0);
		});
		#end

		trace("launchArguments: " + launchArguments);
	}

	#if mobile
	static function updateFPSDisplay():Void{
		if(fpsDisplay == null || FlxG.scaleMode == null){
			return;
		}
		var scale:Float = Math.max(1, FlxG.scaleMode.scale.y);
		fpsDisplay.scaleX = fpsDisplay.scaleY = scale;
		fpsDisplay.x = FlxG.scaleMode.offset.x + 3 * scale;
		fpsDisplay.y = FlxG.scaleMode.offset.y + 3 * scale;
	}
	#end

	#if android
	function onAppPause():Void{
		if(Config.initialized){ Config.write(); }
		if(Std.isOfType(FlxG.state, PlayState) && FlxG.state.subState == null){
			MobileInput.inject("pause");
		}
	}
	#end
}

typedef LaunchArguments = {
	var no_vid:Bool;
	var flippy_mode:Bool;
	var no_mods:Bool;
}