#! /bin/bash
HTTP_PROXY_HOST=www-proxy.statoil.no
HTTP_PROXY_PORT=80
HTTPS_PROXY_HOST=www-proxy.statoil.no
HTTPS_PROXY_PORT=80

http_proxy="http://$HTTP_PROXY_HOST:$HTTP_PROXY_PORT/"
HTTP_PROXY=$http_proxy
https_proxy="http://$HTTPS_PROXY_HOST:$HTTPS_PROXY_PORT/"
HTTPS_PROXY=$https_proxy

if $1 = 'set'; then
    gsettings set org.gnome.system.proxy mode manual
    gsettings set org.gnome.system.proxy.http host "$HTTP_PROXY_HOST"
    gsettings set org.gnome.system.proxy.http port "$HTTP_PROXY_PORT"
    gsettings set org.gnome.system.proxy.https host "$HTTPS_PROXY_HOST"
    gsettings set org.gnome.system.proxy.https port "$HTTPS_PROXY_PORT"

    tee /etc/apt/apt.conf <<EOF
Acquire::http::proxy "${http_proxy}";
Acquire::https::proxy "${https_proxy}";

EOF

grep -qF -- "http_proxy="${http_proxy}
HTTP_PROXY="${http_proxy}"
https_proxy="${https_proxy}"
HTTPS_PROXY="${https_proxy}"

elif $1 = 'unset'; then
    echo 'UNseting'
fi
