package wait;

import openfl.geom.Rectangle;
import network.Chat;
import network.GameBrowser;
import js.Browser;
import js.html.Window;
import js.html.StorageManager;
import ui.InputTextField;
import network.NetworkMessage;
import network.NetworkDialog;
import haxe.Json;
import editor.EditSection;
import gamestate.GameState;
import editor.EditSection;
import info.InfoBox;
import ToBitmapData.toBitmapData;
import openfl.utils.Assets;
import openfl.display.*;
import openfl.display.DisplayObject;
import openfl.events.MouseEvent;
import openfl.events.TextEvent;
import openfl.geom.ColorTransform;
import openfl.geom.Point;
import openfl.media.Sound;
import openfl.media.SoundMixer;
import openfl.text.TextField;
import openfl.text.TextFormat;
import game.creeps.CreepBase;
import game.creeps.CreepFactory;
import game.GameData;
import game.GameGFX;
import game.GameSection;
import grid.GameGrid;
import grid.GridCoord;
import info.InfoBox;
import info.InfoBoxData;
import towers.*;
import network.Network;
import js.html.Storage;

class WaitSection implements IGameSection
{
    private var holder_:Sprite;
    private var nextSection_:IGameSection;
    private static var backgroundBmp_:BitmapData;
    
    // private var messages_:MessageQueue;
    // private var connection_:Connection;
    
    private var bar_:WaitBar;
    
    private var tf:TextField;
    private var gameIdTF:TextField;
    
    private var practice_:Practice;
    
    private var first_:Bool = true;
    
    // private var adClip_:MovieClip = new MovieClip();
    
    // [Embed(source="logo.swf", mimeType="application/octet-stream")] public static const LOGO:Class;
    

    private var gameData_:GameData;

    private var simulationButton:CustomButton;
    private var practiceButton:CustomButton;
    private var multiplayerButton:CustomButton;
    private var createGameButton:CustomButton;
    private var joinGameButton:CustomButton;

    private var loginButton:CustomButton;
    private var registerButton:CustomButton;

    private var backButton:CustomButton;

    private var joinField:InputTextField;
    private var usernameField:InputTextField;
    private var passwordField:InputTextField;
    // private var emailField:InputTextField;

    private var networkMessage:NetworkDialog;

    private var isRegistering:Bool = false;

    private var gameBrowser:GameBrowser;
    private var lobbyChat:Chat;

    private var inLobby:Bool = false;

    private var joiningGame:Bool = false;
    private var MAX_JOIN_GAME_TIMER:Float = 15;
    private var confirmJoinGameTimer:Float = 15;
    private var joiningGameData:ResponseJoinedGame;

    private var livesSelectHolder:Sprite;
    private var lives20Button:CustomButton;
    private var lives40Button:CustomButton;

