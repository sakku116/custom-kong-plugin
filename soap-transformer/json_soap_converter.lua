local cjson = require "cjson"
local xml2lua = require "xml2lua"
local handler = require "xmlhandler.tree"

-- Function to build XML element from JSON
local function build_xml_element(parent, key, value, namespace)
    if type(value) == "table" then
        for k, v in pairs(value) do
            local child = parent:createElement(namespace .. ":" .. k)
            build_xml_element(child, k, v, namespace)
            parent:appendChild(child)
        end
    else
        parent:setText(tostring(value))
    end
end

-- Function to convert JSON to SOAP XML
local function json_to_soap(json_data, root_element, namespace)
    -- Parse JSON data
    local data = cjson.decode(json_data)

    -- Create SOAP envelope
    local envelope = xml2lua.newElement("soapenv:Envelope")
    envelope:setAttribute("xmlns:soapenv", "http://schemas.xmlsoap.org/soap/envelope/")
    envelope:setAttribute("xmlns:web", namespace)

    local header = xml2lua.newElement("soapenv:Header")
    local body = xml2lua.newElement("soapenv:Body")
    local root = xml2lua.newElement(namespace .. ":" .. root_element)

    build_xml_element(root, root_element, data, namespace)

    body:appendChild(root)
    envelope:appendChild(header)
    envelope:appendChild(body)

    return xml2lua.toXml(envelope)
end

-- Function to convert SOAP XML to JSON
local function soap_to_json(soap_xml)
    local parser = xml2lua.parser(handler)
    parser:parse(soap_xml)

    -- Assuming the SOAP body contains a single root element
    local root = handler.root["soapenv:Envelope"]["soapenv:Body"]
    local json_data = cjson.encode(root)

    return json_data
end

-- Example usage
local json_data = '{"name": "John Doe", "age": 30, "city": "New York"}'
local namespace = "http://www.example.org/webservice"
local root_element = "Person"

local soap_xml = json_to_soap(json_data, root_element, namespace)
print(soap_xml)

local json_output = soap_to_json(soap_xml)
print(json_output)