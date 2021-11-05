package;

import flixel.FlxG;
import flixel.FlxState;
import VideoPlayer;
import utils.AndroidData;
import openfl.Assets;
import flash.system.System;
import lime.app.Application;
import flixel.FlxObject;
import flixel.FlxSprite;
import flixel.FlxCamera;
import flixel.addons.transition.FlxTransitionableState;
import flixel.effects.FlxFlicker;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.ui.FlxButton;
import flixel.text.FlxText;
import flixel.math.FlxMath;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;

using StringTools;

class TitleVideo extends FlxState
{
	var cutsceneOp:Bool;
	var data:AndroidData = new AndroidData();

	override public function create():Void
	{
		#if android
	    FlxG.android.preventDefaultKeys = [BACK];
	    #end

	    #if (polymod && !html5)
		polymod.Polymod.init({modRoot: "mods", dirs: folders});
		#end
		FlxG.mouse.visible = false;

		cutsceneOp = data.getCutscenes();

		if (cutsceneOp){
			var video = new VideoPlayer('videos/kickstartertrailer.webm');
			video.finishCallback = () -> {
				remove(video);
				FlxG.switchState(new TitleState());
			}
			video.ownCamera();
			video.setGraphicSize(Std.int(video.width * 2));
			video.updateHitbox();
			add(video);
			video.play();
		}
		else{
			System.exit(0);
		}
	}
}