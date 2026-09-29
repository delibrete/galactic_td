package editor;

// import Editor.ExtraEnemies.ExtraWidget;
import lime.utils.AssetCache;
import openfl.utils.Assets;
import sounds.GameSounds;
import editor.extraEnemies.ExtraWidget;
import network.Chat;
import lobby.LobbySection;
import openfl.text.TextFormatAlign;
import openfl.text.TextFormat;
import haxe.extern.Rest;
import wait.WaitBar;
import towers.TowerBase.NetworkTowerMessage;
import network.NetworkMessage;
import haxe.Json;
import network.Network;
import cheatFree.SafeInt;
import simulation.Simulation;
import gamestate.GameState;
import game.GameSection;
import openfl.Vector;
import openfl.display.*;
import openfl.events.Event;
import openfl.events.KeyboardEvent;
import openfl.events.MouseEvent;
import openfl.geom.Matrix;
import openfl.geom.Point;
import openfl.text.TextField;
import game.GameData;
import game.GameGFX;
import game.GameSection;
import grid.GridCoord;
import info.CashDisplay;
import info.HealthBanner;
import info.InfoBox;
import info.InfoBoxData;
import info.PlayerBox;
import info.PlayerInfo;
// import Sounds.GameSounds;
import towers.*;
import wait.WaitSection;
// import AllowRecordWidget;
import openfl.Lib.getTimer;

import ToBitmapData.toBitmapData;

class EditSection implements IGameSection
{
    private var holder_:Sprite;
    private var debugSurface_:Sprite;
    private var towersSurface_:Sprite;
    private var nextSection_:IGameSection;
    
    private var infoBox_:InfoBox;
    
    private var blocking_:Blocking;
    
    private var gameData_:GameData;
    
    private var selected_:TowerBase;
    private var template_:Vector<TowerBase>;
    private var templateCovers_:Map<TowerBase, Sprite>;
    
    private var drawRad_:Point;
    
    private var placeable_:Vector<Dynamic>;
    
    // private var connection_:Connection;
    private var connection_ = null;

    private var startButton_:CustomButton;
    private var fastButton_:CustomButton;
    
    private var ticking_:Bool;
    
    private var healthBanner0_:HealthBanner;
    private var healthBanner1_:HealthBanner;
    
    private var cashDisplay_:CashDisplay;
    
    private var nextWave_:TextField;
    
    private var score_:TextField;
    
    private var gameStart_:TextField;
    
    private var extraEnemies_:ExtraWidget;
    // private var allowRecord_:AllowRecordWidget;


    private var debugPath:Vector<GridCoord>;
    private var debug:Bool = false;

    private var showEscWindow:Bool;
    private var escapeDialog:Shape;
    private var pressEscAgainText:TextField;

    private var isActive:Bool;

    private var MAX_SENT_TOWERS_TIMER:Float = 5;
    private var CONFIRM_MAX_SENT_TOWERS_RETRY_COUNT:Int = 6;
    private var confirmSentTowerTimer:Float = 5;
    private var confirmSentTowersRetryCount:Int = 0;

    private var gameOverWindow:Sprite;
    
