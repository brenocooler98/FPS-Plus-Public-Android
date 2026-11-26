package mobile;

import haxe.io.Path;
import lime.system.System;
import sys.FileSystem;
#if android
import androidmanager.content.Context;
#end

class StorageUtil
{
	public static function getStoragePath():String{
		var path:Null<String> = null;
		#if android
		path = Context.getExternalFilesDir();
		if(path == null || path.length == 0){
			path = Context.getFilesDir();
		}
		#end
		if(path == null || path.length == 0){
			path = System.applicationStorageDirectory;
		}
		return Path.addTrailingSlash(path);
	}

	public static function init():Void{
		var path:String = getStoragePath();
		if(!FileSystem.exists(path)){
			FileSystem.createDirectory(path);
		}
		Sys.setCwd(path);
	}
}
