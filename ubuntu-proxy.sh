#! /bin/bash
HTTP_PROXY_HOST=www-proxy.statoil.no
HTTP_PROXY_PORT=80
HTTPS_PROXY_HOST=proxy.example.com
HTTPS_PROXY_PORT=3128


http_proxy="http://$HTTP_PROXY_HOST:$HTTP_PROXY_PORT/"
HTTP_PROXY="http://$HTTP_PROXY_HOST:$HTTP_PROXY_PORT/"
https_proxy="http://$HTTP_PROXY_HOST:$HTTP_PROXY_PORT/"
HTTPS_PROXY="http://$HTTP_PROXY_HOST:$HTTP_PROXY_PORT/"


gsettings set org.gnome.system.proxy mode manual
gsettings set org.gnome.system.proxy.http host "$HTTP_PROXY_HOST"
gsettings set org.gnome.system.proxy.http port "$HTTP_PROXY_PORT"
gsettings set org.gnome.system.proxy.https host "$HTTPS_PROXY_HOST"
gsettings set org.gnome.system.proxy.https port "$HTTPS_PROXY_PORT"

sudo sed -i.bak '/http[s]::proxy/Id' /etc/apt/apt.conf
sudo tee -a /etc/apt/apt.conf <<EOF
Acquire::http::proxy "http://$HTTP_PROXY_HOST:$HTTP_PROXY_PORT/";
Acquire::https::proxy "http://$HTTPS_PROXY_HOST:$HTTPS_PROXY_PORT/";
EOF

sudo sed -i.bak '/http[s]_proxy/Id' /etc/environment
sudo tee -a /etc/environment <<EOF
http_proxy="http://$HTTP_PROXY_HOST:$HTTP_PROXY_PORT/"
http_proxy="http://$HTTP_PROXY_HOST:$HTTP_PROXY_PORT/"
https_proxy="http://$HTTPS_PROXY_HOST:$HTTPS_PROXY_PORT/"
https_proxy="http://$HTTPS_PROXY_HOST:$HTTPS_PROXY_PORT/"
EOF
