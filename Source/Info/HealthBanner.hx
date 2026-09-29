package info;

import ToBitmapData.toBitmapData;
import openfl.display.*;
import openfl.text.TextField;

class HealthBanner extends Sprite
{
    public static inline var HEIGHT:Float = 12;
    
    private var heart_:DisplayObject;
    private var healthText_:TextField;
    private var nameText_:TextField;
    private var data_:PlayerInfo;
    
    public function new(data:PlayerInfo) 
    {
        super();
        data_ = data;
        
        // [Embed(source = 'heartSmall.png')] const HEART_SMALL:Class;
        heart_ = new Bitmap(toBitmapData("gfx/info/heartSmall.png"));
        addChild(heart_);
        
        healthText_ = InfoBox.makeTF(12);
        addChild(healthText_);
        healthText_.text = "20";
        
        nameText_ = InfoBox.makeTF(12);
        nameText_.textColor = data.get_team() == 0 ? 0x00FFFF : 0xFFFF00;
        addChild(nameText_);
        
        // Draw
        draw();
    }
    
    public function draw():Void
    {
        nameText_.text = data_.get_name();
        healthText_.text = Std.string(data_.get_lives());
        
        nameText_.x = 0;
        heart_.x = nameText_.x + nameText_.width + 10;
        healthText_.x = heart_.x + heart_.width;
        
        nameText_.y = 0.5 * (HEIGHT - nameText_.height);
        heart_.y = 0.5 * (HEIGHT - heart_.height);
        healthText_.y = 0.5 * (HEIGHT - healthText_.height);
        
        graphics.clear();
        graphics.beginFill(0, 131 / 255);
        // graphics.drawRect(0, 0, healthText_.x + healthText_.width, HEIGHT); //TODO: Slow
    }
    
}