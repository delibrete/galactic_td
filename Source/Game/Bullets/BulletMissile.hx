package game.bullets;
import openfl.Vector;
import openfl.display.BitmapData;
import game.creeps.CreepBase;
import game.shocks.ShockManager;

class BulletMissile extends BulletStandard
{
    private var splash_:Int;
    private var shock_:ShockManager;
    
    public function new(graphic:BitmapData, x:Float, y:Float, damage:Int, target:CreepBase, speed:Float, splash:Int, team:Int, shock:ShockManager) 
    {
        splash_ = splash;
        shock_ = shock;
        
        super(graphic, x, y, damage, target, speed, team);
    }
    
    public override function update():Bool
    {	
        speed_ += 2;
        
        return super.update();
    }
    
    public override function apply(creeps:Vector<CreepBase>):Void
    {
        targetCreep_.mark -= damage_;
        
        shock_.add(this.x_, this.y_, splash_);
        
        // For each creep in range
        var ss:Int = splash_ * splash_;
        
        for (i in 0...creeps.length)
        {
            var creep:CreepBase = creeps[i];
            
            var dx:Float = creep.x - x_;
            var dy:Float = creep.y - y_;
            
            if (dx * dx + dy * dy <= ss)
            {
                if (creep.health > 0)
                {
                    creep.subtractHealth(damage_);
                }
            }
        }
    }
    
}