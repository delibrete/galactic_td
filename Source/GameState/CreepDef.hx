package gamestate;

enum CreepType
{
    NORMAL;
    FAST;
    FLYING;
    FROSTY;
}

class CreepDef
{
    public var type:CreepType;
    public var cash:Int;
    public var health:Int;
    public var boss:Bool;

    // haxe is lame
    // public function new(other:CreepDef) {
    //     this.type = other.type;
    //     this.cash = other.cash;
    //     this.health = other.health;
    //     this.boss = other.boss;
    // }

    public function new(type:CreepType, cash:Int, health:Int, boss:Bool) {
        this.type = type;
        this.cash = cash;
        this.health = health;
        this.boss = boss;
    }
}