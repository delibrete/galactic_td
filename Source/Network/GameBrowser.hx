package network;

import network.NetworkMessage.LobbyGame;
import haxe.Json;
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

class GameBrowser extends Sprite {

    private var gamesList:Vector<LobbyGame>;
    private var scrollList:Vector<LobbyGame>;
    private var gamesListRender:Sprite;

    private var browserTopCursor = 0;
    private var browserBottomCursor = 0;

    private var tempTimer:Float = 0;

    var _width = 350;
    var boxX = 16;
    var boxY = 160;
    var boxWidth = 350 - 32;
    var boxHeight = Global.SCREEN_HEIGHT - 186;

    // scrollbar stuff, should really be in its own class...
    var scrollBarBackground:Shape;
    var scrollBar:Shape;
    var holdingScrollBar:Bool = false;
    var heldMouseStartY:Float = 0;
    var heldMouseDeltaY:Float = 0;
    var scrollIncrement:Float = 0;
    var scrollVisible:Bool = false;

    // var randomNums = [14,13,18,17,19,12,15,17,20,16];
    // var randomNum = 0;

    var refreshMaxTime = 10;
    var refreshBar:Shape;
    var refreshBarColour:Int = 0xFFFB00;

    var headerBar:TextField;

    private var _joinGameFunction:String -> Void;

    public function new(joinGameFunction:String -> Void) {
        super();

        var halfWidth = _width/2;

        var firstQtrScreenX = (0.25 * Global.SCREEN_WIDTH);

        var centerX = firstQtrScreenX - halfWidth;

        _joinGameFunction = joinGameFunction;

        this.x = 0;
        this.y = 0;

        var background = new Shape();
        background.graphics.beginFill (0xFFFFFF, 0.25);
        background.graphics.lineStyle(1, 0xFFFFFF);
        background.graphics.drawRoundRect (boxX, boxY, boxWidth, boxHeight, 10);
        background.graphics.endFill();

        this.gamesList = new Vector<LobbyGame>();

        gamesListRender = new Sprite();

        scrollBarBackground = new Shape();
        scrollBarBackground.graphics.beginFill (0xFFFFFF, 0.25);
        scrollBarBackground.graphics.lineStyle(1, 0xFFFFFF);
        scrollBarBackground.graphics.drawRect(boxX + boxWidth + 6, boxY, 10, boxHeight);
        scrollBarBackground.graphics.endFill();

        scrollBar = new Shape();
        scrollBar.x = boxX + boxWidth + 6;
        scrollBar.y = boxY;
        scrollBar.graphics.beginFill (0xFFFFFF, 1);
        scrollBar.graphics.lineStyle(1, 0xFFFFFF);
        scrollBar.graphics.drawRect(0, 0, 10, boxHeight * (7 / gamesList.length));
        scrollBar.graphics.endFill();
        scrollVisible = false;
        scrollBar.visible = scrollVisible;
        scrollBarBackground.visible = scrollVisible;

        refreshBar = new Shape();
        refreshBar.x = boxX+5;
        refreshBar.y = boxY;
        refreshBar.graphics.beginFill (refreshBarColour, 1);
        refreshBar.graphics.lineStyle(1, refreshBarColour);
        refreshBar.graphics.drawRect(0, 0, boxWidth-5, 1);
        refreshBar.graphics.endFill();

        headerBar = new TextField();
        headerBar.x = boxX;
        headerBar.y = boxY - 20;
        headerBar.width = boxWidth;
        headerBar.defaultTextFormat = new TextFormat(null, null, 0xFFFFFF);
        headerBar.selectable = false;
        headerBar.text = "Title                             User                Lives";
        this.addChild(headerBar);

        this.addChild(background);

        this.addChild(gamesListRender);

        this.addChild(scrollBarBackground);

        this.addChild(scrollBar);

        this.addChild(refreshBar);

        this.addEventListener(MouseEvent.MOUSE_WHEEL, mouseScroll);

        this.addEventListener(MouseEvent.MOUSE_MOVE, mouseMove);

        this.addEventListener(MouseEvent.MOUSE_DOWN, mouseDown);

        this.addEventListener(MouseEvent.MOUSE_UP, mouseUp);

        var remainder = gamesList.length - 7;
        scrollIncrement = (((1-(7/gamesList.length)) * boxHeight) / remainder);
    }

    public function render() {
        this.gamesListRender.removeChildren();
        var i = 0;

        for (j in browserTopCursor ... (browserTopCursor + 7)) {
            if (j < this.gamesList.length) { 
                var g = this.gamesList[j];

                var offsetY = (50 * i);

                this.gamesListRender.addChild(new GameEntry(g, boxX, boxY + offsetY, _joinGameFunction));

                i++;
            }
        }
    }

