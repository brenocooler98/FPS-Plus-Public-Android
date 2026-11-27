package menus.config;

import config.Config;
import extensions.flixel.FlxCameraExt;
import extensions.flixel.FlxTextExt;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.addons.display.FlxGridOverlay;
import flixel.text.FlxText;
import flixel.util.FlxColor;
#if mobile
import mobile.MobileInput;
import mobile.StorageUtil;
import mobile.TouchUtil;
#end

typedef MobileOption = {
	name:String,
	description:String,
	getValue:Void->String,
	change:Int->Void
}

class MobileOptionsSubState extends MusicBeatSubState
{
	static final SELECTION_COLOR:FlxColor = 0xFFFFEE00;

	var camOptions:FlxCameraExt;
	var options:Array<MobileOption> = [];
	var optionNames:Array<FlxTextExt> = [];
	var optionValues:Array<FlxTextExt> = [];
	var descText:FlxTextExt;
	var curSelected:Int = 0;
	var closing:Bool = false;
	var startStorageType:String;

	public function new(){
		super();

		camOptions = new FlxCameraExt();
		camOptions.bgColor.alpha = 0;
		FlxG.cameras.add(camOptions, false);
		cameras = [camOptions];
	}

	override function create():Void{
		setupOptions();

		var bg:FlxSprite = new FlxSprite().makeGraphic(1, 1, 0xFF000000);
		bg.setGraphicSize(FlxG.width, FlxG.height);
		bg.updateHitbox();
		bg.alpha = 0.75;
		add(bg);

		var title:FlxTextExt = new FlxTextExt(0, 90, FlxG.width, "MOBILE OPTIONS", 72);
		title.setFormat(Paths.font("FunkinOptions", "otf"), title.textField.defaultTextFormat.size, FlxColor.WHITE, FlxTextAlign.CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		title.borderSize = 5;
		title.borderQuality = 1;
		add(title);

		var grid:FlxSprite = new FlxSprite(30, 225).loadGraphic(FlxGridOverlay.createGrid(1220, 60, 1220, 60 * options.length, true, 0x7F000000, 0x60000000));
		add(grid);

		for(i in 0...options.length){
			var nameText:FlxTextExt = new FlxTextExt(grid.x + 8, grid.y + 8 + (60 * i), 1220 - 16, options[i].name, 44);
			nameText.setFormat(Paths.font("FunkinOptions", "otf"), nameText.textField.defaultTextFormat.size, FlxColor.WHITE, FlxTextAlign.LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
			nameText.borderSize = 4;
			nameText.borderQuality = 1;
			optionNames.push(nameText);
			add(nameText);

			var valueText:FlxTextExt = new FlxTextExt(grid.x + 8, grid.y + 8 + (60 * i), 1220 - 16, "", 44);
			valueText.setFormat(Paths.font("FunkinOptions", "otf"), valueText.textField.defaultTextFormat.size, FlxColor.WHITE, FlxTextAlign.RIGHT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
			valueText.borderSize = 4;
			valueText.borderQuality = 1;
			optionValues.push(valueText);
			add(valueText);
		}

		var descBar:FlxSprite = new FlxSprite(0, 630).makeGraphic(1280, 90, 0xFF000000);
		descBar.alpha = 0.5;
		add(descBar);

		descText = new FlxTextExt(160, 650, 960, "", 20);
		descText.setFormat(Paths.font("vcr"), descText.textField.defaultTextFormat.size, FlxColor.WHITE, FlxTextAlign.CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		descText.borderQuality = 1;
		add(descText);

		updateText();

		super.create();

		addSwipe();
		addBackButton();
	}

	function setupOptions():Void{
		options.push({
			name: "Invisible Hitbox",
			description: "Hides the hitbox lanes when you press them during gameplay.",
			getValue: function() return Config.invisibleHitbox ? "on" : "off",
			change: function(dir:Int) Config.invisibleHitbox = !Config.invisibleHitbox
		});

		options.push({
			name: "Invisible Pause Button",
			description: "Makes the pause button invisible during gameplay. It can still be pressed.",
			getValue: function() return Config.invisiblePauseButton ? "on" : "off",
			change: function(dir:Int) Config.invisiblePauseButton = !Config.invisiblePauseButton
		});

		options.push({
			name: "Chart Editor in Pause",
			description: "Adds a Chart Editor option to the pause menu in Freeplay.",
			getValue: function() return Config.chartEditorInPause ? "on" : "off",
			change: function(dir:Int) Config.chartEditorInPause = !Config.chartEditorInPause
		});

		#if mobile
		startStorageType = StorageUtil.getStorageType();
		var storageType:String = startStorageType;
		options.push({
			name: "Storage Type",
			description: "Where the game keeps the mods folder and other files.\nRestart the game to apply.",
			getValue: function() return storageType.toLowerCase(),
			change: function(dir:Int){
				var index:Int = StorageUtil.STORAGE_TYPES.indexOf(storageType) + dir;
				if(index < 0){ index = StorageUtil.STORAGE_TYPES.length - 1; }
				if(index >= StorageUtil.STORAGE_TYPES.length){ index = 0; }
				storageType = StorageUtil.STORAGE_TYPES[index];
				StorageUtil.setStorageType(storageType);
			}
		});
		#end
	}

	function updateText():Void{
		for(i in 0...options.length){
			var selected:Bool = i == curSelected;
			optionNames[i].text = options[i].name + "\n\n";
			optionValues[i].text = (selected ? "< " + options[i].getValue() + " >" : options[i].getValue()) + "\n\n";
			optionNames[i].color = selected ? SELECTION_COLOR : FlxColor.WHITE;
			optionValues[i].color = selected ? SELECTION_COLOR : FlxColor.WHITE;
		}

		var description:String = options[curSelected].description;
		#if mobile
		if(options[curSelected].name == "Storage Type"){
			if(StorageUtil.getStorageType() != startStorageType){
				description += "\nRestart required.";
			}
			if(StorageUtil.getStorageType() == "External" && !StorageUtil.hasExternalAccess()){
				description += "\nAllow \"All files access\" for this to work.";
			}
		}
		#end
		descText.text = description + "\n\n";
	}

	function changeSelection(change:Int):Void{
		curSelected += change;
		if(curSelected < 0){ curSelected = options.length - 1; }
		if(curSelected >= options.length){ curSelected = 0; }
		FlxG.sound.play(Paths.sound("scrollMenu"));
		updateText();
	}

	function changeValue(dir:Int):Void{
		options[curSelected].change(dir);
		FlxG.sound.play(Paths.sound("scrollMenu"));
		updateText();
	}

	function tapOptions():Void{
		#if mobile
		if(MobileInput.topState() != this){
			return;
		}
		var i:Int = options.length;
		while(i-- > 0){
			if(TouchUtil.tapped(optionNames[i], camOptions) || TouchUtil.tapped(optionValues[i], camOptions)){
				if(i == curSelected){
					MobileInput.inject("menuAccept");
				}
				else{
					changeSelection(i - curSelected);
				}
				return;
			}
		}
		#end
	}

	override function update(elapsed:Float):Void{
		super.update(elapsed);

		if(closing){
			return;
		}

		tapOptions();

		if(Binds.justPressed("menuUp")){
			changeSelection(-1);
		}
		else if(Binds.justPressed("menuDown")){
			changeSelection(1);
		}
		else if(Binds.justPressed("menuLeft")){
			changeValue(-1);
		}
		else if(Binds.justPressed("menuRight") || Binds.justPressed("menuAccept")){
			changeValue(1);
		}
		else if(Binds.justPressed("menuBack")){
			closing = true;
			Config.write();
			FlxG.sound.play(Paths.sound("cancelMenu"));
			close();
		}
	}

	override function destroy():Void{
		if(FlxG.cameras.list.contains(camOptions)){
			FlxG.cameras.remove(camOptions);
		}
		super.destroy();
	}
}