    // public function EditSection(connection:Connection, gameData:GameData)
    public function new(connection = null, gameData:GameData)
    {
        // trace("edit section new");
        isActive = true;
        ticking_ = false;
        holder_ = new Sprite();
        debugSurface_ = new Sprite();
        nextSection_ = this;
        
        // connection_ = connection;
        
        gameData_ = gameData;
        
        GameGFX.drawBorders(gameData_.grid);
        
        holder_.addChild(new Bitmap(toBitmapData(GameGFX.bg)));
        holder_.addChild(new Bitmap(GameGFX.borders));
        towersSurface_ = new Sprite();
        holder_.addChild(debugSurface_);
        
        // Create placeable grid
        placeable_ = new Vector<Bool>(gameData_.grid.get_width() * gameData_.grid.get_height());
        for (l in 0...placeable_.length) placeable_[l] = 0;
        
        if (connection_ != null)
        {
            // connection_.addEventListener(MessageEvent.MESSAGE, onMessage, false, 0, true);
        }
        
        // if (connection_ != null)
        // trace(Global.simulation);
        if (Global.simulation || (Global.networkGame != null && Global.networkGame.otherPlayer != null))
        {
            for(p in GameData.teamAreas[gameData_.team]) {
                placeable_[Std.int(p.x) + Std.int(p.y) * gameData_.grid.get_width()] = true;
            }
        }
        else
        {
            for (y in 0...gameData_.grid.get_height())
            {
                for (x in 0...gameData_.grid.get_width())
                {
                    if (y > 0 && y < gameData_.grid.get_height() - 1)
                        placeable_[x + y * gameData_.grid.get_width()] = true;
                }
            }
        }
        
        var placeGfx:Shape = new Shape();
        placeGfx.graphics.beginFill(0x00FF00, 0.29);
        
        if (Global.simulation || (Global.networkGame != null && Global.networkGame.otherPlayer != null))
        {
            for (p in GameData.teamAreas[gameData_.team]) {
                placeGfx.graphics.drawRect(p.x * gameData_.grid.get_squareSize(), p.y * gameData_.grid.get_squareSize(), gameData_.grid.get_squareSize(), gameData_.grid.get_squareSize());
            }
        }
        else
        {
            placeGfx.graphics.drawRect(gameData_.grid.get_squareSize(), gameData_.grid.get_squareSize(), gameData_.grid.get_squareSize() * (gameData_.grid.get_width() - 2), gameData_.grid.get_squareSize() * (gameData_.grid.get_height() - 2));
        }
        
        holder_.addChild(placeGfx);
        holder_.addChild(towersSurface_);
        
        if (gameData_.firstWave)
        {
            gameStart_ = InfoBox.makeTF(22);
            gameStart_.text = "Game started!";
            // holder_.addChild(gameStart_);
            gameStart_.x = 0.5 * (gameData_.grid.get_width() * gameData_.grid.get_squareSize() - gameStart_.width);
            gameStart_.y = 0.5 * (Global.SCREEN_HEIGHT - gameStart_.height);
        }
        
        holder_.addEventListener(MouseEvent.MOUSE_MOVE, onMouseMove);
        holder_.addEventListener(MouseEvent.CLICK, onClick);
        
        startButton_ = new CustomButton("Start", 100, 0x44FF44);
        startButton_.x = 329 + 0.5 * (166 - startButton_.width);
        // startButton_.y = 445; // move it down a tad
        startButton_.y = 485;
        holder_.addChild(startButton_);
        startButton_.addEventListener(MouseEvent.CLICK, (listener:MouseEvent) -> {
            if (startButton_.enabled) {
                holder_.removeChild(startButton_);
                holder_.removeChild(extraEnemies_);
                go();
            }
        });

        var fastText = "Enable Fast";
        var fastColour = 0x44FF44;

        if (Global.fast) {
            fastText = "Disable Fast";
            fastColour = 0xE00000;
        }

        fastButton_ = new CustomButton(fastText, 100, fastColour);
        fastButton_.x = startButton_.x;
        fastButton_.y = startButton_.y - 35;
        fastButton_.addEventListener(MouseEvent.CLICK, fast);
        holder_.addChild(fastButton_);

        var pressEscText:TextField = new TextField();
        pressEscText.text = "Press Esc to exit.";
        pressEscText.x = startButton_.x + 8;
        pressEscText.y = startButton_.y + 30;
        pressEscText.textColor = 0xFFFFFF;
        holder_.addChild(pressEscText);

        escapeDialog = new Shape();
        escapeDialog.graphics.beginFill(0x000000, 1);
        escapeDialog.graphics.drawRoundRect(0, 0, 200, 100, 5);
        escapeDialog.graphics.endFill();
        escapeDialog.x = (Global.SCREEN_WIDTH/2) - 100;
        escapeDialog.y = (Global.SCREEN_HEIGHT/2) - 50;

        pressEscAgainText = new TextField();
        pressEscAgainText.width = 200;
        pressEscAgainText.text = "Press Esc again to exit.\n\nPress any other key to resume.";
        pressEscAgainText.x = escapeDialog.x + 25;
        pressEscAgainText.y = escapeDialog.y + 25;
        pressEscAgainText.textColor = 0xFFFFFF;

        escapeDialog.visible = showEscWindow;
        pressEscAgainText.visible = showEscWindow;
        showEscWindow = false;

        // Add templates
        template_ = new Vector<TowerBase>();
        templateCovers_ = [];
        var txp:Int = 347;
        if (GameData.towerLevels[TowerTypes.PELLET] != null) {
            txp = addTemplate(new TowerPellet(txp, 65, gameData_.team), txp);
        }
        //TODO: Add other towers
        if (GameData.towerLevels[TowerTypes.LASER] != null) {
            txp = addTemplate(new TowerLaser(txp, 65, gameData_.team), txp);
        }
        if (GameData.towerLevels[TowerTypes.MISSILE] != null) {
            txp = addTemplate(new TowerMissile(txp, 65, gameData_.team), txp);
        }
        if (GameData.towerLevels[TowerTypes.BASH] != null ) {
            txp = addTemplate(new TowerBash(txp, 65, gameData_.team), txp);
        }
        if (GameData.towerLevels[TowerTypes.FROST] != null)	{
            txp = addTemplate(new TowerFrost(txp, 65, gameData_.team), txp);
        }
        if (GameData.towerLevels[TowerTypes.ANTIAIR] != null) {
            txp = addTemplate(new TowerAntiAir(txp, 65, gameData_.team), txp);
        }
        
        // Stuff
        blocking_ = new Blocking();
        holder_.addChild(blocking_);
        
        infoBox_ = new InfoBox();
        infoBox_.x = 329;
        infoBox_.y = 100;
        holder_.addChild(infoBox_);
        
        infoBox_.upgradeButton.addEventListener(MouseEvent.CLICK, upgradeClick);
        infoBox_.sellButton.addEventListener(MouseEvent.CLICK, sellClick);

        // trace(gameData_.towers.length);
        for (tower in gameData_.towers)
        {
            towersSurface_.addChild(tower.graphic);
        }
        
        healthBanner0_ = new HealthBanner(gameData_.playerData[0]);
        healthBanner1_ = new HealthBanner(gameData_.playerData[1]);
        
        healthBanner0_.x = 110 - healthBanner0_.width;
        healthBanner1_.x = 110 - healthBanner1_.width;

        healthBanner1_.y = Global.SCREEN_HEIGHT - HealthBanner.HEIGHT;
        
        if (Global.simulation || (Global.networkGame != null && Global.networkGame.otherPlayer != null))
        {
            holder_.addChild(healthBanner0_);
            holder_.addChild(healthBanner1_);
        }
        
        cashDisplay_ = new CashDisplay(gameData_.playerData[gameData_.team]);
        cashDisplay_.x = 340 + 0.5 * 163;
        cashDisplay_.y = 30;
        if (Global.simulation || (Global.networkGame != null && Global.networkGame.otherPlayer != null))
            holder_.addChild(cashDisplay_);
        
        score_ = InfoBox.makeTF(16, true);
        if (Global.simulation || (Global.networkGame != null && Global.networkGame.otherPlayer != null))
            holder_.addChild(score_);
        
        nextWave_ = InfoBox.makeTF(16, true);
        nextWave_.text = "Next wave:\n" + gameData_.nextWave;
        nextWave_.x = 329 + 0.5 * (166 - nextWave_.width);
        nextWave_.y = 395;
        
        if (Global.simulation || (Global.networkGame != null && Global.networkGame.otherPlayer != null))
            holder_.addChild(nextWave_);
        
        // trace("!(Global.simulation || Global.practiceSandboxMode)", !(Global.simulation || Global.practiceSandboxMode));
        //TODO: Extra enemies
        // if (connection_)
        if ((Global.networkGame != null))
        {
            var pd = gameData_.playerData[gameData_.team];

            extraEnemies_ = new ExtraWidget(pd, gameData_.creepCost, gameData_.extraAllowed.get_val());
            extraEnemies_.x = 340;
            extraEnemies_.y = 375;
            extraEnemies_.visible = !(Global.simulation || Global.practiceSandboxMode);
            holder_.addChild(extraEnemies_);
            
            // extraEnemies_.visible = gameData_.extraAllowed.get_val() > 0;
            
            // allowRecord_ = new AllowRecordWidget;
            // allowRecord_.x = 326;
            // allowRecord_.y = 476;
            // //holder_.addChild(allowRecord_);
            
            // allowRecord_.addEventListener(Event.CHANGE, checkBoxChanged);
            
            // allowRecord_.checkbox.selected = gameData_.allowRecording[gameData_.team];
            
            // allowRecord_.otherAllowed = (gameData_.allowRecording[0 == gameData_.team ? 1 : 0]);
        }
        
        Global.stage.addEventListener(KeyboardEvent.KEY_DOWN, onKey, false, 0, true);

        if (debug) {
            this.debugPath = gameData_.grid.pathToExit(true, 13, 44);
        } else {
            this.debugPath = new Vector<GridCoord>();
        }

        // trace(Global.networkGame);

        confirmSentTowerTimer = 5;
        confirmSentTowersRetryCount = 0;

        if (Global.gameOver) {
            var gameOverBlank = new Sprite();
            gameOverBlank.graphics.beginFill(0x000000, 0.5);
            gameOverBlank.graphics.drawRect(0, 0, Global.SCREEN_WIDTH, Global.SCREEN_HEIGHT);
            gameOverBlank.graphics.endFill();

            gameOverWindow = new Sprite();
            gameOverWindow.x = Global.SCREEN_WIDTH/2;
            gameOverWindow.y = Global.SCREEN_HEIGHT/2;
            var gameOverWinWidth = 200;
            var gameOverWinHeight = 100;

            gameOverWindow.graphics.beginFill(0x000000, 1);
            gameOverWindow.graphics.drawRoundRect(-gameOverWinWidth/2, -gameOverWinHeight/2, gameOverWinWidth, gameOverWinHeight, 5, 5);
            gameOverWindow.graphics.endFill();

            var f:TextFormat = new TextFormat();
            f.color = 0xFFFFFF;
            f.align = TextFormatAlign.CENTER;

            var gameOverTitleText = new TextField();
            gameOverTitleText.defaultTextFormat = f;
            gameOverTitleText.text = "Game Over!";
            gameOverTitleText.y = -gameOverWinHeight/2;
            gameOverTitleText.width = gameOverWinWidth;
            gameOverTitleText.x = -gameOverWinWidth/2;

            var gameOverWinLoseText = new TextField();
            gameOverWinLoseText.defaultTextFormat = f;
            gameOverWinLoseText.text = Global.draw ? "Draw!" : Global.weWon ? "You won!" : "You lost!";
            gameOverWinLoseText.width = gameOverWinWidth;
            gameOverWinLoseText.x = -gameOverWinWidth/2;
            gameOverWinLoseText.y = -gameOverWinHeight/4;

            var exitButton = new CustomButton("Exit", 100, 0x44FF44);
            exitButton.x = -50;
            exitButton.y = 0;
            exitButton.addEventListener(MouseEvent.CLICK, (listener:MouseEvent) -> handleExit(true));

            gameOverWindow.addChild(gameOverTitleText);
            gameOverWindow.addChild(gameOverWinLoseText);
            gameOverWindow.addChild(exitButton);

            gameOverBlank.addChild(gameOverWindow);

            holder_.addChild(gameOverBlank);
        }

        // trace("holder_.numChildren", holder_.numChildren);
    }
    
