package;

#if (sys && !android)
import Discord.DiscordClient;
#end
import flixel.FlxG;
import flixel.FlxCamera;
import flixel.FlxObject;
import flixel.FlxSprite;
import flixel.text.FlxText;

class Version extends MusicBeatState
{
	public static var psychEngineVer:String = "4.2";

	override function create()
	{
		#if (sys && !android)
		// you mad >:)
		DiscordClient.changePresence("HACKER", null);
		#end
	}
}
