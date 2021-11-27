package;

import openfl.utils.AssetType;
import haxe.crypto.Md5;
import openfl.utils.Assets;
#if sys
import sys.FileSystem;
import sys.io.File;
#end

class Utils
{
    #if android
    public static var storagePath:String = lime.system.System.applicationStorageDirectory;
    
    /*
    WARNING
	DO NOT USE THAT FUNCTION WITH PATH THAT
	CONTAINS LIME ASSETS OR OPENFL ASSETS
	OR PATHS.HX FUNCTIONS
    */
	public static function existsCheck(filePath:String, fileType:AssetType = null):Bool
	{
		if (openfl.utils.Assets.exists(filePath, fileType)) {
		    //trace('!!!!!!!FILE IS EXISTING!!!!!!!');
		    return true;
		} else {
		   // trace('!!!!!!!FILE IS NOT EXISTING!!!!!!!');
		    return false;
		}
	}
	
	/* END OF WARNING */
	
	// Asset2File shit, just copyed, idk why

	public static function getPathFromFile(id:String, ?ext:String = "")
	{
		var file = Assets.getBytes(id);

		var md5 = Md5.encode(Md5.make(file).toString());

		if (FileSystem.exists(storagePath + md5 + ext))
			return storagePath + md5 + ext;


		File.saveBytes(storagePath + md5 + ext, file);

		return storagePath + md5 + ext;
	}
	#else
	//trace('Utils.hx is unsupported not on android targets')
	#end
}