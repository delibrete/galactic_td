# Local Python server

A small Python rewrite of the server code for local development. Requires Python 3.10+.
It listens at **ws://127.0.0.1:1337**.

## Run

From the repository root:

```sh
cd Server
python -m pip install -r requirements.txt
python server.py
```

Optionally create and activate a virtual environment before installing dependencies.
Stop with Ctrl+C. To choose another port, run `python server.py --port 1338`.
Point your game client's WebSocket URL at the address above.

## Local data

`local.db` is created automatically beside `server.py`, regardless of the working directory.
Accounts, login tokens, and the last lobby messages survive restarts. Games and connected
lobby users are kept in memory. Stop the server and delete `local.db` to reset everything.
Passwords use Python's built-in scrypt hashing, avoiding an extra bcrypt dependency.
Logging in again replaces that account's previous token.

## Messages

Send a JSON object followed by `|token`.
Registration and login also accept plain JSON without a token. Responses are plain JSON.

```text
{"type":"newAccount","details":{"username":"Alice","password":"test123"}}
{"type":"login","details":{"username":"Alice","password":"test123"}}
```

Both return `{"type":"playerLogin","details":{"token":"..."}}` on success.
Use that token on subsequent requests:

```text
{"type":"newGame","details":{"lives":3}}|YOUR_TOKEN
{"type":"getGames","details":{}}|YOUR_TOKEN
{"type":"joinGame","details":{"gameId":"GAME_ID"}}|OTHER_PLAYER_TOKEN
```

Use two WebSocket connections and two accounts to test a game.

| Request | Details | Response / event |
| --- | --- | --- |
| `newGame` | `lives` (positive integer) | `newGameId` |
| `getGames` | `{}` | `lobbyGames` (waiting games) |
| `joinGame` | `gameId` | `joinedGame`; host receives `playerJoined` |
| `ackPlayerJoin` | `gameId` | Guest receives `joinAckReceived` |
| `getGameDetails` | `gameId` | `gameDetails` |
| `towers` | `gameId`, `towers`, `extra` | Opponent receives `receivedTowers` |
| `ackReceivedTowers` | `gameId` | Opponent receives `ackReceivedTowers` |
| `readyForNextRound` | `gameId` | Opponent receives `playerReadyForNextRound` |
| `sendChat` | `gameId`, `msg` | Both players receive `chatMsg` |
| `joinChatLobby` | `{}` | `lobbyChatInfo` (users and last 10 messages) |
| `getLobbyUsers` | `{}` | `lobbyUsers` |
| `sendChatLobby` | `msg` | Lobby receives `lobbyChatMsg` |
| `leaveLobby` | `{}` | `leftLobby`; remaining users receive `lobbyUsers` |

Every connection receives `connected`. Errors return `toast` with `details.message`.
Disconnecting removes that connection's games and sends `playerDisconnect` to its opponents.
Spectators remain disabled. Ratings start at 1000 and do not change.
Gameplay relays require the sending connection to be a player in the game.
Pipes inside JSON strings work, and malformed messages do not end the connection.

## Test

```sh
python -m unittest discover -s . -p "test_*.py" -v
```

Tests use real local WebSocket connections and a temporary database.
