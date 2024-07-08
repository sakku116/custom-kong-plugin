-- local BasePlugin = require "kong.plugins.base_plugin"
local cjson = require "cjson"
local xml2lua = require "xml2lua"
local handler = require "xmlhandler.tree"

-- local JsonSoapTransformer = BasePlugin:extend()
local JsonSoapTransformer = {
  VERSION  = "1.0.0",
  PRIORITY = 1000,  -- set high priority to run early
}

function JsonSoapTransformer:new()
  JsonSoapTransformer.super.new(self, "soap-transform")
end

function JsonSoapTransformer:access(conf)
  JsonSoapTransformer.super.access(self)

  local body = ngx.req.get_body_data()
  if body then
    local content_type = ngx.req.get_headers()["Content-Type"]

    if content_type == "application/json" then
      -- Transform JSON to SOAP
      local json_body = cjson.decode(body)
      local soap_body = self.json_to_soap(json_body)
      ngx.req.set_body_data(soap_body)
      ngx.req.set_header("Content-Type", "application/xml")
    elseif content_type == "application/xml" then
      -- Transform SOAP to JSON
      local h = handler:new()
      local parser = xml2lua.parser(h)
      parser:parse(body)
      local json_body = h.root
      ngx.req.set_body_data(cjson.encode(json_body))
      ngx.req.set_header("Content-Type", "application/json")
    end
  end
end

function JsonSoapTransformer:header_filter(conf)
  JsonSoapTransformer.super.header_filter(self)
  local content_type = ngx.header["Content-Type"]

  if content_type == "application/json" then
    ngx.header["Content-Type"] = "application/xml"
  elseif content_type == "application/xml" then
    ngx.header["Content-Type"] = "application/json"
  end
end

function JsonSoapTransformer:body_filter(conf)
  JsonSoapTransformer.super.body_filter(self)

  local chunk, eof = ngx.arg[1], ngx.arg[2]
  if chunk then
    local content_type = ngx.header["Content-Type"]

    if content_type == "application/xml" then
      -- Transform JSON to SOAP
      local json_body = cjson.decode(chunk)
      local soap_body = self.json_to_soap(json_body)
      ngx.arg[1] = soap_body
    elseif content_type == "application/json" then
      -- Transform SOAP to JSON
      local h = handler:new()
      local parser = xml2lua.parser(h)
      parser:parse(chunk)
      local json_body = h.root
      ngx.arg[1] = cjson.encode(json_body)
    end
  end
end

function JsonSoapTransformer:json_to_soap(json_body)
  local soap_body = "<soapenv:Envelope xmlns:soapenv=\"http://schemas.xmlsoap.org/soap/envelope/\"><soapenv:Body>"
  for k, v in pairs(json_body) do
    soap_body = soap_body .. "<" .. k .. ">" .. tostring(v) .. "</" .. k .. ">"
  end
  soap_body = soap_body .. "</soapenv:Body></soapenv:Envelope>"
  return soap_body
end

JsonSoapTransformer.PRIORITY = 1000

return JsonSoapTransformer
