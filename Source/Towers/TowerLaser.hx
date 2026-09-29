package towers;
import sounds.GameSounds;
import openfl.display.*;
import cheatFree.SafeInt;
import ToBitmapData.toBitmapData;
import game.bullets.BulletsManager;
import game.bullets.BulletStandard;
import game.creeps.CreepBase;
import game.GameGFX;
import game.shocks.ShockManager;
import info.InfoBoxData;
// import Sounds.GameSounds;

class TowerLaser extends TowerBase
{		
    private var overlay_:Sprite;
    private var shootCounter_:Int;
    
    public function new(x:Int, y:Int, team:Int) 
    {
        overlay_ = new Sprite();
        var bmp:Bitmap = new Bitmap(toBitmapData(GameGFX.laserTurret), "auto", true);
        bmp.x = -0.5 * bmp.width;
        bmp.y = -0.5 * bmp.height;
        overlay_.addChild(bmp);
        
        super(x, y, TowerTypes.LASER, new SafeInt(0), overlay_, team);
        
        reset();
    }
    
    public override function reset():Void
    {
        shootCounter_ = 0;
    }
    
    public override function update(inRange:Array<Dynamic>, bulletManager:BulletsManager, shocks:ShockManager):Void
    {
        var chosen:CreepBase = null;
        
        for (i in 0...inRange.length)
        {
            var creep:CreepBase = inRange[i];
            
            if (creep.mark < creep.health && creep.y > 0 && creep.y < Global.SCREEN_HEIGHT)
            {
                chosen = creep;
                break;
            }
        }
        
        if (chosen != null)
        {
            if (shootCounter_ <= 0)
            {
                shootCounter_ = Std.int(this.get_speed());
                bulletManager.add(new BulletStandard(toBitmapData(GameGFX.laser), x, y, Std.int(this.get_damage()), chosen, 125, team));
                GameSounds.play(GameSounds.LASER);
            }
            
            // var dx:Float = x - creep.x;
            var dx:Float = x - chosen.x;
            // var dy:Float = y - creep.y;
            var dy:Float = y - chosen.y;
            
            overlay_.rotation = Math.atan2( -dy, -dx) * 180 / Math.PI;
        }
        
        if (shootCounter_ >= 0)
        {
            shootCounter_ -= Global.UPDATE_LENGTH;
        }
    }
    
    public override function clone():TowerBase
    {
        var copy:TowerLaser = new TowerLaser(x, y, team);
        return copy;
    }
    
}