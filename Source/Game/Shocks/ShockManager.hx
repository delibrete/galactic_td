package game.shocks; 

import openfl.display.*;

class ShockManager extends Sprite
{
    private var shocks_:Array<Dynamic>;
    
    public function new():Void 
    {
        super();
        shocks_ = [];
    }
    
    public function add(x:Float, y:Float, rad:Float):Void
    {
        var ns:Shock = new Shock(x, y, 0.45, rad);
        shocks_.push(ns);
        
        // trace(shocks_.length);
    }
    
    public function update():Void
    {
        for (s in shocks_)
        {
            s.life -= Global.UPDATE_SECS;
        }
        
        shocks_ = shocks_.filter(deadFilter);
    }
    
    // private function deadFilter(s:Shock, idx:Int, a:Array<Dynamic>):Bool { return s.life > 0; } //TODO: pointless arguments
    private function deadFilter(s:Shock):Bool { return s.life > 0; }
    
    public function draw():Void
    {
        graphics.clear();
        
        for (s in shocks_)
        {
            graphics.lineStyle(5, 0xFFFFFF, s.life / s.totalLife);
            graphics.drawCircle(s.x, s.y, (s.rad-5) * (1 - s.life / s.totalLife));
        }
    }
    
}