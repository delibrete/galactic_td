package wait;

import openfl.display.*;
import openfl.utils.Assets;

class WaitBar extends Sprite
{
    private var bar_:DisplayObject;
    private var light_:DisplayObject;
    private var moveCount_:Int;
    private var moveIndex_:Int;
    
    public function new() 
    {
        super();

        bar_ = new Bitmap(Assets.getBitmapData("gfx/wait/bar.png"));
        bar_.x = Math.round(0.5 * (Global.SCREEN_WIDTH - 200 - bar_.width));
        bar_.y = Math.round(0.5 * (Global.SCREEN_HEIGHT - bar_.height));
        
        addChild(bar_);
        
        // [Embed(source = 'lit.png')] const LIT:Class;
        light_ = new Bitmap(Assets.getBitmapData("gfx/wait/lit.png"));
        addChild(light_);
        
        moveIndex_ = 0;
        moveCount_ = 0;
        
        update();
    }
    
    public function update():Void
    {
        moveCount_ -= Global.UPDATE_LENGTH;
        if (moveCount_ <= 0)
        {
            moveCount_ = 150;
            
            moveIndex_ = (moveIndex_ +1) % 12;
        }
        
        light_.x = bar_.x + 4 + 10 * moveIndex_;
        light_.y = bar_.y + 4;
    }
    
}