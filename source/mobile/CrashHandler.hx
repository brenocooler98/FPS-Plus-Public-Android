package mobile;

import haxe.CallStack;
import haxe.io.Path;
import openfl.Lib;
import openfl.events.UncaughtErrorEvent;
import sys.FileSystem;
import sys.io.File;

class CrashHandler
{
	static inline var CRASH_FOLDER:String = "crash";

	public static function init():Void{
		Lib.current.loaderInfo.uncaughtErrorEvents.addEventListener(UncaughtErrorEvent.UNCAUGHT_ERROR, onUncaughtError);
		#if cpp
		untyped __global__.__hxcpp_set_critical_error_handler(onCriticalError);
		#end
	}

	static function onUncaughtError(event:UncaughtErrorEvent):Void{
		event.preventDefault();
		event.stopImmediatePropagation();
		report(Std.string(event.error), CallStack.exceptionStack(true));
	}

	static function onCriticalError(message:Dynamic):Void{
		report(Std.string(message), CallStack.callStack());
	}

	static function report(message:String, stack:Array<StackItem>):Void{
		var lines:Array<String> = [];
		for(item in stack){
			lines.push(formatItem(item));
		}

		var text:String = "Uncaught Error: " + message + "\n\n" + lines.join("\n");
		LogHandler.write(text);
		var file:String = save(text);
		if(file != null){
			text += "\n\nSaved to: " + file;
		}

		try{
			Lib.application.window.alert(text, "FPS Plus crashed");
		}
		catch(e){}
		Sys.exit(1);
	}

	static function formatItem(item:StackItem):String{
		return switch(item){
			case FilePos(parent, file, line, column): (parent != null ? formatItem(parent) + " " : "") + file + ":" + line;
			case Method(className, method): (className != null ? className + "." : "") + method;
			case LocalFunction(index): "local function #" + index;
			case Module(module): module;
			case CFunction: "C function";
			default: Std.string(item);
		}
	}

	static function save(text:String):Null<String>{
		try{
			if(!FileSystem.exists(CRASH_FOLDER)){
				FileSystem.createDirectory(CRASH_FOLDER);
			}
			var date:String = DateTools.format(Date.now(), "%Y-%m-%d_%H-%M-%S");
			var file:String = Path.join([CRASH_FOLDER, "FPSPlus_" + date + ".txt"]);
			File.saveContent(file, text + "\n");
			return Path.join([Sys.getCwd(), file]);
		}
		catch(e){
			return null;
		}
	}
}
