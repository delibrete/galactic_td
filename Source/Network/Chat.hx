package network;

import haxe.Json;
import network.NetworkMessage.Player;
import openfl.events.KeyboardEvent;
import openfl.events.MouseEvent;
import openfl.events.Event;
import openfl.Vector;
import openfl.text.TextFormat;
import openfl.text.TextField;
import openfl.display.Shape;
import openfl.display.Sprite;

// it's probably a bad idea to handle the normal chat and lobby chat logic in one file but here we are
class Chat extends Sprite {

    private var chatLog:TextField;
    private var users:TextField;
    private var usersList:Vector<String>;
    private var chatBox:TextField;
    
    private var focused:Bool = false;
    private var changed:Bool = false;
    private var _isLobby:Bool = false;

    public function new(isLobby:Bool = false) {
        super();

        var chatX:Float = 0;
        var chatY:Float = 0;
        var chatWidth:Float = 0;
        var chatHeight:Float = 0;
        var usersLine:Float = 0;
        var chatLine:Float = 0;
        var userX:Float = 0;
        var userY:Float = 0;
        var userWidth:Float = 0;
        var userHeight:Float = 0;

        if (!isLobby) {
            chatX = 500;
            chatWidth = 200;
            chatHeight = Global.SCREEN_HEIGHT;
            usersLine = 50;
            chatLine = 520;
            userWidth = chatWidth;
        } else {
            chatX = (0.5 * Global.SCREEN_WIDTH) + 16;
            // chatY = 250 - 16; // when ranked is added
            chatY = 50 - 16;
            chatWidth = (0.5 * Global.SCREEN_WIDTH) - 32;
            // chatHeight = 250; // when ranked is added
            chatHeight = 450;
            usersLine = chatHeight;
            chatLine = chatHeight - 20;
            userWidth = 100;
            userX = chatWidth - userWidth;
        }

        this.x = chatX;
        this.y = chatY;

        // background
        var background = new Shape();
        background.graphics.beginFill (0xFFFFFF, 0.66);
        background.graphics.lineStyle(1, 0xFFFFFF);
        background.graphics.drawRoundRect (0, 0, chatWidth, chatHeight, 10);
        background.graphics.endFill();
        
        // users list
        background.graphics.beginFill (0xFFFFFF, 1);
        if (isLobby) {
            background.graphics.drawRect(userX, 0, 1, chatHeight);
        } else {
            background.graphics.drawRect(userX, usersLine, chatWidth, 1);
        }
        background.graphics.endFill();

        // chat list
        background.graphics.beginFill (0xFFFFFF, 1);
        if (isLobby) {
            background.graphics.drawRect(0, chatLine, userX, 1);
        } else {
            background.graphics.drawRect(0, chatLine, chatWidth, 1);
        }
        background.graphics.endFill();

        this.addChild(background);

        users = new TextField();
        users.x = userX;
        users.y = 0;
        users.defaultTextFormat = new TextFormat(null, null, 0x000000);
        users.width = userWidth;
        if (isLobby) {
            users.width = userWidth;
        } else {
            users.width = chatWidth;
        }
        users.height = chatHeight;

        this.usersList = new Vector<String>();

        this.addChild(users);

        chatLog = new TextField();
        chatLog.x = 0;
        if (isLobby) {
            chatLog.y = 0;
            chatLog.width = userX;
        } else {
            chatLog.y = usersLine;
            chatLog.width = chatWidth;
        }
        // chatLog.height = chatLine - 14;
        if (isLobby) {
            chatLog.height = chatLine;
        } else {
            chatLog.height = chatLine - usersLine;
        }
        chatLog.defaultTextFormat = new TextFormat(null, null, 0x000000);
        chatLog.wordWrap = true;

        this.addChild(chatLog);

        chatBox = new TextField();
        chatBox.y = chatLine;
        chatBox.textColor = 0x000000;
        chatBox.type = "input";
        // chatBox.border = true;
        // chatBox.borderColor = 0x000000;
        if (isLobby) {
            chatBox.width = userX;
        } else {
            chatBox.width = chatWidth;
        }
        chatBox.height = 14;
        chatBox.selectable = true;
        chatBox.text = "Enter chat message...";

        var onClick = (e:MouseEvent) -> {
            if (e.localX  > 0 && e.localX < chatBox.width && e.localY > 0 && e.localY < chatBox.height) {
                trace("here2");

                // clicked, remove text
                //  but dont remove text if there's text in there
                //  unless it hasnt been changed yet

                focused = true;

                if (changed == false) {
                    chatBox.text = "";
                    changed = true;
                } 
                
                // haxe made me do this
                // if (changed == true) {
                //     chatBox.text = "Enter chat message...";
                // }

            } else {
                if (chatBox.text.length == 0) {
                    chatBox.text = "Enter chat message...";
                    changed = false;
                }

                focused = false;
            }
        }

        var onEnter = (e:KeyboardEvent) -> {
            if (focused == true) {
                changed = true;
                if (e.keyCode == 13) {
                    if (Global.network.isConnected()) {
                        if (isLobby) {
                            var sendLobbyChat = {
                                "type": "sendChatLobby",
                                "details": {
                                    "msg": chatBox.text
                                }
                            };
                            Global.network.send(Json.stringify(sendLobbyChat));
                        } else {
                            var sendChat = {
                                "type": "sendChat",
                                "details": {
                                    "gameId": Global.networkGame.gameId,
                                    "msg": chatBox.text
                                }
                            };
                            Global.network.send(Json.stringify(sendChat));
                        }
                    }

                    chatBox.text = "Enter chat message...";
                    stage.focus = null;
                    changed = false;
                    focused = false;
                }

                if (chatBox.text.length == 0) {
                    changed = false;
                }
            }
        }

        this.addEventListener(MouseEvent.CLICK, onClick);
        this.addEventListener(KeyboardEvent.KEY_DOWN, onEnter);

        this.addChild(chatBox);
    }

