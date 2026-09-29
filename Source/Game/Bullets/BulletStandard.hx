package game.bullets;

import openfl.Vector;
import openfl.display.*;
import openfl.geom.Point;
import game.creeps.CreepBase;

class BulletStandard implements IBullet
{
    private var holder_:Sprite;
    
    private var targetCreep_:CreepBase;
    private var x_:Float;
    private var y_:Float;
    private var targetX_:Float;
    private var targetY_:Float;
    private var speed_:Float;
    private var damage_:Int;
    
    private var team_:Int;
    
    public function new(graphic:BitmapData, x:Float, y:Float, damage:Int, target:CreepBase, speed:Float, team:Int) 
    {
        holder_ = new Sprite();
        damage_ = damage;
        speed_ = speed;
        var bmp:Bitmap = new Bitmap(graphic, "auto", true);
        bmp.x = -0.5 * bmp.width;
        bmp.y = -0.5 * bmp.height;
        holder_.addChild(bmp);
        
        team_ = team;
        
        target.mark += damage;
        
        targetCreep_ = target;
        x_ = x;
        y_ = y;
        targetX_ = target.x;
        targetY_ = target.y;
        
        holder_.x = x_;
        holder_.y = y_;
    }
    
    public function get_team():Int
    {
        return team_;
    }
    
    public function update():Bool
    {			
        var dx:Float = targetCreep_.x - x_;
        var dy:Float = targetCreep_.y - y_;
        var dir:Point = new Point(dx, dy);
        dir.normalize(speed_ * Global.UPDATE_SECS);
        
        x_ += dir.x;
        y_ += dir.y;
        
        holder_.x = x_;
        holder_.y = y_;
        
        dx = targetCreep_.x - x_;
        dy = targetCreep_.y - y_;
        
        holder_.rotation = Math.atan2(dy, dx) * 180 / Math.PI;
        
        return dx*dx+dy*dy < 9;
    }
    
    public function apply(creeps:Vector<CreepBase>):Void
    {
        if (targetCreep_.health > 0)
        {
            targetCreep_.subtractHealth(damage_);
            targetCreep_.mark -= damage_;
        }
    }
    
    public function getGraphic():DisplayObject
    {
        return holder_;
    }

}