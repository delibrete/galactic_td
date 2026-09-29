package gamestate;

import towers.TowerFrost;
import towers.TowerFrost;
import towers.TowerBash;
import towers.TowerLaser;
import towers.TowerMissile;
import towers.TowerAntiAir;
import game.GameGFX;
import grid.GridCoord;
import info.InfoBoxData;
import info.InfoBox;
import openfl.Vector;
import grid.GameGrid;
import game.creeps.CreepFactory;
import towers.TowerPellet;
import towers.TowerBase;
import cheatFree.SafeInt;
import game.GameData;
import gamestate.CreepDef.CreepType;
import gamestate.Tower.TowerType;
import gamestate.Tower.TowerTypeMap;
import openfl.geom.Point;

class GameState
{
    public var gridWidth:Int;
    public var gridHeight:Int;
    public var grid:Array<Point>;
    public var team0Area:Vector<Point>;
    public var team1Area:Vector<Point>;
    public var team0ID:Int;
    public var team1ID:Int;
    public var towers:Array<Tower>;
    public var creeps:Array<Creep>;
    public var playerInfo:Array<PlayerInfo>;

    public var allowRecording:Array<Bool>;
    public var fastMode:Bool;
    public var gameId:String;
    public var creepDefs:Array<CreepDef>;
    public var level:Int = 0;
    public var buildSeconds:Int = 50;
    public var extraAllowed:Int = 1;
    public var towerInfo:Map<Int, Array<TowerData>>;
    public var extraCreepsTeam0:Int = 0;
    public var extraCreepsTeam1:Int = 0;

