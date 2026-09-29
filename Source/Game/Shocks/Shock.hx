package game.shocks;

class Shock 
{
    public var x:Float;
    public var y:Float;
    public var life:Float;
    public var rad:Float;
    public var totalLife:Float;
    
    public function new(x:Float, y:Float, life:Float, rad:Float) 
    {
        this.x = x;
        this.y = y;
        this.life = this.totalLife = life;
        this.rad = rad;
    }
    
}