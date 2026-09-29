package openNetwork.api;

import openfl.Vector;
import openfl.events.EventDispatcher;
import openfl.events.Event;
import openNetwork.api.ConnectionEvent;

class Connection extends EventDispatcher{
    private var p:Dynamic = null;
    private var queue:Vector<Event>;

    function new(){
        super();
        addEventListener(ConnectionEvent.INIT, emptyQueue);
    }

    public function Send(...args:Dynamic):Void{
        trace("Send");
        // if(p != null && p.Initialized == true){
        //     p.Send.apply(p, args);
        // }else queue.push(function(){Send.apply(this, args)})
    }
    
    public function emptyQueue(e:Event):Void{
        trace("emptyQueue");
        // for(i in 0...queue.length)
        //     queue[i]();
        // queue = [];
    }

    public function get_Initialized():Bool{
        return false;
    }

    public function set_proxy(p:Dynamic):Void{
        this.p = p;
    }
}
