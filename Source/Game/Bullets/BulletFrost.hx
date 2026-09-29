package game.bullets;

import openfl.Vector;
import openfl.display.BitmapData;
import game.creeps.CreepBase;

class BulletFrost extends BulletStandard
{
    private var splash_:Int;
    private var slowFor_:Int;
    
    public function new(graphic:BitmapData, x:Float, y:Float, damage:Int, target:CreepBase, speed:Float, splash:Int, slowFor:Int, team:Int) 
    {
        splash_ = splash;
        slowFor_ = slowFor;
        
        super(graphic, x, y, damage, target, speed, team);
    }
    
    public override function apply(creeps:Vector<CreepBase>):Void
    {
        targetCreep_.mark -= damage_;
        
        // For each creep in range
        var ss:Int = splash_ * splash_;
        
        for (i in 0...creeps.length)
        {
            var creep:CreepBase = creeps[i];
            
            var dx:Float = creep.x - x_;
            var dy:Float = creep.y - y_;
            
            if (dx * dx + dy * dy <= ss)
            {
                if (creep.health > 0 && !creep.frostResistant)
                {
                    creep.subtractHealth(damage_);
                    creep.frostTimer = slowFor_;
                }
            }
        }
    }
    
}