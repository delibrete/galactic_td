package game.creeps;
import gamestate.CreepDef;
import gamestate.Creep;
import openfl.display.*;
import game.GameGFX;
import ToBitmapData.toBitmapData;

class CreepFactory 
{
    public static function make(cash:Int, speed:Int, health:Int, startX:Int, startY:Int, frostResistant:Bool, air:Bool, team:Int, boss:Bool, fast:Bool, extra:Bool):CreepBase
    {
        var g:BitmapData = 0 == team ? toBitmapData(GameGFX.creepNormal0) : toBitmapData(GameGFX.creepNormal1);
        
        if (frostResistant)	g = 0 == team ? toBitmapData(GameGFX.creepFrosty0) : toBitmapData(GameGFX.creepFrosty1);
        if (air)	g = 0 == team ? toBitmapData(GameGFX.creepFlying0) : toBitmapData(GameGFX.creepFlying1);
        if (fast) g = 0 == team ? toBitmapData(GameGFX.creepFast0) : toBitmapData(GameGFX.creepFast1);
        
        return new CreepBase(team == 1, cash, speed, health, startX, startY, g, frostResistant, air, team, boss, fast, extra);
    }

    public static function makeFromDef(def:CreepDef, x:Int, y:Int, team:Int, extra:Bool):Creep
    {
        var creep:Creep = new Creep(def.cash, 35, def.health, x, y, false, false, team, def.boss, false, extra);
        
        switch (def.type)
        {
            case CreepType.NORMAL:		
            case CreepType.FAST:
                creep.speed = 50;
                creep.fast = true;
                
            case CreepType.FLYING:
                creep.air = true;
                
            case CreepType.FROSTY:
                creep.frostResistant = true;
        }
        
        if (def.boss)
        {
            creep.speed = Math.round(creep.speed * 0.5);
        }
        
        return creep;
    }
    
}