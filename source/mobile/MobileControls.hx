package mobile;

import flixel.FlxBasic;
import flixel.FlxCamera;
import flixel.FlxG;
import flixel.FlxState;
import flixel.util.FlxColor;

class MobileControls
{
	static inline var MARGIN:Int = 20;

	public static function createCamera():FlxCamera{
		var camera:FlxCamera = new FlxCamera();
		camera.bgColor = FlxColor.TRANSPARENT;
		FlxG.cameras.add(camera, false);
		return camera;
	}

	public static function destroyCamera(camera:FlxCamera):Void{
		if(camera != null && FlxG.cameras.list.contains(camera)){
			FlxG.cameras.remove(camera);
		}
	}

	public static function createBackButton(owner:FlxState, camera:FlxCamera):MobileButton{
		var button:MobileButton = new MobileButton("backButton", "back", "menuBack", 0.65);
		button.owner = owner;
		button.setPosition(FlxG.width - button.width - MARGIN, FlxG.height - button.height - MARGIN);
		button.cameras = [camera];
		return button;
	}

	public static function createPauseButton(owner:FlxState, camera:FlxCamera):MobileButton{
		var button:MobileButton = new MobileButton("pauseButton", "pause", "pause", 0.9);
		button.owner = owner;
		button.setPosition(FlxG.width - button.width - MARGIN, MARGIN);
		button.cameras = [camera];
		return button;
	}

	public static function createHitbox(owner:FlxState, camera:FlxCamera, invisible:Bool = false):Hitbox{
		var hitbox:Hitbox = new Hitbox(owner, invisible);
		hitbox.forEach(function(button:TouchButton) button.cameras = [camera]);
		return hitbox;
	}

	public static function handleList(owner:FlxState, items:Array<FlxBasic>, selected:Int, change:Int->Void, ?camera:FlxCamera):Void{
		if(owner != MobileInput.topState()){
			return;
		}

		var index:Int = TouchUtil.tappedIndex(items, camera != null ? camera : TouchUtil.getStateCamera(owner));
		if(index == -1){
			return;
		}

		if(index == selected){
			MobileInput.inject("menuAccept");
		}
		else{
			change(index - selected);
		}
	}

	public static function handleTap(owner:FlxState, ?object:FlxBasic, input:String = "menuAccept", ?camera:FlxCamera):Bool{
		if(owner != MobileInput.topState() || !TouchUtil.tapped(object, camera != null ? camera : TouchUtil.getStateCamera(owner))){
			return false;
		}
		MobileInput.inject(input);
		return true;
	}
}