    // public function WaitSection(connection:Connection, messages:MessageQueue, background:DisplayObject = null, message:String = "", showPractice:Boolean = false) 
    public function new(gameData:GameData)
    {
        //TEMP
        var showPractice = true;
        var message = "Waiting for another player to join the game...";
        //END TEMP

        SoundMixer.stopAll();
        
        if (showPractice) {
            // practice_ = new Practice();
        }

        // connection_ = connection;
        holder_ = new Sprite();
        nextSection_ = this;

        // messages_ = messages;
        
        if (backgroundBmp_ == null) backgroundBmp_ = new BitmapData(Global.SCREEN_WIDTH, Global.SCREEN_HEIGHT, false, 0);

        // if (background)
        if (null) {
            // backgroundBmp_.draw(background);
            backgroundBmp_.draw(null);
        } else {
            var bg = toBitmapData(GameGFX.bg);
            backgroundBmp_.copyPixels(bg, bg.rect, new Point());
        }
        
        backgroundBmp_.colorTransform(backgroundBmp_.rect, new ColorTransform(0.3, 0.3, 0.3));
        holder_.addChild(new Bitmap(backgroundBmp_));
        
        bar_ = new WaitBar();
        // holder_.addChild(bar_);
        
        bar_.y -= 175;
        
        tf = InfoBox.makeTF(16, true);
        tf.text = message;
        tf.x = 0.5 * (Global.SCREEN_WIDTH - 200 - tf.width);
        tf.y = 200;
        tf.alpha = showPractice ? 1 : 0.01;
        // holder_.addChild(tf);
        
        tf.y -= 175;

        livesSelectHolder = new Sprite();
        lives20Button = new CustomButton("20 Lives", 80, 0xFFFF00);
        lives20Button.x = -40;
        lives20Button.y = -35;
        lives20Button.addEventListener(MouseEvent.CLICK, (listener:MouseEvent) -> {
            if (!Global.network.isConnected()) {
                // if we're simulation
                Global.gameState.playerInfo[0].lives = 20;
                Global.gameState.playerInfo[1].lives = 20;
                Global.simulation = true;
                startGame();
            } else {
                createGameClick(20);
            }
        });
        lives40Button = new CustomButton("40 Lives", 80, 0xFFFF00);
        lives40Button.addEventListener(MouseEvent.CLICK, (listener:MouseEvent) -> {
            if (!Global.network.isConnected()) {
                // if we're simulation
                Global.gameState.playerInfo[0].lives = 40;
                Global.gameState.playerInfo[1].lives = 40;
                Global.simulation = true;
                startGame();
            } else {
                createGameClick(40);
            }
        });
        lives40Button.x = -40;
        lives40Button.y = 5;
        
        // if (practice_ != null)
        if (showPractice)
        {
            var t:TextField = InfoBox.makeTF(12, true);
            t.text = "You can experiment in sandbox mode while you wait for another player.\nClick the button below to play with infinite lives and cash!";
            
            practiceButton = new CustomButton("Sandbox Mode", 125, 0xFFFF00);
            practiceButton.x = (0.5 * Global.SCREEN_WIDTH) - (practiceButton.width/2);
            // practiceButton.x = 0.75 * (Global.SCREEN_WIDTH - practiceButton.width);
            practiceButton.y = 300;
            holder_.addChild(practiceButton);
            practiceButton.addEventListener(MouseEvent.CLICK, practiceSandboxClick);
            
            t.x = 0.5 * (Global.SCREEN_WIDTH - 200 - t.width);
            t.y = practiceButton.y - t.height - 10;
            // holder_.addChild(t);

            simulationButton = new CustomButton("Simulation Mode", 125, 0xFFFF00);
            simulationButton.x = (0.5 * Global.SCREEN_WIDTH) - (simulationButton.width/2);
            simulationButton.y = 250;
            holder_.addChild(simulationButton);
            simulationButton.addEventListener(MouseEvent.CLICK, simulationClick);

            livesSelectHolder.x = (0.5 * Global.SCREEN_WIDTH);
            livesSelectHolder.y = (0.5 * Global.SCREEN_HEIGHT);
            var rectWidth = 250;
            var rectHeight = 150;
            livesSelectHolder.graphics.beginFill(0x000000, 1);
            livesSelectHolder.graphics.drawRect(-rectWidth/2,-rectHeight/2,rectWidth, rectHeight);
            livesSelectHolder.graphics.endFill();
            livesSelectHolder.addChild(lives20Button);
            livesSelectHolder.addChild(lives40Button);
            livesSelectHolder.visible = false;
        }

        multiplayerButton = new CustomButton("Online Multiplayer", 125, 0xFFFF00);
        multiplayerButton.x = (0.5 * Global.SCREEN_WIDTH) - (multiplayerButton.width/2);
        multiplayerButton.y = 200;
        holder_.addChild(multiplayerButton);
        // multiplayerButton.addEventListener(MouseEvent.CLICK, multiplayerClick);
        multiplayerButton.addEventListener(MouseEvent.CLICK, connectToServer);

        var firstQtrScreenX = (0.25 * Global.SCREEN_WIDTH);

        createGameButton = new CustomButton("Create Game", 125, 0xFFFF00);
        // createGameButton.x = (0.5 * Global.SCREEN_WIDTH) - (createGameButton.width/2);
        createGameButton.x = firstQtrScreenX - (createGameButton.width/2);
        createGameButton.y = 50;
        // holder_.addChild(createGameButton);
        createGameButton.addEventListener(MouseEvent.CLICK, (listener:MouseEvent) -> {
            livesSelectHolder.visible = true;
            holder_.addChild(livesSelectHolder);
        });

        joinGameButton = new CustomButton("Join Game", 125, 0xFFFF00);
        joinGameButton.x = firstQtrScreenX - (joinGameButton.width/2) + 55;
        joinGameButton.y = 100;
        // holder_.addChild(joinGameButton);
        joinGameButton.addEventListener(MouseEvent.CLICK, joinGameClick);

        loginButton = new CustomButton("Login", 125, 0xFFFF00);
        loginButton.x = (0.5 * Global.SCREEN_WIDTH) - (multiplayerButton.width/2);
        loginButton.y = 300;
        // holder_.addChild(createGameButton);
        loginButton.addEventListener(MouseEvent.CLICK, loginClick);

        registerButton = new CustomButton("Register", 125, 0xFFFF00);
        registerButton.x = (0.5 * Global.SCREEN_WIDTH) - (multiplayerButton.width/2);
        registerButton.y = 350;
        // holder_.addChild(createGameButton);
        registerButton.addEventListener(MouseEvent.CLICK, showRegisterMenu);

        backButton = new CustomButton("Back To Main Menu", 125, 0xFFFF00);
        backButton.x = (firstQtrScreenX*3) - (backButton.width/2);
        backButton.y = 500;
        // holder_.addChild(backButton);
        backButton.addEventListener(MouseEvent.CLICK, backToHome);

        joinField = new InputTextField("Insert Game ID");
        joinField.x = firstQtrScreenX - (joinGameButton.width/2) - 55;
        joinField.y = 103;
        // holder_.addChild(joinField);

        usernameField = new InputTextField("Username");
        usernameField.x = (0.5 * Global.SCREEN_WIDTH) - (usernameField.width/2);
        usernameField.y = 203;
        // holder_.addChild(joinField);

        passwordField = new InputTextField("Password", 0, 0, 100, 18, true);
        passwordField.x = (0.5 * Global.SCREEN_WIDTH) - (passwordField.width/2);
        passwordField.y = 253;
        // holder_.addChild(joinField);





        // emailField = new InputTextField("Email", 0, 0, 100, 18, false);
        // emailField.x = (0.5 * Global.SCREEN_WIDTH) - (passwordField.width/2);
        // emailField.y = 303;
        // holder_.addChild(joinField);

        /*
        var serverString:TextField = new TextField;
        serverString.defaultTextFormat = new TextFormat(null, null, 0xFFFFFF);

        holder_.addChild(serverString);
        */

        // gameIdTF = new TextField();
        // gameIdTF.defaultTextFormat = new TextFormat(null, null, 0xFFFFFF);
        // gameIdTF.x = 375;
        // gameIdTF.y = 500;
        
        // holder_.addChild(adClip_);
        
        // adClip_.x = 100;
        // adClip_.y = 135;

        // gameData_ = new GameData();
        gameData_ = gameData;
        
        // holder_.addChild(practice_);

        // if (Global.playerToken.length > 0) {
        //     // hacky
        //     multiplayerClick(null);
        //     showMultiplayerMenu();
        // }

        gameBrowser = new GameBrowser(joinGame);

        lobbyChat = new Chat(true);
    }

