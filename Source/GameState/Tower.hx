package gamestate;

enum TowerType {
    PELLET; //0
    LASER; //1
    MISSILE; //2
    BASH; //3
    FROST; //4
    ANTIAIR; //5
}

var TowerTypeMap:Map<TowerType, Int> = [
    PELLET => 0,
    LASER => 1,
    MISSILE => 2,
    BASH => 3,
    FROST => 4,
    ANTIAIR => 5
];

class Tower
{
    public var type:TowerType;
    public var upgradeLevel:Int;
    public var x:Int;
    public var y:Int;
    public var team:Int;

    public function new(x:Int, y:Int, type:TowerType, upgradeLevel:Int, team:Int)
    {
        this.type = type;
        this.x = x;
        this.y = y;
        this.upgradeLevel = upgradeLevel;
        this.team = team;
    }
}