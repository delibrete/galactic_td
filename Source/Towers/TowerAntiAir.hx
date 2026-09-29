package towers; 

import sounds.GameSounds;
import cheatFree.SafeInt;
import ToBitmapData.toBitmapData;
import openfl.display.Bitmap;
import openfl.display.Sprite;
import game.bullets.BulletsManager;
import game.bullets.BulletStandard;
import game.creeps.CreepBase;
import game.GameGFX;
import game.shocks.ShockManager;
import info.InfoBoxData;
// import sounds.GameSounds;

//TODO: Fix air towers
class TowerAntiAir extends TowerBase
{		
    private var overlay_:Sprite;
    private var shootCounter_:Int;
    
    public function new(x:Int, y:Int, team:Int) 
    {
        overlay_ = new Sprite();
        var bmp:Bitmap = new Bitmap(toBitmapData(GameGFX.antiAirTurret), "auto", true);
        bmp.x = -0.5 * bmp.width;
        bmp.y = -0.5 * bmp.height;
        overlay_.addChild(bmp);
        
        super(x, y, TowerTypes.ANTIAIR, new SafeInt(0), overlay_, team);
        
        reset();
    }
    
    public override function reset():Void
    {
        shootCounter_ = 0;
    }
    
    public override function update(inRange:Array<Dynamic>, bulletManager:BulletsManager, shocks:ShockManager):Void
    {
        // trace(shootCounter_, inRange.length);
        if (shootCounter_ <= 0 && 0 != inRange.length)
        {
            for (i in 0...4) {
            
                doShoot(inRange, i, 4, bulletManager);
            
            }				
            
            shootCounter_ = Std.int(this.get_speed());
        }
        
        if (shootCounter_ >= 0)
        {
            shootCounter_ -= Global.UPDATE_LENGTH;
        }
    }
    
    private function doShoot(inRange:Array<Dynamic>, start:Int, total:Int, bulletManager:BulletsManager):Void
    {
        var chosen:CreepBase = null;
        
        for (i in 0...inRange.length)
        {
            var creep:CreepBase = inRange[(i + start) % inRange.length];
            
            if (creep.mark < creep.health && creep.y > 0 && creep.y < Global.SCREEN_HEIGHT)
            {
                chosen = creep;
                break;
            }
        }
        
        var angle:Float = cast(start, Float) / total * 2 * Math.PI;
        var shootFromX:Int = Std.int(x + 5 * Math.cos(angle));
        var shootFromY:Int = Std.int(y + 5 * Math.sin(angle));
        
        
        
        if (chosen != null)
        {
            bulletManager.add(new BulletStandard(toBitmapData(GameGFX.antiAir), shootFromX, shootFromY, Std.int(this.get_damage()), chosen, 125, team));
            GameSounds.play(GameSounds.AIR);
        }
    }
    
    public override function clone():TowerBase
    {
        var copy:TowerAntiAir = new towers.TowerAntiAir(x, y, team);
        return copy;
    }
    
}