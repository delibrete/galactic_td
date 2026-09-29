package game.creeps;

import openfl.Vector;
import openfl.display.*;
import openfl.filters.ColorMatrixFilter;
import openfl.geom.Point;
import game.GameGFX;
import grid.GameGrid;
import grid.GridCoord;

class CreepBase 
{
    public var moveUp:Bool;
    public var speed:Float;
    public var x:Float;
    public var y:Float;
    private var lastX_:Float;
    private var lastY_:Float;
    public var graphic:Sprite;
    public var rot:Float = 0;
    public var startHealth:Int;
    public var health:Int;
    public var air:Bool;
    public var frostResistant:Bool;
    
    public var team:Int;
    
    public var mark:Int;
    
    public var cash:Int;
    
    public var frostTimer:Int;
    
    public var fast:Bool;
    
    public var boss:Bool;
    
    public var healthBar_:EnergyBar;
    
    private var rotGraph_:Sprite;
    
    private var path_:Vector<GridCoord>;
    private var pathIndex_:Int;
    private var lookAtX_:Float;
    private var lookAtY_:Float;
    
    public var extra:Bool;
    
    public function new(moveUp:Bool, cash:Int, speed:Float, health:Int, startX:Float, startY:Float, graphic:BitmapData, frostResistant:Bool, air:Bool, team:Int, boss:Bool, fast:Bool, extra:Bool = false) 
    {
        this.extra = extra;
        this.startHealth = this.health = health;
        this.cash = cash;
        this.fast = fast;
        this.moveUp = moveUp;
        this.speed = speed;
        this.x = lastX_ = startX;
        this.y = lastY_ = startY;
        pathIndex_ = 0;
        this.air = air;
        this.frostResistant = frostResistant;
        this.team = team;
        
        frostTimer = 0;
        
        mark = 0;
        
        var bmp:Bitmap = new Bitmap(graphic, PixelSnapping.ALWAYS, true);
        bmp.x = -0.5 * bmp.width;
        bmp.y = -0.5 * bmp.height;
        this.graphic = new Sprite();
        
        this.graphic.scaleX = this.graphic.scaleY = boss ? 1.2 : 1;
        
        this.rotGraph_ = new Sprite();
        this.rotGraph_.addChild(bmp);
        this.graphic.addChild(rotGraph_);
        
        lookAtX_ = 0;
        lookAtY_ = moveUp ? -1 : 1;
        
        this.graphic.buttonMode = this.graphic.useHandCursor = true;
        
        healthBar_ = new EnergyBar(health);
        this.graphic.addChild(healthBar_);
        
        if (extra)
        {
            var exBmp:Bitmap = new Bitmap(GameGFX.extra);
            exBmp.x = -0.5 * exBmp.width;
            exBmp.y = 12;
            this.graphic.addChild(exBmp);
        }
        
        draw();
    }
    
    public function subtractHealth(amount:Int):Void
    {
        this.health -= amount;
        if (this.health < 0)	this.health = 0;
    }
    
    public function update(dt:Float, grid:GameGrid):Void
    {			
        if (frostTimer >= 0)
        {
            frostTimer -= Global.UPDATE_LENGTH;
        }
        
        var actualSpeed:Float = speed;
        
        if (frostTimer > 0)
        {
            actualSpeed *= 0.5;
        }
        
        var gridPos:GridCoord = grid.coordAt(Math.round(x), Math.round(y));
        var didMove:Bool = false;
        
        if (!air)
        {
            if (gridPos != null)
            {
                if (path_ == null)
                {
                    var startP:Vector<GridCoord> = new Vector<GridCoord>();
                    startP.push(gridPos);

                    path_ = grid.pathToExit(moveUp, gridPos.x, gridPos.y);
                    
                    if (path_ != null)
                    {
                        path_ = startP.concat(path_);
                    }
                }
                
                if (path_ != null)
                {
                    // Move along path
                    var p0:GridCoord = path_[pathIndex_];
                    var hg:Float = 0.5 * grid.get_squareSize();
                    if (p0 != null)
                    {
                        var dst:Point = new Point(p0.x * grid.get_squareSize() + hg - x, p0.y * grid.get_squareSize() + hg - y);
                        if (dst.length < 4)
                        {
                            pathIndex_++;
                        }
                        else
                        {
                            dst.normalize(actualSpeed * dt);
                            x += dst.x;
                            y += dst.y;
                            
                            didMove = true;
                        }
                    }
                }
            }
        }
        
        if (!didMove)
        {
            if (moveUp)
                y -= actualSpeed * dt;
            else
                y += actualSpeed * dt;
                
            didMove = true;
        }
        
        if (didMove)
        {
            var dx:Float = x - lastX_;
            var dy:Float = y - lastY_;
            var look:Point = new Point(dx, dy);
            
            look.normalize(1);
        
            lastX_ = x;
            lastY_ = y;
            
            lookAtX_ = 0.1 * look.x + 0.9 * lookAtX_;
            lookAtY_ = 0.1 * look.y + 0.9 * lookAtY_;
            
            rot = Math.atan2(lookAtY_, lookAtX_);
        }
        
        if (frostTimer > 0)
        {
            this.graphic.filters = [new ColorMatrixFilter([
                0.75, 0, 0, 0, 0,
                0, 0.75, 0, 0, 0,
                0, 0, 0.75, 0, 0,
                0, 0, 0, 1, 0,
            ])];
        }
        else
        {
            this.graphic.filters = [];
        }
        
    }
    
    public function draw():Void
    {
        healthBar_.draw(health);
        
        graphic.x = x;
        graphic.y = y;
        rotGraph_.rotation = rot * 180.0 / Math.PI; //TODO: fix
    }
    
    public function tracePath():Void
    {
        for (i in 0...path_.length)
        {
            var c:GridCoord = path_[i];
            trace(c.x, c.y);
        }
    }
    
    public function get_pathRemaining():Vector<GridCoord>
    {
        return path_.slice(pathIndex_);
    }
    
    public function get_hasPath():Bool
    {
        return path_ != null;
    }
    
}