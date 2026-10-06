#!/bin/sh
set -e

if [ "$(id -u)" = 0 ]; then
  groupmod -o -g "${PGID:-1000}" kolmafia
  usermod -o -u "${PUID:-1000}" kolmafia
  mkdir -p /home/kolmafia/.kolmafia/settings
  chown kolmafia:kolmafia /home/kolmafia /home/kolmafia/.kolmafia /home/kolmafia/.kolmafia/settings /home/kolmafia/jars
  chown -R kolmafia:kolmafia /run/user/1000
  case ${KOLMAFIA_UI_SCALE:-1} in
    *[!0-9.]* | .* | *.*.*) echo "KOLMAFIA_UI_SCALE must be a number" >&2; exit 1 ;;
  esac
  sed -i "s/^const KOLMAFIA_UI_SCALE = .*/const KOLMAFIA_UI_SCALE = ${KOLMAFIA_UI_SCALE:-1};/" /usr/share/xpra/www/kolmafia.js
  exec setpriv --reuid=kolmafia --regid=kolmafia --init-groups "$0" "$@"
fi

export HOME=/home/kolmafia

prefs="$HOME/.kolmafia/settings/GLOBAL_prefs.txt"
touch "$prefs"
if grep -q '^relayAllowRemoteAccess=' "$prefs"; then
  sed -i 's/^relayAllowRemoteAccess=.*/relayAllowRemoteAccess=true/' "$prefs"
else
  echo 'relayAllowRemoteAccess=true' >> "$prefs"
fi

caddy run --config /etc/caddy/Caddyfile --adapter caddyfile &

exec xpra start :100 \
  --daemon=no \
  --xvfb=Xorg \
  --resize-display=1280x800 \
  --bind-tcp=0.0.0.0:14500 \
  --html=on \
  --session-name=KoLmafia \
  --start-child="/usr/local/bin/kolmafia-version launch" \
  --exit-with-children=yes \
  --mdns=no \
  --pulseaudio=no \
  --speaker=off \
  --microphone=off \
  --webcam=no \
  --printing=no \
  --notifications=no \
  --systemd-run=no \
  "$@"
