package mobile;

import haxe.Log;
import haxe.PosInfos;
import sys.FileSystem;
import sys.io.File;
import sys.io.FileOutput;

class LogHandler
{
	static inline var LOG_FOLDER:String = "logs";
	static inline var LOG_FILE:String = "logs/latest.txt";

	static var output:FileOutput;
	static var originalTrace:(Dynamic, ?PosInfos) -> Void;

	public static function init():Void{
		try{
			if(!FileSystem.exists(LOG_FOLDER)){
				FileSystem.createDirectory(LOG_FOLDER);
			}
			output = File.write(LOG_FILE, false);
		}
		catch(e){
			output = null;
			return;
		}

		originalTrace = Log.trace;
		Log.trace = function(value:Dynamic, ?infos:PosInfos):Void{
			write(Log.formatOutput(value, infos));
			originalTrace(value, infos);
		};
	}

	public static function write(line:String):Void{
		if(output == null){
			return;
		}
		try{
			output.writeString(line + "\n");
			output.flush();
		}
		catch(e){
			output = null;
		}
	}
}
