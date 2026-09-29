package game.stars;
import openfl.display.Sprite;

class StarManager extends Sprite
{
    private var stars_:Array<StarParticle>;
    
    public function new() 
    {
        super();
        stars_ = new Array<StarParticle>();
    }
    
    public function explodeAt(x:Int, y:Int):Void
    {
        var phase:Float = 2 * Math.PI * Math.random();
        
        var NUM:Int = 7;
        
        for (i in 0...NUM)
        {
            var a:Float = 2 * Math.PI * i / NUM + phase;
            var p:StarParticle = new StarParticle(x, y);
            p.lastX -= 3 * Math.cos(a);
            p.lastY -= 3 * Math.sin(a);
            
            addChild(p);
            stars_.push(p);
        }
    }
    
    public function update():Void
    {
        for (p in stars_)
        {
            p.update();
            
            if (!(p.life > 0))
            {
                removeChild(p);
            }
        }
        
        stars_ = stars_.filter(deadFilter);
    }
    
    private function deadFilter(p:StarParticle):Bool { return p.life > 0; }
    
    public function draw():Void
    {
        for (p in stars_)
        {
            p.draw();
        }
    }
    
}