package game.popText;

import openfl.display.Sprite;

class PopManager extends Sprite
{
    private var pops_:Array<Pop>;
    
    public function new() 
    {
        super();
        pops_ = new Array<Pop>();
    }
    
    public function add(x:Int, y:Int, text:String, color:Int):Void
    {
        var pop:Pop = new Pop(x, y, text, color);
        addChild(pop);
        pops_.push(pop);
    }
    
    public function update():Void
    {
        for (pop in pops_)
        {
            pop.update();
            
            if (!(pop.life > 0))
            {
                removeChild(pop);
            }
        }
        
        pops_ = pops_.filter(popFilter);
    }
    
    private function popFilter(pop:Pop):Bool { return pop.life > 0; }
    
    public function draw():Void
    {
        for (pop in pops_)
        {
            pop.draw();
        }
    }
    
}