package openNetwork.api;

import openfl.errors.Error;
import openfl.utils.ByteArray;

class Message {
    private var content:Array<Dynamic> = [];
    public var Type:String;
    public function new(type:String, ...args:Dynamic){
        this.Type = type;
        for(a in 0...args.length)
            trace("tried to call add function");
            // add(args[a]);
    }
    
    public function Add(...args:Dynamic){
        for(a in 0...args.length)
            trace("tried to call add function");
    }

    /* Data Getters */
    public function GetNumber(index:Int):Float{
        return cast(content[index], Float);
    }
    public function GetInt(index:Int):Int{
        return cast(content[index], Int);
    }
    public function GetString(index:Int):String{
        return content[index].toString();
    }
    public function GetBoolean(index:Int):Bool{
        return cast(content[index], Bool);
    }
    public function GetByteArray(index:Int):ByteArray{
        return cast(content[index], ByteArray);
    }
    
    public function Clone(to:Dynamic){
        for(a in 0...content.length){
            to.Add(content[a]);
        }
    }

    public function get_length():Int{
        return content.length;
    }
    
    public function toString():String{
        var ret:String = "Message\n";
        ret += "Type:\t\t" + Type + "\n";
        ret += "Length:\t\t" + get_length() + "\n";
        ret += "Content:\tId\tType\t\tValue\n";
        ret += "\t\t\t---------------------\n";
        for(a in 0...content.length){
            var ce:Dynamic = content[a];
            if(ce == null){
                ret += "\t\t\t"+a+"\tundefined\t\t" + ce + "\n";
            }else if(ce is String){
                ret += "\t\t\t"+a+"\tString\t\t" + ce + "\n";
            }else if(ce is Bool){
                ret += "\t\t\t"+a+"\tBoolean\t\t" + ce + "\n";
            }else{ 					
                var ta:ByteArray = new ByteArray();
                ta.writeInt(ce);
                ta.position = 0;
                if(ta.readInt() == ce){
                    ret += "\t\t\t"+a+"\tInt\t\t\t" + ce + "\n";
                    continue;
                }
                ret += "\t\t\t"+a+"\tNumber\t\t" + ce + "\n";
            }
        }
        return ret;
    }
}