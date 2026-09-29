package towers;

import sounds.GameSounds;
import cheatFree.SafeInt;
import ToBitmapData.toBitmapData;
import openfl.display.Bitmap;
import game.bullets.BulletsManager;
import game.creeps.CreepBase;
import game.GameGFX;
import game.shocks.ShockManager;
import info.InfoBoxData;
// import Sounds.GameSounds;

class TowerBash extends TowerBase
{		
    private var shootCounter_:Int;
    
    public function new(x:Int, y:Int, team:Int) 
    {
        var bmp:Bitmap = new Bitmap(toBitmapData(GameGFX.bashTurret));
        bmp.x = -0.5 * bmp.width;
        bmp.y = -0.5 * bmp.height;
        super(x, y, TowerTypes.BASH, new SafeInt(0), bmp, team);
        
        reset();
    }
    
    public override function reset():Void
    {
        shootCounter_ = 0;
    }
    
    public override function update(inRange:Array<Dynamic>, bulletManager:BulletsManager, shocks:ShockManager):Void
    {
        if (shootCounter_ >= 0)
        {
            shootCounter_ -= Global.UPDATE_LENGTH;
        }
        else
        {				
            if (0 != inRange.length)
            {
                shocks.add(x, y, this.get_radius());
                GameSounds.play(GameSounds.BOOM);
                
                shootCounter_ = Std.int(this.get_speed());
                for (i in 0...inRange.length)
                {
                    var creep:CreepBase = inRange[i];
                    if (creep.health > 0)
                    {
                        creep.subtractHealth(Std.int(this.get_damage()));
                    }
                }
            }
        }
    }
    
    public override function clone():TowerBase
    {
        return new TowerBash(x, y, team);
    }
    
}