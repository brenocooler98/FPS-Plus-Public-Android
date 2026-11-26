package mobile;

import flixel.FlxCamera;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.input.FlxInput.FlxInputState;
import flixel.util.FlxColor;
import flixel.util.FlxSpriteUtil;

class TouchButton extends FlxSprite
{
	public var input:Null<String>;
	public var owner:FlxState;
	public var idleAlpha:Float = 0;
	public var pressedAlpha:Float = 0.3;
	public var touchCheck:Null<Void->Bool> = null;

	var currentPressed:Bool = false;
	var previousPressed:Bool = false;

	public function new(x:Float, y:Float, width:Int, height:Int, color:FlxColor, ?input:String){
		super(x, y);
		this.input = input;

		var key:String = 'touchbutton_${width}x${height}_${color.toHexString()}';
		var cached:Bool = FlxG.bitmap.get(key) != null;
		makeGraphic(width, height, FlxColor.TRANSPARENT, false, key);
		graphic.persist = true;
		if(!cached){
			drawGraphic(width, height, color);
		}

		scrollFactor.set();
		antialiasing = false;
		alpha = idleAlpha;
		MobileInput.register(this);
	}

	function drawGraphic(width:Int, height:Int, color:FlxColor):Void{
		var border:Int = 6;
		FlxSpriteUtil.drawRect(this, 0, 0, width, height, color);
		FlxSpriteUtil.drawRect(this, border, border, width - border * 2, height - border * 2, color.getDarkened(0.6));
	}

	public function updateStatus(active:Bool):Void{
		previousPressed = currentPressed;
		currentPressed = active && exists && visible && (touchCheck != null ? touchCheck() : isTouched());
	}

	function isTouched():Bool{
		var camera:FlxCamera = getCameras()[0];
		for(touch in FlxG.touches.list){
			if(touch.pressed && touch.overlaps(this, camera) && !MobileInput.isBlocked(touch)){
				return true;
			}
		}
		return false;
	}

	public function check(state:FlxInputState):Bool{
		return switch(state){
			case PRESSED: currentPressed;
			case JUST_PRESSED: currentPressed && !previousPressed;
			case JUST_RELEASED: !currentPressed && previousPressed;
			case RELEASED: !currentPressed;
		}
	}

	public inline function pressed():Bool{
		return check(PRESSED);
	}

	public inline function justPressed():Bool{
		return check(JUST_PRESSED);
	}

	public inline function justReleased():Bool{
		return check(JUST_RELEASED);
	}

	override function update(elapsed:Float):Void{
		super.update(elapsed);
		alpha = pressed() ? pressedAlpha : idleAlpha;
	}

	override function destroy():Void{
		MobileInput.unregister(this);
		owner = null;
		super.destroy();
	}
}