    private function addTemplate(t:TowerBase, x:Int):Int
    {			
        template_.push(t);
        holder_.addChild(t.graphic);
        var cover:Sprite = new Sprite();
        cover.graphics.beginFill(0, 0.75);
        cover.graphics.drawRect(-11.5, -11.5, 24, 24);
        cover.x = t.graphic.x;
        cover.y = t.graphic.y;
        holder_.addChild(cover);
        templateCovers_[t] = cover;
        return x + 26;
    }
    
    //TODO: multiplayer
    private function go():Void
    {
        startButton_.disable();
        infoBox_.upgradeButton.disable();
        infoBox_.sellButton.disable();
        // if (connection_ != null)
        // if (Global.simulation)
        if ( Global.simulation || (Global.networkGame != null && Global.networkGame.otherPlayer != null))
        {
            startButton_.enabled = false;
            if (Global.simulation) {
                // Skip straight to play
                Global.state = "play";
                Global.gameState = Simulation.setupPhase(Global.gameState);
                gameData_ = Simulation.setupGameData(gameData_);
                gameData_ = GameState.calculatePhase(gameData_, false, false, gameData_.team);

                //TODO: mirror towers, hacky
                //first, delete all the mirrors
                var i = gameData_.towers.length;
                while(i-- > 0) {
                    var tower = gameData_.towers[i];
                    if (tower.team == 1) {
                        var removedTower = gameData_.towers.splice(i, 1)[0];

                        var coord:GridCoord = gameData_.grid.coordAt(Std.int(removedTower.x - 0.5 * gameData_.grid.get_squareSize()), Std.int(removedTower.y - 0.5 * gameData_.grid.get_squareSize()));
                        gameData_.grid.setData(coord.x, coord.y, 0);
                        gameData_.grid.setData(coord.x + 1, coord.y, 0);
                        gameData_.grid.setData(coord.x, coord.y+1, 0);
                        gameData_.grid.setData(coord.x + 1, coord.y + 1, 0);
                    }
                }

                var towersLength = gameData_.towers.length;

                for (i in 0...towersLength) {
                    var tower = gameData_.towers[i];
                    if (tower != null && tower.team != 1) {
                        var mirrorTower:TowerBase;

                        var towerX = (27 * 12) - tower.x;
                        var towerY = 540 - tower.y;
                        var towerTeam = 1;

                        switch (tower.type)
                        {
                            case TowerTypes.ANTIAIR:
                                mirrorTower = new TowerAntiAir(towerX, towerY, towerTeam);
                            case TowerTypes.BASH:
                                mirrorTower = new TowerBash(towerX, towerY, towerTeam);
                            case TowerTypes.FROST:
                                mirrorTower = new TowerFrost(towerX, towerY, towerTeam);
                            case TowerTypes.LASER:
                                mirrorTower = new TowerLaser(towerX, towerY, towerTeam);
                            case TowerTypes.MISSILE:
                                mirrorTower = new TowerMissile(towerX, towerY, towerTeam);
                            case TowerTypes.PELLET:
                                mirrorTower = new TowerPellet(towerX, towerY, towerTeam);
                            default:
                                trace("Unknown tower type", tower.type);	break;
                        }

                        mirrorTower.set_upgradeLevel(tower.get_upgradeLevel());

                        gameData_.towers.push(mirrorTower);

                        var coord:GridCoord = gameData_.grid.coordAt(Std.int(mirrorTower.x - 0.5 * gameData_.grid.get_squareSize()), Std.int(mirrorTower.y - 0.5 * gameData_.grid.get_squareSize()));
                        gameData_.grid.setData(coord.x, coord.y);
                        gameData_.grid.setData(coord.x + 1, coord.y);
                        gameData_.grid.setData(coord.x, coord.y+1);
                        gameData_.grid.setData(coord.x + 1, coord.y + 1);
                    }
                }

                isActive = false;
                nextSection_ = new GameSection(null, gameData_);
            } else {
                var extraEnemiesNum = extraEnemies_.get_extra();
                if (gameData_.team == 0) {
                    Global.gameState.extraCreepsTeam0 = extraEnemiesNum;
                } else {
                    Global.gameState.extraCreepsTeam1 = extraEnemiesNum;
                }

                sendTheTowers();

                Main.toggleWait(true);

                canPlay();
            }

            // nextSection_ = new WaitSection(gameData_);
            // nextSection_ = new GameSection(null, gameData_);



            
            // TODO: Figure all this stuff out later

            // nextSection_ = new WaitSection(connection_, Global.messages, this.holder_, "Waiting for other player to finish building...");
        
            // var m:Message = new Message("buildreport");
            
            // m.Add(Bool(gameData_.allowRecording[gameData_.team]));
            
            // m.Add(gameData_.playerData[gameData_.team].cash);
            
            // m.Add(extraEnemies_.extra);
            
            // // Send build report
            // var numThisTeam:Int = 0;
            // for (i in 0...gameData_.towers.length)
            // {
            //     var tower:TowerBase = gameData_.towers[i];
            //     if (tower.team == gameData_.team)
            //     {
            //         ++numThisTeam;
            //     }
            // }
            
            // m.Add(numThisTeam);
            
            // for (i in 0...gameData_.towers.length)
            // {
            //     tower = gameData_.towers[i];
            //     if (tower.team == gameData_.team)
            //     {
            //         m.Add(tower.x);
            //         m.Add(tower.y);
            //         m.Add(tower.type);
            //         m.Add(tower.upgradeLevel);
            //         m.Add(tower.team);
            //     }
            // }
            
            // connection_.Send(m);
        }
        else
        {
            // nextSection_ = new GameSection(null, gameData_);
            nextSection_ = null;
        }
    }

