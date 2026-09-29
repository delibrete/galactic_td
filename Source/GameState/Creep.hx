package gamestate;

class Creep
{
    public var cash:Int;
    public var speed:Int;
    public var health:Int;
    public var startX:Int;
    public var startY:Int;
    public var frostResistant:Bool;
    public var air:Bool;
    public var team:Int;
    public var boss:Bool;
    public var fast:Bool;
    public var extra:Bool;

    public function new(cash:Int, speed:Int, health:Int, startX:Int, startY:Int, frostResistant:Bool, air:Bool, team:Int, boss:Bool, fast:Bool, extra:Bool)
    {
        this.cash = cash;
        this.speed = speed;
        this.health = health;
        this.startX = startX;
        this.startY = startY;
        this.frostResistant = frostResistant;
        this.air = air;
        this.team = team;
        this.boss = boss;
        this.fast = fast;
        this.extra = extra;
    }
}