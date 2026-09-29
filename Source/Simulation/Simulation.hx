package simulation;

import seedyrng.Random;
import editor.EditSection;
import game.creeps.CreepBase;
import openfl.Vector;
import game.GameData;
import game.creeps.CreepFactory;
import gamestate.CreepDef;
import gamestate.Creep;
import gamestate.GameState;
import seedyrng.Seedy;

class Simulation {
    public static function setupGameData(gameData:GameData):GameData {
        gameData.creepsTeamed = new Vector<Vector<CreepBase>>();
        gameData.creepsTeamed.push(new Vector<CreepBase>());
        gameData.creepsTeamed.push(new Vector<CreepBase>());

        return gameData;
    }

    public static function setupPhase(gameState:GameState):GameState {
        // Console.WriteLine("Moved to playing section");
        // game_ = game;
        // Console.WriteLine(game_.gameState.towers.Count + " towers in total");
        // Console.WriteLine("Level " + game_.gameState.level);
        
        // // Add a bunch of creeps
        // Random r = new Random();

        var s = new Random(1);
        
        // game_.gameState.creeps = new List<Creep>();
        gameState.creeps = new Array<Creep>();
        
        // CreepDef def = game_.gameState.CreepForLevel(game_.gameState, game_.gameState.level);
        var def:CreepDef = GameState.CreepForLevel(gameState.level);
        
        // for (int i = 0; i < (def.boss ? 1 : 20); i++)
        for (i in 0...(def.boss ? 1 : 20))
        {	
        //     Creep c0 = CreepFactory.Make(def, 162 + r.Next(-30, 30), -15 * i, 0, false);
            var x:Int = Std.int(162 + s.randomInt(-30, 30));
            // var y:Int = -15 * i;
            var y:Int = 575 + 15 * i;
            var c0:Creep = CreepFactory.makeFromDef(def, x, y, 1, false);
        //     game_.gameState.creeps.Add(c0);
            gameState.creeps.push(c0);
        }
        
        //TODO: player 2
        // for (int i = 0; i < (def.boss ? 1 : 20); i++)
        // {	
        //     Creep c1 = CreepFactory.Make(def, 162 + r.Next(-30, 30), 575 + 15 * i, 1, false);
        //     game_.gameState.creeps.Add(c1);
        // }

        for (i in 0...(def.boss ? 1 : 20))
        {	
        //     Creep c0 = CreepFactory.Make(def, 162 + r.Next(-30, 30), -15 * i, 0, false);
            var x:Int = Std.int(162 + s.randomInt(-30, 30));
            // var y:Int = -15 * i;
            var y:Int = -15 * i;
            var c1:Creep = CreepFactory.makeFromDef(def, x, y, 0, false);
        //     game_.gameState.creeps.Add(c0);
            gameState.creeps.push(c1);
        }
    
        // Extras
        for (i in 0...gameState.extraCreepsTeam0)
        {	
            var x:Int = Std.int(162 + s.randomInt(-30, 30));
            var y:Int = -400 -15 * i;
            var c0:Creep = CreepFactory.makeFromDef(def, x, y, 0, true);
            gameState.creeps.push(c0);
        }

        for (i in 0...gameState.extraCreepsTeam1)
        {	
            var x:Int = Std.int(162 + s.randomInt(-30, 30));
            var y:Int =  575 + 400 + 15 * i;
            var c1:Creep = CreepFactory.makeFromDef(def, x, y, 1, true);
            gameState.creeps.push(c1);
        }
        
        // // Calculate max valid cash
        // team0MaxValidCash_ = game_.gameState.playerInfo[0].cash;
        // team1MaxValidCash_ = game_.gameState.playerInfo[1].cash;
        // foreach (Creep c in game_.gameState.creeps)
        // {
        //     if (c.team == 0)
        //     {
        //         team1MaxValidCash_ += c.cash;
        //     }
        //     else
        //     if (c.team == 1)
        //     {
        //         team0MaxValidCash_ += c.cash;
        //     }
        // }
        
        // foreach (Player p in game_.Users)
        // {
        //     p.Send(game_.gameState.ToMessage("play", false, p.UserId));
        // }

        return gameState;
    }
}