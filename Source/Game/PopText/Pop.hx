package game.popText;
import openfl.display.Sprite;
import openfl.text.TextField;
import info.InfoBox;

class Pop extends Sprite
{
    public static inline var LIFE_TIME:Float = 1;
    public static inline var DIST:Float = 15;
    
    public var life:Float;
    
    private var startX_:Int;
    private var startY_:Int;
    
    public function new(x:Int, y:Int, text:String, color:Int)
    {
        super();
        life = LIFE_TIME;
        
        this.x = startX_ = x;
        this.y = startY_ = y;
        
        var tf:TextField = InfoBox.makeTF(12, false, 0, Fonts.CLEAR_FONT, true);
        tf.text = text;
        tf.textColor = color;
        tf.x = -0.5 * tf.width;
        tf.y = -0.5 * tf.height;
        addChild(tf);
    }
    
    public function update():Void
    {
        life -= Global.UPDATE_SECS;
    }
    
    public function draw():Void
    {
        var amount:Float = 1 - Math.max(0, life) / LIFE_TIME;
        y = startY_ - amount * DIST;
    }
    
}