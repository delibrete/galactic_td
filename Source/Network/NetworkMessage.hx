package network;

import towers.TowerBase.NetworkTowerMessage;

typedef NetworkMessage = {
    var type:String;
}

typedef NetworkToastMessage = {
    var message:String;
}

typedef GetPlayerToken = {
    var token: String;
}

typedef NewGameDetails = {
    var gameId:String;
    var lives:Int;
}

typedef JoinAckReceived = {
    var details:NewGameDetails;
}

typedef JoinedGame = NewGameDetails & {
    var otherPlayer:String;
    var lives:Int;
    var title:String;
    var ranked:Int;
    // var spectator:Bool;
}

typedef LobbyGame = {
    var gameId:String;
    var title:String;
    var lives:Int;
    var username:String;
    var rating:Int;
}

typedef ChatMsg = {
    var details:{
        username:String,
        message:String
    }
}

typedef LobbyGameDetails = {
    var details:Array<LobbyGame>;
}

typedef LobbyChatInfo = {
    var details:LobbyChatInfoDetails;
}

typedef LobbyChatUsers = {
    var users:Array<String>;
}

typedef LobbyChatInfoDetails = LobbyChatUsers & {
    var messages:Array<String>;
}

typedef ResponseTowers = {
    var towers:Array<NetworkTowerMessage>;
    var extra:Int;
}

typedef ResponseNewGame = {
    var type:String;
    var details:NewGameDetails;
}

typedef ResponseJoinedGame = {
    var type:String;
    var details:JoinedGame;
}

typedef PlayerDisconnected = {
    var type:String;
    var details:NewGameDetails;
}

typedef NetworkToastType = NetworkMessage & {
    var details:NetworkToastMessage;
}

typedef PlayerLoginType = NetworkMessage & {
    var details: GetPlayerToken;
}

// typedef Game = NewGameDetails & {
//     var player1:String;
//     var player2:String;
// }

typedef ResponseReceivedTowers = {
    var type:String;
    var details:ResponseTowers;
}

typedef Game = JoinedGame;

typedef Player = {
    var username: String;
    var rating: Int;
}

typedef GameDetails = {
    details: GamePlayers
}

typedef GamePlayers = {
    var player1: Player;
    var player2: Player;
    var spectators: Array<Player>;
}

// typedef Login = {
//     var username:String;
//     var password:String;
// }