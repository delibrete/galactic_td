package game.stars;
import openfl.display.PixelSnapping;
import ToBitmapData.toBitmapData;
import openfl.display.Bitmap;
import game.GameGFX;

class StarParticle extends Bitmap
{
    public var lastX:Float;
    public var posX:Float;
    public var lastY:Float;
    public var posY:Float;
    
    public var life:Float;
    
    public static inline var START_LIFE:Float = 0.5;
    
    public function new(x:Int, y:Int) 
    {
        // super(GameGFX.starParticle, "auto", false);
        super(toBitmapData(GameGFX.starParticle), PixelSnapping.AUTO, false);
        
        this.posX = this.lastX = x;
        this.posY = this.lastY = y;
        
        life = START_LIFE;
    }
    
    public function update():Void
    {
        var DAMP:Float = 0.05;
        
        var nx:Float = (2 - DAMP) * this.posX - (1 - DAMP) * this.lastX;
        var ny:Float = (2 - DAMP) * this.posY - (1 - DAMP) * this.lastY;
        this.lastX = posX;
        this.lastY = posY;
        this.posX = nx;
        this.posY = ny;
        
        life -= Global.UPDATE_SECS;
        
        this.alpha = life / START_LIFE;
    }
    
    public function draw():Void
    {
        this.x = posX - 0.5 * width;
        this.y = posY - 0.5 * height;
    }
}