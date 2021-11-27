package;

import flixel.FlxCamera;
import Achievements;
import flixel.text.FlxText;
import flixel.FlxState;
import flixel.FlxG;

import extension.webview.WebView;

using StringTools;

class VideoState extends MusicBeatState
{
	public static var androidPath:String = 'file:///android_asset/';
	public var nextState:FlxState;
	private var camAchievement:FlxCamera;

	var someshit:FlxText;

	public function new(source:String, toTrans:FlxState)
	{
		super();

		camAchievement = new FlxCamera();
		camAchievement.bgColor.alpha = 0;
	
		FlxG.cameras.add(camAchievement);

		someshit = new FlxText(0, 0, 0, "Video Ended\nTap To Screen", 48);
		someshit.screenCenter();
		someshit.alpha = 0;
		add(someshit);

		nextState = toTrans;

		WebView.onClose=onClose;
		WebView.onURLChanging=onURLChanging;

		WebView.open(androidPath + source + '.html', false, null, ['http://exitme(.*)']);
	}

	public override function update(dt:Float) {
		for (touch in FlxG.touches.list)
			if (touch.justReleased)
				onClose();

		super.update(dt);	
	}

	function onClose(){
		someshit.alpha = 0;
		MusicBeatState.switchState(nextState);
	}

	function onURLChanging(url:String) {
		someshit.alpha = 1;
		if (url == 'http://exitme(.*)') onClose();
	}
}