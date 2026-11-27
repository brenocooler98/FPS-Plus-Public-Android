package modding;

#if sys
import haxe.io.Bytes;
import haxe.io.Path;
import polymod.fs.SysFileSystem;

class SafeFileSystem extends SysFileSystem
{
	var files:Map<String, Bool>;
	var indexRoot:String;

	function rootPath():String{
		return modRoot != null && modRoot.length > 0 ? modRoot : ".";
	}

	function normalize(path:String):String{
		var normalized:String = Path.normalize(StringTools.replace(path, "\\", "/"));
		while(StringTools.startsWith(normalized, "./")){
			normalized = normalized.substr(2);
		}
		if(normalized.length > 1 && StringTools.endsWith(normalized, "/")){
			normalized = normalized.substr(0, normalized.length - 1);
		}
		return normalized.toLowerCase();
	}

	function buildIndex():Void{
		files = new Map<String, Bool>();
		indexRoot = normalize(rootPath());
		if(!sys.FileSystem.exists(rootPath()) || !sys.FileSystem.isDirectory(rootPath())){
			return;
		}
		files.set(indexRoot, true);
		var pending:Array<String> = [rootPath()];
		while(pending.length > 0){
			var folder:String = pending.pop();
			var entries:Array<String> = [];
			try{
				entries = sys.FileSystem.readDirectory(folder);
			}
			catch(e){
				continue;
			}
			for(entry in entries){
				var full:String = Path.join([folder, entry]);
				var directory:Bool = false;
				try{
					directory = sys.FileSystem.isDirectory(full);
				}
				catch(e){}
				files.set(normalize(full), directory);
				if(directory){
					pending.push(full);
				}
			}
		}
	}

	function lookup(path:String):Null<Bool>{
		if(files == null){
			buildIndex();
		}
		var normalized:String = normalize(path);
		if(normalized != indexRoot && !StringTools.startsWith(normalized, indexRoot + "/")){
			return null;
		}
		return files.get(normalized);
	}

	function insideRoot(path:String):Bool{
		if(files == null){
			buildIndex();
		}
		var normalized:String = normalize(path);
		return normalized == indexRoot || StringTools.startsWith(normalized, indexRoot + "/");
	}

	override public function exists(path:String):Bool{
		if(path == null){ return false; }
		if(!insideRoot(path)){
			return sys.FileSystem.exists(path);
		}
		return lookup(path) != null;
	}

	override public function isDirectory(path:String):Bool{
		if(path == null){ return false; }
		if(!insideRoot(path)){
			return sys.FileSystem.exists(path) && sys.FileSystem.isDirectory(path);
		}
		return lookup(path) == true;
	}

	override public function getFileBytes(path:String):Null<Bytes>{
		if(path == null || !exists(path)){ return null; }
		try{
			return super.getFileBytes(path);
		}
		catch(e){
			return null;
		}
	}

	override public function getFileContent(path:String):Null<String>{
		if(path == null || !exists(path)){ return null; }
		try{
			return super.getFileContent(path);
		}
		catch(e){
			return null;
		}
	}
}
#end