    private function sendTheTowers():Void {
        // trace(towersLength, gameData_.towers.length);
        var towers = [];
        for (i in 0...gameData_.towers.length) {
            var t = gameData_.towers[i];

            if (t.team == gameData_.team) towers.push(t.serialise());
        } 

        var sendTowers = {
            "type": "towers",
            "details": {
                "gameId": Global.networkGame.gameId,
                "towers": towers,
                "extra": extraEnemies_.get_extra()
            }
        }

        // SEND THE TOWERS!!!!!
        Global.network.send(Json.stringify(sendTowers));

        Global.sentTowers = true; //TODO: Hardening, need to check if the message reached the other player
    }
    
    //TODO: Recording
    private function onMessage(e:Dynamic):Void
    {
        // if (e.message.Type == "allowrecord")
        // {
        //     gameData_.allowRecording[e.message.GetInt(0)] = e.message.GetBoolean(1);
        //     allowRecord_.otherAllowed = gameData_.allowRecording[0 == gameData_.team ? 1 : 0];
        // }
    }
    
    //TODO: Recording
    private function checkBoxChanged(e:Dynamic):Void
    {
        // gameData_.allowRecording[gameData_.team] = allowRecord_.checkbox.selected;
        // var m:Message = new Message("allowrecord", allowRecord_.checkbox.selected);
        // connection_.Send(m);
    }
    
