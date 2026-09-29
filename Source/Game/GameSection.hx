package game;

import lobby.LobbySection;
import network.NetworkMessage;
import haxe.Json;
import sounds.GameSounds;
import game.popText.PopManager;
import game.stars.StarManager;
import gamestate.GameState;
import simulation.Simulation;
import ToBitmapData.toBitmapData;
import haxe.display.Display.Package;
import openfl.Vector;
import editor.EditSection;
// import fl.events.ComponentEvent;
import openfl.display.*;
import openfl.events.Event;
import openfl.events.MouseEvent;
import openfl.geom.Matrix;
import openfl.geom.Point;
import openfl.text.TextField;
import game.bullets.*;
import game.creeps.*;
import game.FastForward;
// import Game.PopText.PopManager;
import game.shocks.ShockManager;
// import Game.Stars.StarManager;
import grid.GameGrid;
import grid.GridCoord;
import info.CashDisplay;
import info.CreepBox;
import info.HealthBanner;
import info.InfoBox;
import info.PlayerBox;
import info.PlayerInfo;
// import Recording.Recorder;
// import Sounds.GameSounds;
// import Towers.TowerAntiAir;
import towers.TowerBase;
import wait.WaitSection;
import network.Network;

class GameSection implements IGameSection
{		
    private var holder_:Sprite;
    private var debugSurface_:Sprite;
    private var nextSection_:IGameSection;
    
    private var gameData_:GameData;
    
    private var bulletManager_:BulletsManager;
    
    // private var connection_:Connection;
    
    private var nextCounter_:Float;
    
    private var towerInfo_:InfoBox;
    private var creepInfo_:CreepBox;
    
    private var shockManager_:ShockManager;
    private var starManager_:StarManager;
    private var popManager_:PopManager;
    
    private var radSurface_:Sprite;
    
    private var healthBanner0_:HealthBanner;
    private var healthBanner1_:HealthBanner;
    
    private var cashDisplay_:CashDisplay;
    private var score_:TextField;
    
    private var checkGoFastCounter_:Float;
    private var goFast_:Bool;
    
    private var ff_:FastForward;
    // private var allowRecord_:AllowRecordWidget;
    
