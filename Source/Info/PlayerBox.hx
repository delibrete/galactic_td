package info;
import openfl.display.*;
import openfl.text.TextField;
import ToBitmapData.toBitmapData;

class PlayerBox extends Sprite
{
    private static inline var WIDTH:Int = 178;
    
    private var playerText_:TextField;
    private var cashText_:TextField;
    private var livesText_:TextField;
    private var playerInfo_:PlayerInfo;
    private var pointsText_:TextField;
    
    private var centerProperly_:Bool;
    
    public function new(info:PlayerInfo, centerProperly:Bool = false) 
    {
        super();
        // [Embed(source = 'cash.png')] const CASH:Class;
        var cashGfx = new Bitmap(toBitmapData("gfx/info/cash.png"));
        // [Embed(source = 'heart.png')] const HEART:Class;
        var heartGfx = new Bitmap(toBitmapData("gfx/info/heart.png"));
        
        centerProperly_ = centerProperly;
        
        playerInfo_ = info;
        
        playerText_ = InfoBox.makeTF(14);
        playerText_.text = "asbcdefghijklmnop";
        addChild(playerText_);
        
        pointsText_ = InfoBox.makeTF(16, false);
        pointsText_.text = "01234566789";
        addChild(pointsText_);
        
        pointsText_.y = playerText_.height + 5;
        
        var cashIcon:DisplayObject = cashGfx;
        addChild(cashIcon);
        cashIcon.x = -cashIcon.width - 5;
        cashIcon.y = pointsText_.y + pointsText_.height + 5;
        
        var heartIcon:DisplayObject = heartGfx;
        addChild(heartIcon);
        heartIcon.x = - heartIcon.width - 5;
        heartIcon.y = cashIcon.y + cashIcon.height + 5;
        
        cashText_ = InfoBox.makeTF();
        cashText_.text = "12345456790";
        cashText_.x = 5;
        cashText_.y = cashIcon.y;
        addChild(cashText_);
        
        livesText_ = InfoBox.makeTF();
        livesText_.x = 5;
        livesText_.y = heartIcon.y;
        addChild(livesText_);
        
        draw();
    }
    
    public function draw():Void
    {
        playerText_.text = playerInfo_.get_name();
        
        playerText_.x = -0.5 * playerText_.width;
        
        pointsText_.text = Std.string(playerInfo_.get_score());
        pointsText_.x = -0.5 * pointsText_.width;
        
        playerText_.textColor = 0 == playerInfo_.get_team() ? 0x05F6FF : 0xE1FF05;
        
        cashText_.text = Std.string(playerInfo_.get_cash());
        livesText_.text = Std.string(playerInfo_.get_lives());
    }
    
}