    private function onKey(e:KeyboardEvent):Void
    {
        if (isActive == true) {
            trace(showEscWindow);
            if (e.keyCode == 27) {
                if (showEscWindow) {
                    handleExit(false);
                    showEscWindow = false;
                    holder_.removeChild(escapeDialog);
                    holder_.removeChild(pressEscAgainText);
                } else {
                    
                    showEscWindow = true;
                    holder_.addChild(escapeDialog);
                    holder_.addChild(pressEscAgainText);
                }
            }

            if (e.shiftKey)
            {
                switch (e.keyCode)
                {
                    case 27: // ESC
                        selected_ = null;
                        drawRad_ = null;
                        infoBox_.hide();
                        // break;
                        
                    case 83: // S
                        if (infoBox_.visible && infoBox_.sellButton.visible && infoBox_.sellButton.enabled == true)
                            this.sellClick(null);
                        // break;
                        
                    case 85: // U
                        if (infoBox_.visible && infoBox_.upgradeButton.visible && infoBox_.upgradeButton.enabled == true)
                            this.upgradeClick(null);
                        // break;
                }
                
                // Numbers?
                for (i in 0...template_.length)
                {
                    if (e.keyCode == Std.string(i+1).charCodeAt(0))
                    {
                        var t:TowerBase = template_[i];
                        clickedAt(t.x, t.y);
                    }
                }
            }
        }
    }
    
    private function upgradeClick(e:MouseEvent):Void
    {
        var t:TowerBase = infoBox_.associated;
        if (t != null && infoBox_.upgradeButton.enabled)
        {
            if (t.team == gameData_.team)
            {
                if (t.get_upgradeLevel() < t.get_levels().length - 1)
                {
                    var costInc:Int = t.get_levels()[t.get_upgradeLevel() + 1].cost - t.get_levels()[t.get_upgradeLevel()].cost;
                    
                    if (costInc <= gameData_.playerData[gameData_.team].get_cash())
                    {
                        // trace("upgraded");
                        t.set_upgradeLevel(t.get_upgradeLevel() + 1);
                    
                        var pd:PlayerInfo = gameData_.playerData[gameData_.team];
                        pd.set_cash(pd.get_cash() - costInc);
                        
                        GameSounds.play(GameSounds.UPGRADE);
                    }
                    
                }
                infoBox_.show(t.get_levels()[t.get_upgradeLevel()], true, t.get_levels()[t.get_upgradeLevel() + 1]);
            }
        }
        
        if (e != null)
            e.stopPropagation();
    }
    
    private function sellClick(e:MouseEvent):Void
    {
        var t:TowerBase = infoBox_.associated;
        if (t != null && infoBox_.sellButton.enabled == true)
        {
            if (t.team == gameData_.team)
            {	
                // trace("sold");
                var pd:PlayerInfo = gameData_.playerData[gameData_.team];
                pd.set_cash(pd.get_cash() + t.get_sellPrice());
                GameSounds.play(GameSounds.SELL);
                var idx:Int = gameData_.towers.indexOf(t);
                if ( -1 != idx)
                {
                    gameData_.towers.splice(idx, 1);
                    towersSurface_.removeChild(t.graphic);
                    var coord:GridCoord = gameData_.grid.coordAt(Std.int(t.x - 0.5 * gameData_.grid.get_squareSize()), Std.int(t.y - 0.5 * gameData_.grid.get_squareSize()));
                    if (coord != null)
                    {
                        gameData_.grid.setData(coord.x, coord.y, 0);
                        gameData_.grid.setData(coord.x+1, coord.y, 0);
                        gameData_.grid.setData(coord.x, coord.y+1, 0);
                        gameData_.grid.setData(coord.x+1, coord.y+1, 0);

                        GameGFX.drawBorders(gameData_.grid);
                    }
                }
                
                infoBox_.hide();
            }
        }
        
        if (e != null)
            e.stopPropagation();
    }
    
    private function onClick(e:MouseEvent):Void
    {
        if (Global.sentTowers == false) clickedAt(e.stageX, e.stageY);
    }
    