    public function update() {
        // render();
        tempTimer -= Global.UPDATE_SECS;

        // refresh bar
        refreshBar.graphics.clear();
        refreshBar.graphics.beginFill (refreshBarColour, 1);
        refreshBar.graphics.lineStyle(1, refreshBarColour);
        refreshBar.graphics.drawRect(0, 0, (boxWidth-5) * (tempTimer / refreshMaxTime), 1);
        refreshBar.graphics.endFill();

        if (tempTimer <= 0) {
            if (Global.network.isConnected()) {    
                var getGames = {
                    "type": "getGames",
                    "details": {}
                };
                Global.network.send(Json.stringify(getGames));
            }
    
            tempTimer = refreshMaxTime;
        }

        // browserTopCursor += cast(tempTimer, Int);

        // trace(browserTopCursor);

        // gamesListRender.y -= 10 * Global.UPDATE_SECS;
    }

    private function mouseScroll(e: MouseEvent) {
        if (scrollVisible) {
            var scroll = (e.delta < 0) ? 1 : -1;

            browserTopCursor += scroll;

            var boundaryCheck = gamesList.length - browserTopCursor;

            if (boundaryCheck >= 7 && boundaryCheck <= gamesList.length) {
                scrollBar.y += scroll * scrollIncrement;
            }

            if (browserTopCursor < 0)
                browserTopCursor = 0;

            if (browserTopCursor >= (gamesList.length - 7))
                browserTopCursor = (gamesList.length - 7);

            render();
        }
    }

    private function mouseDown(e: MouseEvent) {
        if(scrollVisible && pointInBox(mouseX, mouseY, scrollBar.x, scrollBar.y, 10, boxHeight * (7 / gamesList.length)))
            holdingScrollBar = true;
    }

    private function mouseUp(e: MouseEvent) {
        holdingScrollBar = false;
    }

    private function mouseMove(e: MouseEvent) {
        if (scrollVisible && holdingScrollBar) {
            heldMouseDeltaY = (heldMouseStartY - mouseY);

            var remainder = gamesList.length - 7;
            var boundaryCheck = gamesList.length - browserTopCursor;

            // move down
            if (heldMouseDeltaY < -scrollIncrement && (boundaryCheck > 7 && boundaryCheck <= gamesList.length)) {
                browserTopCursor++;
                scrollBar.y += 1 * (((1-(7/gamesList.length)) * boxHeight) / remainder);
                heldMouseStartY = mouseY;
            }

            // move up
            if (heldMouseDeltaY > scrollIncrement && (boundaryCheck >= 7 && boundaryCheck < gamesList.length)) {
                browserTopCursor--;
                scrollBar.y += -1 * (((1-(7/gamesList.length)) * boxHeight) / remainder);
                heldMouseStartY = mouseY;
            }

            if (browserTopCursor < 0)
                browserTopCursor = 0;
    
            if (browserTopCursor >= (gamesList.length - 7))
                browserTopCursor = (gamesList.length - 7);

            render();
        }
    }

    private function pointInBox(px:Float, py:Float, bx:Float, by:Float, bw:Float, bh:Float) {
        return (px > bx && px < bx+bw && py > by && py < by+bh);
    }

    private function addGameToList(game:LobbyGame) {
        this.gamesList.push(game);

        var remainder = gamesList.length - 7;
        scrollIncrement = (((1-(7/gamesList.length)) * boxHeight) / remainder);
        browserTopCursor = 0;

        scrollBar.y = boxY;
        scrollBar.graphics.clear();
        scrollBar.graphics.beginFill (0xFFFFFF, 1);
        scrollBar.graphics.lineStyle(1, 0xFFFFFF);
        scrollBar.graphics.drawRect(0, 0, 10, boxHeight * (7 / gamesList.length));
        scrollBar.graphics.endFill();

        if (gamesList.length <= 7) {
            scrollVisible = false;
        } else {
            scrollVisible = true;
        }

        scrollBar.visible = scrollVisible;
        scrollBarBackground.visible = scrollVisible;

        render();
    }

    public function setGameList(games:Array<LobbyGame>) {
        this.gamesList = new Vector<LobbyGame>();
        scrollVisible = false;
        scrollBar.visible = scrollVisible;
        scrollBarBackground.visible = scrollVisible;

        for (g in games) {
            addGameToList(g);
        }
    }

    public function setVisibility(visible:Bool = false) {
        this.visible = visible;
    }
}