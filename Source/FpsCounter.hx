package;
import openfl.display.FPS;
import openfl.display.Sprite;
import openfl.events.Event;
import openfl.text.TextField;
import openfl.text.TextFieldAutoSize;
import openfl.Lib.getTimer;

class FpsCounter extends Sprite
{		
    public static inline var DEFAULT_UPDATE_PERIOD:Int = 1000;
    
    private var frames:Int;
    private var timeBank:Int;
    private var lastTime:Int;
    
    private var tf:TextField;
    
    private var average:Float = -1;
    
    private var updatePeriod:Int;
    
    public function new(updatePeriod:Int = DEFAULT_UPDATE_PERIOD) 
    {
        super();
        
        this.updatePeriod = updatePeriod;
        
        this.frames = 0;
        
        this.lastTime = -1;
        this.timeBank = 0;
        
        this.tf = new TextField();
        this.tf.autoSize = TextFieldAutoSize.LEFT;
        this.tf.background = true;
        this.tf.backgroundColor = 0;
        this.tf.textColor = 0xFFFFFF;
        this.tf.selectable = false;
        this.tf.text = "-- FPS (-- avg)";
        
        this.addChild(this.tf);
        
        this.addEventListener(Event.ENTER_FRAME, onEnterFrame);
    }
    
    private function onEnterFrame(e:Event):Void
    {
        var time:Int = getTimer();
        
        if ( -1 != this.lastTime)
        {
            var timeDiff:Int = time - this.lastTime;
            
            this.timeBank += timeDiff;
            this.frames++;
            
            if (this.timeBank >= this.updatePeriod)
            {
                var fps = (1000 * (1 + this.frames)) / this.timeBank;
                
                this.frames = 0;
                this.timeBank -= this.updatePeriod;
                
                // Calc avg
                if (-1 != this.average)
                {
                    this.average += fps;
                    this.average /= 2;
                }
                else
                {
                    this.average = fps;
                }
                
                this.tf.text = Std.string(fps) + " FPS (" + Std.int(this.average) + " avg)";
            }
        }
        
        this.lastTime = time;
    }
}