    public function new()
    {
        this.gridWidth = 27;
        this.gridHeight = 45;

        this.creepDefs = [
            new CreepDef(CreepType.NORMAL, 1, 20, false),
            new CreepDef(CreepType.FROSTY, 1, 26, false),
            new CreepDef(CreepType.FAST, 1, 33, false),
            new CreepDef(CreepType.NORMAL, 1, 36, false),
            new CreepDef(CreepType.FLYING, 1, 40, false),
        ];

        towerInfo = new Map<Int, Array<TowerData>>();
        towerInfo[TowerTypeMap[TowerType.PELLET]] = [
            new TowerData("Debris Tower", 5, 10, 60, true, true, "Basic tower that fires space debris", "Can upgrade into a super long-range tower", "Increases damage", 1500, 0, 0),
            new TowerData("Debris Tower 2", 10, 20, 60, true, true, "Basic tower that fires space debris", "Can upgrade into a super long-range tower", "Increases damage", 1500, 0, 0),
            new TowerData("Debris Tower 3", 20, 40, 60, true, true, "Basic tower that fires space debris", "Can upgrade into a super long-range tower", "Increases damage", 1500, 0, 0),
            new TowerData("Debris Tower 4", 40, 80, 60, true, true, "Basic tower that fires space debris", "Can upgrade into a super long-range tower", "Increases damage", 1500, 0, 0),
            new TowerData("Debris Tower 5", 80, 160, 60, true, true, "Basic tower that fires space debris", "Can upgrade into a super long-range tower", "Increases damage", 1500, 0, 0),
            new TowerData("Super Debris Tower", 200, 400, 180, true, true, "Basic tower that fires space debris", "Can upgrade into a super long-range tower", "Increases damage and range. Final upgrade.", 1500, 0, 0),
        ];

        towerInfo[TowerTypeMap[TowerType.LASER]] = [
            new TowerData("Laser Tower", 15, 5, 70, true, true, "Fast-firing tower shoots lasers", "Very powerful when fully upgraded", "Increases damage", 350, 0, 0),
            new TowerData("Laser Tower 2", 27, 10, 70, true, true, "Fast-firing tower shoots lasers", "Very powerful when fully upgraded", "Increases damage", 350, 0, 0),
            new TowerData("Laser Tower 3", 50, 18, 70, true, true, "Fast-firing tower shoots lasers", "Very powerful when fully upgraded", "Increases damage", 350, 0, 0),
            new TowerData("Laser Tower 4", 85, 34, 70, true, true, "Fast-firing tower shoots lasers", "Very powerful when fully upgraded", "Increases damage", 350, 0, 0),
            new TowerData("Laser Tower 5", 160, 65, 70, true, true, "Fast-firing tower shoots lasers", "Very powerful when fully upgraded", "Increases damage and range", 350, 0, 0),
            new TowerData("Super Laser Tower", 450, 320, 90, true, true, "Fast-firing tower shoots lasers", "Very powerful when fully upgraded", "Increases damage", 350, 0, 0),
        ];

        towerInfo[TowerTypeMap[TowerType.MISSILE]] = [
            new TowerData("Missile Tower", 20, 8, 90, false, true, "Slow-firing tower that shoots at ground enemies", "Hits multiple enemies near blast radius", "Increases damage, splash and range", 2000, 40, 0),
            new TowerData("Missile Tower 2", 35, 16, 100, false, true, "Slow-firing tower that shoots at ground enemies", "Hits multiple enemies near blast radius", "Increases damage, splash and range", 2000, 52, 0),
            new TowerData("Missile Tower 3", 70, 32, 110, false, true, "Slow-firing tower that shoots at ground enemies", "Hits multiple enemies near blast radius", "Increases damage, splash and range", 2000, 64, 0),
            new TowerData("Missile Tower 4", 130, 64, 120, false, true, "Slow-firing tower that shoots at ground enemies", "Hits multiple enemies near blast radius", "Increases damage, splash and range", 2000, 76, 0),
            new TowerData("Missile Tower 5", 240, 128, 130, false, true, "Slow-firing tower that shoots at ground enemies", "Hits multiple enemies near blast radius", "Increases damage, splash and range", 2000, 88, 0),
            new TowerData("Super Missile Tower", 400, 256, 140, false, true, "Slow-firing tower that shoots at ground enemies", "Hits multiple enemies near blast radius", "Increases damage, splash and range", 2000, 100, 0),
        ];

        towerInfo[TowerTypeMap[TowerType.FROST]] = [
        
            new TowerData("Frost Tower", 50, 10, 50, true, true, "Tower slows down enemies for a short period of time", "Hits multiple enemies near blast radius", "Increases damage and slow time", 1500, 40, 500),
            new TowerData("Frost Tower 2", 75, 15, 50, true, true, "Tower slows down enemies for a short period of time", "Hits multiple enemies near blast radius", "Increases damage and slow time", 1500, 52, 600),
            new TowerData("Frost Tower 3", 100, 20, 50, true, true, "Tower slows down enemies for a short period of time", "Hits multiple enemies near blast radius", "Increases damage and slow time", 1500, 64, 700),
            new TowerData("Frost Tower 4", 125, 25, 50, true, true, "Tower slows down enemies for a short period of time", "Hits multiple enemies near blast radius", "Increases damage and slow time", 1500, 76, 800),
            new TowerData("Frost Tower 5", 150, 30, 50, true, true, "Tower slows down enemies for a short period of time", "Hits multiple enemies near blast radius", "Increases damage, slow time and range", 1500, 88, 900),
            new TowerData("Frost Tower 6", 200, 40, 75, true, true, "Tower slows down enemies for a short period of time", "Hits multiple enemies near blast radius", "Increases damageopjsdslow time", 1500, 100, 1000),
        ];

        towerInfo[TowerTypeMap[TowerType.ANTIAIR]] = [
            new TowerData("Anti-Air Tower", 50, 20, 60, true, false, "Causes high damage to air enemies", "Only affects airborne enemies", "Increases damage", 1000, 0, 0),
            new TowerData("Anti-Air Tower 2", 80, 40, 60, true, false, "Causes high damage to air enemies", "Only affects airborne enemies", "Increases damage and range", 1500, 0, 0),
            new TowerData("Anti-Air Tower 3", 130, 80, 65, true, false, "Causes high damage to air enemies", "Only affects airborne enemies", "Increases damage", 1000, 0, 0),
            new TowerData("Anti-Air Tower 4", 205, 160, 65, true, false, "Causes high damage to air enemies", "Only affects airborne enemies", "Increases damage and range", 1000, 0, 0),
            new TowerData("Anti-Air Tower 5", 330, 320, 70, true, false, "Causes high damage to air enemies", "Only affects airborne enemies", "Increases damage and range", 1000, 0, 0),
            new TowerData("Anti-Air Tower 6", 640, 640, 75, true, false, "Causes high damage to air enemies", "Only affects airborne enemies", "Increases damage", 1000, 0, 0),
        ];

        towerInfo[TowerTypeMap[TowerType.BASH]] = [
            new TowerData("Shockwave Tower", 30, 60, 40, false, true, "Causes high damage to an area around the tower", "Only affects ground enemies", "Increases damage", 2000, 0, 0),
            new TowerData("Shockwave Tower 2", 60, 120, 40, false, true, "Causes high damage to an area around the tower", "Only affects ground enemies", "Increases damage", 2000, 0, 0),
            new TowerData("Shockwave Tower 3", 120, 240, 40, false, true, "Causes high damage to an area around the tower", "Only affects ground enemies", "Increases damage", 2000, 0, 0),
            new TowerData("Shockwave Tower 4", 250, 480, 40, false, true, "Causes high damage to an area around the tower", "Only affects ground enemies", "Increases damage", 2000, 0, 0),
            new TowerData("Shockwave Tower 5", 500, 960, 40, false, true, "Causes high damage to an area around the tower", "Only affects ground enemies", "Increases damage", 2000, 0, 0),
            new TowerData("Super Shockwave Tower", 780, 2000, 40, false, true, "Causes high damage to an area around the tower", "Only affects ground enemies", "Increases damage", 2000, 0, 0),
        ];

        playerInfo = [new PlayerInfo(), new PlayerInfo()];
        playerInfo[0].cash = playerInfo[1].cash = 80;
        playerInfo[0].lives = playerInfo[1].lives = 20;
        playerInfo[0].points = playerInfo[1].points = 0;
        playerInfo[0].team = 0;
        playerInfo[1].team = 1;
        playerInfo[0].name = "player 1";
        playerInfo[1].name = "player 2";

        allowRecording = [false, false];
			
        // team0Area = new List<Point>();
        team0Area = new Vector<Point>();
        // team1Area = new List<Point>();
        team1Area = new Vector<Point>();
        
        // towers = new List<Tower>();
        towers = new Array<Tower>();
        // creeps = new List<Creep>();
        creeps = new Array<Creep>();
        
        team0ID = -1;
        team1ID = -1;

        this.SetMapStd(false);
    }

