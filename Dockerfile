FROM kong/kong-gateway:3.7.1.1

# Install system dependencies
USER root
RUN apt-get update && apt-get install -y git unzip luarocks zlib1g-dev
RUN luarocks install lua-cjson
RUN luarocks install xml2lua 1.4
RUN luarocks install lua-zlib

COPY . /usr/local/share/lua/5.1/kong/plugins/soap-transformer
WORKDIR /usr/local/share/lua/5.1/kong/plugins/soap-transformer
RUN luarocks make kong-plugin-soap-transformer-1.0-1.rockspec
ENV KONG_PLUGINS=bundled,soap-transformer
USER kong
