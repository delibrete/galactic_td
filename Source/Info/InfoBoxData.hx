package info;
import openfl.display.DisplayObject;

class InfoBoxData 
{
    
    public var name:String;
    public var cost:Int;
    public var damage:Int;
    public var radius:Int;
    public var air:Bool;
    public var ground:Bool;
    public var desc:String;
    public var details:String;
    public var upgradeDetails:String;
    public var speed:Int;
    public var splash:Int;
    public var freeze:Int;
    
    public function new(name:String, cost:Int, damage:Int, radius:Int, air:Bool, ground:Bool, desc:String, details:String, upgradeDetails:String, speed:Int, splash:Int, freeze:Int)
    {
        this.name = name;
        this.cost = cost;
        this.damage = damage;
        this.radius = radius;
        this.air = air;
        this.ground = ground;
        this.desc = desc;
        this.details = details;
        this.upgradeDetails = upgradeDetails;
        this.speed = speed;
        this.splash = splash;
        this.freeze = freeze;
    }
}