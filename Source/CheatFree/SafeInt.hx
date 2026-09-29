package cheatFree; 
import openfl.display.BitmapData;
import openfl.utils.ByteArray;

final class SafeInt 
{
    public static final LENGTH:Int = 5000;
    private static var data_:ByteArray;
    
    private var val_:Int;
    private var coVal_:Int;
    
    public function new(defaultVal:Int = 0) 
    {
        if (data_ == null)
        {
            // trace("Generating reklek");
            data_ = new ByteArray();
            data_.length = LENGTH;
            for (i in 0...LENGTH)
            {
                data_[i] = Math.floor(Math.random() * 255);
            }
        }
        
        val_ = defaultVal;
    }
    
    private function getIndex():Int
    {
        return val_ % data_.length;
    }
    
    private function check():Bool
    {
        return coVal_ == data_[getIndex()];
    }
    
    public function get_val():Int
    {
        if (!check())
        {
            Global.cheater = true;
        }
        
        return val_;
    }
    
    public function set_val(v:Int):Void
    {
        val_ = v;
        // coVal_ = data_[getIndex()]; //TODO: Maybe fix this
        
        //trace("val:", val_, "\tcoVal:", coVal_);
    }
    
}