    private function practiceSandboxClick(e:MouseEvent):Void {
        Global.practiceSandboxMode = true;
        practice_ = new Practice();
        holder_.addChild(practice_);
        leaveSection();
    }
    
    private function sandboxClick(e:MouseEvent):Void
    {
        trace(Global.networkGame.gameId);
        Main.toggleWait(true);
        Global.practiceSandboxMode = true;

        practice_ = new Practice();
        holder_.addChild(practice_);
        if (Global.networkGame.gameId != null) {
            Global.chatHolder.setVisibility(true);
            Global.chatHolder.addChat("Server", "Game Code: " + Global.networkGame.gameId);

            var getPlayers = {
                "type": "getGameDetails",
                "details": {
                    "gameId": Global.networkGame.gameId
                }
            };
            Global.network.send(Json.stringify(getPlayers));
        }

        leaveSection();
        
        // adClip_.visible = false;
    }

    private function simulationClick(e:MouseEvent):Void
    {
        // practice_ = new Practice();
        // holder_.addChild(practice_);
        livesSelectHolder.visible = true;
        holder_.addChild(livesSelectHolder);

        // Global.simulation = true;
        // startGame();

        // leaveSection();
    }

    private function connectToServer(e:MouseEvent):Void {
        networkMessage = new NetworkDialog("Connecting to server");

        holder_.addChild(networkMessage);

        Global.network.connect();
    }