    // public function new(connection:Connection, gameData:GameData, extraLayer:DisplayObject = null) 
    public function new(connection = null, gameData:GameData, extraLayer:DisplayObject = null) 
    {
        // trace("game section new");
        GameSounds.play(GameSounds.CHARGE);
        
        this.gameData_ = gameData;
        
        // Remove tower dupes (imaginary bug)
        var towersGrid:Vector<TowerBase> = new Vector<TowerBase>();
        // trace(towersGrid);
        var tower:TowerBase;
        for (i in 0...gameData.towers.length)
        {
            tower = gameData.towers[i];
            var coord:GridCoord = gameData.grid.coordAt(Std.int(tower.x - 0.5 * gameData.grid.get_squareSize()), Std.int(tower.y - 0.5 * gameData.grid.get_squareSize()));
            towersGrid[coord.x + gameData.grid.get_width() * coord.y] = tower;

            //TODO: mirror mode in simulation
            if (Global.simulation) {
                // trace(tower.x, tower.y);
                // var mirrorTower = Reflect.copy(tower);
                // mirrorTower.team = 1;
                // mirrorTower.x = 192;
                // mirrorTower.y = 516;
                // tower.x = (27 * 12)-tower.x;
                // tower.y = Global.SCREEN_HEIGHT - tower.y;

                // trace(mirrorTower.team, tower.team);

                // var mirrorCoord:GridCoord = gameData.grid.coordAt(Std.int(mirrorTower.x - 0.5 * gameData.grid.get_squareSize()), Std.int(mirrorTower.y - 0.5 * gameData.grid.get_squareSize()));
                // towersGrid[mirrorCoord.x + gameData.grid.get_width() * mirrorCoord.y] = mirrorTower;
            }
        }
        
        // gameData.towers = [];
        gameData.towers = new Vector<TowerBase>();

        for (tower in towersGrid)
        {
            if (tower != null) {
                // trace(tower.team, tower.x, tower.y);
                gameData.towers.push(tower);
            }
        }
        
        // if (connection)
        // {
        //     connection.addEventListener(MessageEvent.MESSAGE, onMessage, false, 0, true);
        //     // Recording
        //     Recorder.add(gameData);
        // }
        
        GameGFX.drawBorders(gameData_.grid);
        
        nextCounter_ = 1;
        
        // connection_ = connection;
        
        holder_ = new Sprite();
        debugSurface_ = new Sprite();
        radSurface_ = new Sprite();
        nextSection_ = this;
        
        holder_.addChild(new Bitmap(toBitmapData(GameGFX.bg)));
        holder_.addChild(new Bitmap(GameGFX.borders));
        holder_.addChild(radSurface_);
        holder_.addChild(debugSurface_);
        
        towerInfo_ = new InfoBox();
        towerInfo_.x = 329;
        towerInfo_.y = 100;
        holder_.addChild(towerInfo_);
        creepInfo_ = new CreepBox();
        creepInfo_.x = 329;
        creepInfo_.y = 100;
        holder_.addChild(creepInfo_);
        
        holder_.addEventListener(MouseEvent.CLICK, onClick);

        for (tower in gameData_.towers)
        {
            // trace(tower.team, tower.x, tower.y, tower.graphic);
            holder_.addChild(tower.graphic);
            tower.reset();
        }
        
        for (creep in gameData_.creepsTeamed[0])
        {
            holder_.addChild(creep.graphic);
        }
        
        for (creep in gameData_.creepsTeamed[1])
        {
            holder_.addChild(creep.graphic);
        }
        
        bulletManager_ = new BulletsManager();
        holder_.addChild(bulletManager_);
        
        shockManager_ = new ShockManager();
        holder_.addChild(shockManager_);
        starManager_ = new StarManager();
        holder_.addChild(starManager_);
        popManager_ = new PopManager();
        holder_.addChild(popManager_);
        
        healthBanner0_ = new HealthBanner(gameData_.playerData[0]);
        healthBanner1_ = new HealthBanner(gameData_.playerData[1]);
        
        healthBanner0_.x = 110 - healthBanner0_.width;
        healthBanner1_.x = 110 - healthBanner1_.width;
        
        healthBanner1_.y = Global.SCREEN_HEIGHT - HealthBanner.HEIGHT;
        
        // if (connection_)
        // {
            holder_.addChild(healthBanner0_);
            holder_.addChild(healthBanner1_);
            
        //     allowRecord_ = new AllowRecordWidget;
        //     allowRecord_.x = 326;
        //     allowRecord_.y = 476;
        //     //holder_.addChild(allowRecord_);

        //     allowRecord_.visible = false;

        //     allowRecord_.addEventListener(Event.CHANGE, checkBoxChanged);
            
        //     allowRecord_.checkbox.selected = gameData_.allowRecording[gameData_.team];
            
        //     allowRecord_.otherAllowed = (gameData_.allowRecording[0 == gameData_.team ? 1 : 0]);
        // }
        
        cashDisplay_ = new CashDisplay(gameData_.playerData[gameData_.team]);
        cashDisplay_.x = 340 + 0.5 * 163;
        cashDisplay_.y = 30;
        // if (connection_)
            holder_.addChild(cashDisplay_);
        
        score_ = InfoBox.makeTF(16, true);
        // if (connection_)
            holder_.addChild(score_);
        
        checkGoFastCounter_ = 1;
        goFast_ = false;
        
        ff_ = new FastForward();
        ff_.visible = true;
        ff_.x = 0.5 * (gameData_.grid.get_squareSize() * gameData_.grid.get_width() - ff_.width);
        ff_.y = 0.5 * (gameData_.grid.get_squareSize() * gameData_.grid.get_height() - ff_.height);
        holder_.addChild(ff_);
        
        if (extraLayer != null)
        {
            // holder_.addChild(extraLayer);
        }
        
    }
    
    private function onMessage(e:Dynamic):Void
    {
        // if (e.message.Type == "allowrecord")
        // {
        //     gameData_.allowRecording[e.message.GetInt(0)] = e.message.GetBoolean(1);
        //     allowRecord_.otherAllowed = gameData_.allowRecording[0 == gameData_.team ? 1 : 0];
        // }
    }
    
