package;

import android.Permissions;
import sys.FileSystem;
import flixel.FlxG;
import flixel.FlxSprite;
import android.AndroidTools;

class DirSetupState extends MusicBeatState 
{
    var curError:ErrorType;

    override function create() 
    {
        curError = checkDir();

        if (curError == NOERROR)
        {
            MusicBeatState.switchState(new TitleState());
            return super.create();
        }

        var logoBl = new FlxSprite(0, 0);
		logoBl.frames = Paths.getSparrowAtlas('logoBumpin');
		
		logoBl.antialiasing = ClientPrefs.globalAntialiasing;
		logoBl.animation.addByPrefix('bump', 'logo bumpin', 24, false);
		logoBl.animation.play('bump');
		logoBl.updateHitbox();
        logoBl.screenCenter();
        logoBl.y -= FlxG.height / 4;
        add(logoBl);
        super.create();
    }    

    function initDir() 
    {
        FileSystem.createDirectory(Paths.mods());

    }

    function checkDir():ErrorType
    {
        
        if (!AndroidTools.getGrantedPermissions().contains(Permissions.READ_EXTERNAL_STORAGE))
            return PERMISSION;
        
        if (!FileSystem.exists(Paths.mods()))
            return EMPTYFOLDER;

        return NOERROR;
    }
}

enum ErrorType {
    NOERROR;
    PERMISSION;
    EMPTYFOLDER;
}