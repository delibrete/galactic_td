package towers;
import openfl.events.Event;

class TowerEvent extends Event 
{
    public static final SELECT:String = "oihsdoihjsoidhtowerselectiliveinaworld";
    
    public var tower:TowerBase;
    
    public function new(tower:TowerBase, type:String, bubbles:Bool=false, cancelable:Bool=false) 
    { 
        super(type, bubbles, cancelable);
        this.tower = tower;
    } 
    
    public override function clone():Event 
    { 
        return new TowerEvent(tower, type, bubbles, cancelable);
    } 
    
    public override function toString():String 
    { 
        return formatToString("TowerEvent", "type", "bubbles", "cancelable", "eventPhase"); 
    }
    
}