    private function loginClick(e:MouseEvent):Void {
        networkMessage = new NetworkDialog("Logging in");

        holder_.addChild(networkMessage);

        var login = {
			"type": "login",
			"details": {
				"username": this.usernameField.getValue(),
                "password": this.passwordField.getValue()
			}
		};

        Global.network.send(Json.stringify(login));
    }

    private function multiplayerClick(e:MouseEvent):Void
    {
        holder_.removeChild(multiplayerButton);
        holder_.removeChild(practiceButton);
        holder_.removeChild(simulationButton);

        // holder_.addChild(createGameButton);
        // holder_.addChild(joinField);
        // holder_.addChild(joinGameButton);

        holder_.addChild(usernameField);
        holder_.addChild(passwordField);
        holder_.addChild(loginButton);
        holder_.addChild(registerButton);
        holder_.addChild(backButton);

        if (Browser.getLocalStorage().getItem("username") != null && 
            Browser.getLocalStorage().getItem("password") != null) {
            networkMessage = new NetworkDialog("Logging in");

            holder_.addChild(networkMessage);

            var login = {
                "type": "login",
                "details": {
                    "username": Browser.getLocalStorage().getItem("username"),
                    "password": Browser.getLocalStorage().getItem("password")
                }
            };

            Global.network.send(Json.stringify(login));
        }
    }

    private function showMultiplayerMenu():Void {
        inLobby = true;
        holder_.removeChild(usernameField);
        holder_.removeChild(passwordField);
        // holder_.removeChild(emailField);
        holder_.removeChild(loginButton);
        holder_.removeChild(registerButton);
        // holder_.removeChild(backButton);

        holder_.addChild(createGameButton);
        holder_.addChild(joinField);
        holder_.addChild(joinGameButton);
        holder_.addChild(gameBrowser);
        holder_.addChild(lobbyChat);

        // if (Global.network.isConnected()) {
            var joinChatLobby = {
                "type": "joinChatLobby",
                "details": {}
            };

            Global.network.send(Json.stringify(joinChatLobby));
        // }
    }

    private function showRegisterMenu(e:MouseEvent):Void {

        if (!isRegistering) {
            holder_.removeChild(loginButton);

            // holder_.addChild(emailField);
        } else {
            isRegistering = false;
            // perform register request
            networkMessage = new NetworkDialog("Registering account");

            holder_.addChild(networkMessage);

            var newAccount = {
                "type": "newAccount",
                "details": {
                    "username": this.usernameField.getValue(),
                    "password": this.passwordField.getValue()
                }
            };

            Global.network.send(Json.stringify(newAccount));
            return;
        }

        isRegistering = true;
    }

    private function createGameClick(lives:Int):Void
    {
        networkMessage = new NetworkDialog("Creating new game");

        holder_.addChild(networkMessage);

        var newGame = {
			"type": "newGame",
            "details": {
                "lives": lives
            }
		};

        Global.network.send(Json.stringify(newGame));
    }

    private function joinGameClick(e:MouseEvent):Void {
        joinGame(this.joinField.getValue());
    }

    private function joinGame(gameId:String):Void {

        networkMessage = new NetworkDialog("Joining game");

        holder_.addChild(networkMessage);

        var joinGame = {
			"type": "joinGame",
			"details": {
				"gameId": gameId
			}
		};

        Global.network.send(Json.stringify(joinGame));
    }

    private function backToHome(e:MouseEvent):Void
    {
        isRegistering = false;
        Global.resetGlobal(true);
        lobbyChat.reset();
        Main.toggleWait(false);

        holder_.removeChild(createGameButton);
        holder_.removeChild(joinField);
        holder_.removeChild(joinGameButton);
        holder_.removeChild(loginButton);
        holder_.removeChild(registerButton);
        holder_.removeChild(backButton);
        holder_.removeChild(gameBrowser);
        holder_.removeChild(lobbyChat);

        Global.chatHolder.setVisibility(false);
        Global.chatHolder.reset();
        Global.network.disconnect();
        Global.networkGame = null;
        // holder_.removeChildren();

        holder_.addChild(multiplayerButton);
        holder_.addChild(practiceButton);
        holder_.addChild(simulationButton);
    }

