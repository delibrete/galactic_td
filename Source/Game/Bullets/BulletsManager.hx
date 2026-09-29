package game.bullets;
import game.creeps.CreepBase;
import openfl.Vector;
import openfl.display.Sprite;

class BulletsManager extends Sprite
{
    private var bullets_:Array<IBullet>;
    
    public function new():Void 
    {
        super();
        bullets_ = new Array<IBullet>();
    }
    
    public function add(bullet:IBullet):Void
    {
        addChild(bullet.getGraphic());
        bullets_.push(bullet);
    }
    
    public function update(creeps0:Vector<CreepBase>, creeps1:Vector<CreepBase>):Void
    {
        var copy:Array<IBullet> = [];

        var i:Int = 0;
        for (i in 0...bullets_.length)
        {
            var b:IBullet = bullets_[i];
            if (b.update())
            {
                b.apply(b.get_team() == 0 ? creeps1 : creeps0);
                removeChild(b.getGraphic());
            }
            else
            {
                copy.push(b);
            }
        }
        
        bullets_ = copy;
    }
    
}