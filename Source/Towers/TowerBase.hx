package towers;
import openfl.Vector;
import info.InfoBoxData;
import info.InfoBox;
import ToBitmapData.toBitmapData;
import cheatFree.SafeInt;
import openfl.display.*;
import openfl.events.EventDispatcher;
import openfl.events.MouseEvent;
import game.bullets.BulletsManager;
import game.GameData;
import game.GameGFX;
import game.shocks.ShockManager;

typedef NetworkTowerMessage = {
    x: Int,
    y: Int,
    type: Int,
    upgradeLevel: Int
}

class TowerBase extends EventDispatcher
{
    public var x:Int;
    public var y:Int;
    public var type:Int;
    private var upgradeLevel_:SafeInt = new SafeInt(0);
    public var graphic:DisplayObject;
    public var team:Int;
    private var upgradePips_:Sprite;
    
    public function get_upgradeLevel():Int {return upgradeLevel_.get_val();}
    public function set_upgradeLevel(val:Int):Void {upgradeLevel_.set_val(val);}
    
    public function new(x:Int, y:Int, type:Int, upgradeLevel:SafeInt, overlay:DisplayObject, team:Int) 
    {
        super();

        this.x = x;
        this.y = y;
        this.type = type;
        this.upgradeLevel_ = upgradeLevel;
        this.team = team;
        
        upgradePips_ = new Sprite();
        
        var s_:Sprite;
        graphic = s_ = new Sprite();
        graphic.x = this.x;
        graphic.y = this.y;
        var baseBmp:Bitmap = new Bitmap(team == 0 ? toBitmapData(GameGFX.towerBase0) : toBitmapData(GameGFX.towerBase1), PixelSnapping.ALWAYS, false);
        baseBmp.x = -0.5 * baseBmp.width;
        baseBmp.y = -0.5 * baseBmp.height;
        s_.addChild(baseBmp);
        s_.addChild(upgradePips_);
        s_.addChild(overlay);
        
        s_.useHandCursor = s_.buttonMode = true;
        
        s_.addEventListener(MouseEvent.CLICK, click);
    }
    
    public function reset():Void
    {
        
    }
    
    public function update(inRange:Array<Dynamic>, bulletManager:BulletsManager, shocks:ShockManager):Void
    {
        
    }
    
    public function positionAt(x:Int, y:Int):Void
    {
        this.x = x;
        this.y = y;
        graphic.x = this.x;
        graphic.y = this.y; 
    }
    
    private function click(e:MouseEvent):Void
    {
        dispatchEvent(new TowerEvent(this, TowerEvent.SELECT));
    }
    
    public function clone():TowerBase
    {
        return new TowerBase(x, y, type, upgradeLevel_, null, team);
    }
    
    public function draw():Void
    {
        var g:Graphics = upgradePips_.graphics;
        g.clear();
        
        for (i in 0...upgradeLevel_.get_val())
        {
            var x:Int = -9 + i * 4, y:Int = 7;
            g.beginFill(0);
            g.drawRect(x-1, y-1, 5, 5);
            g.beginFill(0xFFFF00);
            g.drawRect(x, y, 3, 3);
        }
    }
    
    public function get_speed():Float { return get_levels()[upgradeLevel_.get_val()].speed; }
    public function get_radius():Float { return get_levels()[upgradeLevel_.get_val()].radius; }
    public function get_damage():Float { return get_levels()[upgradeLevel_.get_val()].damage; }
    public function get_cost():Float { return get_levels()[upgradeLevel_.get_val()].cost; }
    public function get_air():Bool { return get_levels()[upgradeLevel_.get_val()].air; }
    public function get_ground():Bool { return get_levels()[upgradeLevel_.get_val()].ground; }
    public function get_splash():Float { return get_levels()[upgradeLevel_.get_val()].splash; }
    public function get_freeze():Float { return get_levels()[upgradeLevel_.get_val()].freeze; }
    public function get_sellPrice():Int { return Math.floor(0.75 * get_cost()); }
    
    public function get_levels():Vector<InfoBoxData> { return GameData.towerLevels[this.type]; }

    public function serialise():NetworkTowerMessage {
        var tower:NetworkTowerMessage = {
            x: this.x,
            y: this.y,
            type: this.type,
            upgradeLevel: this.upgradeLevel_.get_val()
        }

        return tower;
    }
    
}