package info;

import towers.TowerBase;
import ToBitmapData.toBitmapData;
import openfl.display.*;
import openfl.net.URLLoaderDataFormat;
import openfl.text.*;
import game.GameGFX;
import towers.TowerBase;

class InfoBox extends Sprite
{
    private var title_:TextField;
    private var descText_:TextField;
    private var statsText_:TextField;
    private var groundAndAir_:TextField;
    private var details_:TextField;
    
    public var sellButton:CustomButton;
    public var upgradeButton:CustomButton;
    
    private var upgradeBack_:Bitmap;
    private var upgradeText_:TextField;
    
    public var associated:TowerBase;
    
    public function new() 
    {
        super();

        // var centerOffset = 44;
        var centerOffset = -4;

        var back:Bitmap = new Bitmap(toBitmapData(GameGFX.infoBox), PixelSnapping.ALWAYS, false);
        back.x = 0;
        back.y = 0;
        addChild(back);
        
        // 325, 125
        
        upgradeBack_ = new Bitmap(toBitmapData(GameGFX.upgradeBack), "auto", true);
        addChild(upgradeBack_);
        upgradeBack_.x = 16;
        upgradeBack_.y = 47;
        upgradeBack_.visible = false;
        
        this.visible = false;
        
        title_ = makeTF(16, true);
        title_.x = back.x;
        title_.y = 5;
        addChild(title_);
        
        descText_ = makeTF(12, true);
        descText_.x = back.x - centerOffset;
        descText_.y = 35;
        addChild(descText_);
        
        statsText_ = makeTF();
        statsText_.x = 5;
        statsText_.y = 35;
        addChild(statsText_);
        
        upgradeText_ = makeTF();
        upgradeText_.autoSize = TextFieldAutoSize.RIGHT;
        upgradeText_.y = statsText_.y;
        upgradeText_.x = statsText_.x + 100;
        addChild(upgradeText_);
        
        groundAndAir_ = makeTF(12, true, 0xFF0000);
        groundAndAir_.x = back.x - centerOffset;
        addChild(groundAndAir_);
        
        details_ = makeTF(12, true);
        details_.x = back.x;
        addChild(details_);
        
        upgradeButton = new CustomButton("Upgrade", 100, 0xE9FF00);
        addChild(upgradeButton);
        upgradeButton.visible = true;
        // upgradeButton.y = 140;
        upgradeButton.y = 160;
        centerIt(upgradeButton);
        
        sellButton = new CustomButton("Sell", 100, 0xFF0000);
        addChild(sellButton);
        sellButton.visible = true;
        // sellButton.y = this.height - 10 - sellButton.height;
        sellButton.y = upgradeButton.y + 30;
        centerIt(sellButton);
        
        wrap(title_);
        wrap(descText_);
        // wrap(statsText_);
        wrap(groundAndAir_);
        wrap(details_);
        wrap(upgradeText_);
        
        upgradeButton.disable();
    }
    
    private function centerIt(src:DisplayObject):Void
    {
        src.x = 0.5 * (164 - src.width);
    }
    
    public function show(data:Dynamic, showSellButton:Bool = false, upgradeData:InfoBoxData = null):Void
    {			
        var upgradeMode:Bool = upgradeData != null;
        
        upgradeButton.visible = upgradeBack_.visible = upgradeText_.visible = upgradeMode;
        groundAndAir_.visible = !upgradeMode;
        
        sellButton.visible = showSellButton;
        sellButton.text = "Sell for " + Std.string(Math.floor(data.cost * 0.75));
        
        this.visible = true;			
        title_.text = data.name;
        
        descText_.text = data.desc;
        statsText_.text = "Cost: " + Std.string(data.cost) + "\nDamage: " + Std.string(data.damage) + "\nRadius: " + Std.string(data.radius);
        
        upgradeText_.y = statsText_.y = descText_.y + descText_.height + 5;
        
        details_.y = statsText_.y + statsText_.height;
        
        details_.text = "";
        
        if (upgradeMode)
        {
            details_.text = data.upgradeDetails;
            
            upgradeText_.text = "+" + Std.string(upgradeData.cost - data.cost) + "\n";
            upgradeText_.appendText("+" + Std.string(upgradeData.damage - data.damage) + "\n");
            upgradeText_.appendText("+" + Std.string(upgradeData.radius - data.radius) + "\n");
            
            upgradeBack_.y = statsText_.y;
            
            details_.y = upgradeBack_.y + 50;
            
            details_.width = 135;
            details_.x = 19;
            
            // upgradeButton.y = upgradeBack_.y + upgradeBack_.height - upgradeButton.height - 15;
        }
        else
        {
            details_.width = 164;
            details_.x = 0;
            details_.text = data.details;
        }
        
        groundAndAir_.y = details_.y + details_.height;
        if (data.ground && data.air)	groundAndAir_.text = "Ground and air";
        if (data.ground && !data.air)	groundAndAir_.text = "Ground only";
        if (!data.ground && data.air)	groundAndAir_.text = "Air only";
        
        centerIt(title_);
    }
    
    public function hide():Void
    {
        this.visible = false;
    }
    
    public static function makeTF(size:Int = 12, center:Bool = false, color:Int = 0xFFFFFF, font:String = Fonts.DEFAULT_FONT, bold:Bool = false):TextField
    {
        var f:TextFormat = new TextFormat();
        f.size = size;
        f.color = color;
        f.align = center ? TextFormatAlign.CENTER : TextFormatAlign.LEFT;
        f.font = font;
        f.bold = bold;
        var tf:TextField = new TextField();
        tf.embedFonts = true;
        tf.selectable = false;
        tf.defaultTextFormat = f;
        tf.autoSize = center ? TextFieldAutoSize.CENTER : TextFieldAutoSize.LEFT;
        tf.antiAliasType = AntiAliasType.ADVANCED;
        tf.sharpness = 0;
        
        return tf;
    }
    
    private static function wrap(tf:TextField):Void
    {
        tf.width = 154;
        tf.wordWrap = true;
    }
    
}