package lobby; 
// import Editor.EditSection;
import haxe.Json;
import game.GameData;
import gamestate.GameState;
import openNetwork.api.Message;
import openfl.utils.Assets;
import wait.WaitSection;
import openfl.display.*;
// import Game.GameData;
// import Messages.MessageQueue;
import openNetwork.api.Connection;
// import Wait.WaitSection;
import network.Network;

class LobbySection implements IGameSection
{
    private var nextSection_:IGameSection;
    private var holder_:Sprite;
    private var connection_:Connection;

    private var trigger:Bool = true;
    
    public function new() 
    {
        holder_ = new Sprite();
        nextSection_ = this;
        
        // Global.connection = connection_;
        
        // Global.messages = new MessageQueue(connection_);

        // MY_CODE
        // initialiseGameData();

        // Global.gameState = new GameState();
    }
    
    public function update():IGameSection
    {
        // trace("in here" + openfl.Lib.getTimer());
        // Wait for the "hello" message
        // if (0 != Global.messages.length)
        if (trigger == true)
        {
            // var m:* = Global.messages.shift();
            // if ("hello" == m.Type)
            // {
                // connection_.Send("hello");
                WaitSection.Message2GameData(Global.gameState); //TODO: Do we need this?
                // nextSection_ = new WaitSection(connection_, Global.messages, null, "Waiting for another player to join the game...", true);
                // nextSection_ = new WaitSection(connection_, Global.messages, null, "Waiting for another player to join the game...", true);
                nextSection_ = new WaitSection(new GameData());
            // }

            trigger = false;
        }
        
        return nextSection_;
    }

    public function draw() {}
    
    public function getGraphic():DisplayObject { return holder_; }

    public function networkHandler(data:String):Void {
        trace("wait");
        trace("received from server:");
        trace(data);

        var hello = {
            "type": "hello",
            "details": "yo"
        }

        trace(Json.stringify(hello));

        Global.network.send(Json.stringify(hello));
    }
}