package = "kong-plugin-soap-transformer"
version = "1.0-1"
source = {
  url = "git://github.com/yourusername/kong-plugin-soap-transformer",
  tag = "v1.0"
}
description = {
  summary = "Transform SOAP requests and responses",
  detailed = [[
    This plugin transforms SOAP requests into JSON and vice versa.
  ]],
  homepage = "http://github.com/yourusername/kong-plugin-soap-transformer",
  license = "Apache 2.0"
}
dependencies = {
  "lua >= 5.1",
  "xml2lua",
  "kong"
}
build = {
  type = "builtin",
  modules = {
    ["kong.plugins.soap-transformer.handler"] = "./soap-transformer/handler.lua",
    ["kong.plugins.soap-transformer.schema"] = "./soap-transformer/schema.lua"
  }
}