    private function clickedAt(clickX:Float, clickY:Float):Void
    {
        var didPlaceNew:Bool = false;
        
        drawRad_ = null;
        
        // Are we going to place?
        if (selected_ != null)
        {
            var coord:GridCoord = gameData_.grid.coordAt(Std.int(clickX - 0.5 * gameData_.grid.get_squareSize()), Std.int(clickY - 0.5 * gameData_.grid.get_squareSize()));
            if (coord != null && canPlaceAt(coord))
            {
                var nt:TowerBase = selected_.clone();
                nt.positionAt(Math.round(coord.x * gameData_.grid.get_squareSize() + gameData_.grid.get_squareSize()), Math.round(coord.y * gameData_.grid.get_squareSize() + gameData_.grid.get_squareSize()));
                
                gameData_.grid.setData(coord.x, coord.y);
                gameData_.grid.setData(coord.x + 1, coord.y);
                gameData_.grid.setData(coord.x, coord.y+1);
                gameData_.grid.setData(coord.x + 1, coord.y + 1);
                
                // blocking?
                var blocking:Bool = gameData_.grid.get_isBlocking();
                if (blocking)
                {
                    blocking_.show();
                    gameData_.grid.setData(coord.x, coord.y, 0);
                    gameData_.grid.setData(coord.x + 1, coord.y, 0);
                    gameData_.grid.setData(coord.x, coord.y+1, 0);
                    gameData_.grid.setData(coord.x + 1, coord.y + 1, 0);
                }
                else
                {
                    // TOWER ADDED HERE
                    var pd:PlayerInfo = gameData_.playerData[gameData_.team];
                    pd.set_cash(Std.int(pd.get_cash() - nt.get_cost()));
                    
                    towersSurface_.addChild(nt.graphic);
                    gameData_.towers.push(nt);

                    //Mirror mode
                    // if (Global.simulation) {
                    //     var pd:PlayerInfo = gameData_.playerData[1];
                    //     var mirrorTower = Reflect.copy(nt);
                    //     mirrorTower.team = 1;
                    //     mirrorTower.x = (27 * 12) - mirrorTower.x;
                    //     mirrorTower.y = 540 - mirrorTower.y;
                        
                    //     gameData_.towers.push(mirrorTower);
                    // }

                    if (debug) {
                        this.debugPath = gameData_.grid.pathToExit(true, 13, 44);
                    }

                }
                
                didPlaceNew = true;
                GameSounds.play(GameSounds.PLACE);
            }
        }
        
        if (!didPlaceNew)
        {
            selected_ = null;
            infoBox_.hide();
        
            var p:Point = new Point(clickX, clickY);
            
            // Is there a tower where we clicked?
            var towerClicked:TowerBase = null;
            for (t in template_)
            {
                if (t.graphic.getRect(holder_).containsPoint(p))
                {
                    towerClicked = t;
                }
            }
            
            for (t in gameData_.towers)
            {
                if (t.graphic.getRect(holder_).containsPoint(p))
                {
                    towerClicked = t;
                    drawRad_ = new Point(t.x, t.y);
                }
            }
            
            if (towerClicked != null)
            {					
                var t;
                for (t in template_)
                {
                    if (t == towerClicked)
                    {
                        selected_ = t;
                        break;
                    }
                }
                
                t = null;

                var showSell:Bool = towerClicked.team == gameData_.team && null == selected_;
                var upgradeData:InfoBoxData = null != selected_  ? null : towerClicked.get_levels()[towerClicked.get_upgradeLevel() + 1];
                
                if (towerClicked.team != gameData_.team)	upgradeData = null;
                
                infoBox_.show(towerClicked.get_levels()[towerClicked.get_upgradeLevel()], showSell, upgradeData);
                infoBox_.associated = towerClicked;
            }
        }
    }
    
    private function onMouseMove(e:MouseEvent):Void
    {
    }
    
    public function update():IGameSection
    {
        // trace("edit update");
        // if (waitingBar.alpha < 1)
        // {
        //     waitingBar.alpha = waitingBar.alpha + 1 / 150.0;
        //     waitingText.alpha = waitingBar.alpha;
        // }

        // trace(gameData_.buildTime);
        if ((Global.networkGame != null))
            extraEnemies_.update();

        escapeDialog.visible = showEscWindow;
        pressEscAgainText.visible = showEscWindow;
        
        if (gameStart_ != null)
        {
            gameStart_.alpha -= 0.2 * Global.UPDATE_SECS;
            if (gameStart_.alpha < 0.01)
            {
                holder_.removeChild(gameStart_);
                gameStart_ = null;
            }
        }
        
        blocking_.update(Global.UPDATE_SECS);
        
        // set to false to turn off timer
        if (!Global.simulation) {
            if ((Global.networkGame != null && Global.networkGame.otherPlayer != null))
            {
                gameData_.buildTime -= Global.UPDATE_SECS;
            
                if (gameData_.buildTime <= 0 && Global.sentTowers == false)
                {
                    trace("this was called");
                    go();
                }
                
                if (!ticking_ && gameData_.buildTime <= 5)
                {
                    ticking_ = true;
                    GameSounds.play(GameSounds.TICK);
                }
            }
        }

        if (Global.sentTowers && gameData_.buildTime <= 0) {
            confirmSentTowerTimer -= Global.UPDATE_SECS;
            if (!Global.ackReceivedTowers && confirmSentTowerTimer <= 0) {
                Global.chatHolder.addChatStr("<Game> Checking if player received towers " + (confirmSentTowersRetryCount+1) + "/" + CONFIRM_MAX_SENT_TOWERS_RETRY_COUNT);
                if (confirmSentTowersRetryCount >= CONFIRM_MAX_SENT_TOWERS_RETRY_COUNT) {
                    // TODO: in ranked, if the other person leaves, then you win
                    Global.networkToast.setText("Other player abandoned the game.");
                    handleExit(true);
                } else {
                    // send the towers again
                    sendTheTowers();

                    confirmSentTowerTimer = MAX_SENT_TOWERS_TIMER;
                    confirmSentTowersRetryCount++;

                    trace(confirmSentTowersRetryCount);
                }
            }
        }
        
        return nextSection_;
    }
    
