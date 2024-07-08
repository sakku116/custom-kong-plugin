local BasePlugin = require "kong.plugins.base_plugin"
local cjson = require "cjson"
local xml2lua = require "xml2lua"
local handler = require "xmlhandler.tree"

local JsonSoapTransformer = BasePlugin:extend()

function JsonSoapTransformer:new()
  JsonSoapTransformer.super.new(self, "soap-transform")
end

function JsonSoapTransformer:access(conf)
  JsonSoapTransformer.super.access(self)

  local body = ngx.req.get_body_data()
  if body then
    if conf.request_format == "json" then
      -- Transform JSON to SOAP
      local json_body = cjson.decode(body)
      local soap_body = conf.soap_request_template
      for k, v in pairs(json_body) do
        soap_body = soap_body:gsub("{{" .. k .. "}}", v)
      end
      ngx.req.set_body_data(soap_body)
      ngx.req.set_header("Content-Type", "text/xml")
    elseif conf.request_format == "soap" then
      -- Transform SOAP to JSON
      local h = handler:new()
      local parser = xml2lua.parser(h)
      parser:parse(body)
      local json_body = {}
      for k, v in pairs(conf.json_request_mapping) do
        json_body[v] = h.root[k]
      end
      ngx.req.set_body_data(cjson.encode(json_body))
      ngx.req.set_header("Content-Type", "application/json")
    end
  end
end

function JsonSoapTransformer:header_filter(conf)
  JsonSoapTransformer.super.header_filter(self)
  ngx.header["Content-Type"] = conf.response_format == "json" and "application/json" or "text/xml"
end

function JsonSoapTransformer:body_filter(conf)
  JsonSoapTransformer.super.body_filter(self)

  local chunk, eof = ngx.arg[1], ngx.arg[2]
  if chunk then
    if conf.response_format == "json" and conf.request_format == "soap" then
      -- Transform SOAP to JSON
      local h = handler:new()
      local parser = xml2lua.parser(h)
      parser:parse(chunk)
      local json_body = {}
      for k, v in pairs(conf.json_response_mapping) do
        json_body[v] = h.root[k]
      end
      ngx.arg[1] = cjson.encode(json_body)
    elseif conf.response_format == "soap" and conf.request_format == "json" then
      -- Transform JSON to SOAP
      local json_body = cjson.decode(chunk)
      local soap_body = conf.soap_response_template
      for k, v in pairs(json_body) do
        soap_body = soap_body:gsub("{{" .. k .. "}}", v)
      end
      ngx.arg[1] = soap_body
    end
  end
end

JsonSoapTransformer.PRIORITY = 1000

return JsonSoapTransformer
