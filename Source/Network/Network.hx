package network;

import openfl.Vector;
import openfl.events.OutputProgressEvent;
import openfl.events.ProgressEvent;
import openfl.events.IOErrorEvent;
import openfl.events.Event;
import openfl.net.Socket;

class Network {
    private var socket:Socket;
    private var connected:Bool = false;
    private var lastData:String = "";

    private var dataVectorToSend:Vector<String>;
    private var expectFunctions:Vector<Void -> Void>;

    public function new() {        
        socket = new Socket();
        socket.addEventListener( Event.CONNECT, onConnect );
		socket.addEventListener( Event.CLOSE, onClose );
		socket.addEventListener( IOErrorEvent.IO_ERROR, onError );
        socket.addEventListener(ProgressEvent.PROGRESS, progressHandler);
        socket.addEventListener(ProgressEvent.SOCKET_DATA, dataHandler);
        // socket.connect(new sys.net.Host("localhost"), 1337);
        dataVectorToSend = new Vector<String>();
        expectFunctions = new Vector<Void -> Void>();
    }

    public function connect():Void {
        socket.connect("wss://127.0.0.1", 1337); //TODO: set the server and port to a variable
    }

    public function disconnect():Void {
        if (connected)
            socket.close();
    }

    public function listen(handler:String -> Void):Void {
        if (connected) { 
            if (socket.bytesAvailable > 0) {
                // var data = socket.input.readLine();
                var data = socket.readUTFBytes(socket.bytesAvailable);
                trace("received from server:", data);
                handler(data);
                // this.socket.flush();

                if (dataVectorToSend.length > 0)
                    send(dataVectorToSend.pop());
            }
        }
    }

    private function onConnect( e:Event ) : Void
    {
        trace( "Socket connected" );
        connected = true;

        // just send whatever we're waiting for
        // this.socket.writeUTFBytes(lastData);
        // this.socket.flush();
        // lastData = "";
    }

    private function onClose( e:Event ) : Void
    {
        trace( "Socket closed" );
        connected = false;
    }

    private function progressHandler(e:Event): Void
    {
        trace("progress", e);
    }

    private function dataHandler(e:Event): Void
    {
        trace("dataHandler", e);
    }

    private function onError( e:Event ) : Void
    {
        trace( "Socket error" );
    }

    public function sendAndExpect(data:String, promise:Void -> Void):Void {
        // trace("Global.playerToken", Global.playerToken);
        trace("trying to send", data, socket.bytesPending);

        // we're still waiting for something, park the request until the other one is done
        if (socket.bytesPending > 0) {
            trace("waiting for something else to finish, will send soon");
            dataVectorToSend.push(data);
            // expectFunctions.push(promise);
            return;
        }

        var dataToSend = data + "|" + Global.playerToken;
        lastData = dataToSend;

        if (!connected) {
            connect();
        } else {
            this.socket.writeUTFBytes(dataToSend);
            // this.socket.flush();
            lastData = "";
        }
    }

    public function send(data:String):Void {
        // sendAndExpect(data, ()->{});

        // trace("Global.playerToken", Global.playerToken);
        trace("trying to send", data, socket.bytesPending);

        // we're still waiting for something, park the request until the other one is done
        if (socket.bytesPending > 0) {
            trace("waiting for something else to finish, will send soon");
            dataVectorToSend.push(data);
            return;
        }

        var dataToSend = data + "|" + Global.playerToken;
        lastData = dataToSend;

        if (!connected) {
            connect();
        } else {
            this.socket.writeUTFBytes(dataToSend);
            // this.socket.flush();
            lastData = "";
        }
    }

    public function isConnected():Bool {
        return connected;
    }
}