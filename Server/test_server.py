import asyncio
import json
from pathlib import Path
import tempfile
import unittest

from websockets.asyncio.client import connect
from websockets.asyncio.server import serve

from server import GameServer


class ServerTests(unittest.IsolatedAsyncioTestCase):
    async def asyncSetUp(self):
        self.temp = tempfile.TemporaryDirectory()
        self.path = Path(self.temp.name) / "test.db"
        self.app = GameServer(self.path)
        self.server = await serve(self.app.connection, "127.0.0.1", 0)
        self.url = f"ws://127.0.0.1:{self.server.sockets[0].getsockname()[1]}"
        self.clients = []

    async def asyncTearDown(self):
        for ws in self.clients:
            await ws.close()
        self.server.close()
        await self.server.wait_closed()
        self.app.db.close()
        self.temp.cleanup()

    async def receive(self, ws, kind):
        message = json.loads(await asyncio.wait_for(ws.recv(), 2))
        self.assertEqual(message["type"], kind, message)
        return message["details"]

    async def request(self, ws, kind, details=None, token=""):
        await ws.send(json.dumps({"type": kind, "details": details or {}}) + "|" + token)

    async def client(self, name):
        ws = await connect(self.url, proxy=None)
        self.clients.append(ws)
        await self.receive(ws, "connected")
        await self.request(ws, "newAccount", {"username": name, "password": "test|password"})
        token = (await self.receive(ws, "playerLogin"))["token"]
        return ws, token

    async def new_game(self, ws, token):
        await self.request(ws, "newGame", {"lives": 3}, token)
        return (await self.receive(ws, "newGameId"))["gameId"]

    async def test_game_flow_and_disconnect_isolation(self):
        a, ta = await self.client("Alice")
        b, tb = await self.client("Bob")
        c, tc = await self.client("Carol")
        game = await self.new_game(a, ta)
        unrelated = await self.new_game(c, tc)
        await self.request(b, "getGames", token=tb)
        self.assertEqual(len(await self.receive(b, "lobbyGames")), 2)
        await self.request(b, "joinGame", {"gameId": game}, tb)
        joined = await self.receive(b, "joinedGame")
        self.assertEqual((joined["otherPlayer"], joined["lives"], joined["spectator"]), ("Alice", 3, False))
        await self.receive(a, "playerJoined")
        await self.request(a, "ackPlayerJoin", {"gameId": game}, ta)
        self.assertEqual(await self.receive(b, "joinAckReceived"), {"gameId": game})
        await self.request(b, "getGameDetails", {"gameId": game}, tb)
        info = await self.receive(b, "gameDetails")
        self.assertEqual(info["player2"], {"username": "Bob", "rating": 1000})
        await self.request(a, "towers", {"gameId": game, "towers": [{"x": 1}], "extra": 7}, ta)
        self.assertEqual((await self.receive(b, "receivedTowers"))["extra"], 7)
        for request, event in (("ackReceivedTowers", "ackReceivedTowers"),
                               ("readyForNextRound", "playerReadyForNextRound")):
            await self.request(b, request, {"gameId": game}, tb)
            self.assertEqual(await self.receive(a, event), {})
        await self.request(a, "sendChat", {"gameId": game, "msg": "hello|world"}, ta)
        for ws in (a, b):
            self.assertEqual((await self.receive(ws, "chatMsg"))["message"], "hello|world")
        await self.request(c, "towers", {"gameId": game, "towers": [], "extra": 0}, tc)
        await self.receive(c, "toast")
        await a.close()
        self.assertEqual(await self.receive(b, "playerDisconnect"), {"gameId": game})
        await self.request(c, "getGames", token=tc)
        self.assertEqual([g["gameId"] for g in await self.receive(c, "lobbyGames")], [unrelated])

    async def test_lobby_history_leave_and_restart(self):
        a, ta = await self.client("Alice")
        b, tb = await self.client("Bob")
        await self.request(a, "joinChatLobby", token=ta)
        self.assertEqual((await self.receive(a, "lobbyChatInfo"))["messages"], [])
        for i in range(12):
            await self.request(a, "sendChatLobby", {"msg": f"hello|{i}"}, ta)
            await self.receive(a, "lobbyChatMsg")
        await self.request(b, "joinChatLobby", token=tb)
        history = await self.receive(b, "lobbyChatInfo")
        self.assertEqual(history["messages"], [f"<Alice> hello|{i}" for i in range(2, 12)])
        await self.receive(a, "lobbyUsers")
        await self.request(a, "leaveLobby")
        await self.receive(a, "leftLobby")
        self.assertEqual(await self.receive(b, "lobbyUsers"), {"users": ["Bob"]})
        await self.request(b, "getLobbyUsers", token=tb)
        self.assertEqual(await self.receive(b, "lobbyUsers"), {"users": ["Bob"]})
        await a.close()
        await b.close()
        self.server.close()
        await self.server.wait_closed()
        self.app.db.close()
        self.app = GameServer(self.path)
        self.server = await serve(self.app.connection, "127.0.0.1", 0)
        self.url = f"ws://127.0.0.1:{self.server.sockets[0].getsockname()[1]}"
        ws = await connect(self.url, proxy=None)
        self.clients.append(ws)
        await self.receive(ws, "connected")
        await self.request(ws, "joinChatLobby", token=ta)
        self.assertEqual((await self.receive(ws, "lobbyChatInfo"))["messages"], history["messages"])
        await self.request(ws, "login", {"username": "Alice", "password": "test|password"})
        new_token = (await self.receive(ws, "playerLogin"))["token"]
        self.assertNotEqual(ta, new_token)
        await self.request(ws, "getGames", token=ta)
        await self.receive(ws, "toast")
        await self.request(ws, "getGames", token=new_token)
        self.assertEqual(await self.receive(ws, "lobbyGames"), [])

    async def test_errors_and_reconnect_token(self):
        a, ta = await self.client("Alice")
        for raw in ("bad json", "[]", '{"type":"getGames","details":null}',
                    '{"type":"getGames"}|invalid'):
            await a.send(raw)
            await self.receive(a, "toast")
        for kind, details in (
            ("newAccount", {"username": "Alice", "password": "x"}),
            ("newAccount", {"username": "Bad Name", "password": "x"}),
            ("login", {"username": "Alice", "password": "wrong"}),
            ("newGame", {"lives": -1}),
            ("joinGame", {"gameId": "missing"}),
        ):
            await self.request(a, kind, details, ta)
            await self.receive(a, "toast")
        ws = await connect(self.url, proxy=None)
        self.clients.append(ws)
        await self.receive(ws, "connected")
        game = await self.new_game(ws, ta)
        await self.request(ws, "joinGame", {"gameId": game}, ta)
        await self.receive(ws, "toast")
        await ws.close()
        # Wait for server-side close cleanup before querying the lobby.
        for _ in range(100):
            if game not in self.app.games:
                break
            await asyncio.sleep(0.01)
        await self.request(a, "getGames", token=ta)
        self.assertEqual(await self.receive(a, "lobbyGames"), [])


if __name__ == "__main__":
    unittest.main()
