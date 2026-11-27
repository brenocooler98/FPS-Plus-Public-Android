package modding;

#if sys
import haxe.io.Bytes;
import polymod.fs.SysFileSystem;

class SafeFileSystem extends SysFileSystem
{
	override public function getFileBytes(path:String):Null<Bytes>{
		if(path == null){ return null; }
		try{
			return super.getFileBytes(path);
		}
		catch(e){
			return null;
		}
	}

	override public function getFileContent(path:String):Null<String>{
		if(path == null){ return null; }
		try{
			return super.getFileContent(path);
		}
		catch(e){
			return null;
		}
	}
}
#end
