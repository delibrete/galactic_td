package info;

import openfl.display.Bitmap;
import openfl.display.Sprite;
import openfl.text.TextField;
import openfl.text.TextFieldAutoSize;
import game.creeps.CreepBase;
import game.GameGFX;

import ToBitmapData.toBitmapData;

class CreepBox extends Sprite
{
    private var title_:TextField;
    private var statsText_:TextField;
    private var pic_:Bitmap;
    private var current_:CreepBase;
    
    public function new() 
    {
        super();

        addChild(new Bitmap(toBitmapData(GameGFX.infoBox)));
        
        title_ = InfoBox.makeTF(16, true);
        wrapIt(title_);
        addChild(title_);
        title_.y = 5;
        
        pic_ = new Bitmap();
        pic_.y = 60;
        pic_.scaleX = pic_.scaleY = 1.5;
        pic_.smoothing = true;
        pic_.rotation = -90;
        addChild(pic_);
        
        statsText_ = InfoBox.makeTF();
        statsText_.x = 5;
        statsText_.y = 67;
        addChild(statsText_);
        
        this.visible = false;
    }
    
    private function wrapIt(t:TextField):Void
    {
        t.autoSize = TextFieldAutoSize.NONE;
        t.wordWrap = true;
        t.width = 164;
    }
    
    public function show(creep:CreepBase):Void
    {
        this.visible = true;
        
        setData(creep);
    }
    
    private function setData(creep:CreepBase):Void
    {
        title_.text = "Normal Enemy";
        
        current_ = creep;
        
        pic_.bitmapData = 0 == creep.team ? toBitmapData(GameGFX.creepNormal0) : toBitmapData(GameGFX.creepNormal1);
        
        if (creep.frostResistant)
        {
            pic_.bitmapData = 0 == creep.team ? toBitmapData(GameGFX.creepFrosty0) : toBitmapData(GameGFX.creepFrosty1);
            
            title_.text = "Frost Resistant";
        }
        
        if (creep.air)
        {
            pic_.bitmapData = 0 == creep.team ? toBitmapData(GameGFX.creepFlying0) : toBitmapData(GameGFX.creepFlying1);
            
            title_.text = "Flying Enemy";
        }
        
        if (creep.fast)
        {
            pic_.bitmapData = 0 == creep.team ? toBitmapData(GameGFX.creepFast0) : toBitmapData(GameGFX.creepFast1);
            
            title_.text = "Fast Enemy";
        }
        
        pic_.x = 0.5 * (this.width - pic_.width);
        
        statsText_.text = "Health:\t\t" + Std.string(creep.health);
        statsText_.appendText("\n");
        statsText_.appendText("Cash:\t\t" + Std.string(creep.cash));
        statsText_.appendText("\n");
        statsText_.appendText("Speed:\t\t" + Std.string(creep.speed));
    }
    
    public function hide():Void
    {
        this.visible = false;
        current_ = null;
    }
    
    public function draw():Void
    {
        if (current_ != null && this.visible)
        {
            setData(current_);
            
            if (current_.health <= 0)
            {
                hide();
            }
        }
    }
    
}