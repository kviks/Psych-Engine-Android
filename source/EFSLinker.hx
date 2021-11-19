package;

import lime.system.JNI;

class EFSLinker {
	
	public static function getInternalStorageDir()
	{
		#if android
		return efileSystem_getInternalStorageDir();
		#end
	}
	
	public static function getAppCacheDir()
	{
		#if android
		return efileSystem_getAppCacheDir();
		#end
	}
	
	/*public static function getContext()
	{
		#if android
		return efileSystem_getContext();
		#end
	}*/

    #if android
	private static var efileSystem_getInternalStorageDir = JNI.createStaticMethod ("org.haxe.extension.Extension_fileSystem", "getInternalStorageDir", "(V)Ljava/io/File;");
	private static var efileSystem_getAppCacheDir = JNI.createStaticMethod ("org.haxe.extension.Extension_fileSystem", "getAppCacheDir", "(V)Ljava/io/File;");
	//private static var efileSystem_getContext = JNI.createStaticMethod ("org.haxe.extension.Extension_fileSystem", "getContext", "(Ljava/lang/String;)V");
	#end
}