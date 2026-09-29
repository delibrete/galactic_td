package game;

import grid.GameGrid;
import ToBitmapData.toBitmapData;
import openfl.display.BitmapData;
import openfl.geom.Rectangle;
// import grid.GameGrid;

/**
	 * ...
	 * @author Wayne Marsh
	 */
@:final class GameGFX
{
    // @:meta(Embed(source="gfx/bg.jpg"))
    // private static var BG_ : Class<Dynamic>;
    // public static var bg : BitmapData = toBitmapData(Type.createInstance(BG_, []));
    public static var bg = "gfx/bg.jpg";

    // @:meta(Embed(source="gfx/cross.png"))
    // private static var CROSS_ : Class<Dynamic>;
    // public static var cross : BitmapData = toBitmapData(Type.createInstance(CROSS_, []));
    public static var cross = "gfx/cross.png";

    // @:meta(Embed(source="gfx/infoBox.png"))
    // private static var INFO_BOX_ : Class<Dynamic>;
    // public static var infoBox : BitmapData = toBitmapData(Type.createInstance(INFO_BOX_, []));
    public static var infoBox = "gfx/infoBox.png";

    // @:meta(Embed(source="gfx/blocking.png"))
    // private static var BLOCKING_ : Class<Dynamic>;
    // public static var blocking : BitmapData = toBitmapData(Type.createInstance(BLOCKING_, []));
    public static var blocking = "gfx/blocking.png";

    // @:meta(Embed(source="gfx/pellet.png"))
    // private static var PELLET_ : Class<Dynamic>;
    // public static var pellet : BitmapData = toBitmapData(Type.createInstance(PELLET_, []));
    public static var pellet = "gfx/pellet.png";

    // @:meta(Embed(source="gfx/towerBase0.png"))
    // private static var TOWER_BASE0_ : Class<Dynamic>;
    // public static var towerBase0 : BitmapData = toBitmapData(Type.createInstance(TOWER_BASE0_, []));
    public static var towerBase0 = "gfx/towerBase0.png";

    // @:meta(Embed(source="gfx/towerBase1.png"))
    // private static var TOWER_BASE1_ : Class<Dynamic>;
    // public static var towerBase1 : BitmapData = toBitmapData(Type.createInstance(TOWER_BASE1_, []));
    public static var towerBase1 = "gfx/towerBase1.png";

    // @:meta(Embed(source="gfx/pelletTurret.png"))
    // private static var PELLET_TURRET_ : Class<Dynamic>;
    // public static var pelletTurret : BitmapData = toBitmapData(Type.createInstance(PELLET_TURRET_, []));
    public static var pelletTurret = "gfx/pelletTurret.png";

    // @:meta(Embed(source="gfx/laserTurret.png"))
    // private static var LASER_TURRET_ : Class<Dynamic>;
    // public static var laserTurret : BitmapData = toBitmapData(Type.createInstance(LASER_TURRET_, []));
    public static var laserTurret = "gfx/laserTurret.png";

    // @:meta(Embed(source="gfx/missileTurret.png"))
    // private static var MISSILE_TURRET_ : Class<Dynamic>;
    // public static var missileTurret : BitmapData = toBitmapData(Type.createInstance(MISSILE_TURRET_, []));
    public static var missileTurret = "gfx/missileTurret.png";

    // @:meta(Embed(source="gfx/bashTurret.png"))
    // private static var BASH_TURRET_ : Class<Dynamic>;
    // public static var bashTurret : BitmapData = toBitmapData(Type.createInstance(BASH_TURRET_, []));
    public static var bashTurret = "gfx/bashTurret.png";

    // @:meta(Embed(source="gfx/frostTurret.png"))
    // private static var FROST_TURRET_ : Class<Dynamic>;
    // public static var frostTurret : BitmapData = toBitmapData(Type.createInstance(FROST_TURRET_, []));
    public static var frostTurret = "gfx/frostTurret.png";

    // @:meta(Embed(source="gfx/antiAirTurret.png"))
    // private static var ANTI_AIR_TURRET_ : Class<Dynamic>;
    // public static var antiAirTurret : BitmapData = toBitmapData(Type.createInstance(ANTI_AIR_TURRET_, []));
    public static var antiAirTurret = "gfx/antiAirTurret.png";

    // @:meta(Embed(source="gfx/laser.png"))
    // private static var LASER_ : Class<Dynamic>;
    // public static var laser : BitmapData = toBitmapData(Type.createInstance(LASER_, []));
    public static var laser = "gfx/laser.png";

    // @:meta(Embed(source="gfx/missile.png"))
    // private static var MISSILE_ : Class<Dynamic>;
    // public static var missile : BitmapData = toBitmapData(Type.createInstance(MISSILE_, []));
    public static var missile = "gfx/missile.png";

    // @:meta(Embed(source="gfx/frost.png"))
    // private static var FROST_ : Class<Dynamic>;
    // public static var frost : BitmapData = toBitmapData(Type.createInstance(FROST_, []));
    public static var frost = "gfx/frost.png";

    // @:meta(Embed(source="gfx/antiAir.png"))
    // private static var ANTI_AIR_ : Class<Dynamic>;
    // public static var antiAir : BitmapData = toBitmapData(Type.createInstance(ANTI_AIR_, []));
    public static var antiAir = "gfx/antiAir.png";

    // @:meta(Embed(source="gfx/creepNormal0.png"))
    // private static var CREEP_NORMAL0_ : Class<Dynamic>;
    // public static var creepNormal0 : BitmapData = toBitmapData(Type.createInstance(CREEP_NORMAL0_, []));
    public static var creepNormal0 = "gfx/creepNormal0.png";

    // @:meta(Embed(source="gfx/creepNormal1.png"))
    // private static var CREEP_NORMAL1_ : Class<Dynamic>;
    // public static var creepNormal1 : BitmapData = toBitmapData(Type.createInstance(CREEP_NORMAL1_, []));
    public static var creepNormal1 = "gfx/creepNormal1.png";

    // @:meta(Embed(source="gfx/creepFast0.png"))
    // private static var CREEP_FAST0_ : Class<Dynamic>;
    // public static var creepFast0 : BitmapData = toBitmapData(Type.createInstance(CREEP_FAST0_, []));
    public static var creepFast0 = "gfx/creepFast0.png";

    // @:meta(Embed(source="gfx/creepFast1.png"))
    // private static var CREEP_FAST1_ : Class<Dynamic>;
    // public static var creepFast1 : BitmapData = toBitmapData(Type.createInstance(CREEP_FAST1_, []));
    public static var creepFast1 = "gfx/creepFast1.png";

    // @:meta(Embed(source="gfx/creepFrosty0.png"))
    // private static var CREEP_FROSTY0_ : Class<Dynamic>;
    // public static var creepFrosty0 : BitmapData = toBitmapData(Type.createInstance(CREEP_FROSTY0_, []));
    public static var creepFrosty0 = "gfx/creepFrosty0.png";

    // @:meta(Embed(source="gfx/creepFrosty1.png"))
    // private static var CREEP_FROSTY1_ : Class<Dynamic>;
    // public static var creepFrosty1 : BitmapData = toBitmapData(Type.createInstance(CREEP_FROSTY1_, []));
    public static var creepFrosty1 = "gfx/creepFrosty1.png";

    // @:meta(Embed(source="gfx/creepFlying0.png"))
    // private static var CREEP_FLYING0_ : Class<Dynamic>;
    // public static var creepFlying0 : BitmapData = toBitmapData(Type.createInstance(CREEP_FLYING0_, []));
    public static var creepFlying0 = "gfx/creepFlying0.png";

    // @:meta(Embed(source="gfx/creepFlying1.png"))
    // private static var CREEP_FLYING1_ : Class<Dynamic>;
    // public static var creepFlying1 : BitmapData = toBitmapData(Type.createInstance(CREEP_FLYING1_, []));
    public static var creepFlying1 = "gfx/creepFlying1.png";

    // @:meta(Embed(source="gfx/buttonLeft.png"))
    // private static var BUTTON_LEFT_ : Class<Dynamic>;
    // public static var buttonLeft : BitmapData = toBitmapData(Type.createInstance(BUTTON_LEFT_, []));
    public static var buttonLeft = "gfx/buttonLeft.png";

    // @:meta(Embed(source="gfx/buttonRight.png"))
    // private static var BUTTON_RIGHT_ : Class<Dynamic>;
    // public static var buttonRight : BitmapData = toBitmapData(Type.createInstance(BUTTON_RIGHT_, []));
    public static var buttonRight = "gfx/buttonRight.png";

    // @:meta(Embed(source="gfx/buttonMiddle.png"))
    // private static var BUTTON_MIDDLE_ : Class<Dynamic>;
    // public static var buttonMiddle : BitmapData = toBitmapData(Type.createInstance(BUTTON_MIDDLE_, []));
    public static var buttonMiddle = "gfx/buttonMiddle.png";

    // @:meta(Embed(source="gfx/upgradeBack.png"))
    // private static var UPGRADE_BACK_ : Class<Dynamic>;
    // public static var upgradeBack : BitmapData = toBitmapData(Type.createInstance(UPGRADE_BACK_, []));
    public static var upgradeBack = "gfx/upgradeBack.png";

    // @:meta(Embed(source="gfx/starparticle.png"))
    // private static var STAR_PARTICLE_ : Class<Dynamic>;
    // public static var starParticle : BitmapData = toBitmapData(Type.createInstance(STAR_PARTICLE_, []));
    public static var starParticle = "gfx/starparticle.png";

    // @:meta(Embed(source="gfx/win.png"))
    // private static var WIN_ : Class<Dynamic>;
    // public static var win : BitmapData = toBitmapData(Type.createInstance(WIN_, []));
    public static var win = "gfx/win.png";

    // @:meta(Embed(source="gfx/lose.png"))
    // private static var LOSE_ : Class<Dynamic>;
    // public static var lose : BitmapData = toBitmapData(Type.createInstance(LOSE_, []));
    public static var lose = "gfx/lose.png";

    // @:meta(Embed(source="gfx/draw.png"))
    // private static var DRAW_ : Class<Dynamic>;
    // public static var draw : BitmapData = toBitmapData(Type.createInstance(DRAW_, []));
    public static var draw = "gfx/draw.png";

    // @:meta(Embed(source="gfx/extra.png"))
    // private static var EXTRA_ : Class<Dynamic>;
    // public static var extra : BitmapData = toBitmapData(Type.createInstance(EXTRA_, []));
    public static var extra = "gfx/extra.png";

    // @:meta(Embed(source="gfx/fastForward.png"))
    // private static var FF_ : Class<Dynamic>;
    // public static var fastForward : BitmapData = toBitmapData(Type.createInstance(FF_, []));
    public static var fastForward = "gfx/fastForward.png";

    public static var borders : BitmapData = new BitmapData(GameGrid.DEFAULT_GRID_WIDTH * Std.int(GameGrid.DEFAULT_SQUARE_SIZE), GameGrid.DEFAULT_GRID_HEIGHT * Std.int(GameGrid.DEFAULT_SQUARE_SIZE), true, 0);
    
    public static function drawBorders(grid : GameGrid): Void
    {
        var r : Rectangle = new Rectangle(0, 0, grid.get_squareSize(), grid.get_squareSize());
        
        borders.fillRect(borders.rect, 0);
        for (y in 0...grid.get_height())
        {
            for (x in 0...grid.get_height())
            {
                r.x = x * grid.get_squareSize();
                r.y = y * grid.get_squareSize();
                if (grid.isOccupied(x, y))
                {
                    borders.fillRect(r, 0xAAFFFFFF); //TODO: Borders
                }
            }
        }
    }

    public function new()
    {
    }
}

