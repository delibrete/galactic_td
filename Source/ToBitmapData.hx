package;
import openfl.utils.Assets;
import openfl.display.BitmapData;
import openfl.display.DisplayObject;

function toBitmapData(d_string:String, trans:Bool = true):BitmapData
{
    var d = Assets.getBitmapData(d_string);
    // var b:BitmapData = new BitmapData(Std.int(d.width), Std.int(d.height), trans, 0);
    // b.draw(d);
    
    return d;
}