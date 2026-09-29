package;

import ToBitmapData.toBitmapData;
import openfl.display.*;
import openfl.events.MouseEvent;
import openfl.geom.ColorTransform;
import openfl.geom.Matrix;
import openfl.text.TextField;
import game.GameGFX;
import info.InfoBox;

class CustomButton extends Sprite
{
    private var tf:TextField;
    private var ct_:ColorTransform;
    private var ctTf_:ColorTransform;
    private var buttonWidth:Int;

    public var enabled:Bool;
    public var text:String;
    public var color:Int;
    
    public function new(text:String, width:Int, color:Int = 0xFFFFFF) 
    {
        super();

        this.text = text;
        this.buttonWidth = width;
        this.color = color;
        
        redraw(text, width, color);
    }
    
    public function set_text(val:String):Void
    {
        tf.text = val;
        tf.x = 0.5 * (this.buttonWidth - tf.width);
        // tf.y = 0.5 * (this.buttonWidth - tf.height);
        // redraw(val, this.buttonWidth, this.color);
    }

    public function set_colour(colour:Int) {
        redraw(this.text, this.buttonWidth, colour);
    }
    
    private function mouseOver(e:MouseEvent):Void
    {
        if (enabled)
            tf.textColor = 0xFFFF00;
    }
    
    private function mouseOut(e:MouseEvent):Void
    {
        if (enabled)
            tf.textColor = 0xFFFFFF;
    }
    
    public function disable():Void
    {
        if (enabled)
        {
            buttonMode = useHandCursor = false;
            ct_.redMultiplier *= 0.45;
            ct_.greenMultiplier *= 0.45;
            ct_.blueMultiplier *= 0.45;
            enabled = false;
            
            tf.textColor = 0x666666;
        }
    }
    
    public function enable():Void
    {
        if (!enabled)
        {
            buttonMode = useHandCursor = true;
            ct_.redMultiplier *= 1 / 0.45;
            ct_.greenMultiplier *= 1 / 0.45;
            ct_.blueMultiplier *= 1 / 0.45;
            enabled = true;
            
            tf.textColor = 0xFFFFFF;
        }
    }

    private function redraw(text:String, width:Int, color:Int = 0xFFFFFF):Void {
        removeChildren();
        useHandCursor = buttonMode = true;
        
        tf = InfoBox.makeTF();
        tf.text = text;
        // tf.x = 5;
        addChild(tf);
        
        var m:Matrix = new Matrix();
        m.identity();
        
        var r:Float = (color & 0xFF0000) / 0xFF0000;
        var g:Float = (color & 0xFF00) / 0xFF00;
        var b:Float = (color & 0xFF) / 0xFF;
        var ct:ColorTransform = new ColorTransform(r, g, b);
        
        ct_ = ct;

        var buttonMiddle = toBitmapData(GameGFX.buttonMiddle);
        var src:BitmapData = new BitmapData(buttonMiddle.width, buttonMiddle.height, true, 0);
        src.draw(buttonMiddle, null, ct);
        
        graphics.beginBitmapFill(src, m, true, true);

        var buttonLeft = toBitmapData(GameGFX.buttonLeft);
        var buttonRight = toBitmapData(GameGFX.buttonRight);
        graphics.drawRect(buttonLeft.width, 0, width - buttonLeft.width - buttonRight.width, buttonMiddle.height);
        src = new BitmapData(buttonLeft.width, buttonLeft.height, true, 0);
        src.draw(buttonLeft, null, ct);
        
        graphics.beginBitmapFill(src, m, false, true);
        graphics.drawRect(0, 0, buttonLeft.width, buttonLeft.height);
        
        src = new BitmapData(buttonRight.width, buttonRight.height, true, 0);
        src.draw(buttonRight, null, ct);
        
        m.translate(width - buttonRight.width, 0);
        graphics.beginBitmapFill(src, m, false, true);
        graphics.drawRect(width - buttonRight.width, 0, buttonRight.width, buttonRight.height);
        
        var over:Sprite = new Sprite();
        over.graphics.beginFill(0xFFFFFF, 0);
        over.graphics.drawRect(0, 0, width, buttonLeft.height);
        addChild(over);
        
        this.text = tf.text;
        this.buttonWidth = width;
        
        addEventListener(MouseEvent.MOUSE_OVER, mouseOver);
        addEventListener(MouseEvent.MOUSE_OUT, mouseOut);

        tf.x = 0.5 * (this.width - tf.width);
        tf.y = 0.5 * (this.height - tf.height);
        
        enabled = true;
    }
    
}