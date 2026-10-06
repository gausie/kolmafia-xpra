# kolmafia-xpra

KoLmafia running under [xpra](https://xpra.org), usable from a browser or the native Xpra client.

```sh
cp .env.example .env
docker compose up -d --build
```

Or skip the build and pull `ghcr.io/gausie/kolmafia-xpra:latest` (amd64 and arm64, rebuilt on every push to `main`). In Portainer, create a stack from `compose.yaml` with the `build:` block removed, and set the variables from `.env.example` in the stack's environment.

- `14500`: xpra (HTML5 client at `/`, native clients via `xpra attach tcp://host:14500` or `wss://`)
- `60080`: KoLmafia relay browser, once you're logged in

Both bind to `BIND_ADDRESS` (default `127.0.0.1`). Put them behind your reverse proxy and auth; the relay needs its own hostname because it serves from `/`.

The settings directory is bind-mounted from `KOLMAFIA_SETTINGS_DIR`. Everything else (jars, scripts, relay, images) lives in the `kolmafia` volume. Set `PUID`/`PGID` to the owner of the settings directory.

## Versions

The KoLmafia version is chosen from inside the session: the "KoLmafia version" button in the browser, Start → KoLmafia → KoLmafia Version in Linux/Windows Xpra clients, or Server → Run Command → `kolmafia-version` on macOS. It defaults to tracking the latest release, and offers to update when a new one comes out.

## Options

- `XPRA_CHANNEL=beta` builds against the xpra beta repo (amd64 only)
- `KOLMAFIA_UI_SCALE=2` renders KoLmafia at 2x; pair with `--desktop-scaling=0.5` on a HiDPI native client
