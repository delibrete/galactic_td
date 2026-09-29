# Galactic TD

This is the haxe source code for Galactic TD.

## Requirements

- Haxe and Haxelib
- OpenFL, with the `openfl` command available in your terminal
- The `seedyrng` Haxelib dependency

## Install Haxe and OpenFL

1. Download and install Haxe for your operating system from the [official Haxe download page](https://haxe.org/download/). On Windows, use the installer and include Neko when offered. OpenFL's Haxelib tools require Haxe and Neko.
2. Open a new terminal (PowerShell or Command Prompt on Windows) and check that the tools are available:

   ```sh
   haxe --version
   neko -version
   haxelib version
   ```

   If a command is not found, check that its installation directory is on your `PATH`, then reopen your terminal.

3. Install OpenFL and configure its command-line tools using the [official OpenFL setup steps](https://www.openfl.org/download/):

   ```sh
   haxelib install openfl
   haxelib run openfl setup
   ```

   Follow the setup prompts. If Haxelib asks you to configure its library directory first, run `haxelib setup` and choose a writable directory for installed libraries.

4. Install this project's additional dependency:

   ```sh
   haxelib install seedyrng
   ```

5. Verify that the OpenFL command is available:

   ```sh
   openfl help
   ```

   If `openfl` is not found, reopen your terminal after setup. You can also use `haxelib run openfl` in place of `openfl` in the commands below.

## Build and run

Run the following command from this folder:

```sh
openfl build html5 && openfl run html5
```

This builds the HTML5 version and then runs it. Build output is written to `Export/html5/`.

If your shell does not support `&&`, run `openfl build html5` first, then run `openfl run html5` after the build succeeds.

## Run the local server

The server in `Server/` requires Python 3.10 or newer. Check your installation with `python --version`.

From the repository root, create a virtual environment, install the dependencies, and start the server.

On Windows (PowerShell or Command Prompt):

```sh
python -m venv Server/.venv
Server\.venv\Scripts\python.exe -m pip install -r Server/requirements.txt
Server\.venv\Scripts\python.exe Server/server.py
```

On macOS or Linux:

```sh
python3 -m venv Server/.venv
Server/.venv/bin/python -m pip install -r Server/requirements.txt
Server/.venv/bin/python Server/server.py
```

These commands use the virtual environment directly, so activation is not required. On later runs, only the final command is needed.

Wait for `Server running at ws://127.0.0.1:1337`, then keep that terminal open while building and running the game in a second terminal. Stop the server with Ctrl+C. To use another port, append `--port 1338` to the server command and update the client's port to match.

The current `connect()` method in `Source/Network/Network.hx` specifies which host and port to connect to (by default it's set to `wss://127.0.0.1`); Sometimes changing this string to `ws://127.0.0.1` and rebuilding the HTML5 client might work if you're having trouble connecting.

The SQLite database is created automatically at `Server/local.db`; no separate database service is needed. Accounts, login tokens, and lobby chat history persist across restarts. Active games are kept in memory. For a two-player test, use two client connections with separate accounts.

See [the server README](Server/README.md) for message formats and server tests.

## Project layout

- `Source/` — Haxe source code, with `Main.hx` as the entry point.
- `Server/` — Python WebSocket server, dependencies, and tests.
- `Assets/` — Graphics, fonts, and sound effects.
- `project.xml` — OpenFL project settings, dependencies, and asset configuration.
- `Export/` — Generated build output.

## License

This project is licensed under the [MIT License](LICENSE).
