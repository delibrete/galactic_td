package game;
import game.creeps.CreepBase;
import towers.TowerBase;
import info.InfoBoxData;
import openfl.geom.Point;
import openfl.Vector;
import grid.GameGrid;
import info.PlayerInfo;
import cheatFree.SafeInt;

class GameData 
{
    public var gameId:String;
    
    public var allowRecording:Array<Dynamic> = [];
    
    public var fastMode:Bool = false;
    
    public var buildTime:Float;
    
    public var nextWave:String = "";
    
    public var firstWave:Bool = false;
    
    public var team:Int = -1;
    
    public var creepCost:Int = 0;
    
    public var extraAllowed:SafeInt = new SafeInt(0);
    
    public var playerData:Array<PlayerInfo> = [new PlayerInfo(), new PlayerInfo()];
    
    public var towers:Vector<TowerBase>;
    public var creepsTeamed:Vector<Vector<CreepBase>>;
    public var grid:GameGrid;
    
    // Data for the lifetime of the game
    public static var teamAreas:Array<Vector<Point>>;
    public static var towerLevels:Map<Int, Vector<InfoBoxData>>;
    // public static var towerLevels:Vector<InfoBoxData>;
    public static var masterGrid = new GameGrid();
    
    public function new()
    {
        towers = new Vector<TowerBase>();
    }
}