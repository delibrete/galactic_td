"""Local WebSocket server. Run with: python server.py"""

import argparse
import asyncio
import hashlib
import hmac
import json
import logging
from pathlib import Path
import secrets
import sqlite3
import string

from websockets.asyncio.server import serve
from websockets.exceptions import ConnectionClosed


def make_id(length):
    return "".join(secrets.choice(string.ascii_letters + string.digits) for _ in range(length))


def password_hash(password, salt):
    return hashlib.scrypt(password.encode(), salt=bytes.fromhex(salt), n=16384, r=8, p=1).hex()


def parse_message(raw):
    # Decode JSON first so a pipe inside a password or chat message stays intact.
    if isinstance(raw, bytes):
        raw = raw.decode("utf-8")
    message, end = json.JSONDecoder().raw_decode(raw.lstrip())
    suffix = raw.lstrip()[end:].strip()
    if suffix and not suffix.startswith("|"):
        raise ValueError("Expected JSON followed by |token.")
    if not isinstance(message, dict) or not isinstance(message.get("type"), str):
        raise ValueError("Message must contain a type.")
    details = message.get("details", {})
    if not isinstance(details, dict):
        raise ValueError("Message details must be an object.")
    return message["type"], details, suffix[1:] if suffix else ""


async def send(ws, kind, details):
    try:
        await ws.send(json.dumps({"type": kind, "details": details}))
    except ConnectionClosed:
        pass  # Disconnect cleanup runs in the connection handler.