    public function draw():Void
    {
        // trace("edit draw");
        score_.text = "Score: " + Std.string(gameData_.playerData[gameData_.team].get_score());
        score_.y = 5;
        score_.x = 329 + 0.5 * (162 - score_.width);
        
        healthBanner0_.draw();
        healthBanner1_.draw();
        
        cashDisplay_.draw();
        
        // if (connection_)
        if ((Global.networkGame != null))
            extraEnemies_.draw();
        if ((Global.networkGame != null && Global.networkGame.otherPlayer != null) && gameData_.buildTime > 0)
            startButton_.set_text("Start (" + Math.round(gameData_.buildTime) + ")");
        else
            startButton_.set_text("Start");
        
        var g:Graphics = debugSurface_.graphics;
        g.clear();

        // Bleh
        if (true) {
            if (selected_ != null)
            {
                var coord:GridCoord = gameData_.grid.coordAt(Std.int(holder_.mouseX - 0.5 * gameData_.grid.get_squareSize()), Std.int(holder_.mouseY - 0.5 * gameData_.grid.get_squareSize()));
                if (coord != null)
                {
                    var c1:GridCoord = coord;
                    var c2:GridCoord = new GridCoord(c1.x + 1, c1.y);
                    var c3:GridCoord = new GridCoord(c1.x + 1, c1.y+1);
                    var c4:GridCoord = new GridCoord(c1.x, c1.y + 1);
                    
                    if (gameData_.grid.isInGrid(c1.x, c1.y) && gameData_.grid.isInGrid(c2.x, c2.y) && gameData_.grid.isInGrid(c3.x, c3.y) && gameData_.grid.isInGrid(c4.x, c4.y))
                    {
                        var canPlace:Bool = canPlaceAt(c1);
                        var color:Int = canPlace ? 0x00FF00 : 0xFF0000;
                        
                        drawRadCircle(g, new Point(coord.x * gameData_.grid.get_squareSize() + gameData_.grid.get_squareSize(), coord.y * gameData_.grid.get_squareSize() + gameData_.grid.get_squareSize()), selected_.get_levels()[0].radius);
                        
                        g.beginFill(color, 1);
                        g.lineStyle(1, canPlace ? 0x88FF88 : 0xFF8888, 0.75);
                        // g.drawRect(10,10,20,20);
                        g.drawRect(coord.x * gameData_.grid.get_squareSize(), coord.y * gameData_.grid.get_squareSize(), 2 * gameData_.grid.get_squareSize(), 2 * gameData_.grid.get_squareSize());
                    }
                }
            }
            
            if (drawRad_ != null)
            {
                var towerAt:TowerBase = null;
                for (t in gameData_.towers)
                {
                    if (t.graphic.getRect(holder_).containsPoint(drawRad_))
                    {
                        towerAt = t;
                        break;
                    }
                }
                if (towerAt != null)
                {
                    drawRadCircle(g, drawRad_, towerAt.get_radius());
                }
            }
            
            for (t in gameData_.towers)
            {
                t.draw();
            }
            
            for (t in template_)
            {
                templateCovers_[t].visible = t.get_cost() > gameData_.playerData[gameData_.team].get_cash();
            }
            
            if (selected_ == null)
            {
                if (infoBox_.associated != null)
                {
                    var upgradeCost:Int = 0;
                    
                    if (infoBox_.associated.get_upgradeLevel() < infoBox_.associated.get_levels().length - 1)
                    {
                        upgradeCost = Std.int(infoBox_.associated.get_levels()[infoBox_.associated.get_upgradeLevel() + 1].cost - infoBox_.associated.get_cost());
                        if (upgradeCost <= gameData_.playerData[gameData_.team].get_cash() && startButton_.enabled == true)
                        {
                            infoBox_.upgradeButton.enable();
                        }
                        else
                        {
                            infoBox_.upgradeButton.disable();
                        }
                    }
                }
            }

            for (coord in debugPath) {
                g.drawCircle(coord.x * 12, coord.y * 12, 4);
            }
        }
    }
    
    private function drawRadCircle(g:Graphics, coord:Point, r:Float):Void
    {
        g.lineStyle(1, 0xFFFF00, 0.45);
        g.beginFill(0xFFFFFF, 0.4);
        g.drawCircle(coord.x, coord.y, r);
    }
    
    //TODO: Fix
    private function canPlaceAt(c1:GridCoord):Bool
    {
        var c2:GridCoord = new GridCoord(c1.x + 1, c1.y);
        var c3:GridCoord = new GridCoord(c1.x + 1, c1.y+1);
        var c4:GridCoord = new GridCoord(c1.x, c1.y + 1);

        // trace(c1, c2, c3, c4);
        
        // Can we even afford it?
        if (selected_ != null)
        {
            if (selected_.get_cost() > gameData_.playerData[gameData_.team].get_cash())
            {
                return false;
            }
        }
        
        if (gameData_.grid.isOccupied(c1.x, c1.y))	return false;
        if (gameData_.grid.isOccupied(c2.x, c2.y))	return false;
        if (gameData_.grid.isOccupied(c3.x, c3.y))	return false;
        if (gameData_.grid.isOccupied(c4.x, c4.y))	return false;
        
        // On placeable part for us?
        if (!placeable_[c1.x + c1.y * gameData_.grid.get_width()])	return false;
        if (!placeable_[c2.x + c2.y * gameData_.grid.get_width()])	return false;
        if (!placeable_[c3.x + c3.y * gameData_.grid.get_width()])	return false;
        if (!placeable_[c4.x + c4.y * gameData_.grid.get_width()])	return false;
        
        // Don't block entrances
        if (c1.y == 0 || c2.y == 0 || c3.y == 0 || c4.y == 0)	return false;
        if (c1.y == gameData_.grid.get_height() - 1 || c2.y == gameData_.grid.get_height() - 1 || c3.y == gameData_.grid.get_height() - 1 || c4.y == gameData_.grid.get_height() - 1)	return false;
        
        return true;
    }
    
    public function getGraphic():DisplayObject { return holder_; }

    private function fast(e:Event):Void{
        Global.fast = !Global.fast;

        if (Global.fast) {
            fastButton_.set_colour(0xE00000);
            fastButton_.set_text("Disable Fast");
        } else {
            fastButton_.set_colour(0x44FF44);
            fastButton_.set_text("Enable Fast");
        }
    }

