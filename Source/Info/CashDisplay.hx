package info;

import openfl.display.Bitmap;
import openfl.display.DisplayObject;
import openfl.display.Sprite;
import openfl.text.TextField;
import ToBitmapData.toBitmapData;

class CashDisplay extends Sprite
{
    private var data_:PlayerInfo;
    private var cash_:DisplayObject;
    private var tf_:TextField;
    
    public function new(data:PlayerInfo) 
    {
        super();
        data_ = data;
        
        // [Embed(source = 'cash.png')] const CASH_D:Class;
        cash_ = new Bitmap(toBitmapData("gfx/info/cash.png"));
        
        tf_ = InfoBox.makeTF(14);
        
        addChild(cash_);
        addChild(tf_);
        
        draw();
    }
    
    public function draw():Void
    {
        cash_.x = -cash_.width - 5;
        tf_.x = 5;
        
        tf_.text = Std.string(data_.get_cash());
    }
    
}