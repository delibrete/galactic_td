package network;

import haxe.Json;
import network.NetworkMessage.LobbyGame;
import network.NetworkMessage.Game;
import network.NetworkMessage.Player;
import openfl.events.KeyboardEvent;
import openfl.events.MouseEvent;
import openfl.events.Event;
import openfl.Vector;
import openfl.text.TextFormat;
import openfl.text.TextField;
import openfl.display.Shape;
import openfl.display.Sprite;

class GameEntry extends Sprite {

    private var title:TextField;
    private var username:TextField;
    private var lives:TextField;
    private var joinButton:CustomButton;
    private var gameId:String;
    private var _joinGameFunction:String -> Void;

    // private var ranked:TextField;

    public function new(game:LobbyGame, dx:Float, dy:Float, joinGameFunction:String -> Void) {
        super();

        var width = 350;
        var halfWidth = width/2;
        var height = 50;
        _joinGameFunction = joinGameFunction;

        var firstQtrScreenX = (0.25 * Global.SCREEN_WIDTH);

        var centerX = firstQtrScreenX - halfWidth;

        this.x = 0;
        this.y = 0;

        var padding = 4;

        var background = new Shape();
        background.graphics.beginFill (0x003355, 1);
        background.graphics.lineStyle(1, 0x0099FF);
        background.graphics.drawRoundRect(dx+padding, dy+padding, width - 32 - (padding*2), height - (padding), 10);
        background.graphics.endFill();

        this.addChild(background);

        title = new TextField();
        title.width = 90;
        title.x = dx + 8;
        title.y = dy + 15;
        title.defaultTextFormat = new TextFormat(null, null, 0xFFFFFF);
        title.selectable = false;
        title.text = game.title;

        username = new TextField();
        username.width = 50;
        username.height = 100;
        username.x = dx + 100 + 8;
        username.y = dy + 15;
        username.defaultTextFormat = new TextFormat(null, null, 0xFFFFFF);
        username.selectable = false;
        username.text = game.username;

        lives = new TextField();
        lives.width = 50;
        lives.height = 100;
        lives.x = dx + 178 + 8;
        lives.y = dy + 15;
        lives.defaultTextFormat = new TextFormat(null, null, 0xFFFFFF);
        lives.selectable = false;
        lives.text = Std.string(game.lives);

        joinButton = new CustomButton("Join", 75, 0xFFFF00);
        joinButton.x = dx + 225;
        joinButton.y = dy + 13;
        joinButton.addEventListener(MouseEvent.CLICK, buttonClick);

        gameId = game.gameId;

        this.addChild(title);
        this.addChild(username);
        this.addChild(lives);
        this.addChild(joinButton);
    }

    // public function render() {
 
    // }

    // public function update() {

    // }

    private function buttonClick(e:MouseEvent) {
        // trace(e);
        _joinGameFunction(this.gameId);
    }


    public function setVisibility(visible:Bool = false) {
        this.visible = visible;
    }
}