    private function onClick(e:MouseEvent):Void
    {
        towerInfo_.hide();
        creepInfo_.hide();
        
        radSurface_.graphics.clear();
        
        var clickPoint:Point = new Point(e.stageX, e.stageY);
        
        var towerClicked:Bool = false;
        
        var towerChosen:TowerBase = null;
        
        // Tower under mouse?
        for (t in gameData_.towers)
        {
            if (t.graphic.getRect(holder_).containsPoint(clickPoint))
            {
                towerInfo_.show(t.get_levels()[t.get_upgradeLevel()], false, null);
                towerClicked = true;
                towerChosen = t;
            }
        }
        
        if (towerClicked)
        {
            drawRad(towerChosen);
        }
        
        // Creep under mouse?
        if (!towerClicked)
        {
            for (c in gameData_.creepsTeamed[0])
            {
                if (c.graphic.getRect(holder_).containsPoint(clickPoint))
                {
                    creepInfo_.show(c);
                }
                else
                if (c.healthBar_.getRect(holder_).containsPoint(clickPoint))
                {
                    creepInfo_.show(c);
                }
            }
            
            for (c in gameData_.creepsTeamed[1])
            {
                if (c.graphic.getRect(holder_).containsPoint(clickPoint))
                {
                    creepInfo_.show(c);
                }
            }
        }
    }
    
    public function update():IGameSection
    {
        goFast_ = (Global.fast && !Global.readyForNextRound);
        var ns:IGameSection = innerUpdate();
        
        if (goFast_)
        {
            if (ns == this)	ns = innerUpdate();
            if (ns == this)	ns = innerUpdate();
            if (ns == this)	ns = innerUpdate();
            if (ns == this)	ns = innerUpdate();
            if (ns == this)	ns = innerUpdate();
            if (ns == this)	ns = innerUpdate();
        }
        
        return ns;
    }
    
    private function checkBoxChanged(e:Event):Void
    {
        // gameData_.allowRecording[gameData_.team] = allowRecord_.checkbox.selected;
        // var m:Message = new Message("allowrecord", allowRecord_.checkbox.selected);
        // connection_.Send(m);
    }
    
    private function checkGoFast():Void
    {
        checkGoFastCounter_ -= Global.UPDATE_SECS;
        if (checkGoFastCounter_ <= 0)
        {				
            // Go fast?
            var fast:Bool = true;
            
            var allCreeps:Vector<CreepBase> = gameData_.creepsTeamed[0].concat(gameData_.creepsTeamed[1]);
            
            var hg:Float = 0.5 * gameData_.grid.get_squareSize();
            
            for (creep in allCreeps)
            {					
                if (!creep.get_hasPath())
                {
                    fast = false;
                    break;
                }
                else
                {
                    // Check path is only on safe squares
                    var remaining:Vector<GridCoord> = creep.get_pathRemaining();
                    for (c in remaining)
                    {
                        if (!fast)	break;
                        
                        // Translate coord to grid pos
                        var dst:Point = new Point(c.x * gameData_.grid.get_squareSize() + hg, c.y * gameData_.grid.get_squareSize() + hg);
                        
                        // Safe?
                        for (t in gameData_.towers)
                        {
                            if (!t.get_ground())	continue;
                            
                            if (t.team != creep.team)
                            {
                                var dist:Point = new Point(t.x - dst.x, t.y - dst.y);
                                if (dist.length < t.get_radius())
                                {
                                    fast = false;
                                    break;
                                }
                            }
                        }
                    }
                }
            }
            
            if (0 == allCreeps.length)	fast = false;
            
            if (!fast)
            {
                checkGoFastCounter_ = 1;
            }
            
            goFast_ = fast;
        }
    }
    