    public function addEnemyTowers(towers:Array<NetworkTowerMessage>):Void {
        var enemyTowerTeam = gameData_.team == 0 ? 1 : 0;

        // nuke all the enemy team towers that might be in there
        var i = gameData_.towers.length;
        while(i-- > 0) {
            var tower = gameData_.towers[i];
            if (tower.team == enemyTowerTeam) {
                var removedTower = gameData_.towers.splice(i, 1)[0];

                var coord:GridCoord = gameData_.grid.coordAt(Std.int(removedTower.x - 0.5 * gameData_.grid.get_squareSize()), Std.int(removedTower.y - 0.5 * gameData_.grid.get_squareSize()));
                gameData_.grid.setData(coord.x, coord.y, 0);
                gameData_.grid.setData(coord.x + 1, coord.y, 0);
                gameData_.grid.setData(coord.x, coord.y+1, 0);
                gameData_.grid.setData(coord.x + 1, coord.y + 1, 0);
            }
        }

        // Now add the enemy towers
        for (i in 0...towers.length) {
            var towerToAdd:TowerBase;
            var tower = towers[i];
            var towerX = tower.x;
            var towerY = tower.y;

            var towerTeam = enemyTowerTeam;

            switch (tower.type)
            {
                case TowerTypes.ANTIAIR:
                    towerToAdd = new TowerAntiAir(towerX, towerY, towerTeam);
                case TowerTypes.BASH:
                    towerToAdd = new TowerBash(towerX, towerY, towerTeam);
                case TowerTypes.FROST:
                    towerToAdd = new TowerFrost(towerX, towerY, towerTeam);
                case TowerTypes.LASER:
                    towerToAdd = new TowerLaser(towerX, towerY, towerTeam);
                case TowerTypes.MISSILE:
                    towerToAdd = new TowerMissile(towerX, towerY, towerTeam);
                case TowerTypes.PELLET:
                    towerToAdd = new TowerPellet(towerX, towerY, towerTeam);
                default:
                    trace("Unknown tower type", tower.type);	break;
            }

            towerToAdd.set_upgradeLevel(tower.upgradeLevel);

            gameData_.towers.push(towerToAdd);

            var coord:GridCoord = gameData_.grid.coordAt(Std.int(towerToAdd.x - 0.5 * gameData_.grid.get_squareSize()), Std.int(towerToAdd.y - 0.5 * gameData_.grid.get_squareSize()));
            gameData_.grid.setData(coord.x, coord.y);
            gameData_.grid.setData(coord.x + 1, coord.y);
            gameData_.grid.setData(coord.x, coord.y+1);
            gameData_.grid.setData(coord.x + 1, coord.y + 1);
        }
    }

    public function networkHandler(data:String):Void {
        // trace("networkHandler edit");
        // trace("received from server:");
        // trace(data);

        var parsed:NetworkMessage = Json.parse(data);

        trace(parsed.type, "parsed.type");

        switch(parsed.type) {
            case "receivedTowers":
                if (Global.receivedTowers == false) {
                    //TODO: properly handle receiving towers
                    var t:ResponseReceivedTowers = Json.parse(data);
                    addEnemyTowers(t.details.towers);
                    if (gameData_.team == 1) {
                        Global.gameState.extraCreepsTeam0 = t.details.extra;
                    } else {
                        Global.gameState.extraCreepsTeam1 = t.details.extra;
                    }
                    
                    Global.receivedTowers = true;
                    var ackReceivedTowers = {
                        "type": "ackReceivedTowers",
                        "details": {
                            "gameId": Global.networkGame.gameId
                        }
                    };
                    Global.network.send(Json.stringify(ackReceivedTowers));
                    canPlay();
                }

            case "ackReceivedTowers":
                Global.ackReceivedTowers = true;
                canPlay();

            case "playerReadyForNextRound":
                Global.opponentReadyForNextRound = true;

            case "gameDetails":
                var gd:GameDetails = Json.parse(data);
                var n = gd.details;
                trace(n);
                Global.chatHolder.setUsers(n.player1, n.player2, n.spectators);
            
            case "playerJoined":
                var n:ResponseJoinedGame = Json.parse(data);
                trace(n);
                // Global.networkGame.otherPlayer = n.details.otherPlayer;
                Global.chatHolder.addChat("Server", "Player '" + n.details.otherPlayer + "' Joined");

            case "playerDisconnect":
                var n:PlayerDisconnected = Json.parse(data);
                Global.networkToast.setText("Other player disconnected");
                if (!Global.gameOver)
                    handleExit(true);

            case "chatMsg":
                var n:ChatMsg = Json.parse(data);
                Global.chatHolder.addChat(n.details.username, n.details.message);

            default:
                trace("never heard of " + parsed.type);
        }
    }

    private function canPlay():Void {
        if (Global.receivedTowers == true && Global.sentTowers == true && Global.ackReceivedTowers == true) {
            // Skip straight to play
            Global.state = "play";
            Global.gameState = Simulation.setupPhase(Global.gameState);
            gameData_ = Simulation.setupGameData(gameData_);
            gameData_ = GameState.calculatePhase(gameData_, false, false, gameData_.team);

            Global.sentTowers = false;
            Global.receivedTowers = false;
            Global.ackReceivedTowers = false;
            Main.toggleWait(false);
            isActive = false;
            nextSection_ = new GameSection(null, gameData_);
        }
    }

    private function handleExit(force:Bool):Void {
        if (showEscWindow == true || force == true) {
            var isNetworked = Global.networkGame != null;
            var isPractice = (Global.simulation || Global.practiceSandboxMode);

            if (isPractice || isNetworked) {
                Global.resetGlobal(true);
                isActive = false;
                Global.chatHolder.setVisibility(false);
                Global.chatHolder.reset();
                Global.network.disconnect();
                Global.networkGame = null;
                Global.stage = null;
                Global.resetAll = true;
                // nextSection_ = new LobbySection();
            }

            // if (isNetworked && !isPractice) {
            //     Global.chatHolder.setVisibility(false);
            //     Global.chatHolder.reset();
            //     Global.network.disconnect();
            //     Global.networkGame = null;
            // }
        }
    }
}