class GameServer:
    def __init__(self, database):
        self.db = sqlite3.connect(database)
        self.db.row_factory = sqlite3.Row
        self.db.executescript("""
            CREATE TABLE IF NOT EXISTS users (
                username TEXT PRIMARY KEY,
                password TEXT NOT NULL,
                salt TEXT NOT NULL,
                rating INTEGER NOT NULL DEFAULT 1000,
                token TEXT UNIQUE
            );
            CREATE TABLE IF NOT EXISTS lobby_chat (
                id INTEGER PRIMARY KEY,
                username TEXT NOT NULL,
                chatmsg TEXT NOT NULL
            );
        """)
        self.games = {}
        self.lobby = {}

    async def account(self, ws, kind, details):
        username, password = details.get("username"), details.get("password")
        if not isinstance(username, str) or not isinstance(password, str):
            raise ValueError("Username and password must be strings.")
        user = self.db.execute("SELECT * FROM users WHERE username = ?", (username,)).fetchone()
        if kind == "newAccount":
            if not username or len(username) > 256:
                raise ValueError("Username must contain 1 to 256 characters.")
            if not username.isalnum():
                raise ValueError("Username can't have special characters.")
            if username == "Username":
                raise ValueError("Username can't be 'Username'.")
            if user:
                raise ValueError("Username already exists.")
            if not password or len(password) > 256:
                raise ValueError("Password must contain 1 to 256 characters.")
            salt = secrets.token_hex(16)
            # Synchronous hashing keeps this small local server straightforward.
            with self.db:
                self.db.execute(
                    "INSERT INTO users (username, password, salt) VALUES (?, ?, ?)",
                    (username, password_hash(password, salt), salt),
                )
        elif not user or not hmac.compare_digest(password_hash(password, user["salt"]), user["password"]):
            raise ValueError("Username or Password incorrect")
        token = make_id(32)
        with self.db:
            self.db.execute("UPDATE users SET token = ? WHERE username = ?", (token, username))
        await send(ws, "playerLogin", {"token": token})

    def lobby_users(self):
        return {"users": list(self.lobby.values())}

    async def broadcast_lobby(self, kind, details, exclude=None):
        for ws in list(self.lobby):
            if ws is not exclude:
                await send(ws, kind, details)

    def player_details(self, player):
        if player is None:
            return None
        user = self.db.execute(
            "SELECT username, rating FROM users WHERE username = ?", (player["name"],)
        ).fetchone()
        return dict(user)

    async def handle_message(self, ws, raw):
        kind, details, token = parse_message(raw)
        if kind in ("newAccount", "login"):
            await self.account(ws, kind, details)
            return
        if kind == "leaveLobby":
            self.lobby.pop(ws, None)
            await send(ws, "leftLobby", {})
            await self.broadcast_lobby("lobbyUsers", self.lobby_users())
            return

        user = self.db.execute("SELECT * FROM users WHERE token = ?", (token,)).fetchone()
        if not user:
            raise ValueError("Please log in first.")
        username = user["username"]

        if kind == "newGame":
            lives = details.get("lives")
            if type(lives) is not int or lives <= 0:
                raise ValueError("Lives must be a positive integer.")
            game_id = make_id(8)
            while game_id in self.games:
                game_id = make_id(8)
            self.games[game_id] = {
                "player1": {"ws": ws, "name": username}, "player2": None, "lives": lives,
            }
            await send(ws, "newGameId", {"gameId": game_id, "lives": lives})
        elif kind == "getGames":
            await send(ws, "lobbyGames", [
                {"gameId": game_id, "title": "Game", "lives": game["lives"],
                 **self.player_details(game["player1"])}
                for game_id, game in self.games.items() if game["player2"] is None
            ])
        elif kind == "joinChatLobby":
            self.lobby[ws] = username
            messages = self.db.execute(
                "SELECT username, chatmsg FROM lobby_chat ORDER BY id DESC LIMIT 10"
            ).fetchall()
            await send(ws, "lobbyChatInfo", {
                **self.lobby_users(),
                "messages": [f"<{m['username']}> {m['chatmsg']}" for m in reversed(messages)],
            })
            await self.broadcast_lobby("lobbyUsers", self.lobby_users(), exclude=ws)
        elif kind == "getLobbyUsers":
            await send(ws, "lobbyUsers", self.lobby_users())
        elif kind == "sendChatLobby":
            msg = details.get("msg")
            if not isinstance(msg, str):
                raise ValueError("Chat message must be a string.")
            with self.db:
                self.db.execute("INSERT INTO lobby_chat (username, chatmsg) VALUES (?, ?)", (username, msg))
            await self.broadcast_lobby("lobbyChatMsg", {"username": username, "message": msg})
        elif kind in ("joinGame", "getGameDetails", "ackPlayerJoin", "towers",
                      "ackReceivedTowers", "readyForNextRound", "sendChat"):
            await self.handle_game(ws, username, kind, details)
        else:
            raise ValueError(f"Unknown message type: {kind}")

    async def handle_game(self, ws, username, kind, details):
        game_id = details.get("gameId")
        if not isinstance(game_id, str) or game_id not in self.games:
            raise ValueError("Game not found.")
        game = self.games[game_id]
        player1, player2 = game["player1"], game["player2"]
        if kind == "joinGame":
            if player2:
                raise ValueError("Game already in progress.")
            if player1["name"] == username or player1["ws"] is ws:
                raise ValueError("You cannot join your own game.")
            game["player2"] = {"ws": ws, "name": username}
            await send(ws, "joinedGame", {
                "gameId": game_id, "message": f"Joined Game {game_id}",
                "otherPlayer": player1["name"], "spectator": False, "lives": game["lives"],
            })
            await send(player1["ws"], "playerJoined", {"message": "Someone joined", "otherPlayer": username})
            return
        if kind == "getGameDetails":
            await send(ws, "gameDetails", {
                "gameId": game_id, "player1": self.player_details(player1),
                "player2": self.player_details(player2), "spectators": [],
            })
            return
        player = next((p for p in (player1, player2)
                       if p and p["ws"] is ws and p["name"] == username), None)
        if player is None:
            raise ValueError("You are not a player in this game.")
        if player2 is None:
            raise ValueError("Waiting for another player.")
        other = player2 if player is player1 else player1
        if kind == "ackPlayerJoin":
            if player is not player1:
                raise ValueError("Only the host can acknowledge a join.")
            await send(player2["ws"], "joinAckReceived", {"gameId": game_id})
        elif kind == "towers":
            if "towers" not in details or "extra" not in details:
                raise ValueError("Towers and extra are required.")
            await send(other["ws"], "receivedTowers", {
                "message": "Received Towers", "towers": details["towers"], "extra": details["extra"],
            })
        elif kind == "ackReceivedTowers":
            await send(other["ws"], "ackReceivedTowers", {})
        elif kind == "readyForNextRound":
            await send(other["ws"], "playerReadyForNextRound", {})
        elif kind == "sendChat":
            if not isinstance(details.get("msg"), str):
                raise ValueError("Chat message must be a string.")
            for recipient in (player1, player2):
                await send(recipient["ws"], "chatMsg", {"username": username, "message": details["msg"]})

    async def disconnect(self, ws):
        self.lobby.pop(ws, None)
        # Remove games before awaiting sends so another connection cannot join them.
        notifications = []
        for game_id, game in list(self.games.items()):
            players = [p for p in (game["player1"], game["player2"]) if p]
            if any(p["ws"] is ws for p in players):
                del self.games[game_id]
                notifications.extend((p["ws"], game_id) for p in players if p["ws"] is not ws)
        for other, game_id in notifications:
            await send(other, "playerDisconnect", {"gameId": game_id})
        await self.broadcast_lobby("lobbyUsers", self.lobby_users())

    async def connection(self, ws):
        try:
            await send(ws, "connected", {})
            async for raw in ws:
                try:
                    await self.handle_message(ws, raw)
                except ValueError as error:
                    await send(ws, "toast", {"message": str(error)})
                except Exception:
                    logging.exception("Could not handle message")
                    await send(ws, "toast", {"message": "Something went wrong."})
        except ConnectionClosed:
            pass
        finally:
            await self.disconnect(ws)


async def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--port", type=int, default=1337)
    args = parser.parse_args()
    database = Path(__file__).with_name("local.db")
    app = GameServer(database)
    try:
        async with serve(app.connection, "127.0.0.1", args.port):
            print(f"Server running at ws://127.0.0.1:{args.port}", flush=True)
            print(f"Database: {database}\nPress Ctrl+C to stop.", flush=True)
            await asyncio.Future()
    finally:
        app.db.close()


if __name__ == "__main__":
    try:
        asyncio.run(main())
    except KeyboardInterrupt:
        pass
