package editor.extraEnemies; 

import ToBitmapData.toBitmapData;
import cheatFree.SafeInt;
import openfl.display.*;
import openfl.events.MouseEvent;
import openfl.text.TextField;
import game.GameData;
import info.InfoBox;
import info.PlayerInfo;

/**
    * ...
    * @author Wayne Marsh
    */
class ExtraWidget extends Sprite
{
    public static var WIDTH = 145;
    public static var HEIGHT = 19;
    public static var BAR_WIDTH = 107;
    
    // [Embed(source = 'widgetBack.png')] private static const WIDGET_BACK:Class;
    public static var widgetBack = "gfx/widgetBack.png";
    // [Embed(source = 'minus.png')] private static const MINUS:Class;
    public static var minus = "gfx/minus.png";
    // [Embed(source = 'plus.png')] private static const PLUS:Class;
    public static var plus = "gfx/plus.png";
    
    private var playerData_:PlayerInfo;
    
    private var minus_:Sprite;
    private var plus_:Sprite;
    
    private var extra_:Int = 0;
    
    private var cost_:Int;
    private var max_:Int;
    
    private var report_:TextField;
    
    private var bar_:Sprite;
    
    public function new (playerData:PlayerInfo, cost:Int, max:Int) 
    {
        super();
        playerData_ = playerData;
        cost_ = cost;
        max_ = max;
        
        // addChild(new WIDGET_BACK);
        var widgetBackBMP = new Bitmap(toBitmapData(widgetBack));
        addChild(widgetBackBMP);
        
        var tf:TextField = InfoBox.makeTF(12, true);
        tf.text = "Send extra enemies to\nopponent (cost: " + (cost_) + " each):";
        tf.x = 0.5 * (width - tf.width);
        tf.y = -tf.height - 3;
        addChild(tf);
        
        minus_ = new Sprite();
        plus_ = new Sprite();
        // minus_.addChild(new MINUS);
        minus_.addChild(new Bitmap(toBitmapData(minus)));
        // plus_.addChild(new PLUS);
        plus_.addChild(new Bitmap(toBitmapData(plus)));
        
        plus_.x = 126;
        
        addChild(minus_);
        addChild(plus_);
        
        minus_.addEventListener(MouseEvent.CLICK, minusClick);
        plus_.addEventListener(MouseEvent.CLICK, plusClick);
        
        bar_ = new Sprite();
        bar_.x = minus_.width;
        addChild(bar_);
        
        report_ = InfoBox.makeTF(12, true, 0xFFFFFF);
        addChild(report_);
        
        update();
    }
    
    private function minusClick(e:MouseEvent):Void
    {
        if (extra_ > 0)
        {
            var cash = playerData_.get_cash();
            playerData_.set_cash(cash + cost_);
            extra_--;
        }
    }
    
    private function plusClick(e:MouseEvent):Void
    {
        var cash = playerData_.get_cash();
        if (cash >= cost_ && extra_ < max_)
        {
            playerData_.set_cash(cash - cost_);
            extra_++;
        }
    }
    
    private function enableButton(b:Sprite):Void
    {
        b.useHandCursor = b.buttonMode = true;
        b.alpha = 1;
    }
    
    private function disableButton(b:Sprite):Void
    {
        b.useHandCursor = b.buttonMode = false;
        b.alpha = 0.5;
    }
    
    public function update():Void
    {
        if (0 == extra_)
            disableButton(minus_);
        else
            enableButton(minus_);
            
        if (playerData_.get_cash() >= cost_)
            enableButton(plus_);
        else
            disableButton(plus_);
            
        if (max_ == extra_)
            disableButton(plus_);
    }
    
    public function draw():Void
    {
        if (0 != max_)
        {
            report_.text = (extra_) + " extra / " + (max_);
            report_.x = 0.5 * (WIDTH - report_.width);
            report_.y = 0.5 * (HEIGHT - report_.height);
            
            bar_.graphics.clear();
            bar_.graphics.beginFill(0x267F00);
            bar_.graphics.drawRect(0, 0, BAR_WIDTH * extra_ / max_, HEIGHT);
        }
    }
    
    public function get_extra():Int { return extra_; }
    public function set_extra(val:Int):Void {extra_ = val; }
    
}