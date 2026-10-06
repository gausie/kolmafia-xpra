FROM debian:trixie AS gio-browse
RUN apt-get update \
 && apt-get install -y --no-install-recommends gcc libc6-dev libglib2.0-dev pkgconf
COPY gio-browse/browse.c /src/
RUN gcc -shared -fPIC -O2 -o /src/libgiobrowse.so /src/browse.c $(pkg-config --cflags --libs gio-2.0)

FROM debian:trixie

ARG XPRA_CHANNEL=stable

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update \
 && apt-get install -y --no-install-recommends ca-certificates curl \
 && curl -fsSL https://xpra.org/xpra.asc -o /usr/share/keyrings/xpra.asc \
 && if [ "$XPRA_CHANNEL" = beta ]; then repo=xpra-beta; else repo=xpra; fi \
 && curl -fsSL "https://raw.githubusercontent.com/Xpra-org/xpra/master/packaging/repos/trixie/$repo.sources" \
      -o "/etc/apt/sources.list.d/$repo.sources" \
 && apt-get update \
 && apt-get install -y --no-install-recommends \
      xpra xpra-x11 xpra-html5 xserver-xorg-core xserver-xorg-video-dummy xauth python3-xdg \
      openjdk-21-jre zenity jq caddy \
      libgtk-3-0t64 \
      fonts-inter fonts-dejavu fonts-liberation fontconfig \
 && rm -rf /var/lib/apt/lists/*

RUN useradd --create-home --uid 1000 kolmafia \
 && mkdir -p /home/kolmafia/.kolmafia /home/kolmafia/jars /run/user/1000/xpra \
 && mkdir -m 1777 -p /tmp/.X11-unix \
 && chown -R kolmafia:kolmafia /home/kolmafia /run/user/1000

COPY --chmod=755 entrypoint.sh kolmafia-version open-url /usr/local/bin/
COPY kolmafia-version.desktop open-url.desktop /usr/share/applications/
COPY applications.menu /etc/xdg/menus/
COPY mimeapps.list /etc/xdg/
COPY fonts.conf /etc/fonts/local.conf
COPY --from=gio-browse /src/libgiobrowse.so /usr/local/lib/gio/modules/
COPY Caddyfile /etc/caddy/Caddyfile
COPY html5/default-settings.txt /etc/xpra/html5-client/
COPY html5/kolmafia.js html5/kolmafia.css /usr/share/xpra/www/
RUN sed -i 's|</head>|<link rel="stylesheet" href="kolmafia.css" /><script src="kolmafia.js"></script></head>|' \
      /usr/share/xpra/www/index.html \
 && rm -f /usr/share/xpra/www/index.html.br /usr/share/xpra/www/index.html.gz

WORKDIR /home/kolmafia
ENV XDG_RUNTIME_DIR=/run/user/1000
ENV GIO_EXTRA_MODULES=/usr/local/lib/gio/modules

VOLUME /home/kolmafia/.kolmafia /home/kolmafia/jars

EXPOSE 8080 14500

ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]
