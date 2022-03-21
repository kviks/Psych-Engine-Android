package;

import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.ui.FlxButton;
import flixel.text.FlxText;
import android.CallbackHelper.ExtensionEvent;
import android.Permissions;
import sys.FileSystem;
import flixel.FlxG;
import flixel.FlxSprite;
import android.AndroidTools;

class DirSetupState extends MusicBeatState 
{
    var curError:ErrorType;
    var text:FlxText;
	var logoBl:FlxSprite;
    var buttonGroup:FlxTypedGroup<FlxButton>;

    override function create() 
    {
        curError = checkDir();

        if (curError == NOERROR)
        {
            MusicBeatState.switchState(new TitleState());
            return super.create();
        }

        buttonGroup = new FlxTypedGroup();
        add(buttonGroup);

        logoBl = new FlxSprite(0, 0);
		logoBl.frames = Paths.getSparrowAtlas('logoBumpin');
		logoBl.antialiasing = ClientPrefs.globalAntialiasing;
		logoBl.animation.addByPrefix('bump', 'logo bumpin', 24, false);
		logoBl.animation.play('bump');
		logoBl.updateHitbox();
        logoBl.screenCenter();
        logoBl.y -= FlxG.height / 4;
        add(logoBl);
        super.create();

        text = new FlxText(0, 0);
        add(text);
    }    

    function showUiError() 
    {
        buttonGroup.forEach(button -> buttonGroup.remove(button).destroy());

        switch (curError)
        {
            case PERMISSION:
            {
                setText('grand perm for contiune');
                var buttony = text.y + text.height + 10;
                var requsetPermButton = new FlxButton(0, buttony, 'requset perm', ()->{
                    initPermisson();
                });
                var goSettingsButton = new FlxButton(0, buttony, 'go settings', AndroidTools.goToSettings());
                var disableModButton = new FlxButton(0, buttony, 'disable mod future', () -> {

                });

                goSettingsButton.y = (FlxG.width / 2) - (goSettingsButton.width / 2);
                requsetPermButton.y = goSettingsButton.y - requsetPermButton.width - 10;
                disableModButton.y = goSettingsButton.y + goSettingsButton.width + 10;

                buttonGroup.add(requsetPermButton);
                buttonGroup.add(goSettingsButton);
                buttonGroup.add(disableModButton);
            }

            case EMPTYFOLDER:
            {

            }

            default:
                MusicBeatState.switchState(new TitleState());
        }
    }

    function setText(str:String) {
        text.text = str;
        text.screenCenter();
        text.y = logoBl.y + logoBl.height + 20;
    }

    function initDir() 
    {
        FileSystem.createDirectory(Paths.mods());
    }

    function initPermisson() 
    {
        function callback(requestCode:Int, permissions:Array<Permissions>, grantResults:Array<Int>) 
        {
            var ri = permissions.indexOf(Permissions.READ_EXTERNAL_STORAGE);
            var wi = permissions.indexOf(Permissions.WRITE_EXTERNAL_STORAGE);

            if (ri == -1 || wi == -1)
                return;

            if (grantResults[ri] == 0 && grantResults[wi] == 0)
            {
                curError = checkDir();
                showUiError();
            }
            
        }
        AndroidTools.callback.addEventListener(ExtensionEvent.onRequestPermissionsResult, callback);
        AndroidTools.requestPermissions([Permissions.READ_EXTERNAL_STORAGE, 
            Permissions.WRITE_EXTERNAL_STORAGE]);
        
        
    }

    public static function checkDir():ErrorType
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