package network;

import openfl.display.Shape;
import openfl.text.TextField;
import openfl.display.Sprite;

class NetworkToast extends Sprite {
    private var tf:TextField;
    private var _alpha:Float = 0;

    public function new() {
        super();

        this.x = 225;
        this.y = 450;

        var background = new Shape();
        background.graphics.beginFill(0xFFFFFF, 0.66);
        background.graphics.drawRoundRect(0, 0, 250, 50, 10);
        background.graphics.endFill();
        this.addChild(background);

        this.tf = new TextField();
        this.tf.width = 250;
        this.tf.height = 50;
        this.addChild(this.tf);
    }

    public function setText(str:String) {
        this.y = 450;
        this._alpha = 2;

        this.tf.text = str;
    }

    public function update() {
        if (this._alpha > 0) {
            this._alpha = this._alpha - (1/100);
            this.alpha = this._alpha;
        } else {
            this.y = 1000;
        }
    }
}