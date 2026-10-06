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
      fonts-dejavu fonts-liberation fontconfig \
 && rm -rf /var/lib/apt/lists/*

RUN useradd --create-home --uid 1000 kolmafia \
 && mkdir -p /home/kolmafia/.kolmafia /home/kolmafia/jars /run/user/1000/xpra \
 && mkdir -m 1777 -p /tmp/.X11-unix \
 && chown -R kolmafia:kolmafia /home/kolmafia /run/user/1000

COPY --chmod=755 entrypoint.sh kolmafia-version /usr/local/bin/
COPY kolmafia-version.desktop /usr/share/applications/
COPY applications.menu /etc/xdg/menus/
COPY Caddyfile /etc/caddy/Caddyfile
COPY html5/default-settings.txt /etc/xpra/html5-client/
COPY html5/kolmafia.js html5/kolmafia.css /usr/share/xpra/www/
RUN sed -i 's|</head>|<link rel="stylesheet" href="kolmafia.css" /><script src="kolmafia.js"></script></head>|' \
      /usr/share/xpra/www/index.html \
 && rm -f /usr/share/xpra/www/index.html.br /usr/share/xpra/www/index.html.gz

WORKDIR /home/kolmafia
ENV XDG_RUNTIME_DIR=/run/user/1000

VOLUME /home/kolmafia/.kolmafia /home/kolmafia/jars

EXPOSE 8080 14500

ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]
