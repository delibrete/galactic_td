package game;

import ToBitmapData.toBitmapData;
import openfl.display.*;
import openfl.Lib.getTimer;

class FastForward extends Sprite
{
    private var ff_:Bitmap;
    
    public function new() 
    {
        super();
        ff_ = new Bitmap(toBitmapData(GameGFX.fastForward));
        addChild(ff_);
    }
    
    public function update():Void
    {
        ff_.visible = (getTimer() % 1000) < 500;
    }
    
}