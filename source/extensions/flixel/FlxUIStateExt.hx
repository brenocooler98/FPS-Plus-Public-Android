package extensions.flixel;

import extensions.flixel.FlxCameraExt;
import flixel.FlxBasic;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.FlxSubState;
import flixel.addons.ui.FlxUIState;
import openfl.display.BitmapData;
import restricted.RestrictedUtils;
import scripts.ScriptableState;
import scripts.ScriptedState;
import transition.*;
import transition.data.*;
#if mobile
import flixel.FlxCamera;
import mobile.Hitbox;
import mobile.MobileButton;
import mobile.MobileControls;
import mobile.MobileInput;
#end

using StringTools;

class FlxUIStateExt extends FlxUIState
{
	public var useDefaultTransIn:Bool = true;
	public var useDefaultTransOut:Bool = true;

	public static var defaultTransIn:Class<Dynamic>;
	public static var defaultTransInArgs:Array<Dynamic>;
	public static var defaultTransOut:Class<Dynamic>;
	public static var defaultTransOutArgs:Array<Dynamic>;

	public static var inTransition:Bool = false;

	public var customTransIn:BaseTransition = null;
	public var customTransOut:BaseTransition = null;

	private var gcTimer:Int = 0;

	#if mobile
	public var backButton:MobileButton;
	public var pauseButton:MobileButton;
	public var hitbox:Hitbox;

	var mobileCamera:FlxCamera;

	function getMobileCamera():FlxCamera{
		if(mobileCamera == null){
			mobileCamera = MobileControls.createCamera();
		}
		return mobileCamera;
	}
	#end

	public function addSwipe():Void{
		#if mobile
		MobileInput.addSwipeState(this);
		#end
	}

	public function addBackButton():Void{
		#if mobile
		backButton = MobileControls.createBackButton(this, getMobileCamera());
		add(backButton);
		#end
	}

	public function addPauseButton():Void{
		#if mobile
		pauseButton = MobileControls.createPauseButton(this, getMobileCamera());
		add(pauseButton);
		#end
	}

	public function addHitbox(invisible:Bool = false):Void{
		#if mobile
		hitbox = MobileControls.createHitbox(this, getMobileCamera(), invisible);
		add(hitbox);
		#end
	}

	public function mobileList(items:Array<Dynamic>, selected:Int, change:Int->Void):Void{
		#if mobile
		MobileControls.handleList(this, cast items, selected, change);
		#end
	}

	public function mobileTap(object:FlxBasic, input:String = "menuAccept"):Bool{
		#if mobile
		return object != null && MobileControls.handleTap(this, object, input);
		#else
		return false;
		#end
	}

	public function mobileTapAnywhere(input:String = "menuAccept"):Bool{
		#if mobile
		return MobileControls.handleTap(this, null, input);
		#else
		return false;
		#end
	}

	override function create(){
		if(customTransIn != null){
			CustomTransition.transition(customTransIn, null);
		}
		else if(useDefaultTransIn){
			CustomTransition.transition(Type.createInstance(defaultTransIn, defaultTransInArgs), null);
		}

		//This creates a camera and a cover sprite that gets automatically added to a state that will hide anything outside the normal camera bounds.
		//Not noticable most of the time but Flixel can extend cameras out by 1 pixel when the game isn't at it's native resolution can it can create a weird pixel gap.
		//Also useful to hide stuff outside the frame on rotated cameras since those won't be clipped to the game resolution and show up when the game is maximized.
		var coverCamera:FlxCameraExt = new FlxCameraExt(((FlxG.width*2)-FlxG.width)/-2, ((FlxG.height*2)-FlxG.height)/-2, FlxG.width*2, FlxG.height*2);
		coverCamera.bgColor.alpha = 0;
		FlxG.cameras.add(coverCamera, false);

		//3x3 black image with transparent hole in the center. 
		var coverBitmap:BitmapData = new BitmapData(3, 3, true, 0xFF000000);
		coverBitmap.setPixel32(1, 1, 0x00000000);
		
		var coverSprite:FlxSprite = new FlxSprite().loadGraphic(coverBitmap);
		coverSprite.scale.set(1280, 720);
		coverSprite.x = (coverCamera.width - coverSprite.width) / 2;
		coverSprite.y = (coverCamera.height - coverSprite.height) / 2;
		coverSprite.antialiasing = false;
		coverSprite.cameras = [coverCamera];
		add(coverSprite);

		FlxG.signals.postUpdate.add(gcCount);
		
		super.create();
	}

	public function switchState(_state:FlxState, ?_allowScriptedOverrides:Bool = true):Void{
		//Scripted States
		if(_allowScriptedOverrides){
			final statePath = Type.getClassName(Type.getClass(_state));
			final stateName = statePath.split(".")[statePath.split(".").length - 1];
			final scriptedStateList:Array<String> = RestrictedUtils.callStaticGeneratedMethod(ScriptableState, "listScriptClasses"); //A bit hacky but we have to do this to create script instance in parent...

			if(scriptedStateList.contains("states.overrides."+stateName)){
				_state = ScriptedState.init("states.overrides."+stateName);
			}
			#if BACKWARD_COMPATIBILITY
			else if(scriptedStateList.contains(stateName)){
				_state = ScriptedState.init(stateName);
			}
			#end
		}

		//Transition stuff.
		if(customTransOut != null){
			CustomTransition.transition(customTransOut, _state);
		}
		else if(useDefaultTransOut){
			CustomTransition.transition(Type.createInstance(defaultTransOut, defaultTransOutArgs), _state);
			return;
		}
		else{
			CustomTransition.transition(new InstantTransition(), _state);
			return;
		}
	}

	override function destroy():Void{
		#if mobile
		MobileInput.removeSwipeState(this);
		MobileControls.destroyCamera(mobileCamera);
		mobileCamera = null;
		#end
		super.destroy();
	}

	override function openSubState(SubState:FlxSubState):Void{
		Binds.lockControllerInputs(2);
		super.openSubState(SubState);
	}

	//For some reason doing a post update signal doesn't do garbage collection correctly so this delays it by 1 frame.
	private function gcCount():Void{
		if(gcTimer == 1){
			Utils.gc();
			FlxG.signals.postUpdate.remove(gcCount);
		}
		gcTimer++;
	}
}
