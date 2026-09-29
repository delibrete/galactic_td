package;
import openfl.display.Bitmap;
import openfl.Vector;
import openfl.display.Sprite;
import openfl.events.MouseEvent;
import openfl.text.TextField;
import info.InfoBox;
import ToBitmapData.toBitmapData;

class PracticeButton extends Sprite
{
    private var left_:Sprite;
    private var right_:Sprite;
    
    private var choiceIndex_:Int = 0;
    
    private var names_:Array<String>;
    private var values_:Array<Dynamic>;
    
    private var tf_:TextField;
    
    private var width_:Int;
    
    public function new(names:Array<String>, values:Array<Dynamic>, width:Int) 
    {
        super();
        // [Embed(source = 'practiceButtonLeft.png')] const LEFT:Class;
        var practiceButtonLeftGfx = new Bitmap(toBitmapData("gfx/practiceButtonLeft.png"));
        // [Embed(source = 'practiceButtonRight.png')] const RIGHT:Class;
        var practiceButtonRightGfx = new Bitmap(toBitmapData("gfx/practiceButtonRight.png"));
        
        width_ = width;
        
        left_ = new Sprite();
        right_ = new Sprite();
        
        left_.addChild(practiceButtonLeftGfx);
        right_.addChild(practiceButtonRightGfx);
        
        left_.useHandCursor = left_.buttonMode = true;
        right_.useHandCursor = right_.buttonMode = true;
        
        right_.x = width - right_.width;
        
        addChild(left_);
        addChild(right_);
        
        left_.addEventListener(MouseEvent.CLICK, leftClick);
        right_.addEventListener(MouseEvent.CLICK, rightClick);
        
        names_ = names;
        values_ = values;
        
        tf_ = InfoBox.makeTF(12, true);
        displayChoice(choiceIndex_);
        
        addChild(tf_);
    }
    
    public function get_value():Dynamic
    {
        return values_[choiceIndex_];
    }
    
    private function leftClick(e:MouseEvent):Void
    {
        choiceIndex_--;
        if (choiceIndex_ < 0)	choiceIndex_ = names_.length - 1;
        
        displayChoice(choiceIndex_);
    }
    
    private function rightClick(e:MouseEvent):Void
    {
        choiceIndex_ = (choiceIndex_ +1) % names_.length;
        
        displayChoice(choiceIndex_);
    }
    
    private function displayChoice(index:Int):Void
    {
        tf_.text = names_[index];
        tf_.x = 0.5 * (width_ - tf_.width);
    }
    
}