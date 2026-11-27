package mobile;

import haxe.io.Path;
import lime.system.System;
import sys.FileSystem;
import sys.io.File;
#if android
import androidmanager.content.Assets as AndroidAssets;
import androidmanager.content.Context;
import androidmanager.os.Environment;
import androidmanager.tools.PermissionUtils;
#end

class StorageUtil
{
	public static final STORAGE_TYPES:Array<String> = ["Data", "Media", "External", "Obb"];
	public static final EXTERNAL_FOLDER:String = ".FPSPlus";
	public static final MODS_FOLDER:String = "mods";

	public static var currentPath(default, null):String;

	static function getSettingsFile():String{
		var path:Null<String> = null;
		#if android
		path = Context.getFilesDir();
		#end
		if(path == null || path.length == 0){
			path = System.applicationStorageDirectory;
		}
		return Path.join([path, "storageType.txt"]);
	}

	public static function getStorageType():String{
		var file:String = getSettingsFile();
		try{
			if(FileSystem.exists(file)){
				var type:String = StringTools.trim(File.getContent(file));
				if(STORAGE_TYPES.contains(type)){
					return type;
				}
			}
		}
		catch(e){}
		return STORAGE_TYPES[0];
	}

	public static function setStorageType(type:String):Void{
		if(!STORAGE_TYPES.contains(type)){
			return;
		}
		try{
			File.saveContent(getSettingsFile(), type);
		}
		catch(e){}
		#if android
		if(type == "External" && !hasExternalAccess()){
			PermissionUtils.requestManageExternalStorage();
		}
		#end
	}

	public static function hasExternalAccess():Bool{
		#if android
		return PermissionUtils.isExternalStorageManager();
		#else
		return true;
		#end
	}

	public static function getStoragePath(type:String):String{
		var path:Null<String> = null;
		#if android
		switch(type){
			case "Media":
				path = Context.getExternalMediaDir();
			case "External":
				if(hasExternalAccess()){
					var root:String = Environment.getExternalStorageDirectory();
					if(root != null && root.length > 0){
						path = Path.join([root, EXTERNAL_FOLDER]);
					}
				}
			case "Obb":
				path = Context.getObbDir();
			default:
		}
		if(path == null || path.length == 0){
			path = Context.getExternalFilesDir();
		}
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
		var type:String = getStorageType();
		#if android
		if(type == "External" && !hasExternalAccess()){
			PermissionUtils.requestManageExternalStorage();
		}
		#end

		currentPath = getStoragePath(type);
		try{
			if(!FileSystem.exists(currentPath)){
				FileSystem.createDirectory(currentPath);
			}
		}
		catch(e){
			currentPath = getStoragePath(STORAGE_TYPES[0]);
			if(!FileSystem.exists(currentPath)){
				FileSystem.createDirectory(currentPath);
			}
		}
		Sys.setCwd(currentPath);
		extractMods();
	}

	static function extractMods():Void{
		var target:String = Path.join([currentPath, MODS_FOLDER]);
		try{
			if(!FileSystem.exists(target)){
				FileSystem.createDirectory(target);
			}
		}
		catch(e){
			return;
		}
		#if android
		AndroidAssets.copyFolder(MODS_FOLDER, target, false);
		#end
	}
}
