
FROM kong/kong-gateway:3.7.1.1

# Install system dependencies
USER root
RUN apt-get update && apt-get install -y unzip curl

# Install Python + dependencies

# RUN apt-get install -y \
#     python3 \
#     python3-pip \
#     python3-dev \
#     libc6-dev \
#     libffi-dev \
#     gcc \
#     g++ \
#     file \
#     make \
#     && rm -rf /var/lib/apt/lists/*
# #Install Python Plugin dependency
# RUN PYTHONWARNINGS=ignore pip3 install kong-pdk

# # Copy in Plugin Server Exec
# COPY --chown=kong --chmod=555 ./pluginserver.py /usr/local/bin/kong-python-pluginserver

# # 💥 Copy in Python Plugins
# COPY --chown=kong --chmod=555 ./soap-transformer-py /usr/local/kong/python-plugins

# Install xml2lua globally using LuaRocks
RUN luarocks install xml2lua
RUN luarocks install kong
# Make sure all LuaRocks commands are run as root to avoid permissions issues
COPY soap-transformer /usr/local/share/lua/5.1/kong/plugins/soap-transformer
ENV KONG_PLUGINS=bundled,soap-transformer

# Optionally, set LuaRocks to install packages locally by default for the kong user
# And ensure kong user has proper access to the LuaRocks installation directory
# RUN luarocks config --local-tree --local-by-default true
# RUN mkdir -p /home/kong/.luarocks && chown -R kong:kong /home/kong/.luarocks

# Copy the custom plugin into the Docker image
# COPY soap-transform /usr/local/share/lua/5.1/kong/plugins/soap-transform

# Configure Lua paths to include local LuaRocks tree
ENV LUA_PATH="/home/kong/.luarocks/share/lua/5.1/?.lua;/home/kong/.luarocks/share/lua/5.1/?/init.lua;/usr/local/share/lua/5.1/?.lua;/usr/local/share/lua/5.1/?/init.lua;;"
# ENV LUA_CPATH="/home/kong/.luarocks/lib/lua/5.1/?.so;/usr/local/lib/lua/5.1/?.so;;"
# ENV KONG_LUA_PACKAGE_PATH="./?.lua;./?/init.lua;"

# Switch back to kong user
USER kong

# RUN ["kong", "migrations", "up"]