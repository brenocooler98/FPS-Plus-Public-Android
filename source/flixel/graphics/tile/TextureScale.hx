package flixel.graphics.tile;

import flixel.graphics.FlxGraphic;
import haxe.Json;

class TextureScale
{
	public static inline var MANIFEST:String = "assets/data/textureScale.json";

	static var scales:Map<FlxGraphic, Float> = new Map<FlxGraphic, Float>();
	static var count:Int = 0;
	static var sizes:Map<String, Array<Int>>;

	public static inline function get(graphic:FlxGraphic):Float
	{
		if (count == 0 || graphic == null)
			return 1;
		var scale:Null<Float> = scales.get(graphic);
		return scale == null ? 1 : scale;
	}

	static function loadManifest():Void
	{
		sizes = new Map<String, Array<Int>>();
		try
		{
			if (openfl.utils.Assets.exists(MANIFEST))
			{
				var data:Dynamic = Json.parse(openfl.utils.Assets.getText(MANIFEST));
				for (key in Reflect.fields(data))
					sizes.set(key, Reflect.field(data, key));
			}
		}
		catch (e) {}
	}

	public static function applyFromManifest(graphic:FlxGraphic, path:String):Void
	{
		if (graphic == null || path == null)
			return;
		if (sizes == null)
			loadManifest();
		var key:String = path.indexOf(":") != -1 ? path.substr(path.indexOf(":") + 1) : path;
		var size:Array<Int> = sizes.get(key);
		if (size != null && size.length >= 2)
			apply(graphic, size[0], size[1]);
	}

	@:access(flixel.graphics.FlxGraphic)
	public static function apply(graphic:FlxGraphic, originalWidth:Int, originalHeight:Int):Void
	{
		if (graphic == null || graphic.bitmap == null || originalWidth <= 0 || graphic.bitmap.width >= originalWidth)
			return;

		var scale:Float = graphic.bitmap.width / originalWidth;
		if (!scales.exists(graphic))
			count++;
		scales.set(graphic, scale);
		graphic.width = originalWidth;
		graphic.height = originalHeight;
	}

	public static function remove(graphic:FlxGraphic):Void
	{
		if (graphic != null && scales.remove(graphic))
			count--;
	}

	public static function clearManifest():Void
	{
		sizes = null;
	}
}