    public function innerUpdate():IGameSection
    {	
        if (!goFast_)
            checkGoFast();
            
        if (gameData_.fastMode)	goFast_ = true;
            
        ff_.update();
        
        var i:Int = 0, j:Int = 0;
        var creep:CreepBase, tower:TowerBase;

        bulletManager_.update(gameData_.creepsTeamed[0], gameData_.creepsTeamed[1]);
        
        shockManager_.update();
        starManager_.update();
        popManager_.update();

        // trace(gameData_.creepsTeamed[0].length, gameData_.creepsTeamed[1].length);
        
        for (cc in 0...2)
        {
            var creepsCopy:Vector<CreepBase> = new Vector<CreepBase>();
        
            for (i in 0...gameData_.creepsTeamed[cc].length)
            {
                creep = gameData_.creepsTeamed[cc][i];
                creep.update(Global.UPDATE_SECS, gameData_.grid);
                
                var stillAlive:Bool = creep.health > 0;
                var escaped:Bool = false;

                var creepTeam = 0 == creep.team ? 1 : 0;
                
                if (creep.moveUp && creep.y < 0)
                {
                    escaped = true;
                }
                else
                if (!creep.moveUp && creep.y > Global.SCREEN_HEIGHT)
                {
                    escaped = true;
                }
                
                if (stillAlive && !escaped)
                {
                    creepsCopy.push(creep);
                }
                else
                {
                    holder_.removeChild(creep.graphic);
                }
                
                if (escaped)
                {
                    gameData_.playerData[creepTeam].set_lives(gameData_.playerData[creepTeam].get_lives() - 1);
                    popManager_.add(Std.int(creep.x), Std.int(Math.min(Math.max(creep.y, 15), Global.SCREEN_HEIGHT - 15)), "-1", 0xFF0000);
                    GameSounds.play(GameSounds.ESCAPE);
                }
                else
                {
                    if (!stillAlive)
                    {
                        if (!creep.extra)
                        {
                            gameData_.playerData[creepTeam].set_cash(gameData_.playerData[creepTeam].get_cash() + creep.cash);
                            gameData_.playerData[creepTeam].set_score(gameData_.playerData[creepTeam].get_score() + creep.cash);
                            popManager_.add(Std.int(creep.x), Std.int(creep.y), "+" + Std.string(creep.cash), 0x00FF00);
                        }
                        
                        starManager_.explodeAt(Std.int(creep.x), Std.int(creep.y));
                        GameSounds.play(GameSounds.BURST);
                    }
                }
            }
            
            gameData_.creepsTeamed[cc] = creepsCopy;
        }
        
        for (i in 0...gameData_.towers.length)
        {
            tower = gameData_.towers[i];
            var rad:Float = tower.get_levels()[tower.get_upgradeLevel()].radius;
            var rr:Float = rad * rad;
            
            // Get in range of tower
            var towerCreeps:Array<CreepBase> = [];
            var otherTeam:Vector<CreepBase> = gameData_.creepsTeamed[tower.team == 0 ? 1 : 0];
            for (j in 0...otherTeam.length)
            {					
                creep = otherTeam[j];

                // var canShoot = false;
                var canShootCheck = 0;

                if (creep.air && tower.type == 2) canShootCheck++; // Missile can only hit ground targets
                if (creep.air && tower.type == 3) canShootCheck++; // Bash can only hit ground targets
                if (!creep.air && tower.type == 5) canShootCheck++; // Antiair can only hit air targets

                // if ((tower.get_ground() && !creep.air) || (tower.type))

                // trace(tower.type);
                
                //TODO: Make sure this is correct. Looks like a bug?
                // if (
                //     (creep.air && !tower.get_ground()) ||
                //     (creep.air && (tower.type != 2 || tower.type != 3)) ||
                //     (!creep.air && tower.get_ground())
                //     ) {
                //     canShoot = true;
                // }

                
                // if (!(creep.air && !tower.get_ground() || !creep.air && !tower.get_ground()))
                if (canShootCheck == 0)
                {
                    // trace("here");
                    var dxx:Float = Math.pow(tower.x - creep.x, 2);
                    var dyy:Float = Math.pow(tower.y - creep.y, 2);
                    
                    if (dxx + dyy <= rr) {
                        towerCreeps.push(creep);
                    }
                }
            }
            
            tower.update(towerCreeps, bulletManager_, shockManager_);
        }
        
        if (0 == gameData_.creepsTeamed[0].length && 0 == gameData_.creepsTeamed[1].length)
        {
            nextCounter_ -= Global.UPDATE_SECS;
            if (nextCounter_ <= 0)
            {
                draw();
                
                // if (connection_ != null)
                if (Global.simulation || Global.practiceSandboxMode)
                {
                    
                    // nextSection_ = new WaitSection(connection_, Global.messages, holder_);
                    
                    // var m:Message = new Message("playreport");
                    // m.Add(gameData_.allowRecording[gameData_.team]);
                    // var gd0:PlayerInfo = gameData_.playerData[0];
                    // var gd1:PlayerInfo = gameData_.playerData[1];
                    // m.Add(gd0.score);
                    // m.Add(gd0.cash);
                    // m.Add(gd0.lives);
                    // m.Add(gd1.score);
                    // m.Add(gd1.cash);
                    // m.Add(gd1.lives);
                    
                    // connection_.Send(m);

                    //TODO: janky but works
                    setupNextRound();
                }
            
                if (Global.networkGame != null && Global.networkGame.otherPlayer != null) {
                    if (Global.readyForNextRound == false) {
                        var readyForNextRound = {
                            "type": "readyForNextRound",
                            "details": {
                                "gameId": Global.networkGame.gameId
                            }
                        };
                        Global.network.send(Json.stringify(readyForNextRound));

                        Global.readyForNextRound = true;
                        Main.toggleWait(true);
                    }
                    // trace(Global.opponentReadyForNextRound, "Global.opponentReadyForNextRound");

                    if (Global.opponentReadyForNextRound == true)
                        setupNextRound();
                }
            }
        }
        
        return nextSection_;
    }

