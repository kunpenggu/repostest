var wsServer = "ws://127.0.0.1:8088/"
var websocket = null;
function connect(){
    websocket = new WebSocket(wsServer, "echo-protocol");

    websocket.onopen = function(event){
        console.log("Web Socket Connected.");
	websocket.send("Hello, Git.");
    }

    websocket.onclose = function(event){
    	console.log("Web Socket Closed.");
	websocket.close();
    }

    websocket.onmessage = function(event){
    	console.log("Web Socket Received Messages.\n");
	console.log(event.data);
    }

    websocket.onerror = function(event){
    	console.log("Web Socket Error.\n");
    	console.log(event.data);
    }
}