    public function SetMapStd(reverse:Bool):Void
    {
        // Grid
        this.grid = new Array<Point>();
        for (y in 0...this.gridHeight)
        {
            for (x in 0...this.gridWidth)
            {
                if (y == 0 || y == gridHeight - 1 || x == 0 || x == gridWidth - 1)
                {
                    var hw:Int = Math.floor(0.5 * gridWidth);
                    if (x < hw - 3 || x > hw + 3)
                    {
                        grid.push(new Point(x, y));
                    }
                }
            }
        }
        
        // Team areas
        for (y in 1...21)
        {
            for (x in 1...26)
            {
                if (reverse)
                {
                    this.team0Area.push(new Point(x, y));
                    this.team1Area.push(new Point(x, y + 23));
                }
                else
                {
                    this.team1Area.push(new Point(x, y));
                    this.team0Area.push(new Point(x, y + 23));
                }
            }
        }
    }

    public static function calculatePhase(gameData:GameData, extended:Bool, initial:Bool = true, team:Int = 0){
        // var idx:int = 0;
        // var i:int;
        
        // // Game id
        // gameData.gameId = m.GetString(idx++);
        gameData.gameId = Global.gameState.gameId;
        
        // // Allow recording
        // gameData.allowRecording[0] = m.GetBoolean(idx++);
        gameData.allowRecording[0] = Global.gameState.allowRecording[0];
        // gameData.allowRecording[1] = m.GetBoolean(idx++);
        gameData.allowRecording[1] = Global.gameState.allowRecording[1];
        
        // gameData.fastMode = m.GetBoolean(idx++);
        gameData.fastMode = Global.gameState.fastMode;
        
        // // User id
        // Global.userId = m.GetInt(idx++);
        Global.userId = 0;
        
        // // Next wave
        // gameData.nextWave = m.GetString(idx++);
        var nextWave:String = "Normal";
        var next:CreepDef = CreepForLevel(Global.gameState.level);
        switch (next.type) //TODO: Fix
        {
            default:	
            case CreepType.NORMAL: nextWave = "Normal";	
            case CreepType.FAST: nextWave = "Fast";
            case CreepType.FLYING: nextWave = "Flying";
            case CreepType.FROSTY: nextWave = "Frost Resistant";
        }

        if (next.boss == true){
            nextWave = "Boss (" + nextWave + ")";
        }
			
        // m.Add(nextWave);
        gameData.nextWave = nextWave + "\n" + "Wave: " + (Global.gameState.level + 1);
        
        // // Creep cost
        // gameData.creepCost = m.GetInt(idx++);
        gameData.creepCost = next.cash;
        
        // // Extras allowed
        // gameData.extraAllowed.val = m.GetInt(idx++);
        gameData.extraAllowed = new SafeInt(Global.gameState.extraAllowed);
        
        // // Build time
        // gameData.buildTime = m.GetInt(idx++);
        gameData.buildTime = Global.gameState.buildSeconds;
        
        // TODO: Logic for teams. For now, always 0
        // // Teams
        // if (m.GetInt(idx++) == Global.userId)	gameData.team = 0;
        // if (m.GetInt(idx++) == Global.userId)	gameData.team = 1;
        gameData.team = team;

        if (initial) {
        // gameData.playerData[0].score = m.GetInt(idx++);
        gameData.playerData[0].set_score(Global.gameState.playerInfo[0].points);
        // gameData.playerData[0].lives = m.GetInt(idx++);
        gameData.playerData[0].set_lives(Global.gameState.playerInfo[0].lives);
        // gameData.playerData[0].cash = m.GetInt(idx++);
        gameData.playerData[0].set_cash(Global.gameState.playerInfo[0].cash);
        // gameData.playerData[0].name = m.GetString(idx++);
        gameData.playerData[0].set_name(Global.gameState.playerInfo[0].name);
        // gameData.playerData[0].team = m.GetInt(idx++);
        gameData.playerData[0].set_team(Global.gameState.playerInfo[0].team);
        
        // gameData.playerData[1].score = m.GetInt(idx++);
        gameData.playerData[1].set_score(Global.gameState.playerInfo[1].points);
        // gameData.playerData[1].lives = m.GetInt(idx++);
        gameData.playerData[1].set_lives(Global.gameState.playerInfo[1].lives);
        // gameData.playerData[1].cash = m.GetInt(idx++);
        gameData.playerData[1].set_cash(Global.gameState.playerInfo[1].cash);
        // gameData.playerData[1].name = m.GetString(idx++);
        gameData.playerData[1].set_name(Global.gameState.playerInfo[1].name);
        // gameData.playerData[1].team = m.GetInt(idx++);
        gameData.playerData[1].set_team(Global.gameState.playerInfo[1].team);
        }

        //TODO: for now, we've invincible
        // gameData.playerData[0].set_lives(Global.gameState.playerInfo[0].lives);
        // gameData.playerData[1].set_lives(Global.gameState.playerInfo[1].lives);
        
        // // Towers
        // var towerCount:int = m.GetInt(idx++);
        var towerCount:Int = Global.gameState.towers.length;
        // for (i = 0; i < towerCount; i++)
        for (i in 0...towerCount)
        {
            var towerItem = Global.gameState.towers[i];
        //     var towerX:int = m.GetInt(idx++);
            var towerX:Int = towerItem.x;
        //     var towerY:int = m.GetInt(idx++);
            var towerY:Int = towerItem.y;
        //     var towerType:int = m.GetInt(idx++);
            var towerType:TowerType = towerItem.type;
        //     var towerUpgrade:int = m.GetInt(idx++);
            var towerUpgrade:Int = towerItem.upgradeLevel;
        //     var towerTeam:int = m.GetInt(idx++);
            var towerTeam:Int = towerItem.team;
            
            var tower:TowerBase;
            
            switch (towerType)
            {
                case TowerType.ANTIAIR:
                    tower = new TowerAntiAir(towerX, towerY, towerTeam);
                case TowerType.BASH:
                    tower = new TowerBash(towerX, towerY, towerTeam);
                case TowerType.FROST:
                    tower = new TowerFrost(towerX, towerY, towerTeam);
                case TowerType.LASER:
                    tower = new TowerLaser(towerX, towerY, towerTeam);
                case TowerType.MISSILE:
                    tower = new TowerMissile(towerX, towerY, towerTeam);
                case TowerType.PELLET:
                    tower = new TowerPellet(towerX, towerY, towerTeam);
                default:
                    trace("Unknown tower type", towerType);	break;
            }
            
            if (tower != null)
            {
                tower.set_upgradeLevel(towerUpgrade);
                gameData.towers.push(tower);
            }
        }
        
        // // Creeps
        // var creepCount:int = m.GetInt(idx++);
        var creepCount:Int = Global.gameState.creeps.length;
        // trace(creepCount);
        // for (i = 0; i < creepCount; i++)
        for(i in 0...creepCount)
        {
            var creep:Creep = Global.gameState.creeps[i];
            // trace(creep);
        //     var ccash:int = m.GetInt(idx++);
            var ccash:Int = creep.cash;
        //     var speed:int = m.GetInt(idx++);
            var speed:Int = creep.speed;
        //     var health:int = m.GetInt(idx++);
            var health:Int = creep.health;
        //     var startX:int = m.GetInt(idx++);
            var startX:Int = creep.startX;
        //     var startY:int = m.GetInt(idx++);
            var startY:Int = creep.startY;
        //     var frostResistant:Boolean = m.GetBoolean(idx++);
            var frostResistant:Bool = creep.frostResistant;
        //     var air:Boolean = m.GetBoolean(idx++);
            var air:Bool = creep.air;
        //     var team:int = m.GetInt(idx++);
            var team:Int = creep.team;
        //     var boss:Boolean = m.GetBoolean(idx++);
            var boss:Bool = creep.boss;
        //     var fast:Boolean = m.GetBoolean(idx++);
            var fast:Bool = creep.fast;
        //     var extra:Boolean = m.GetBoolean(idx++);
            var extra:Bool = creep.extra;

            gameData.creepsTeamed[team].push(CreepFactory.make(ccash, speed, health, startX, startY, frostResistant, air, team, boss, fast, extra));
        }

        // if (creepCount > 0) {
        //     trace(gameData.creepsTeamed[0].length, gameData.creepsTeamed[1].length);
        // }
        
        // var extended:Boolean = m.GetBoolean(idx++);
        
        if (extended)
        {
            gameData.firstWave = true;
            
            // Grid
        //     var gridWidth:int = m.GetInt(idx++);
        //     var gridHeight:int = m.GetInt(idx++);
        //     GameData.masterGrid = new GameGrid(gridWidth, gridHeight);
            GameData.masterGrid = new GameGrid(Global.gameState.gridWidth, Global.gameState.gridHeight);
        //     var gridCount:int = m.GetInt(idx++);
            var gridCount:Int = Global.gameState.grid.length;
        //     for (i = 0; i < gridCount; i++)
            for(i in 0...gridCount)
            {
        //         var gx:int = m.GetInt(idx++);
                var gx:Int = cast(Global.gameState.grid[i].x, Int);
        //         var gy:int = m.GetInt(idx++);
                var gy:Int = cast(Global.gameState.grid[i].y, Int);
                GameData.masterGrid.setData(gx, gy, 1);
            }
            
            GameGFX.drawBorders(GameData.masterGrid);
            
        //     // Team areas
            // GameData.teamAreas = [[],[]];
            GameData.teamAreas = new Array<Vector<Point>>();
            GameData.teamAreas.push(new Vector<Point>());
            GameData.teamAreas.push(new Vector<Point>());
            
        //     var team0AreaCount:int = m.GetInt(idx++);
            var team0AreaCount:Int = Global.gameState.team0Area.length;
        //     for (i = 0; i < team0AreaCount; i++)
            for (i in 0...team0AreaCount)
            {
                GameData.teamAreas[0][i] = new Point();
        //         GameData.teamAreas[0][i].x = m.GetInt(idx++);
                GameData.teamAreas[0][i].x = Global.gameState.team0Area[i].x;
        //         GameData.teamAreas[0][i].y = m.GetInt(idx++);
                GameData.teamAreas[0][i].y = Global.gameState.team0Area[i].y;
            }
        //     var team1AreaCount:int = m.GetInt(idx++);
                var team1AreaCount:Int = Global.gameState.team1Area.length;
        //     for (i = 0; i < team0AreaCount; i++)
            for (i in 0...team1AreaCount)
            {
                GameData.teamAreas[1][i] = new Point();
        //         GameData.teamAreas[0][i].x = m.GetInt(idx++);
                GameData.teamAreas[1][i].x = Global.gameState.team1Area[i].x;
        //         GameData.teamAreas[0][i].y = m.GetInt(idx++);
                GameData.teamAreas[1][i].y = Global.gameState.team1Area[i].y;
            }
            
        //     // Tower data
        //     GameData.towerLevels = [];
            GameData.towerLevels = new Map<Int, Vector<InfoBoxData>>();
        //     var numTowerTypes:int = m.GetInt(idx++);
            // var numTowerTypes:Int = Lambda.count(Global.gameState.towerInfo);
        //     for (i = 0; i < numTowerTypes; i++)
            // for(i in 0...numTowerTypes)
            for(defType => towerData in Global.gameState.towerInfo)
            {
        //         var defType:int = m.GetInt(idx++);
                // var defType:Int
        //         var numDefs:int = m.GetInt(idx++);
                var numDefs:Int = towerData.length;

                GameData.towerLevels[defType] = new Vector<InfoBoxData>();

        //         for (var ii:int = 0; ii < numDefs; ii++)
                for (ii in 0...numDefs)
                {
                    var tower = towerData[ii];
        //             var defName:String = m.GetString(idx++);
                    var defName:String = tower.name;
        //             var defCost:int = m.GetInt(idx++);
                    var defCost:Int = tower.cost;
        //             var defDamage:int = m.GetInt(idx++);
                    var defDamage:Int = tower.damage;
        //             var defRadius:int = m.GetInt(idx++);
                    var defRadius:Int = tower.radius;
        //             var defAir:Boolean = m.GetBoolean(idx++);
                    var defAir:Bool = tower.air;
        //             var defGround:Boolean = m.GetBoolean(idx++);
                    var defGround:Bool = tower.ground;
        //             var defDesc:String = m.GetString(idx++);
                    var defDesc:String = tower.desc;
        //             var defDetails:String = m.GetString(idx++);
                    var defDetails:String = tower.details;
        //             var defUpgradeDetails:String = m.GetString(idx++);
                    var defUpgradeDetails:String = tower.upgradeDetails;
        //             var defSpeed:int = m.GetInt(idx++);
                    var defSpeed:Int = tower.speed;
        //             var defSplash:int = m.GetInt(idx++);
                    var defSplash:Int = tower.splash;
        //             var defFreeze:int = m.GetInt(idx++);
                    var defFreeze:Int = tower.freeze;
                    GameData.towerLevels[defType][ii] = 
                        new InfoBoxData(defName, defCost, defDamage, defRadius, defAir, defGround, defDesc, defDetails, defUpgradeDetails, defSpeed, defSplash, defFreeze);
                    

                }
            }
        }
        
        gameData.grid = GameData.masterGrid.clone();
        
        // Calculate grid blockages on map
        // for each (tower in gameData.towers)
        for (tower in gameData.towers)
        {
            var coord:GridCoord = gameData.grid.coordAt(cast(tower.x - 0.5 * gameData.grid.get_squareSize(), Int), cast(tower.y - 0.5 * gameData.grid.get_squareSize(), Int));
            gameData.grid.setData(coord.x, coord.y);
            gameData.grid.setData(coord.x + 1, coord.y);
            gameData.grid.setData(coord.x, coord.y+1);
            gameData.grid.setData(coord.x + 1, coord.y + 1);
        }
        
        return gameData;
    }

    public static function CreepForLevel(level:Int):CreepDef
    {
        var otherCreep = Global.gameState.creepDefs[level%Global.gameState.creepDefs.length];

        var def:CreepDef = new CreepDef(otherCreep.type, otherCreep.cash, otherCreep.health, otherCreep.boss);

        // var loop:Int = (Int)Math.Floor((Float)Global.gameState.level / Global.gameState.creepDefs.Length);
        var loop:Int = cast(Math.ffloor(level / Global.gameState.creepDefs.length), Int);
        // trace(loop);
        
        if (loop > 0)
        {
            // def.health = (int)Math.Floor(def.health*Math.Pow(2.2, loop));
            def.health = cast(Math.ffloor(def.health * Math.pow(2.2, loop)), Int);
            def.cash = def.cash * (loop+1);
            
            if (level % Global.gameState.creepDefs.length == (loop+(Global.gameState.creepDefs.length-1)) % Global.gameState.creepDefs.length)
            {
                def.boss = true;
                def.health *= 12;
                def.cash *= 20;
            }
        }
        
        return def;
    }
}