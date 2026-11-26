package mobile;

import flixel.FlxSprite;
import flixel.FlxState;

class MobileButton extends FlxSprite
{
	public var owner:FlxState;
	public var input:String;

	public function new(asset:String, prefix:String, input:String, size:Float){
		super();
		this.input = input;

		frames = Paths.getSparrowAtlas("mobile/" + asset);
		animation.addByNames("idle", [prefix + "0000"], 24, false);
		animation.addByPrefix("press", prefix, 24, false);
		animation.play("idle");

		setGraphicSize(Std.int(frameWidth * size));
		updateHitbox();
		scrollFactor.set();
		antialiasing = true;

		MobileInput.addBlocker(this);
	}

	override function update(elapsed:Float):Void{
		super.update(elapsed);

		if(owner == MobileInput.topState() && visible && TouchUtil.justTouched(this)){
			animation.play("press", true);
			MobileInput.inject(input);
		}

		if(animation.name == "press" && animation.finished){
			animation.play("idle");
		}
	}

	override function destroy():Void{
		MobileInput.removeBlocker(this);
		owner = null;
		super.destroy();
	}
}
