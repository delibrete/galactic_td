package ui;

import openfl.events.KeyboardEvent;
import openfl.events.Event;
import openfl.events.MouseEvent;
import openfl.display.Shape;
import openfl.text.TextFormat;
import openfl.text.TextFieldAutoSize;
import openfl.text.TextField;
import openfl.display.Sprite;

class InputTextField extends Sprite {
    private var tf:TextField;
    private var firstSelection:Bool = false;
    private var text:String = "";

    public function new(placeholderText:String, x:Int = 0, y:Int = 0, width:Int = 100, fontSize:Int = 18, password:Bool = false) {
        super();

        var textFormat = new TextFormat(); //TODO: fix font size bug
        textFormat.size = fontSize;

        this.x = x;
        this.y = y;

        this.tf = new TextField();
        this.tf.textColor = 0xFFFFFF;
        this.tf.type = "input";
        this.tf.border = true;
        this.tf.borderColor = 0xFFFF00;
        this.tf.width = width;
        this.tf.height = fontSize;
        this.tf.selectable = true;

        if (password == true) {
            this.tf.displayAsPassword = true;
        }

        this.tf.text = placeholderText;

        // var background = new Shape ();
        // background.graphics.beginFill(0xFFFFFF, 1);
        // background.graphics.drawRect(0, 0, width, fontSize);
        // background.graphics.endFill();
        // this.addChild(background);
        
        this.addChild(this.tf);

        var onClick = (e:Event) -> {
            if (!firstSelection) {
                this.tf.text = "";
                firstSelection = true;
            }
        }

        var onEnter = (e:KeyboardEvent) -> {
            if (!firstSelection) {
                this.tf.text = "";
                firstSelection = true;
            }
        }

        this.addEventListener(MouseEvent.CLICK, onClick);
        this.addEventListener(KeyboardEvent.KEY_UP, onEnter);
    }

    public function getValue():String {
        return this.tf.text;
    }
}