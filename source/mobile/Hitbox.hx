package mobile;

import flixel.FlxG;
import flixel.FlxState;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.math.FlxPoint;
import flixel.util.FlxColor;

class Hitbox extends FlxTypedGroup<TouchButton>
{
	static inline var STICKY_PADDING:Float = 45;

	var lanes:Array<TouchButton> = [];
	var assignments:Map<Int, Int> = new Map<Int, Int>();
	var assignedFrame:Int = -1;
	var point:FlxPoint = FlxPoint.get();
	var owner:FlxState;

	public function new(owner:FlxState, invisible:Bool = false){
		super();
		this.owner = owner;

		var laneWidth:Int = Std.int(FlxG.width / 4);
		var colors:Array<FlxColor> = [0xFFC24B99, 0xFF00FFFF, 0xFF12FA05, 0xFFF9393F];
		var inputs:Array<String> = ["gameplayLeft", "gameplayDown", "gameplayUp", "gameplayRight"];
		for(i in 0...4){
			var x:Int = laneWidth * i;
			var width:Int = i == 3 ? FlxG.width - x : laneWidth;
			var lane:TouchButton = new TouchButton(x, 0, width, FlxG.height, colors[i], inputs[i]);
			lane.owner = owner;
			lane.idleAlpha = 0;
			lane.pressedAlpha = invisible ? 0 : 0.3;
			var index:Int = i;
			lane.touchCheck = function() return isLaneTouched(index);
			lanes.push(lane);
			add(lane);
		}
	}

	function isLaneTouched(index:Int):Bool{
		updateAssignments();
		for(lane in assignments){
			if(lane == index){
				return true;
			}
		}
		return false;
	}

	function updateAssignments():Void{
		if(assignedFrame == MobileInput.currentFrame){
			return;
		}
		assignedFrame = MobileInput.currentFrame;

		var alive:Array<Int> = [];
		for(touch in FlxG.touches.list){
			if(!touch.pressed || MobileInput.isBlocked(touch)){
				continue;
			}

			var id:Int = touch.touchPointID;
			alive.push(id);
			touch.getViewPosition(lanes[0].getCameras()[0], point);

			var current:Int = assignments.exists(id) ? assignments.get(id) : -1;
			if(current != -1 && laneContains(lanes[current], STICKY_PADDING)){
				continue;
			}

			var found:Int = -1;
			for(i in 0...lanes.length){
				if(laneContains(lanes[i], 0)){
					found = i;
					break;
				}
			}

			if(found == -1){
				assignments.remove(id);
			}
			else{
				assignments.set(id, found);
			}
		}

		for(id in [for(key in assignments.keys()) key]){
			if(!alive.contains(id)){
				assignments.remove(id);
			}
		}
	}

	function laneContains(lane:TouchButton, padding:Float):Bool{
		return point.x >= lane.x - padding && point.x < lane.x + lane.width + padding && point.y >= lane.y - padding && point.y < lane.y + lane.height + padding;
	}

	override function destroy():Void{
		point.put();
		lanes = [];
		assignments.clear();
		owner = null;
		super.destroy();
	}
}