    private function setupNextRound():Void {
        Main.toggleWait(false);
        Global.gameState.level++;
        Global.gameState = Simulation.setupPhase(Global.gameState);
        gameData_ = Simulation.setupGameData(gameData_);
        gameData_ = GameState.calculatePhase(gameData_, false, false, gameData_.team);

        checkGameOver();
    }

    private function checkGameOver():Void {
        var pd = gameData_.playerData[gameData_.team];
        // trace(gameData_.playerData[0].get_lives());
        // trace(gameData_.playerData[1].get_lives());

        var p1Lives = gameData_.playerData[0].get_lives();
        var p2Lives = gameData_.playerData[1].get_lives();

        // draw logic
        if (p1Lives <= 0 && p2Lives <= 0) {
            if (p1Lives == p2Lives) {
                triggerGameOver(true, -1);
                return;
            }

            if (p1Lives > p2Lives) {
                triggerGameOver(true, 0);
                return;
            }

            triggerGameOver(false, 1);
            return;
        }

        if (p1Lives <= 0) {
            // trace("3");
            triggerGameOver(false, 1);
            return;
        }

        if (p2Lives <= 0) {
            // trace("4");
            triggerGameOver(false, 0);
            return;
        }

        Global.readyForNextRound = false;
        Global.opponentReadyForNextRound = false;
        nextSection_ = new EditSection(null, gameData_);
    }

    private function triggerGameOver(draw:Bool, playerWin:Int):Void {
        Global.gameOver = true;
        if (playerWin == -1) {
            Global.draw = true;
        } else {
            Global.weWon = playerWin == gameData_.team;
        }
        Global.readyForNextRound = false;
        Global.opponentReadyForNextRound = false;
        nextSection_ = new EditSection(null, gameData_);
    }
    
    public function draw():Void
    {
        // trace("game draw");
        ff_.visible = goFast_;
        
        score_.text = "Score: " + Std.string(gameData_.playerData[gameData_.team].get_score());
        score_.y = 5;
        score_.x = 329 + 0.5 * (162 - score_.width);
        
        creepInfo_.draw();
        shockManager_.draw();
        starManager_.draw();
        popManager_.draw();
        
        healthBanner0_.draw();
        healthBanner1_.draw();
        
        cashDisplay_.draw();
        
        for (creep in gameData_.creepsTeamed[0])
        {
            creep.draw();
        }
        
        for (creep in gameData_.creepsTeamed[1])
        {
            creep.draw();
        }
        
        for (tower in gameData_.towers)
        {
            tower.draw();
        }
    }
    
    private function drawRad(tower:TowerBase):Void
    {
        var g:Graphics = radSurface_.graphics;
        g.clear();
        drawRadCircle(g, new Point(tower.x, tower.y), tower.get_radius());
    }
    
    private function drawRadCircle(g:Graphics, coord:Point, r:Float):Void
    {
        g.lineStyle(1, 0xFFFF00, 0.45);
        g.beginFill(0xFFFFFF, 0.4);
        g.drawCircle(coord.x, coord.y, r);
    }
    
    public function getGraphic():DisplayObject { return holder_; }

    private function handleExit():Void {
        Global.resetGlobal(true);
        Global.chatHolder.setVisibility(false);
        Global.chatHolder.reset();
        Global.network.disconnect();
        Global.networkGame = null;
        Global.stage = null;
        Global.resetAll = true;
        // nextSection_ = new LobbySection();
    }

    public function networkHandler(data:String):Void {
        var parsed:NetworkMessage = Json.parse(data);

        switch(parsed.type) {
            case "playerReadyForNextRound":
                Global.opponentReadyForNextRound = true;

            case "playerDisconnect":
                var n:PlayerDisconnected = Json.parse(data);
                Global.networkToast.setText("Other player disconnected");
                if (!Global.gameOver)
                    handleExit();

            case "chatMsg":
                var n:ChatMsg = Json.parse(data);
                Global.chatHolder.addChat(n.details.username, n.details.message);
        }
    }
    
}