    private function startGame(joined = false, spectator=false):Void {
        trace("!!!!!trying to start game!!!!");
        // trace(Global.networkGame);
        if (Global.networkGame != null && Global.networkGame.gameId != null) {
            Global.chatHolder.setVisibility(true);

            var getPlayers = {
                "type": "getGameDetails",
                "details": {
                    "gameId": Global.networkGame.gameId
                }
            };
            Global.network.send(Json.stringify(getPlayers));
        }

        if (networkMessage != null) {
            holder_.removeChild(networkMessage);
            networkMessage.cleanup();
        }

        Global.practiceSandboxMode = false;
        Main.toggleWait(false);
        Global.state = "build";

        var team = 0;
        if (joined) {
            team = 1;

            leaveLobby();

            joiningGameData = null;
            joiningGame = false;
            confirmJoinGameTimer = MAX_JOIN_GAME_TIMER;
        }

        // gameData_ = GameState.calculatePhase(gameData_, true, true, team);
        holder_.removeChildren();
        nextSection_ = new EditSection(null, GameState.calculatePhase(gameData_, true, true, team));
    }

    public function update():IGameSection
    {
        // trace("wait update");
        if (practice_ != null) {
            practice_.update();
        }
        
        if (tf.alpha < 1)
        {
            tf.alpha = tf.alpha + 1 / 150.0;
        }
        
        bar_.update();
        
        // if (0 != messages_.length)
        if (true)
        {
            // trace("in here" + openfl.Lib.getTimer());
            // var m:* = messages_.shift();
            // switch (m.Type)
            switch (Global.state)
            {
                case "build":
                    // nextSection_ = new EditSection(connection_, Message2GameData(m));
                    // nextSection_ = new EditSection(null, Message2GameData(Global.gameState));
                    // nextSection_ = new EditSection(null, GameState.calculatePhase(gameData_, true));
            //         break;
                    
                case "play":
            //         nextSection_ = new GameSection(connection_, Message2GameData(m));
                    // nextSection_ = new GameSection(null, gameData_);
            //         break;
                    
            //     case "win":
            //         nextSection_ = new WinSection(connection_, Message2GameData(m));
            //         break;
                    
                default:
                    // trace("unknown section type", Global.state);
            //         break;
            }
        }
        
        if (first_) {
        
            first_ = false;
            
            // var l:Loader = new Loader;
            // adClip_.addChild(l);
            // l.loadBytes(new LOGO);
        
        }

        if (Global.network.isConnected() && Global.playerToken.length > 0 && inLobby) {
            gameBrowser.update();
        }

        if (joiningGame) {
            confirmJoinGameTimer -= Global.UPDATE_SECS;
            if (confirmJoinGameTimer <= 0) {
                Global.networkToast.setText("Couldn't join game");
                holder_.removeChild(networkMessage);
                networkMessage.cleanup();
                joiningGameData = null;
                joiningGame = false;
                backToHome(null);
            }
        }
        
        return nextSection_;
    }
    
    // public static function Message2GameData(m:Dynamic):GameData
    public static function Message2GameData(gameState:GameState):GameData
    {
        // trace("Message length:", m.length);
        
        var gameData:GameData = new GameData();
        
        return GameState.calculatePhase(gameData, true);
    }
    
    public function draw():Void
    {
        // trace("wait draw");
        if (practice_ != null) {
            practice_.draw();
        } else {

        }
    }
    
    public function getGraphic():DisplayObject { return holder_; }

    private function leaveSection():Void {
        holder_.removeChild(practiceButton);
        holder_.removeChild(simulationButton);
    }

    private function leaveLobby():Void {
        inLobby = false;

        var leaveLobby = {
            "type": "leaveLobby",
            "details": {}
        };
        Global.network.send(Json.stringify(leaveLobby));
    }

    private function pendingJoinGame(n:ResponseJoinedGame):Void {
        trace("pending joined game");

        Global.networkGame = {
            gameId: n.details.gameId,
            otherPlayer: n.details.otherPlayer,
            title: n.details.title,
            ranked: n.details.ranked,
            lives: n.details.lives
        };

        Global.gameState.playerInfo[0].lives = n.details.lives;
        Global.gameState.playerInfo[1].lives = n.details.lives;

        joiningGame = true;

        networkMessage = new NetworkDialog("Waiting to join game");

        holder_.addChild(networkMessage);

        confirmJoinGameTimer = MAX_JOIN_GAME_TIMER;

        // startGame(true);
    }

