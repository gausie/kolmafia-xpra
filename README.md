# kolmafia-xpra

KoLmafia running under [xpra](https://xpra.org), usable from a browser or the native Xpra client.

```sh
cp .env.example .env
docker compose up -d --build
```

Or skip the build and pull `ghcr.io/gausie/kolmafia-xpra:latest` (amd64 and arm64, rebuilt on every push to `main`). In Portainer, create a stack from `compose.yaml` with the `build:` block removed, and set the variables from `.env.example` in the stack's environment.

- `8080`: everything on one port. The KoLmafia relay is at `/` and the xpra HTML5 client at `/xpra/`.
- `14500`: xpra directly, for native clients on a trusted network (`xpra attach tcp://host:14500`).

Both bind to `BIND_ADDRESS` (default `127.0.0.1`). Put `8080` behind your reverse proxy and auth on a single hostname. Native clients can also go through it with `xpra attach wss://kol.example.com/xpra/`.

KoLmafia's data directory (settings, scripts, relay, images) is bind-mounted from `KOLMAFIA_DIR`, so an existing one can be used as-is. Downloaded KoLmafia jars go in the separate `jars` volume. Set `PUID`/`PGID` to the owner of the data directory.

## Versions

The KoLmafia version is chosen from inside the session: the "KoLmafia version" button in the browser, Start → KoLmafia → KoLmafia Version in Linux/Windows Xpra clients, or Server → Run Command → `kolmafia-version` on macOS. It defaults to tracking the latest release, and offers to update when a new one comes out.

## Options

- `XPRA_CHANNEL=beta` uses the xpra beta repo, both when building and for the published image tag (amd64 only)
- `KOLMAFIA_UI_SCALE=2` renders KoLmafia and its dialogs at 2x for sharp text on HiDPI screens. The HTML5 client scales it back down by itself; native clients need `--desktop-scaling=0.5`
- `KOLMAFIA_PUBLIC_URL=https://kolmafia.example.com` is where the relay browser opens when KoLmafia asks for it. Without it the HTML5 client opens it on whatever address you reached xpra on, but the native client can't

## Native client behind Authelia

The native client can't follow Authelia's login redirect. `contrib/xpra-attach-authelia` logs in via Authelia's API and passes the session cookie to `xpra attach`:

```sh
contrib/xpra-attach-authelia wss://kol.example.com/xpra/
```

It finds the Authelia portal from the redirect it gets for that URL (set `AUTHELIA_URL` to override), asks for your login in a dialog, and with "Remember me" keeps it in the macOS keychain or Secret Service. Saved logins that stop working are forgotten and you're asked again. On macOS it uses `/Applications/Xpra.app` when `xpra` isn't on your `PATH`. Needs `curl` and `jq`.

`contrib/make-macos-app wss://kol.example.com/xpra/` builds `~/Applications/KoLmafia.app`, a renamed copy of Xpra.app that runs the above, so it shows up as KoLmafia in Spotlight, the dock and the app switcher.
