local cjson = require "cjson"
local xml2lua = require("xml2lua")
local handler = require("xmlhandler.tree")

local JsonSoapTransformer = {
  VERSION  = "1.0.0",
  PRIORITY = 1000,  -- set high priority to run early
}

function JsonSoapTransformer:access(config)
  if config.transform_on == "request" then
    local json_data = kong.request.get_body()
    local soap_xml = json_to_soap(json_data)  -- Assume this function converts JSON to SOAP
    kong.service.request.set_raw_body(soap_xml)
  end
end

function JsonSoapTransformer:header_filter(config)
  if config.transform_on == "response" then
    kong.response.clear_header("Content-Length")
    kong.response.set_header("Content-Type", "application/json")
  end
end

function JsonSoapTransformer:body_filter(config)
  if config.transform_on == "response" then
    local soap_body = kong.response.get_raw_body()
    local json_body = soap_to_json(soap_body)  -- Assume this function converts SOAP to JSON
    kong.response.set_raw_body(json_body)
  end
end

function soap_to_json(soap)
  local parser = xml2lua.parser(handler)
  parser:parse(soap)
  return cjson.encode(handler.root)
end

function json_to_soap(json)
  -- Convert JSON object to SOAP XML string
  -- This will require a proper mapping depending on the expected SOAP schema
  return "<SOAP-ENV:Envelope>...</SOAP-ENV:Envelope>"
end

return JsonSoapTransformer