    private function ackPlayerJoined(n:ResponseJoinedGame):Void {
        leaveLobby();
        trace(n);
        Global.networkGame.otherPlayer = n.details.otherPlayer;
        Global.chatHolder.addChat("Server", "Player '" + n.details.otherPlayer + "' Joined");

        var ackPlayerJoin = {
            "type": "ackPlayerJoin",
            "details": {
                "gameId": Global.networkGame.gameId,
                "playerName": n.details.otherPlayer
            }
        };
        
        Global.network.send(Json.stringify(ackPlayerJoin));
    }

    public function networkHandler(data:String):Void {
        // trace("wait");
        // trace("received from server:");
        // trace(data);

        // var hello = {
        //     "type": "hello",
        //     "details": "yo"
        // }

        // trace(Json.stringify(hello));

        // Global.network.send(Json.stringify(hello));

        holder_.removeChild(networkMessage);
        networkMessage.cleanup();

        var parsed:NetworkMessage = Json.parse(data);

        trace(parsed.type, "parsed.type");

        switch(parsed.type) {
            case "connected":
                multiplayerClick(null);

            case "newGameId":
                leaveLobby();
                var n:ResponseNewGame = Json.parse(data);
                // trace(n);
                Global.networkGame = {
                    gameId: n.details.gameId,
                    otherPlayer: null,
                    title: "sdf",
                    ranked: 0,
                    lives: n.details.lives
                };
                Global.gameState.playerInfo[0].lives = n.details.lives;
                Global.gameState.playerInfo[1].lives = n.details.lives;
                // gameIdTF.text = "Code: " + n.details.gameId;
                sandboxClick(null);

            case "gameDetails":
                var gd:GameDetails = Json.parse(data);
                var n = gd.details;
                trace(n);
                Global.chatHolder.setUsers(n.player1, n.player2, n.spectators);

            case "joinedGame":
                var n:ResponseJoinedGame = Json.parse(data);
                
                pendingJoinGame(n);
                // startGame(true);

            case "playerJoined":
                var n:ResponseJoinedGame = Json.parse(data);
                ackPlayerJoined(n);
                startGame();

            case "joinAckReceived":
                var n:JoinAckReceived = Json.parse(data);
                trace("JOIN ACK RECEIVED");
                trace(n.details.gameId, Global.networkGame.gameId, "n.details.gameId, Global.networkGame.gameId");
                if (n.details.gameId == Global.networkGame.gameId)
                    startGame(true);
            
            case "playerDisconnect":
                var n:PlayerDisconnected = Json.parse(data);
                Global.networkToast.setText("Other player disconnected");
                backToHome(null);

            case "chatMsg":
                var n:ChatMsg = Json.parse(data);
                Global.chatHolder.addChat(n.details.username, n.details.message);

            case "toast":
                var n:NetworkToastType = Json.parse(data);
                Global.networkToast.setText(n.details.message);

            case "lobbyGames":
                var n:LobbyGameDetails = Json.parse(data);
                trace(n.details);
                gameBrowser.setGameList(n.details);

            case "playerLogin":
                // sloppy, but works
                if (this.usernameField.getValue() != "Username")
                    Browser.getLocalStorage().setItem("username", this.usernameField.getValue());
                
                if (this.passwordField.getValue() != "Password")
                    Browser.getLocalStorage().setItem("password", this.passwordField.getValue());

                var n:PlayerLoginType = Json.parse(data);
                trace(n);
                Global.playerToken = n.details.token;
                showMultiplayerMenu();

            case "lobbyChatMsg":
                var n:ChatMsg = Json.parse(data);
                lobbyChat.addChat(n.details.username, n.details.message);

            case "lobbyUsers":
                var n:{details:LobbyChatUsers} = Json.parse(data);
                trace(n);
                lobbyChat.setLobbyUsers(n.details.users);

            case "lobbyChatInfo":
                var n:LobbyChatInfo = Json.parse(data);
                trace(n);
                lobbyChat.setLobbyUsers(n.details.users);
                for (m in n.details.messages) {
                    lobbyChat.addChatStr(m);
                }

            default:
                trace("never heard of " + parsed.type);
        }
    }
}