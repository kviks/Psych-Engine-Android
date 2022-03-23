package;

import sys.thread.Thread;
import openfl.display.Application;
import flixel.util.FlxTimer;
import sys.io.File;
import haxe.io.BytesBuffer;
import flixel.addons.api.FlxGameJolt;
import haxe.io.Bytes;
import haxe.io.BytesInput;
import haxe.zip.Reader;
import sys.Http;
import flixel.FlxObject;
import openfl.geom.Rectangle;
import openfl.display.Bitmap;
import openfl.display.BitmapData;
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

    public function new(i, o) {
        Paths.dir = AndroidTools.getExternalStorageDirectory() + '/psych/';
        // Paths.dir = lime.system.System.userDirectory + '/psych/';

        // Sys.setCwd(AndroidTools.getExternalStorageDirectory() + '/psych/');
        // trace(Sys.getCwd());
        super(i , o);
    }

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
        logoBl.setGraphicSize(Std.int(logoBl.width / 1.5));
		logoBl.updateHitbox();
        logoBl.screenCenter();
        logoBl.y -= FlxG.height / 5;
        add(logoBl);

        var curdirtext = new FlxText(5);
        curdirtext.text = 'Working dir: ${Paths.dir}';
        curdirtext.size = 16;
        curdirtext.y = FlxG.height - curdirtext.height - 20;
        add(curdirtext);

        text = new FlxText(0, 0);
        text.size = 24;
        text.alignment = CENTER;
        add(text);
        showUiError();
        super.create();
    }   
    // override function update(elapsed:Float) {
    //     trace(AndroidTools.getExternalStorageDirectory() + '/psych/');
    //     super.update(elapsed);
    // }
    
    function clearAll() {
        buttonGroup.forEach(button -> buttonGroup.remove(button).destroy());
        text.text = '';
    }

    function showUiError() 
    {
        buttonGroup.forEach(button -> buttonGroup.remove(button).destroy());

        switch (curError)
        {
            case PERMISSION:
            {
                setText('grand perm for contiune');
                var buttony = text.y + text.height + 20;
                var requsetPermButton = new FlxButton(0, buttony, 'requset perm', ()->{
                    initPermisson();
                });
                var goSettingsButton = new FlxButton(0, buttony, 'go settings', AndroidTools.goToSettings);
                var disableModButton = new FlxButton(0, buttony, 'disable mod future', () -> {

                });

                setGS(goSettingsButton, 2);
                setGS(goSettingsButton.label, 2);
                setGS(requsetPermButton, 2);
                setGS(requsetPermButton.label, 2);
                setGS(disableModButton, 2, 3);
                setGS(disableModButton.label, 2);

                goSettingsButton.x = (FlxG.width / 2) - (goSettingsButton.width / 2);
                requsetPermButton.x = goSettingsButton.x - requsetPermButton.width - 10;
                disableModButton.x = goSettingsButton.x + goSettingsButton.width + 10;

                buttonGroup.add(requsetPermButton);
                buttonGroup.add(goSettingsButton);
                buttonGroup.add(disableModButton);
            }

            case EMPTYFOLDER:
            {
                setText('Current folder is empty\nDownload assets?');
                var buttony = text.y + text.height + 20;

                initDir();
                var downloadButton = new FlxButton(0, buttony, 'Download', ()->{
                    // Thread.create(downloadAssets);
                    downloadAssets();
                });
                setGS(downloadButton, 2);
                setGS(downloadButton.label, 2);
                downloadButton.x = (FlxG.width / 2) - (downloadButton.width / 2);
                buttonGroup.add(downloadButton);
            }

            default:
                MusicBeatState.switchState(new TitleState());
        }
    }

    function setText(str:String) {
        text.text = str;
        text.screenCenter();
        text.y = logoBl.y + logoBl.height - 30;
    }

    function setGS(obj:FlxSprite, size:Float, ?sizeh:Float) {
        obj.setGraphicSize(Std.int(obj.width * size), sizeh != null ? Std.int(obj.height * sizeh) : 0);
        obj.updateHitbox();
    }

    function initDir() 
    {
        try{
            FileSystem.createDirectory(Paths.mods());
        }catch(e) trace(e);
    }

    function initPermisson() 
    {
        function callback(requestCode:Int, permissions:Array<Permissions>, grantResults:Array<Int>) 
        {
            var ri = permissions.indexOf(Permissions.READ_EXTERNAL_STORAGE);
            var wi = permissions.indexOf(Permissions.WRITE_EXTERNAL_STORAGE);

            if (grantResults[ri] == 0 && grantResults[wi] == 0 && (ri != -1 || wi != -1))
            {
                curError = checkDir();
                showUiError();
            }
            
            AndroidTools.callback.removeEventListener(ExtensionEvent.onRequestPermissionsResult, callback);
        }
        AndroidTools.callback.addEventListener(ExtensionEvent.onRequestPermissionsResult, callback);
        AndroidTools.requestPermissions([Permissions.READ_EXTERNAL_STORAGE, 
            Permissions.WRITE_EXTERNAL_STORAGE]);
        
        
    }

    // static var buttonBitmap:BitmapData;
    // public static function buttongraphic() {
    //     if (buttonBitmap != null)
    //         return buttonBitmap;

    //     buttonBitmap = new BitmapData(200, 150);
    //     buttonBitmap.fillRect(new Rectangle(0, 0, ))
    // }

    public static function checkDir():ErrorType
    {
        if (!AndroidTools.getGrantedPermissions().contains(Permissions.READ_EXTERNAL_STORAGE))
            return PERMISSION;
        
        if (!FileSystem.exists(Paths.mods()))
            return EMPTYFOLDER;

        return NOERROR;
    }

	function downloadAssets() 
    {
        // pro tip: delete lime version of Reader
        clearAll();
        setText('downloading assets..');
        var http = new Http('https://media.githubusercontent.com/media/luckydog7/aa/main/psychassets052h.zip');
        http.onBytes = (bytes) ->
        {
            var zipList = Reader.readZip(new BytesInput(bytes));

            for (file in zipList)
            {
				var dirs = ~/[\/\\]/g.split(file.fileName);
                trace(dirs);
				var path = "";
				var fileName = dirs.pop();
				for( d in dirs ) {
					path += d;
					sys.FileSystem.createDirectory(Paths.dir + "/" + path);
					path += "/";
				}

                if( fileName == "" )
                    continue;

				path += fileName;
				var data = haxe.zip.Reader.unzip(file);
                // var f = File.write (Paths.dir + "/" + path, true);
                // f.write(data);
                // f.close();
                File.saveBytes(Paths.dir + "/" + path, data);

            }
        }
        http.onError = (msg) -> 
        {
            lime.app.Application.current.window.alert(msg, 'Download error');
            showUiError();
        }
        new FlxTimer().start(0.1, _ -> {
            http.request();
            setText('done');
            new FlxTimer().start(2, (_)-> {
                checkDir();
                showUiError();
            });
        });
    }
}

enum ErrorType {
    NOERROR;
    PERMISSION;
    NOINTERNET;
    EMPTYFOLDER; // should be??
}