package openNetwork.api;

import openfl.events.Event;
import openNetwork.api.Message;

class ConnectionEvent extends Event{
    public static final INIT:String 		= "onInit";
    public static final DISCONNECT:String 	= "onDisconnect";
    public static final FAILED:String 		= "onFail";
    public var Description:String = "";
    public var Title:String = "";
    
    function new(type:String, title:String = "", description:String = ""){
        
        this.Title = title;
        this.Description = description;
        super(type);
    }
    public override function clone():Event {
            return new ConnectionEvent(type);
    }
}