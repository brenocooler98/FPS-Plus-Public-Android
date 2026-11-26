package;

import flixel.FlxBasic;
import flixel.FlxSubState;
#if mobile
import flixel.FlxCamera;
import mobile.MobileButton;
import mobile.MobileControls;
import mobile.MobileInput;
#end

class MusicBeatSubState extends FlxSubState
{
	public var curStep:Int = 0;
	public var curBeat:Int = 0;

	#if mobile
	public var backButton:MobileButton;

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
		super.create();

		Conductor.onStepHit.add(onStep);
		Conductor.onBeatHit.add(onBeat);
	}

	override function update(elapsed:Float){
		super.update(elapsed);
	}

	private function onStep():Void{
		curStep = Math.floor(Conductor.step);
		stepHit();
	}

	private function onBeat():Void{
		curBeat = Math.floor(Conductor.beat);
		beatHit();
	}

	public function stepHit():Void{}

	public function beatHit():Void{}

	override public function destroy(){
		Conductor.onStepHit.remove(onStep);
		Conductor.onBeatHit.remove(onBeat);

		#if mobile
		MobileInput.removeSwipeState(this);
		MobileControls.destroyCamera(mobileCamera);
		mobileCamera = null;
		#end

		super.destroy();
	}

}