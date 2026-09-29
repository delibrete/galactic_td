package network;

import openfl.events.Event;
import openfl.text.TextFormat;
import openfl.text.StyleSheet;
import openfl.display.Shape;
import openfl.geom.Rectangle;
import openfl.text.TextFieldAutoSize;
import openfl.text.TextField;
import openfl.display.Sprite;
import openfl.Lib.getTimer;

class NetworkDialog extends Sprite {
    private var tf:TextField;

    private var dots:Int = 0;

    private var str:String;
    private var frames = 0;

    public function new(str:String) {
        super();

        var textFormat = new TextFormat();
        textFormat.size = 28;

        this.tf = new TextField();
        this.tf.autoSize = TextFieldAutoSize.LEFT;
        this.tf.textColor = 0xFFFFFF;
        this.tf.selectable = false;
        this.tf.setTextFormat(textFormat);
        this.str = str;
        this.tf.text = this.str;

        var background = new Shape ();
        background.graphics.beginFill (0x000000, 0.5);
        background.graphics.drawRect (0, 0, Global.SCREEN_WIDTH, Global.SCREEN_HEIGHT);
        background.graphics.endFill ();
        this.addChild(background);
        
        this.addChild(this.tf);

        this.addEventListener(Event.ENTER_FRAME, onEnterFrame);
    }

    private function onEnterFrame(e:Event):Void
    {
        frames = frames + 1;
        if (frames >= 5) {
            dots++;

            if (dots > 3) {
                dots = 0;
            }

            var d = "";

            for (i in 0...dots) {
                d += ".";
            }
            
            this.tf.text = this.str + d;
            frames = 0;
        }
    }

    public function cleanup() {
        this.removeEventListener(Event.ENTER_FRAME, onEnterFrame);
    }
}