package;
import network.NetworkMessage.NewGameDetails;
import network.NetworkToast;
import openfl.display.Sprite;
import network.NetworkMessage.Game;
import network.Network;
import network.Chat;
import gamestate.GameState;
import openfl.display.Stage;
// import Messages.MessageQueue;

class Global
{
    public static final SCREEN_WIDTH:Int = 700;
    public static final SCREEN_HEIGHT:Int = 540;
    
    public static final UPDATE_LENGTH:Int = 20;
    public static final UPDATE_SECS:Float = UPDATE_LENGTH / 1000.0;
    public static final MAX_FRAME_DELTA:Int = 200;
    
    // public static var messages:MessageQueue;
    
    public static var userId:Int = -1;
    
    public static var stage:Stage;
    
    public static var cheater:Bool = false;
    
    // public static var connection:Connection;

    public static var simulation:Bool = false;

    public static var practiceSandboxMode:Bool = false;

    public static var fast:Bool = false;

    public static var state:String = "wait";

    public static var gameState:GameState;

    public static var waitHolder:Sprite;

    public static var chatHolder:Chat;

    // Network Related Globals
    public static var network:Network;

    public static var networkGame:Game;

    public static var networkToast:NetworkToast;

    public static var sentTowers:Bool = false;
    
    public static var receivedTowers:Bool = false;
    public static var ackReceivedTowers:Bool = false;

    public static var playerToken:String = "";

    public static var gameOver:Bool = false;
    public static var weWon:Bool = false;
    public static var draw:Bool = false;
    public static var readyForNextRound:Bool = false;
    public static var opponentReadyForNextRound:Bool = false;

    public static var resetAll:Bool = false;

    public static function resetGlobal(clearStage:Bool = false) {
        Main.toggleWait(false);
        Global.simulation = false;
        Global.practiceSandboxMode = false;

        Global.gameState = new GameState();

        // TODO: allow custom setup
        Global.gameState.gameId = "123";
        Global.gameState.buildSeconds = 50; // Setup.GetInteger("roundTime");
        Global.gameState.extraAllowed = 20; // Setup.GetInteger("extra");
        Global.gameState.playerInfo[0].lives = 20; // gameState.playerInfo[1].lives = int.Parse(Setup.GetOption("lives"));
        // Global.gameState.playerInfo[1].points = 0;
        Global.gameState.allowRecording[0] = false;// gameState.allowRecording[1] = true;
        Global.gameState.fastMode = false; //Setup.GetBoolean("fast");

        Global.stage = clearStage ? null : Global.stage;

        Global.sentTowers = false;
        Global.receivedTowers = false;
        Global.ackReceivedTowers = false;
        Global.gameOver = false;
        Global.weWon = false;
        Global.draw = false;
        Global.readyForNextRound = false;
        Global.opponentReadyForNextRound = false;

        // Global.chatHolder = new Chat();
        // Global.chatHolder.setVisibility(false);
    }
}