    public function addChat(user:String, str:String, col:Int = 0x000000):Void {
        this.chatLog.textColor = col;
        this.chatLog.appendText("<" + user + "> " + str + "\n");
        this.chatLog.scrollV = this.chatLog.maxScrollV;
    }

    public function addChatStr(str:String, col:Int = 0x000000):Void {
        this.chatLog.textColor = col;
        this.chatLog.appendText(str + "\n");
        this.chatLog.scrollV = this.chatLog.maxScrollV;
    }

    public function addUserString(str:String):Void {
        this.usersList.push(str);

        this.users.text = "";

        for (u in this.usersList) {
            this.users.appendText(u + "\n");
        }
        this.users.scrollV = this.users.maxScrollV;
    }

    public function setLobbyUsers(lobbyUsers:Array<String>):Void {
        this.users.text = "";
        this.usersList = new Vector<String>();

        for (u in lobbyUsers) {
            this.usersList.push(u);
            this.users.appendText(u + "\n");
        }
        this.users.scrollV = this.users.maxScrollV;
    }

    public function setUsers(player1:Player, player2:Player, spectators:Array<Player>):Void {
        trace(player1);
        trace(player2);
        trace(spectators);
        this.users.text = "";
        this.usersList = new Vector<String>();

        if (player1 != null) {
            this.usersList.push("(1) " + player1.username);
        }

        if (player2 != null) {
            this.usersList.push("(2) " + player2.username);
        }

        if (spectators != null) {
            for (s in spectators) {
                this.usersList.push("(spec) " + s.username);
            }
        }

        for (u in this.usersList) {
            this.users.appendText(u + "\n");
        }

        this.users.scrollV = this.users.maxScrollV;

        trace("finished adding users");
    }

    public function setVisibility(visible:Bool = false) {
        this.visible = visible;
        trace(this.visible);
    }

    public function reset() {
        this.chatLog.text = "";
        this.usersList = new Vector<String>();
        this.users.text = "";
    }
}